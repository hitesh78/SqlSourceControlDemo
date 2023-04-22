SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vLunchWarnings] as 
with Pending as (
	select 
		lc.SessionID,
		lc.TransactionTypeID,
		ip.InvoicePeriodID,
		s._title SessionTitle,
		lc.StudentID, 
		ip.title BillingPeriod, 
		tt.title TransactionType,
		lc.Date, 
		lc.Amount 
	from LunchCharges lc
	inner join InvoicePeriods ip
	on ip.InvoicePeriodID = lc.InvoicePeriodID
	inner join TransactionTypes tt
	on lc.TransactionTypeID = tt.TransactionTypeID
	inner join vSession s
	on tt.SessionID = s.SessionID
		and s.Status = 'Open'
),
Posted as (
	select 
		tt.sessionid, 
		r.TransactionTypeID,
		ip.InvoicePeriodID,
		s._Title SessionTitle,
		r.StudentID,
		ip.Title BillingPeriod, 
		tt.title TransactionType,
		r.Date, 
		r.Amount
	from Receivables r
	inner join TransactionTypes tt
	on r.TransactionTypeID = tt.TransactionTypeID
	inner join vSession s
	on tt.SessionID = s.SessionID
		and s.Status = 'Open'
	left join InvoicePeriods ip
		on r.date between ip.FromDate and ip.ThruDate
			and tt.SessionID = ip.SessionID
	where tt.AttendanceCode is not null
), 
LunchPosting as (
	select 
		p1.Date p1date, p2.Date p2date,
		isnull(p1.Date,p2.Date) Date,
		isnull(p1.SessionTitle,p2.SessionTitle) SessionTitle,
		isnull(p1.StudentID,p2.StudentID) StudentID,
		isnull(p1.BillingPeriod,p2.BillingPeriod) BillingPeriod,
		isnull(p1.TransactionType,p2.TransactionType) TransactionType, 
		p1.Amount PendingAmount,
		p2.Amount PostedAmount
	from Pending p1
	full outer join Posted p2
	on p1.SessionID = p2.SessionID
	and p1.TransactionTypeID = p2.TransactionTypeID
	and p1.InvoicePeriodID = p2.InvoicePeriodID
	and p1.StudentID = p2.StudentID
	and p1.Date = p2.Date
)
select 
	ROW_NUMBER() OVER (ORDER BY lp.Date,s.StudentID,lp.TransactionType ASC) row_number,
	s.xStudentID, 
	s.StudentID, 
	s.FullName, 
	s.GradeLevX,
	lp.Date, 
	lp.SessionTitle Session, 
	lp.BillingPeriod Period, 
	lp.TransactionType, 
	lp.PendingAmount ComputedAmount, 
	lp.PostedAmount PostedAmount,
	case when p2date is null then 'Not posted' else
		case when p1date is null 
			then 'Removed from attendance after posting' 
			else 'Amount discrepancy' 
		end  
	end as ExceptionMessage
from LunchPosting lp
inner join vStudents s
on lp.StudentID = s.StudentID
where 
	Date >= (select min(Attendance.ClassDate) Date from Attendance) 
	and ( p1date is null or p2date is null 
			or isnull(PendingAmount,0)<>isnull(PostedAmount,0) )

GO
