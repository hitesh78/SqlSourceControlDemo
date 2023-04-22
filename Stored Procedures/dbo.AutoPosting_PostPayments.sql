SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 1/20/2023
-- Description:	Provides data for the Autoposting Main Posting Grid
-- =============================================
CREATE     PROCEDURE [dbo].[AutoPosting_PostPayments]
@PostGrid varchar(20),
@PaymentsStartDate varchar(50),
@PaymentsEndDate varchar(50),
@PayerNameFilter nvarchar(100),
@AmountFilter nvarchar(50),
@DescriptionFilter nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

--Declare
--@ClassID varchar(100) = '13308',
--@EK varchar(100) = '0.466264767708138',
--@PaymentsStartDate varchar(100) = '',
--@PaymentsEndDate varchar(100) = '',
--@PayerNameFilter varchar(100) = '',
--@AmountFilter varchar(100) = '',
--@DescriptionFilter varchar(100) = ''

Declare 
@StartDate date = dbo.toDBDate(@PaymentsStartDate),
@EndDate date = dbo.toDBDate(@PaymentsEndDate),
@LatestSessionID int = (Select top 1 SessionID From Session Where status = 'Open' Order By FromDate desc);


Declare 
@APTL_BCForOverPayment int,
@APTL_BCForNonPaymentCategory int,
@APTL_AutoPostingMethod nvarchar(20),
@APTL_ProcessRegistrationFeesPaymentsSeparately bit;

Select
@APTL_BCForOverPayment = APTL_BCForOverPayment,
@APTL_BCForNonPaymentCategory = APTL_BCForNonPaymentCategory,
@APTL_AutoPostingMethod = APTL_AutoPostingMethod,
@APTL_ProcessRegistrationFeesPaymentsSeparately = APTL_ProcessRegistrationFeesPaymentsSeparately
From Settings
Where SettingID = 1;


Declare @BillingCategoryPaymentPriority table (Title nvarchar(50) Primary Key, SelectOptionID int, PaymentPriority int);
Insert into @BillingCategoryPaymentPriority
Select 
Title,
SelectOptionID,
PaymentPriority
From SelectOptions 
Where 
SelectListID = 21 
Order By PaymentPriority;

	
Declare @TTPaymentPriority table (TransactionTypeID int Primary Key, TTName nvarchar(50), SessionID int, BillingCategoryID int, BillingCategoryTitle nvarchar(50), PaymentPriority int)
Insert into @TTPaymentPriority
Select
TT.TransactionTypeID,
TT.Title + ' (' + S.Title + ')' as TTName,
TT.SessionID as SessionID,
BC.SelectOptionID,
BC.Title,
BC.PaymentPriority
From
TransactionTypes TT
	inner join
@BillingCategoryPaymentPriority BC
	on TT.ReceivableCategory = BC.Title
	inner join
Session S
	on TT.SessionID = S.SessionID
Where
S.Status = 'Open'
and
TT.DB_CR_Code = 'Payment';



Declare
@DefaultPaymentTransactionTypeID int = (Select top 1 TransactionTypeID From @TTPaymentPriority Where BillingCategoryID = @APTL_BCForNonPaymentCategory and SessionID = @LatestSessionID),
@OverPaymentTransactionTypeID int = (Select top 1 TransactionTypeID From @TTPaymentPriority Where BillingCategoryID = @APTL_BCForOverPayment and SessionID = @LatestSessionID)


Declare @PaymentsByFSID table 
(
FSID int Primary Key, 
MaxStudentID int, 
MinPSPaymentID int, 
PSPaymentDate date, 
NumberOfPayments int, 
TotalAmount money, 
PaymentIDs varchar(500), 
PaymentsInfo nvarchar(max)
);

Declare @APTL_AutoPostingStartDate date = (Select APTL_AutoPostingStartDate From Settings Where SettingID = 1);

