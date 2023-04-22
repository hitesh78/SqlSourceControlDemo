SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vContractWarnings] as
select 
	st.StudentID,
	c.ContractID,
	c.ContractID*100 + c.LineNum as ContractID_Line,

	st.xStudentID, 
	st.FamilyID,
	st.fullname,
	s._title as Session, c.date as ContractDate, c.Date, ip.Status BillingPeriodStatus, 
	tt.Title TransactionType, tt.DB_CR_Code as DebitCredit, amnt as Amount,  
	case when ip.Status is null
	then
		'Session/date/billing period discrepancy'
	else
		case when r.ContractID is null 
		then 
			case when c.date > getdate() then
				'Pending'
			else
				'Not Posted' 
			end
		else 
			'Posting discrepancy (check type and amount)' 
		end
	end WarningType,
	descr as Description
from ContractNormalized c
inner join vstudents st
on st.studentid = c.studentid
left join InvoicePeriods ip
	on c.date between ip.FromDate and ip.ThruDate -- dbo.MinDate(getdate(),ip.ThruDate)
		and c.SessionID = ip.SessionID
inner join TransactionTypes tt
on c.TransactionTypeID = tt.TransactionTypeID
inner join vSession s
on tt.SessionID = s.SessionID
	and s.Status = 'Open'
left outer join Receivables r
on c.ContractID = r.ContractID
	and c.Date = r.Date
where ( ( r.ContractID is null and isnull(c.amnt,0)>0 )	
		or c.StudentID <> r.StudentID -- should never occur
		or c.TransactionTypeID <> r.TransactionTypeID
		or c.amnt <> r.amount )

GO
