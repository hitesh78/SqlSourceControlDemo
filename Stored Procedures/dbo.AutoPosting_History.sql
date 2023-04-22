SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 --=============================================
 --Author:		Don Puls
 --Create date: 2023-01-20
 --Description:	Provides data for the AutoPosting History tab
 --=============================================
CREATE   PROCEDURE [dbo].[AutoPosting_History]
@PaymentsStartDate nvarchar(50),
@PaymentsEndDate nvarchar(50),
@PayerNameFilter nvarchar(50),
@AmountFilter nvarchar(50),
@DescriptionFilter nvarchar(50),
@LedgerPaymentsToFilter nvarchar(50)
AS
BEGIN


--Declare
--@PaymentsStartDate varchar(100) = '',
--@PaymentsEndDate varchar(100) = '',
--@PayerNameFilter varchar(100) = '',
--@AmountFilter varchar(100) = '',
--@DescriptionFilter varchar(100) = '',
--@LedgerPaymentsToFilter varchar(100) = ''

	SET NOCOUNT ON;


	Declare 
	@StartDate date = dbo.toDBDate(@PaymentsStartDate),
	@EndDate date = dbo.toDBDate(@PaymentsEndDate);



	Declare 
	@APTL_BCForOverPayment int,
	@APTL_BCForNonPaymentCategory int;

	Select
	@APTL_BCForOverPayment = APTL_BCForOverPayment,
	@APTL_BCForNonPaymentCategory = APTL_BCForNonPaymentCategory
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


	Declare @History table (
		PSPaymentID int, 
		PostDate datetime, 
		TotalDue nvarchar(30), 
		BalanceAfterPayment money, 
		FamilyID int, 
		FamilyStr nvarchar(300), 
		PaymentAmount money, 
		SumOfPayments money,
		BCTitles nvarchar(1000),
		PaymentTransactionTitles nvarchar(1000),
		PaymentsInfo nvarchar(max)
	);
	Insert into @History
	select distinct
	PSPaymentID,
	PostDate, 
	TotalDue,
	BalanceAfterPayment,
	S.FamilyID, 
	replace(dbo.getFamiliyNameAndSiblingsFromStudentID(P.GLXrefID), '-', '<br/>-')  as FamilyStr,
	isnull(P.StatementAmount,P.PSAmount) as PaymentAmount,
	P.SumOfPayments,
	--(
	--	select sum(PSAmount) 
	--	From
	--	PSPayments x
	--		inner join
	--	(
	--		Select value as PSPaymentID
	--		From 
	--		string_split(P.PaymentIDs, ',')
	--	) y
	--		on x.PSPaymentID = y.PSPaymentID
	--) as PaymentAmount,
	(
		select distinct bcTitle as 'data()' 
		from 
		PSPaymentBCBalances BC
		Where BC.PSPaymentID = P.PSPaymentID
		for xml path('')
	) as BCTitles,
	(
		select distinct Title as 'data()' 
		from 
		TransactionTypes TT
			inner join
		PSPaymentLedgerEntries LE
			on TT.TransactionTypeID = LE.TransactionTypeID
		Where LE.PSPaymentID = P.PSPaymentID
		for xml path('')
	) as PaymentTransactionTitles,
	(
		(
			select
			N'<tr><td class="paymentDateTD" title="' + DATENAME(dw,PSPaymentDate) + '">' + dbo.GLformatdate(PSPaymentDate) + '</td><td class="paymentAmountTD" title="' + PSDescription + '">' + FORMAT(PSAmount, 'N', 'en-us') + '</td></tr>'
			as 'data()' 
			from 
			PSPayments x
				inner join
			(
				Select value as PSPaymentID
				From 
				string_split(P.PaymentIDs, ',')
			) y
				on x.PSPaymentID = y.PSPaymentID
				FOR XML PATH(''),TYPE)
			  .value('text()[1]','nvarchar(max)'
		  )
	) as PaymentsInfo
	From
	PSPayments P
		left join
	Students S
		on P.GLXrefID = S.StudentID
	Where
	P.PostID is not null
	and
	case 
		when ltrim(rtrim(isnull(@PaymentsStartDate,''))) = '' then 1
		when P.PostDate between @StartDate and @EndDate then 1
		else 0
	end = 1



	Declare @FamilySiblingCount table (FamilyID int, SiblingCount int)
	Insert into @FamilySiblingCount
	Select
	H.FamilyID,
	count(distinct LE.StudentID) as SiblingCount
	From
	@History H
		inner join
	PSPaymentLedgerEntries LE
		on H.PSPaymentID = LE.PSPaymentID
	Group By FamilyID;


	Declare @IgnoredPayments table (PSPaymentID int, PostDate date, PaymentAmount money, FamilyStr nvarchar(300), BCTitles nvarchar(100), PaymentTransactionTitles nvarchar(100))  

	Insert into @IgnoredPayments
	Select 
	PSPaymentID,
	PostDate,
	isnull(StatementAmount,PSAmount) as PaymentAmount,
	replace(dbo.getFamiliyNameAndSiblingsFromStudentID(GLXrefID), '-', '<br/>-')  as FamilyStr,
	'Ignored/Hidden Payment' as BCTitles,
	'Ignored/Hidden Payment' as PaymentTransactionTitles
	From PSPayments
	Where
	IgnorePayment = 1
	and
	case 
		when ltrim(rtrim(isnull(@PaymentsStartDate,''))) = '' then 1
		when PostDate between @StartDate and @EndDate then 1
		else 0
	end = 1;