if @APTL_AutoPostingMethod = 'ByFamily'
Begin
	Declare @PaymentInfoByFamilyIDs table 
	(
	FamilyID int, 
	StudentID int, 
	PSPaymentID int, 
	PSPaymentDate date, 
	PSAmount money, 
	PSDescription nvarchar(max)
	);
	insert into @PaymentInfoByFamilyIDs
	Select 
		S.FamilyID as FamilyID,
		S.StudentID as StudentID,
		P.PSPaymentID as PSPaymentID,
		P.PSPaymentDate,
		vP.NetPaid,
		P.PSDescription
	From 
	Students S
		inner join
	PSPayments P	
		on S.StudentID = P.GLXrefID
		inner join
	vPSPaymentsReport vp
		on P.PSPaymentID = vP.PaymentID
	Where
	P.PSStatus = 'Settled'
	and
	isnull(P.IgnorePayment,0) = 0
	and
	P.PSPaymentDate >= @APTL_AutoPostingStartDate
	and
	P.PostID is null
	and
	P.parentPSPaymentID is null
	and
	P.GLXrefID is not null
	and
	case
		when @PostGrid = 'General' and @APTL_ProcessRegistrationFeesPaymentsSeparately = 0 then 1
		when 
				@PostGrid = 'General' 
				and 
				@APTL_ProcessRegistrationFeesPaymentsSeparately = 1 
				and 
				isnull(p.glPaymentcontext,'') not like '%enrollme%' then 1
		when @PostGrid = 'Registration' and isnull(p.glPaymentcontext,'') like '%enrollme%' then 1
		else 0
	end = 1;




	-- Group Payments By FamilyID

	Insert into @PaymentsByFSID
	Select 
	FamilyID as FamilyID,
	max(StudentID) as StudentID,
	min(PSPaymentID) as MinPSPaymentID,
	min(PSPaymentDate) as PSPaymentDate,
	count(*) as NumberOfPayments,
	sum (PSAmount) as TotalAmount,
	(
		SELECT Stuff(
		  (	
			SELECT distinct N',' + convert(nvarchar(20),PSPaymentID) 
			From @PaymentInfoByFamilyIDs 
			Where FamilyID = PF.FamilyID
			FOR XML PATH('')
		  ,TYPE).value('text()[1]','varchar(1000)'),1,1,N'')
	) as PaymentIDs,
	(
		(
			select
			N'<tr PSPaymentID="' + convert(varchar(20),PSPaymentID) + '"><td class="paymentDateTD" title="' + DATENAME(dw,PSPaymentDate) + '">' + dbo.GLformatdate(PSPaymentDate) + '</td><td class="paymentAmountTD" title="' + isnull(PSDescription,'') + '">' + FORMAT(PSAmount, 'N', 'en-us') + '</td>' + 
			'<td><i class="fa fa-ban" aria-hidden="true" onclick="IgnorePayment(this,''' + FORMAT(PSAmount, 'N', 'en-us') + ''')" title="Ignore/Hide this payment&#013;&#013;This is typically used for payments that have already been posted or payments that you don''t want to add ledger entries for."/></td>' +
			'</tr>'
			as 'data()' 
			from @PaymentInfoByFamilyIDs 
			Where FamilyID = PF.FamilyID
				FOR XML PATH(''),TYPE)
			  .value('text()[1]','nvarchar(max)'
		  )
	) as PaymentsInfo
	From
	@PaymentInfoByFamilyIDs PF
	Group By FamilyID;

	--Select * From @PaymentsByFamilyID

End
else
Begin	--Group Payments By StudentID


	Insert into @PaymentsByFSID
	Select 
	P.GLXrefID as FSID,
	P.GLXrefID as StudentID,
	min(P.PSPaymentID) as MinPSPaymentID,
	min(P.PSPaymentDate) as PSPaymentDate,
	count(*) as NumberOfPayments,
	sum (vP.NetPaid) as TotalAmount,
	(
		SELECT Stuff(
		  (	
			SELECT distinct N',' + convert(nvarchar(20),PSPaymentID) 
			From @PaymentInfoByFamilyIDs 
			Where StudentID = P.GLXrefID
			FOR XML PATH('')
		  ,TYPE).value('text()[1]','varchar(1000)'),1,1,N'')
	) as PaymentIDs,
	(
		(
			select
			N'<tr PSPaymentID="' + convert(varchar(20),PSPaymentID) + '"><td class="paymentDateTD" title="' + DATENAME(dw,PSPaymentDate) + '">' + dbo.GLformatdate(PSPaymentDate) + '</td><td class="paymentAmountTD" title="' + isnull(PSDescription,'') + '">' + FORMAT(PSAmount, 'N', 'en-us') + '</td>' + 
			'<td><i class="fa fa-ban" aria-hidden="true" onclick="IgnorePayment(this,''' + FORMAT(PSAmount, 'N', 'en-us') + ''')" title="Ignore/Hide this payment&#013;&#013;This is typically used for payments that have already been posted or payments that you don''t want to add ledger entries for."/></td>' +
			'</tr>'
			as 'data()' 
			from @PaymentInfoByFamilyIDs 
			Where StudentID = P.GLXrefID
				FOR XML PATH(''),TYPE)
			  .value('text()[1]','nvarchar(max)'
		  )
	) as PaymentsInfo
	From 
	PSPayments P
		inner join
	vPSPaymentsReport vp
		on P.PSPaymentID = vP.PaymentID
	where
	P.PSStatus = 'Settled'
	and
	isnull(P.IgnorePayment,0) = 0
	and
	P.PSPaymentDate >= @APTL_AutoPostingStartDate
	and
	P.PostID is null
	and
	P.parentPSPaymentID is null
	and
	P.GLXrefID is not null
	and
	case
		when @PostGrid = 'General' and @APTL_ProcessRegistrationFeesPaymentsSeparately = 0 then 1
		when 
				@PostGrid = 'General' 
				and 
				@APTL_ProcessRegistrationFeesPaymentsSeparately = 1 
				and 
				isnull(p.glPaymentcontext,'') not like '%enrollme%' then 1
		when @PostGrid = 'Registration' and isnull(p.glPaymentcontext,'') like '%enrollme%' then 1
		else 0
	end = 1
	Group By P.GLXrefID;

End


Declare @CurrentChargesByStudent table (
	StudentID int INDEX IX1 NONCLUSTERED, 
	FamilyID int INDEX IX2 NONCLUSTERED, 
	SessionID int, 
	SessionFromDate date,
	ReceivableCategory nvarchar(50), 
	ReceivableCategoryBalance money, 
	TotalBalance money,
	SiblingTotalBalance money,
	ReceivableCategories nvarchar(300)
);



insert into @CurrentChargesByStudent
select 
r.StudentID,
r.FamilyID,
s.SessionID,
s.FromDate,
tt.ReceivableCategory as ReceivableCategory,
sum(case when tt.DB_CR_Code in ('Payment','Credit memo') then  -r.Amount else r.Amount end) as Amount,
null,
null,
null
from 
Receivables r
	inner join 
TransactionTypes tt
	on r.TransactionTypeID = tt.TransactionTypeID
	inner join
Session s
	on TT.SessionID = s.SessionID
where 
s.Status = 'open'
and
s.BillingThruDate >= DATEADD(day, -350, getdate())	 -- Only get open Sessions from last 350 days
and
case
	when @APTL_AutoPostingMethod = 'ByStudent' and r.studentID in (Select FSID From @PaymentsByFSID) then 1
	when @APTL_AutoPostingMethod = 'ByFamily' and r.FamilyID in (Select FSID From @PaymentsByFSID) then 1
	else 0
end = 1
and
case
	when @PostGrid = 'General' and @APTL_ProcessRegistrationFeesPaymentsSeparately = 0 then 1
	when 
			@PostGrid = 'General' 
			and 
			@APTL_ProcessRegistrationFeesPaymentsSeparately = 1 
			and 
			tt.ReceivableCategory not like '%enrollme%' then 1
	when @PostGrid = 'Registration' and tt.ReceivableCategory like '%enrollme%' then 1
	else 0
end = 1
group by 
	r.StudentID, 
	r.FamilyID,
	tt.ReceivableCategory,
	s.SessionID,
	s.FromDate;
	
-- Remove zero balance items	
Delete From @CurrentChargesByStudent Where ReceivableCategoryBalance = 0;	


if @APTL_AutoPostingMethod = 'ByStudent'
Begin
	Update @CurrentChargesByStudent
	Set 
	SiblingTotalBalance = x.TotalBalance,
	TotalBalance = x.TotalBalance,
	ReceivableCategories = x.ReceivableCategories
	From
	@CurrentChargesByStudent cc
		inner join
	(
		Select 
		StudentID,
		sum(ReceivableCategoryBalance) as TotalBalance,
		(
			select distinct ' ' + ReceivableCategory as 'data()' 
			from @CurrentChargesByStudent 
			Where StudentID = y.StudentID
			for xml path('')
		) as ReceivableCategories
		From
		@CurrentChargesByStudent y
		Group By StudentID
	) x
		on cc.StudentID = x.StudentID
End
else
Begin	-- Get Current Charges by Family
	Update @CurrentChargesByStudent
	Set 
	TotalBalance = x.TotalBalance,
	ReceivableCategories = x.ReceivableCategories
	From
	@CurrentChargesByStudent cc
		inner join
	(
		Select 
		FamilyID,
		sum(ReceivableCategoryBalance) as TotalBalance,
		(
			select distinct ' ' + ReceivableCategory as 'data()' 
			from @CurrentChargesByStudent 
			Where FamilyID = y.FamilyID
			for xml path('')
		) as ReceivableCategories
		From
		@CurrentChargesByStudent y
		Group By FamilyID
	) x
		on cc.FamilyID = x.FamilyID;

	-- Update Family Sibling Balance - used to prevent ledgers entries being generated for siblings with zero balance or a credit
	Update @CurrentChargesByStudent
	Set 
	SiblingTotalBalance = x.TotalBalance
	From
	@CurrentChargesByStudent cc
		inner join
	(
		Select 
		StudentID,
		sum(ReceivableCategoryBalance) as TotalBalance
		From
		@CurrentChargesByStudent y
		Group By StudentID
	) x
		on cc.StudentID = x.StudentID
End




Declare @APTL table(
	ID int Primary Key identity(1,1), 
	PSPaymentID int,  
	TType int,
	PSPaymentDate date,
	StudentID int,
	StudentName nvarchar(100),
	FamilyID int,
	FamilyName nvarchar(300),
	PaymentAmount money, 
	SiblingTotalBalance money,
	TotalBalance money,
	ReceivableCategories nvarchar(500),
	Title nvarchar(100), 
	BillingCategoryID int,
	SessionID int,
	SessionFromDate date,
	PaymentPriority int, 
	ReceivableCategoryBalance money,
	PaymentTransactionTypeID int,
	PaymentTransactionTypeTitle nvarchar(50),
	TTPaymentAmount money,
	SiblingRowSpan int,
	PaymentIDs varchar(500), 
	NumberOfPayments int,
	PaymentsInfo nvarchar(max)

);


Insert into @APTL
Select distinct
P.MinPSPaymentID,
1 as TType,
P.PSPaymentDate,
St.StudentID,
ltrim(rtrim(St.Fname)) + ' (' + St.GradeLevel + ')' as StudentName,
St.FamilyID,
replace(dbo.getFamiliyNameAndSiblingsFromStudentID(P.MaxStudentID ), '-', '<br/>-')  as FamilyName,
P.TotalAmount,
CC.SiblingTotalBalance as SiblingTotalBalance,
CC.TotalBalance as TotalBalance,
CC.ReceivableCategories as ReceivableCategories,
CC.ReceivableCategory + ' (' + S.Title + ')' as Title,
BC.SelectOptionID,
CC.SessionID,
CC.SessionFromDate,
BC.PaymentPriority,
CC.ReceivableCategoryBalance,
isnull(PP.TransactionTypeID, PDef.TransactionTypeID) as PaymentTransactionTypeID,
isnull(PP.TTName, PDef.TTName) as PaymentTransactionTypeTitle,
null as TTPaymentAmount,
null as SiblingRowSpan,
P.PaymentIDs,
P.NumberOfPayments,
P.PaymentsInfo
From
Students St
	inner join
@CurrentChargesByStudent CC
	on St.StudentID = CC.StudentID
	inner join
Session S
	on CC.SessionID = S.SessionID
	left join
@PaymentsByFSID P
	on	
		(@APTL_AutoPostingMethod = 'ByStudent' and P.FSID = St.StudentID)
		or
		(@APTL_AutoPostingMethod = 'ByFamily' and P.FSID = St.FamilyID)
	left join
@BillingCategoryPaymentPriority BC
	on CC.ReceivableCategory = BC.Title
	left join
@TTPaymentPriority PP
	on PP.BillingCategoryID = BC.SelectOptionID and CC.SessionID = PP.SessionID
	left join
@TTPaymentPriority PDef	-- Payment Default Category TT when category does not have payment TT
	on CC.SessionID = PDef.SessionID and PDef.BillingCategoryID = @APTL_BCForNonPaymentCategory


--Select * From @CurrentChargesByStudent
--Where
--FamilyID = 903

-- Add Overpayment Entries for Current Charges where the CCTotalBalance <= 0
insert into @APTL (
PSPaymentDate, 
PSPaymentID, 
StudentID,
StudentName,
FamilyID, 
FamilyName, 
ReceivableCategories, 
TType, 
PaymentAmount, 
PaymentTransactionTypeID, 
PaymentTransactionTypeTitle, 
PaymentPriority, 
TTPaymentAmount
)
select distinct
PSPaymentDate,
PSPaymentID,
StudentID,
StudentName,
FamilyID,
FamilyName, 
ReceivableCategories, 
3, 
PaymentAmount, 
@OverPaymentTransactionTypeID, 
null, 
100, 
PaymentAmount
From
@APTL
Where
TType = 1
and
TotalBalance <= 0;



Declare @CCTTPayments table 
(
ID int identity(1,1) Primary Key, 
APTL_ID int, 
PSPaymentDate datetime, 
PSPaymentID int, 
PaymentAmount money, 
ReceivableCategoryBalance money, 
TTPaymentAmount money
);
Insert into @CCTTPayments(APTL_ID, PSPaymentDate, PSPaymentID, PaymentAmount, ReceivableCategoryBalance, TTPaymentAmount)
Select ID, PSPaymentDate, PSPaymentID, PaymentAmount, ReceivableCategoryBalance, null 
From @APTL
Where 
TType = 1
and
ReceivableCategoryBalance > 0	-- Only process Ledger entries with a Billing Category balance over zero
and
TotalBalance > 0	-- If they have a credit balance don't process other ledger entries as payment all goes to over payment entry above. 
and
SiblingTotalBalance > 0 -- If ByFamily the sibling doesn't have a balance then don't add any ledger entries for this sibling 
Order By PSPaymentDate, PSPaymentID, SessionFromDate, PaymentPriority;



Declare @NumLines int = isnull(@@RowCount,0);
Declare @LineNumber int = 1;
Declare @PSPaymentID int = 0;
Declare @ReceivableCategoryBalance money;
Declare @PaymentBalance money = 0;

--Select * From @CCTTPayments


if @NumLines != 0
Begin

	While @LineNumber <= @NumLines
	Begin


		If @PSPaymentID != (Select PSPaymentID From @CCTTPayments Where ID = @LineNumber)
		Begin		-- reset @PSPaymentID and PaymentBalance if PSPaymentID is different


			-- Before resetting @PSPaymentID first add Overpayment type6 record to @APTL if @PaymentBalance > 0
			if @PaymentBalance > 0
			Begin
				insert into @APTL (PSPaymentDate, PSPaymentID, StudentID, StudentName, FamilyID, FamilyName, ReceivableCategories, TType, PaymentAmount, PaymentTransactionTypeID, PaymentTransactionTypeTitle, PaymentPriority, TTPaymentAmount)
				select top 1
				PSPaymentDate,
				PSPaymentID,
				StudentID,
				StudentName,
				FamilyID,
				FamilyName, 
				ReceivableCategories, 
				3, 
				PaymentAmount, 
				@OverPaymentTransactionTypeID, 
				null, 
				100, 
				@PaymentBalance
				From
				@APTL
				Where
				PSPaymentID = @PSPaymentID
				and
				TType = 1
			End
			Set @PSPaymentID = (Select PSPaymentID From @CCTTPayments Where ID = @LineNumber);
			Set @PaymentBalance = (Select PaymentAmount From @CCTTPayments Where ID = @LineNumber);
		End;

		Set @ReceivableCategoryBalance = (Select ReceivableCategoryBalance From @CCTTPayments Where ID = @LineNumber);

		if @ReceivableCategoryBalance >= @PaymentBalance
		Begin
			Update @CCTTPayments Set TTPaymentAmount =  @PaymentBalance Where ID = @LineNumber;
			Set @PaymentBalance = 0;
		End
		Else
		Begin
			Update @CCTTPayments Set TTPaymentAmount =  @ReceivableCategoryBalance Where ID = @LineNumber;
			Set @PaymentBalance = @PaymentBalance - @ReceivableCategoryBalance;
		End

		-- if @NumLines = @LineNumber and there still is a balance then add overpayment record
		if @LineNumber = @NumLines and @PaymentBalance > 0
		Begin

			insert into @APTL (PSPaymentDate, PSPaymentID, StudentID, StudentName, FamilyID, FamilyName, ReceivableCategories, TType, PaymentAmount, PaymentTransactionTypeID, PaymentTransactionTypeTitle, PaymentPriority, TTPaymentAmount)
			select top 1
			PSPaymentDate,
			PSPaymentID,
			StudentID,
			StudentName,
			FamilyID,
			FamilyName, 
			ReceivableCategories, 
			3, 
			PaymentAmount, 
			@OverPaymentTransactionTypeID, 
			null, 
			100, 
			@PaymentBalance
			From
			@APTL
			Where
			PSPaymentID = @PSPaymentID
			and
			TType = 1

			Set @PaymentBalance = 0;
		End

		Set @LineNumber = @LineNumber + 1;

	End


End		-- if NumLines != 0





Update @APTL
Set TTPaymentAmount = P.TTPaymentAmount
From
@APTL A
	inner join
@CCTTPayments P
	on A.ID = P.APTL_ID;


-- Set SiblingRowSpan 
Update @APTL
Set SiblingRowSpan = x.RowSpan
From
@APTL A
	inner join
(
Select 
PSPaymentID, 
StudentID,
count(StudentID) as RowSpan
From @APTL
Where 
TType = 1
Group By PSPaymentID, StudentID
) x
	on A.PSPaymentID = x.PSPaymentID and A.StudentID = x.StudentID;



--***********************************************
--******* Payment Transaction Types *************
--***********************************************


Declare @PTT table(
FromDate date,
PaymentPriority int,
TransactionTypeID int,
Title nvarchar(50),
DefaultPaymentTransactionTypeID int,
OverPaymentTransactionTypeID int
)

Insert into @PTT
Select 
S.FromDate as FromDate,
PP.PaymentPriority as PaymentPriority,
TT.TransactionTypeID as TransactionTypeID,
TT.Title + ' (' + S.Title + ')' as Title,
case when TT.TransactionTypeID = @DefaultPaymentTransactionTypeID then 1 else 0 end as DefaultPaymentTransactionTypeID,
case when TT.TransactionTypeID = @OverPaymentTransactionTypeID then 1 else 0 end as OverPaymentTransactionTypeID
From TransactionTypes TT
	inner join
Session S
	on TT.SessionID = S.SessionID
	inner join
@BillingCategoryPaymentPriority PP
	on TT.ReceivableCategory = PP.Title
Where
S.Status = 'Open'
and
DB_CR_Code = 'Payment';


-- Get for regular payments
Select 
1 as tag,
null as parent,
TransactionTypeID as [PaymentTT!1!TransactionTypeID],
Title as [PaymentTT!1!Title],
DefaultPaymentTransactionTypeID as [PaymentTT!1!DefaultPaymentTransactionTypeID],
OverPaymentTransactionTypeID as [PaymentTT!1!OverPaymentTransactionTypeID]
From @PTT
Order By FromDate, PaymentPriority, Title
FOR XML EXPLICIT;




-- get for overpayments where the select list shows an Transaction Type for each student in family

Select distinct
1 as tag,
null as parent,
FamilyID as [OPStudent!1!FamilyID],
StudentID as [OPStudent!1!StudentID],
StudentName as [OPStudent!1!StudentName],
null as [OPTT!2!FromDate],
null as [OPTT!2!PaymentPriority],
null as [OPTT!2!TransactionTypeID],
null as [OPTT!2!Title],
null as [OPTT!2!DefaultPaymentTransactionTypeID],
null as [OPTT!2!OverPaymentTransactionTypeID]
From @APTL

Union All

Select distinct
2 as tag,
1 as parent,
FamilyID as [OPStudent!1!FamilyID],
StudentID as [OPStudent!1!StudentID],
StudentName as [OPStudent!1!StudentName],
FromDate as [OPTT!2!FromDate],
P.PaymentPriority as [OPTT!2!PaymentPriority],
TransactionTypeID as [OPTT!2!TransactionTypeID],
P.Title as [OPTT!2!Title],
DefaultPaymentTransactionTypeID as [OPTT!2!DefaultPaymentTransactionTypeID],
OverPaymentTransactionTypeID as [OPTT!2!OverPaymentTransactionTypeID]
From 
@APTL A
	cross join
@PTT P
Order By [OPStudent!1!FamilyID], [OPStudent!1!StudentID], [OPTT!2!FromDate], [OPTT!2!PaymentPriority], [OPTT!2!Title]
FOR XML EXPLICIT;




Select distinct
1 as tag,
null as parent,
@OverPaymentTransactionTypeID as [Payment!1!OverPaymentTransactionTypeID],
PSPaymentID as [Payment!1!PSPaymentID],
PSPaymentDate as [Payment!1!PSPaymentDate], 
DATENAME(dw,PSPaymentDate) as [Payment!1!PSPaymentDateWkDayString],
dbo.GLformatdate(PSPaymentDate) as [Payment!1!PSPaymentDateString],  
FamilyName as [Payment!1!FamilyName],
PaymentAmount as [Payment!1!PaymentAmount],
TotalBalance as [Payment!1!TotalBalance],
PaymentIDs as [Payment!1!PaymentIDs],
NumberOfPayments as [Payment!1!NumberOfPayments],
PaymentsInfo as [Payment!1!PaymentsInfo],
null as [Transaction!2!StudentID], 
null as [Transaction!2!StudentName], 
null as [Transaction!2!FamilyID],
null as [Transaction!2!TType],
null as [Transaction!2!Title],
null as [Transaction!2!SessionFromDate],
null as [Transaction!2!PaymentPriority],
null as [Transaction!2!TransactionTypeBalance],
null as [Transaction!2!PaymentTransactionTypeID],
null as [Transaction!2!TTPaymentAmount],
null as [Transaction!2!SiblingRowSpan]
From @APTL A
Where 
TType = 1
and
case 
	when ltrim(rtrim(isnull(@PaymentsStartDate,''))) = '' then 1
	when PSPaymentDate between @StartDate and @EndDate then 1
	else 0
end = 1
and
case
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) < 1 then 1
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) = 1 and ltrim(rtrim(@PayerNameFilter)) = substring(FamilyName, 1,1) then 1
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and FamilyName like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and convert(nvarchar(20),PaymentAmount) like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
	else 0
end = 1	
and
case
	when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) < 1 then 1
	when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) = 1 and ltrim(rtrim(@DescriptionFilter)) = substring(ReceivableCategories, 1,1) then 1
	when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) > 1 and ReceivableCategories like '%' + ltrim(rtrim(@DescriptionFilter)) + '%' then 1
	else 0
end = 1	


Union

Select 
2 as tag,
1 as parent,
null as [Payment!1!OverPaymentTransactionTypeID],
PSPaymentID as [Payment!1!PSPaymentID],
PSPaymentDate as [Payment!1!PSPaymentDate], 
null as [Payment!1!PSPaymentDateWkDayString],
null as [Payment!1!PSPaymentDateString], 
FamilyName as [Payment!1!FamilyName],
PaymentAmount as [Payment!1!PaymentAmount],
null as [Payment!1!TotalBalance],
null as [Payment!1!PaymentIDs],
null as [Payment!1!NumberOfPayments],
null as [Payment!1!PaymentsInfo],
StudentID as [Transaction!2!StudentID], 
StudentName as [Transaction!2!StudentName], 
FamilyID as [Transaction!2!FamilyID],
TType as [Transaction!2!TType],
Title as [Transaction!2!Title],
SessionFromDate as [Transaction!2!SessionFromDate],
PaymentPriority as [Transaction!2!PaymentPriority],
ReceivableCategoryBalance as [Transaction!2!TransactionTypeBalance],
PaymentTransactionTypeID as [Transaction!2!PaymentTransactionTypeID],
TTPaymentAmount as [Transaction!2!TTPaymentAmount],
SiblingRowSpan as [Transaction!2!SiblingRowSpan]
From @APTL A
Where
case 
	when ltrim(rtrim(isnull(@PaymentsStartDate,''))) = '' then 1
	when PSPaymentDate between @StartDate and @EndDate then 1
	else 0
end = 1
and
case
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) < 1 then 1
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) = 1 and ltrim(rtrim(@PayerNameFilter)) = substring(FamilyName, 1,1) then 1
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and FamilyName like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
	when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and convert(nvarchar(20),PaymentAmount) like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
	else 0
end = 1	
and
case
	when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) < 1 then 1
	when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) = 1 and ltrim(rtrim(@DescriptionFilter)) = substring(ReceivableCategories, 1,1) then 1
	when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) > 1 and ReceivableCategories like '%' + ltrim(rtrim(@DescriptionFilter)) + '%' then 1
	else 0
end = 1	
Order By PSPaymentDate desc, PSPaymentID, [Transaction!2!StudentID], [Transaction!2!TType], [Transaction!2!SessionFromDate], [Transaction!2!PaymentPriority], tag

FOR XML EXPLICIT


END
GO
