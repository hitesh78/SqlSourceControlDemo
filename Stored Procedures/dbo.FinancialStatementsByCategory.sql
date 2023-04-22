SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 3/18/2021
-- Description:	The is for the Statements By Category Report under Financial > Reports > "Stmts by Category"
-- =============================================
CREATE PROCEDURE [dbo].[FinancialStatementsByCategory]
@Range nvarchar(50),
@PeriodFrom int,
@PeriodThru int,
@DateFrom nvarchar(50),
@DateThru nvarchar(50),
@StudentFamilyFilter nvarchar(50),
@theFamilyID int,
@StudentID int,
@billCategory nvarchar(50),
@SessionID int
AS
BEGIN


	declare @SearchFromDate date = (
		case      
			when @Range = 'Periods' then (select FromDate from InvoicePeriods where InvoicePeriodID = @PeriodFrom)     
			when @Range = 'Dates' and @DateFrom != '' then dbo.toDBDate(@DateFrom)     
			else null     
		end
	);     

	declare @SearchThruDate date = (
		case      
			when @Range = 'Periods' and @PeriodThru is null then (select ThruDate From InvoicePeriods where InvoicePeriodID = @PeriodFrom)     
			when @Range = 'Periods' then (select ThruDate from InvoicePeriods where InvoicePeriodID = @PeriodThru)     
			when @Range = 'Dates' and @DateThru is not null then dbo.toDBDate(@DateThru)     
			else null     
		end
	);     

	if @SearchThruDate is null set @SearchThruDate = @SearchFromDate;       

	declare @SearchFromDateFormatted char(10) = isnull(dbo.GLformatdate(@SearchFromDate),'');   
	declare @SearchThruDateFormatted char(10) = isnull(dbo.GLformatdate(@SearchThruDate),'');     
	declare @SessionTitle varchar(50) = (select Title from Session where SessionID = @SessionID);    
	declare @FamilyID int = case 
								when @StudentFamilyFilter = 'Family' then @theFamilyID      
								else (select FamilyID from Students where StudentID = @StudentID)        
							end;   
						
	if @SearchFromDate<=@SearchThruDate  
	begin    
 
		select * into #getStudentAddressTitle from dbo.getStudentAddressTitle();

		Declare
		@SchoolName nvarchar(100),
		@SchoolStreet nvarchar(100),
		@School_CtStZp nvarchar(30),
		@SchoolPhone nvarchar(50),
		@SchoolFax nvarchar(50),
		@SchoolEmailAddress nvarchar(50),
		@TaxID nvarchar(30)

		Select
		@SchoolName = SchoolName,
		@SchoolStreet = SchoolStreet,
		@School_CtStZp = dbo.ConcatWithDelimiter(SchoolCity,SchoolState,', ') +' '+ SchoolZip,
		@SchoolPhone = SchoolPhone,
		@SchoolFax = SchoolFax,
		@SchoolEmailAddress = SchoolEmailAddress,
		@TaxID = TaxID
		From Settings
		Where
		SettingID = 1;


		Create table #PB (StudentID int, SessionID int, ReceivableCategory nvarchar(50), theDate date, SortOrder nvarchar(50), PBal money)
		CREATE CLUSTERED INDEX cx_PB ON #PB (StudentID, SessionID, ReceivableCategory, theDate, SortOrder);

		insert into #PB
		SELECT
		StudentID,
		ttt.SessionID,
		ttt.ReceivableCategory,
		Date,
		SortOrder,
		SUM(case when ttt.DB_CR_Code in ('Payment','Credit memo') then  -r2.Amount else r2.Amount end)
		FROM         
		dbo.Receivables AS r2
			inner join
		TransactionTypes ttt 
			on	r2.TransactionTypeID = ttt.TransactionTypeID 
		Group By 
		StudentID, ttt.SessionID, ttt.ReceivableCategory, Date, SortOrder

	
		select distinct    
		@SearchFromDateFormatted SearchFromDate,    
		@SearchThruDateFormatted SearchThruDate,    
		@SessionTitle SessionTitle,    
		StudentID,
		Lname,
		FullName,
		xStudentID,
		AddressName,
		Street,
		City,
		State,
		Zip,    
		ReceivableID,    
		dbo.GLformatdate(Date) Date,    
		TransactionType,
		cast(Notes as varchar(MAX)) as Notes,    
		ContractID,
		TransactionMethod,
		ReferenceNumber,
		SignedAmount,
		DB_CR_Code,    
		month,
		PriorBal,
		isnull(Balance,PriorBalance) as Balance,    
		SortOrder,
		Family_CtStZp,    
		@SchoolName as SchoolName,
		@SchoolStreet as SchoolStreet,
		@School_CtStZp as School_CtStZp,
		@SchoolPhone as SchoolPhone,
		@SchoolFax as SchoolFax,
		@SchoolEmailAddress as SchoolEmailAddress, 
		@TaxID as TaxID,      
		PriorBalance,
		CAST(BillingNote as varchar(MAX)) as BillingNote,    
		ReceivableCategory   
		from    
		(    
			select 
			x.*,      
			r.ReceivableID,
			r.Date,
			tt.Title AS TransactionType,
			r.Notes,
			r.ContractID,
			r.TransactionMethod,
			r.ReferenceNumber,
			(case when tt.DB_CR_Code in ('Payment','Credit memo') then  -r.Amount else r.Amount end) as SignedAmount,
			tt.DB_CR_Code,
			DATENAME(mm, r.Date) + ' ' + DATENAME(year, r.Date) AS month,
			(
						SELECT     
						SUM(PBal)
						FROM     
						#PB
						WHERE     
						StudentID = x.StudentID
						and
						SessionID = tt.SessionID
						and
						ReceivableCategory = tt.ReceivableCategory
						and
						SortOrder < r.SortOrder
			) AS PriorBal,
			ISNULL(
					(
						SELECT     
						SUM(PBal)
						FROM     
						#PB
						WHERE     
						SessionID = @SessionID
						and
						StudentID = x.StudentID
						and
						ReceivableCategory = tt.ReceivableCategory
						and
						SortOrder < r.SortOrder
					)
					, 0
			) + (case when tt.DB_CR_Code in ('Payment','Credit memo') then  -r.Amount else r.Amount end)
				as Balance,
			cast(tt.SessionID as nvarchar(16))+'-'+cast(r.SortOrder as nvarchar(32)) as SortOrder,
			dbo.ConcatWithDelimiter(City,State,', ') +' '+ Zip Family_CtStZp,     
			(
						SELECT     
						SUM(PBal)
						FROM     
						#PB
						WHERE     
						SessionID = @SessionID
						and
						StudentID = x.StudentID
						and
						ReceivableCategory = x.ReceivableCategory
						and
						theDate < @SearchFromDate
			) AS PriorBalance,      
			case 
				when datediff(day,@SearchFromDate,@SearchThruDate) > 35 then '' 
				else	(
							Select BillingNote 
							from InvoicePeriods ip        
							where 
							ip.FromDate = (
												Select MAX(FromDate) 
												from InvoicePeriods ip2 
												where 
												ip2.FromDate <= @SearchFromDate            -- was: ip2.ThruDate <= @SearchThruDate Fresh Desk #68327, Wrike #SearchThruDate
												and 
												ip2.SessionID = @SessionID          
											) 
							and 
							ip.SessionID = @SessionID       
						)       
			end BillingNote        
			From 
			(     
				select distinct      
				s.StudentID, 
				s.Lname,       
				s.Fname+' '+ltrim(isnull(s.Mname,'')+' '+s.Lname) as FullName,      
				s.xStudentID,            
				case rtrim(ltrim(isnull(AddressName,''))) when '' then sa.AddressTitle else s.AddressName end as AddressName,            
				s.Street,
				s.City,
				s.State,
				s.Zip,      
				i.InvoicePeriodID, 
				i.FromDate, 
				i.ThruDate,      
				c.ReceivableCategory      
				from       
				Students s     
					inner join 
				#getStudentAddressTitle sa      
					on s.StudentID = Sa.StudentID       
					cross join 
				InvoicePeriods i      
					cross join 
				(       -- consider index on ReceivableCategory when we use this discrete table       
					select distinct ReceivableCategory       
					from TransactionTypes      
					where 
					SessionID=@SessionID      
					and 
					(@billCategory='' or @billCategory=ReceivableCategory) -- optional, but might speed query      
				) c     
				where 
				i.SessionID = @SessionID      
				and 
				(@StudentFamilyFilter <> 'Student' or s.StudentID = @StudentID)       
				and 
				(@StudentFamilyFilter <> 'Family' or s.FamilyID = @FamilyID)
			) x    
				left join 
			Receivables r
				on (	
						r.Date is null /* show balance forward even if not transactions */
						or 
						r.Date between @SearchFromDate and @SearchThruDate
					)
					and x.StudentID=r.StudentID 
					and r.Date between x.FromDate and x.ThruDate
					and r.ReceivableID<>-1 -- filter out new row default used in UI
				left join 
			TransactionTypes tt 
				on	tt.SessionID = @SessionID      
					and 
					r.TransactionTypeID = tt.TransactionTypeID 
					and 
					tt.ReceivableCategory = x.ReceivableCategory  				     
			where   
			(@billCategory='' or @billCategory=x.ReceivableCategory)
			and  
			(r.Date is null or tt.SessionID is not null)	/* if transaction then make sure we found a transaction in current session! */    
		) y   
		where 
		(PriorBalance>0 or ReceivableID is not null) 
		order by Lname, FullName, ReceivableCategory, SortOrder  
	end  

END

GO