--Select SumOfPayments From @History
--Select * From @IgnoredPayments

	select 
	1 as tag,
	null as parent,
	PSPaymentID as [Payment!1!PSPaymentID],
	'Posted' as [Payment!1!PaymentStatus],
	PostDate as [Payment!1!PostDate], 
	dbo.GLformatdate(PostDate) + ' ' + format(PostDate, '%h:mm tt') as [Payment!1!PostDateStr],
	TotalDue as [Payment!1!TotalDue],
	BalanceAfterPayment as [Payment!1!BalanceAfterPayment],
	DATENAME(dw,PostDate) as [Payment!1!PSPaymentDateWkDayString],
	dbo.GLformatdate(PostDate) as [Payment!1!PSPaymentDateString], 
	H.FamilyID as [Payment!1!FamilyID], 
	FamilyStr  as [Payment!1!FamilyName],
	SiblingCount as [Payment!1!FamilySiblingCount],
	SumOfPayments as [Payment!1!PaymentAmount],
	PaymentsInfo as [Payment!1!PaymentsInfo],
	null as [Transaction!2!pType],
	null as [Transaction!2!StudentID],
	null as [Transaction!2!StudentName],
	null as [Transaction!2!bcTitle],
	null as [Transaction!2!bcBalance],
	null as [Transaction!2!bcRowOrder],
	null as [Transaction!2!SiblingRowSpan],
	null as [Transaction!2!SessionFromDate], 
	null as [Transaction!2!TTDescription],
	null as [Transaction!2!TTAmount],
	null as [Transaction!2!PaymentTransactionTypePriority],
	null as [Transaction!2!OverPaymentEntry],
	null as [Transaction!2!NewRowOrder]
	From
	@History H
		inner join
	@FamilySiblingCount F
		on H.FamilyID = F.FamilyID
	Where
	case
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) = 1 and ltrim(rtrim(@PayerNameFilter)) = substring(FamilyStr, 1,1) then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and FamilyStr like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and convert(nvarchar(20),PaymentAmount) like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1		
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) = 1 and ltrim(rtrim(@DescriptionFilter)) = substring(BCTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) > 1 and BCTitles like '%' + ltrim(rtrim(@DescriptionFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) = 1 and ltrim(rtrim(@LedgerPaymentsToFilter)) = substring(PaymentTransactionTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) > 1 and PaymentTransactionTitles like '%' + ltrim(rtrim(@LedgerPaymentsToFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) = 1 and ltrim(rtrim(@AmountFilter)) = substring(convert(nvarchar(20),H.SumOfPayments), 1,1) then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) > 1 and convert(nvarchar(20),H.SumOfPayments) like '%' + ltrim(rtrim(@AmountFilter)) + '%' then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) > 1 and convert(nvarchar(1000),dbo.udf_StripHTML(PaymentsInfo)) like '%' + ltrim(rtrim(@AmountFilter)) + '%' then 1
		else 0
	end = 1
	
	Union 

	select 
	1 as tag,
	null as parent,
	PSPaymentID as [Payment!1!PSPaymentID],
	'Ignored' as [Payment!1!PaymentStatus],
	PostDate as [Payment!1!PostDate],
	dbo.GLformatdate(PostDate) + ' ' + format(PostDate, '%h:mm tt') as [Payment!1!PostDateStr],
	null as [Payment!1!TotalDue],
	null as [Payment!1!BalanceAfterPayment],
	DATENAME(dw,PostDate) as [Payment!1!PSPaymentDateWkDayString],
	dbo.GLformatdate(PostDate) as [Payment!1!PSPaymentDateString], 
	null as [Payment!1!FamilyID], 
	FamilyStr  as [Payment!1!FamilyName],
	null as [Payment!1!FamilySiblingCount],
	PaymentAmount as [Payment!1!PaymentAmount],
	null as [Payment!1!PaymentsInfo],
	null as [Transaction!2!pType],
	null as [Transaction!2!StudentID],
	null as [Transaction!2!StudentName],
	null as [Transaction!2!bcTitle],
	null as [Transaction!2!bcBalance],
	null as [Transaction!2!bcRowOrder],
	null as [Transaction!2!SiblingRowSpan],
	null as [Transaction!2!SessionFromDate], 
	null as [Transaction!2!TTDescription],
	null as [Transaction!2!TTAmount],
	null as [Transaction!2!PaymentTransactionTypePriority],
	null as [Transaction!2!OverPaymentEntry],
	null as [Transaction!2!NewRowOrder]
	From
	@IgnoredPayments
	Where
	case
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) = 1 and ltrim(rtrim(@PayerNameFilter)) = substring(FamilyStr, 1,1) then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and FamilyStr like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and convert(nvarchar(20),PaymentAmount) like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1		
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) = 1 and ltrim(rtrim(@DescriptionFilter)) = substring(BCTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) > 1 and BCTitles like '%' + ltrim(rtrim(@DescriptionFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) = 1 and ltrim(rtrim(@LedgerPaymentsToFilter)) = substring(PaymentTransactionTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) > 1 and PaymentTransactionTitles like '%' + ltrim(rtrim(@LedgerPaymentsToFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) = 1 and ltrim(rtrim(@AmountFilter)) = substring(convert(nvarchar(20),PaymentAmount), 1,1) then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) > 1 and convert(nvarchar(20),PaymentAmount) like '%' + ltrim(rtrim(@AmountFilter)) + '%' then 1
		else 0
	end = 1

	Union

	select 
	2 as tag,
	1 as parent,
	H.PSPaymentID as [Payment!1!PSPaymentID],
	null as [Payment!1!PaymentStatus],
	PostDate as [Payment!1!PostDate],
	null as [Payment!1!PostDateStr],
	null as [Payment!1!TotalDue],
	null as [Payment!1!BalanceAfterPayment],
	null as [Payment!1!PSPaymentDateWkDayString],
	null as [Payment!1!PSPaymentDateString], 
	null as [Payment!1!FamilyID], 
	FamilyStr  as [Payment!1!FamilyName],
	null as [Payment!1!FamilySiblingCount],
	null as [Payment!1!PaymentAmount],
	null as [Payment!1!PaymentsInfo],
	'BillingCategory' as [Transaction!2!pType],
	BC.StudentID as [Transaction!2!StudentID],
	St.Fname as [Transaction!2!StudentName],
	BC.bcTitle as [Transaction!2!bcTitle],
	BC.bcBalance as [Transaction!2!bcBalance],
	BC.bcRowOrder as [Transaction!2!bcRowOrder],
	x.RowSpan as [Transaction!2!SiblingRowSpan],
	null as [Transaction!2!SessionFromDate],
	null as [Transaction!2!TTDescription],
	null as [Transaction!2!TTAmount],
	null as [Transaction!2!PaymentTransactionTypePriority],
	NUll as [Transaction!2!OverPaymentEntry],
	NUll as [Transaction!2!NewRowOrder]
	From
	@History H
		inner join
	PSPaymentBCBalances BC
		on H.PSPaymentID = BC.PSPaymentID	
		inner join
	Students St
		on BC.StudentID = St.StudentID
		inner join
	(
		Select
		PSPaymentID, 
		StudentID,
		count(*) as RowSpan
		From PSPaymentBCBalances
		Group By PSPaymentID, StudentID
	) x
		on BC.PSPaymentID = x.PSPaymentID and BC.StudentID = x.StudentID
	Where
	case
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) = 1 and ltrim(rtrim(@PayerNameFilter)) = substring(FamilyStr, 1,1) then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and FamilyStr like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) = 1 and ltrim(rtrim(@DescriptionFilter)) = substring(BCTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) > 1 and BCTitles like '%' + ltrim(rtrim(@DescriptionFilter)) + '%' then 1
		else 0
	end = 1		
	and
	case
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) = 1 and ltrim(rtrim(@LedgerPaymentsToFilter)) = substring(PaymentTransactionTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) > 1 and PaymentTransactionTitles like '%' + ltrim(rtrim(@LedgerPaymentsToFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) = 1 and ltrim(rtrim(@AmountFilter)) = substring(convert(nvarchar(20),H.SumOfPayments), 1,1) then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) > 1 and convert(nvarchar(20),H.SumOfPayments) like '%' + ltrim(rtrim(@AmountFilter)) + '%' then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) > 1 and convert(nvarchar(1000),dbo.udf_StripHTML(PaymentsInfo)) like '%' + ltrim(rtrim(@AmountFilter)) + '%' then 1
		else 0
	end = 1

	Union

	select
	2 as tag,
	1 as parent,
	H.PSPaymentID as [Payment!1!PSPaymentID],
	null as [Payment!1!PaymentStatus],
	PostDate as [Payment!1!PostDate], 
	null as [Payment!1!PostDateStr],
	null as [Payment!1!TotalDue],
	null as [Payment!1!BalanceAfterPayment],
	null as [Payment!1!PSPaymentDateWkDayString],
	null as [Payment!1!PSPaymentDateString], 
	null as [Payment!1!FamilyID], 
	FamilyStr  as [Payment!1!FamilyName],
	null as [Payment!1!FamilySiblingCount],
	null as [Payment!1!PaymentAmount],
	null as [Payment!1!PaymentsInfo],
	'LedgerEntry' as [Transaction!2!pType],
	LE.StudentID as [Transaction!2!StudentID],
	St.Fname as [Transaction!2!StudentName],
	null as [Transaction!2!bcTitle],
	null as [Transaction!2!bcBalance],
	null as [Transaction!2!bcRowOrder],
	null as [Transaction!2!SiblingRowSpan],
	FromDate as [Transaction!2!SessionFromDate],
	TT.Title + ' (' + S.Title + ')' as [Transaction!2!TTDescription],
	LE.TTAmount as [Transaction!2!TTAmount],
	isnull(PP.PaymentPriority, PDef.PaymentPriority) as [Transaction!2!PaymentTransactionTypePriority],
	LE.OverPayment as [Transaction!2!OverPaymentEntry],
	LE.NewRowOrder as [Transaction!2!NewRowOrder]
	From
	@History H
		inner join
	PSPaymentLedgerEntries LE
		on H.PSPaymentID = LE.PSPaymentID	
		inner join
	Students St
		on LE.StudentID = St.StudentID
		inner join
	TransactionTypes TT
		on LE.TransactionTypeID = TT.TransactionTypeID
		inner join
	Session S
		on TT.SessionID = S.SessionID
		left join
	@BillingCategoryPaymentPriority BC
		on TT.ReceivableCategory = BC.Title
		left join
	@TTPaymentPriority PP
		on PP.BillingCategoryID = BC.SelectOptionID and TT.SessionID = PP.SessionID
		left join
	@TTPaymentPriority PDef	-- Payment Default Category TT when category does not have payment TT
		on TT.SessionID = PDef.SessionID and PDef.BillingCategoryID = @APTL_BCForNonPaymentCategory
	Where
	case
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) = 1 and ltrim(rtrim(@PayerNameFilter)) = substring(FamilyStr, 1,1) then 1
		when len(ltrim(rtrim(isnull(@PayerNameFilter,'')))) > 1 and FamilyStr like '%' + ltrim(rtrim(@PayerNameFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) = 1 and ltrim(rtrim(@DescriptionFilter)) = substring(BCTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@DescriptionFilter,'')))) > 1 and BCTitles like '%' + ltrim(rtrim(@DescriptionFilter)) + '%' then 1
		else 0
	end = 1		
	and
	case
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) = 1 and ltrim(rtrim(@LedgerPaymentsToFilter)) = substring(PaymentTransactionTitles, 1,1) then 1
		when len(ltrim(rtrim(isnull(@LedgerPaymentsToFilter,'')))) > 1 and PaymentTransactionTitles like '%' + ltrim(rtrim(@LedgerPaymentsToFilter)) + '%' then 1
		else 0
	end = 1	
	and
	case
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) < 1 then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) = 1 and ltrim(rtrim(@AmountFilter)) = substring(convert(nvarchar(20),H.SumOfPayments), 1,1) then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) > 1 and convert(nvarchar(20),H.SumOfPayments) like '%' + ltrim(rtrim(@AmountFilter)) + '%' then 1
		when len(ltrim(rtrim(isnull(@AmountFilter,'')))) > 1 and convert(nvarchar(1000),dbo.udf_StripHTML(PaymentsInfo)) like '%' + ltrim(rtrim(@AmountFilter)) + '%' then 1
		else 0
	end = 1
	Order By [Payment!1!PostDate] desc, [Payment!1!PSPaymentID], tag, [Transaction!2!StudentID], [Transaction!2!bcRowOrder], [Transaction!2!OverPaymentEntry], [Transaction!2!NewRowOrder], [Transaction!2!SessionFromDate], [Transaction!2!PaymentTransactionTypePriority], [Transaction!2!TTAmount] desc, [Transaction!2!TTDescription]
	FOR XML EXPLICIT



end
GO
