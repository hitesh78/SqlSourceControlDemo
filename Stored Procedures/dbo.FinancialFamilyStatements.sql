SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author:		Don Puls
---- Create date: 3/31/2022
---- Description:	Returns Results for the Family Statements financial Report
---- =============================================
CREATE   PROCEDURE [dbo].[FinancialFamilyStatements]
	@SessionID int,
	@periodFrom nvarchar(50),
	@periodThru nvarchar(50),
	@range nvarchar(50),
	@dateFrom nvarchar(50),
	@dateThru nvarchar(50),
	@StudentID nvarchar(50),
	@theFamilyID nvarchar(50),
	@studentFamilyFilter nvarchar(50),
	@SchoolID nvarchar(50),
	@EK nvarchar(50)
AS
BEGIN



--Declare
--@SessionID int = 5,
--@periodFrom nvarchar(50) = 'null',
--@periodThru nvarchar(50) = '',
--@range nvarchar(50) = 'Dates',
--@dateFrom nvarchar(50) = '2021-03-01',
--@dateThru nvarchar(50) = '2022-03-31',
--@StudentID nvarchar(50) = '70',
--@theFamilyID nvarchar(50) = '0',
--@studentFamilyFilter nvarchar(50) = 'Student',
--@SchoolID nvarchar(50) = '2758',
--@EK nvarchar(50) = '.211123600768688'


	SET NOCOUNT ON;



	declare @SearchFromDate date = 		
		(	
		case 
			when @range = 'Periods' then
				(select FromDate from InvoicePeriods ip1 where cast(ip1.InvoicePeriodID as varchar(10)) = @periodFrom)
			when @range = 'Dates' and @dateFrom != '' then
				dbo.toDBDate(@dateFrom)
			else null
		end
		);

	declare @SearchThruDate date = 		
		(case 
			when @range = 'Periods' and @periodThru = '' then  
				(select ThruDate from InvoicePeriods ip1 where cast(ip1.InvoicePeriodID as varchar(10)) = @periodFrom)
			when @range = 'Periods' then
				(select ThruDate from InvoicePeriods ip1 where cast(ip1.InvoicePeriodID as varchar(10)) = @periodThru)
			when @range = 'Dates' and @dateThru !='' then
				dbo.toDBDate(@dateThru)
			else
				null
			end);

	if @SearchThruDate is null
		set @SearchThruDate = @SearchFromDate
		
	declare @SearchFromDateFormatted char(10) = isnull(dbo.GLformatdate(@SearchFromDate),'');
	declare @SearchThruDateFormatted char(10) = isnull(dbo.GLformatdate(@SearchThruDate),'');


	declare @SessionTitle varchar(50) = 
		( select Title from Session where SessionID = @SessionID )

	declare @FamilyID int = case when @studentFamilyFilter = 'Family'  
							then cast(@theFamilyID as int)
							else (select FamilyID from Students where StudentID = @StudentID)
							end

	Declare @getStudentAddressTitle table (StudentID int primary key, AddressTitle nvarchar(100), FamilySortOrderByMaxStudentName nvarchar(100));

	Insert into @getStudentAddressTitle
	select 
	S.StudentID,
	N.AddressTitle,
	(Select max((Lname+','+Fname)) From Students Where isnull(FamilyID,-StudentID) = isnull(S.FamilyID,-S.StudentID))
	from 
	Students S
		inner join
	dbo.getStudentAddressTitle() N
		on S.StudentID = N.StudentID;	



	--Create Table #BillingNotes (InvoicePeriodID int, BillingNote nvarchar(4000));

	--CREATE NONCLUSTERED INDEX IX3  ON #BillingNotes (InvoicePeriodID);

	--Insert into #BillingNotes
	--Select 
	--InvoicePeriodID,
	--case when datediff(day,@SearchFromDate,@SearchThruDate) > 35 then '' else BillingNote end as BillingNote
	--from InvoicePeriods ip 
	--where 
	--ip.SessionID = @SessionID
	--and
	--ip.FromDate = 
	--(
	--	Select MAX(FromDate) 
	--	from InvoicePeriods ip2 
	--	where 
	--	ip2.FromDate <= @SearchFromDate 
	--	and 
	--	ip2.SessionID = @SessionID
	--	-- above was: ip2.ThruDate <= @SearchThruDate
	--	-- (Fresh Desk #68327, Wrike #SearchThruDate
	--)


	Declare @BillingNote nvarchar(max) = '';
	if datediff(day,@SearchFromDate,@SearchThruDate) <= 35
	Begin
		Set @BillingNote = (

			Select top 1 
			BillingNote
			from InvoicePeriods ip 
			where 
			ip.SessionID = @SessionID
			and
			ip.FromDate = 
			(
				Select MAX(FromDate) 
				from InvoicePeriods ip2 
				where 
				ip2.FromDate <= @SearchFromDate 
				and 
				ip2.SessionID = @SessionID
				-- above was: ip2.ThruDate <= @SearchThruDate
				-- (Fresh Desk #68327, Wrike #SearchThruDate
			)
		);
	End;

	Create Table #PriorBalances (FamilyID int, PriorBalance money);

	CREATE NONCLUSTERED INDEX IX1  ON #PriorBalances (FamilyID);

	Insert into #PriorBalances
	Select 
	r.FamilyID, 
	SUM(case when tt.DB_CR_Code in ('Payment','Credit memo') then  -r.Amount else r.Amount end)
	from 
	Receivables r
		inner join 
	TransactionTypes tt 
		on tt.TransactionTypeID=r.TransactionTypeID 
	where 
	tt.SessionID = @SessionID 
	and r.Date < @SearchFromDate
	Group By r.FamilyID


	Create table #ReceivablesFamily (
	FamilyOrTempID int,
	ReceivableID int,
	StudentID int,
	FullName nvarchar(200),
	[Date] date,
	TransactionType nvarchar(100),
	Notes nvarchar(2000),
	ContractID int,
	TransactionMethod nvarchar(100),
	ReferenceNumber nvarchar(100),
	SignedAmount money,
	DB_CR_Code nvarchar(60),
	month nvarchar(60),
	PriorBal money,
	Balance money,
	SortOrder nvarchar(60)
	);

	CREATE NONCLUSTERED INDEX IX2  ON #ReceivablesFamily (FamilyOrTempID,Date);

	Insert into #ReceivablesFamily
	Select distinct
	vr.FamilyOrTempID,
	vr.ReceivableID,
	vr.StudentID,
	s.Fname+' '+ltrim(isnull(s.Mname,'')+' '+s.Lname) as FullName,	
	vr.Date,vr.TransactionType,vr.Notes,vr.ContractID,
	vr.TransactionMethod,vr.ReferenceNumber,
	vr.SignedAmount,vr.DB_CR_Code,vr.month,vr.PriorBal,vr.Balance,vr.SortOrder
	From 
	vReceivablesFamily  vr
		left join
	Students s
		on vr.StudentID = s.StudentID
	Where
	vr.sessionID = @SessionID
	and
	(
		vr.Date is null /* show balance forward even if not transactions */	
		or 
		vr.Date between @SearchFromDate and @SearchThruDate
	)

	union

	select distinct
	vr.FamilyOrTempID,
	null as ReceivableID,
	null as StudentID,
	null as FullName,
	null as Date,
	null as TransactionType,
	null as Notes,
	null as ContractID,
	null as TransactionMethod,
	null as ReferenceNumber,
	null as SignedAmount,
	null as DB_CR_Code,
	null as month,
	null as PriorBal,
	vr.Balance,
	null as SortOrder
	From 
	vReceivablesFamily vr
		inner join
	(
		select 
		FamilyOrTempID,
		max(SortOrder) as maxSortOrder
		From
		vReceivablesFamily
		Where
		sessionID = @SessionID
		group By FamilyOrTempID
	) vr2
		on vr.FamilyOrTempID = vr2.FamilyOrTempID and vr.SortOrder = vr2.maxSortOrder
	Where 
	vr.sessionID = @SessionID
	and
	vr.Date < @SearchFromDate
	and
	vr.Balance != 0;

	Declare
	@SchoolName nvarchar(100),
	@SchoolStreet nvarchar(100),
	@SchoolCity nvarchar(100),
	@SchoolState nvarchar(100),
	@SchoolZip nvarchar(20),
	@SchoolPhone nvarchar(20),
	@SchoolFax nvarchar(20),
	@SchoolEmailAddress nvarchar(30),
	@TaxID nvarchar(30);

	select 
	@SchoolName = SchoolName,
	@SchoolStreet = SchoolStreet,
	@SchoolCity = SchoolCity,
	@SchoolState = SchoolState,
	@SchoolZip = SchoolZip,
	@SchoolPhone = SchoolPhone,
	@SchoolFax = SchoolFax,
	@SchoolEmailAddress = SchoolEmailAddress,
	@TaxID = TaxID 
	from Settings
	Where SettingID = 1;



	select distinct

	ROW_NUMBER() 
		OVER(
			PARTITION BY isnull(s.FamilyID, -s.StudentID)*10 + case when vr.ReceivableID is null then 0 else 1 end 
				ORDER BY vr.SortOrder ASC) as RowNumber,
		isnull(RC.NumRows,0) NumRows,
		@SearchFromDateFormatted SearchFromDate,
		@SearchThruDateFormatted SearchThruDate,
		@SessionTitle SessionTitle,
		isnull(s.FamilyID, -s.StudentID) as FamilyID,
		sa.FamilySortOrderByMaxStudentName as FamilySortOrderByMaxStudentName,
		s.StudentID, s.Lname, 
		vr.FullName as FullName,
		s.xStudentID,			
		case rtrim(ltrim(isnull(AddressName,'')))
			when '' then sa.AddressTitle
			else s.AddressName 
		end as AddressName,
		s.Street,s.City,s.State,s.Zip,
		vr.ReceivableID,
		dbo.GLformatdate(vr.Date) as Date,vr.TransactionType,vr.Notes,vr.ContractID,
		vr.TransactionMethod,vr.ReferenceNumber,
		vr.SignedAmount,vr.DB_CR_Code,vr.month,
		vr.PriorBal,isnull(vr.Balance,isnull(pb.PriorBalance,0.00)) as Balance,vr.SortOrder,
		case 
			when isnull(s.City,'') = '' or  isnull(s.State,'') = '' then isnull(s.City,'') + isnull(s.State,'')
			else s.City + ', ' +  s.State
		end + ' ' + s.Zip Family_CtStZp,

		@SchoolName as SchoolName,
		@SchoolStreet as SchoolStreet,
		case 
			when isnull(@SchoolCity,'') = '' or  isnull(@SchoolState,'') = '' then isnull(@SchoolCity,'') + isnull(@SchoolState,'')
			else @SchoolCity + ', ' +  @SchoolState
		end + ' ' + @SchoolZip as School_CtStZp,
		@SchoolPhone as SchoolPhone,
		@SchoolFax as SchoolFax,
		@SchoolEmailAddress as SchoolEmailAddress, 
		@TaxID as TaxID,
		isnull(pb.PriorBalance,0.00) PriorBalance,
		@BillingNote as BillingNote,
		@SchoolID as SchoolID, -- to support audit trail
		@EK as EK,
		getdate() as runTime -- to support audit trail
	from
	#ReceivablesFamily vr
		inner join 
	Students s
		on	isnull(s.FamilyID, -s.StudentID) = vr.FamilyOrTempID 
		and
		s.StudentID in (
			select
			min(StudentID) as MinStudentID 
			From Students
			Group By FamilyID
		)
		left join 
	@getStudentAddressTitle sa
		on s.StudentID = Sa.StudentID
		left join 
	#PriorBalances pb
		on pb.FamilyID = s.FamilyID
	left join (
		SELECT 
		s2.FamilyID,
		COUNT(*) NumRows
		FROM 
		Students s2
			left join 
		#ReceivablesFamily vr2	
				on isnull(s2.FamilyID, -s2.StudentID)=vr2.FamilyOrTempID
			left join 
		#PriorBalances pb2
			on pb2.FamilyID = s2.FamilyID				
		WHERE (pb2.PriorBalance>0 or vr2.ReceivableID is not null) and Date is not null
		GROUP BY s2.FamilyID 
	) RC
		on RC.FamilyID = s.FamilyID
	where 
	case
		when @studentFamilyFilter = 'All' then 1
		when @studentFamilyFilter = 'Family' and s.FamilyID = @FamilyID then 1
		when @studentFamilyFilter = 'Student' and s.FamilyID = @FamilyID then 1
		else 0
	end = 1
	--(@studentFamilyFilter <> 'Family' or s.FamilyID = @FamilyID)
	--and 
	--@studentFamilyFilter <> 'Student'
	and
	(pb.PriorBalance>0 or ReceivableID is not null) 
	order by /*Lname,FullName*/ FamilySortOrderByMaxStudentName,FamilyID,SortOrder


	drop table #ReceivablesFamily;
	drop table #PriorBalances;




END
GO
