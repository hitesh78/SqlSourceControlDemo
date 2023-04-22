SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vContract] as
select c.ContractID, c.SessionID, c.PaymentPlanID, c.StudentID, c.ContractDate, c.TransactionTypeID, c.TotalAmount, 
	s.Title SessionTitle, p.Title PaymentPlan, t.Title TransactionType, xx.*
from
(
	select 
		x.ContractID xContractID,
		
		MAX(case when x.NewLineNum=1 then x.date else null end) date1,
		MAX(case when x.NewLineNum=1 then x.descr else null end) desc1,
		MAX(case when x.NewLineNum=1 then x.amnt else null end) amount1,
		MAX(case when x.NewLineNum=1 then x.BillStat else null end) BillStat1,
		MAX(case when x.NewLineNum=1 then x.BillError else null end) BillError1,
		
		MAX(case when x.NewLineNum=2 then x.date else null end) date2,
		MAX(case when x.NewLineNum=2 then x.descr else null end) desc2,
		MAX(case when x.NewLineNum=2 then x.amnt else null end) amount2,
		MAX(case when x.NewLineNum=2 then x.BillStat else null end) BillStat2,
		MAX(case when x.NewLineNum=2 then x.BillError else null end) BillError2,
		
		MAX(case when x.NewLineNum=3 then x.date else null end) date3,
		MAX(case when x.NewLineNum=3 then x.descr else null end) desc3,
		MAX(case when x.NewLineNum=3 then x.amnt else null end) amount3,
		MAX(case when x.NewLineNum=3 then x.BillStat else null end) BillStat3,
		MAX(case when x.NewLineNum=3 then x.BillError else null end) BillError3,
		
		MAX(case when x.NewLineNum=4 then x.date else null end) date4,
		MAX(case when x.NewLineNum=4 then x.descr else null end) desc4,
		MAX(case when x.NewLineNum=4 then x.amnt else null end) amount4,
		MAX(case when x.NewLineNum=4 then x.BillStat else null end) BillStat4,
		MAX(case when x.NewLineNum=4 then x.BillError else null end) BillError4,
		
		MAX(case when x.NewLineNum=5 then x.date else null end) date5,
		MAX(case when x.NewLineNum=5 then x.descr else null end) desc5,
		MAX(case when x.NewLineNum=5 then x.amnt else null end) amount5,
		MAX(case when x.NewLineNum=5 then x.BillStat else null end) BillStat5,
		MAX(case when x.NewLineNum=5 then x.BillError else null end) BillError5,
		
		MAX(case when x.NewLineNum=6 then x.date else null end) date6,
		MAX(case when x.NewLineNum=6 then x.descr else null end) desc6,
		MAX(case when x.NewLineNum=6 then x.amnt else null end) amount6,
		MAX(case when x.NewLineNum=6 then x.BillStat else null end) BillStat6,
		MAX(case when x.NewLineNum=6 then x.BillError else null end) BillError6,
		
		MAX(case when x.NewLineNum=7 then x.date else null end) date7,
		MAX(case when x.NewLineNum=7 then x.descr else null end) desc7,
		MAX(case when x.NewLineNum=7 then x.amnt else null end) amount7,
		MAX(case when x.NewLineNum=7 then x.BillStat else null end) BillStat7,
		MAX(case when x.NewLineNum=7 then x.BillError else null end) BillError7,
		
		MAX(case when x.NewLineNum=8 then x.date else null end) date8,
		MAX(case when x.NewLineNum=8 then x.descr else null end) desc8,
		MAX(case when x.NewLineNum=8 then x.amnt else null end) amount8,
		MAX(case when x.NewLineNum=8 then x.BillStat else null end) BillStat8,
		MAX(case when x.NewLineNum=8 then x.BillError else null end) BillError8,
		
		MAX(case when x.NewLineNum=9 then x.date else null end) date9,
		MAX(case when x.NewLineNum=9 then x.descr else null end) desc9,
		MAX(case when x.NewLineNum=9 then x.amnt else null end) amount9,
		MAX(case when x.NewLineNum=9 then x.BillStat else null end) BillStat9,
		MAX(case when x.NewLineNum=9 then x.BillError else null end) BillError9,
		
		MAX(case when x.NewLineNum=10 then x.date else null end) date10,
		MAX(case when x.NewLineNum=10 then x.descr else null end) desc10,
		MAX(case when x.NewLineNum=10 then x.amnt else null end) amount10,
		MAX(case when x.NewLineNum=10 then x.BillStat else null end) BillStat10,
		MAX(case when x.NewLineNum=10 then x.BillError else null end) BillError10,
		
		MAX(case when x.NewLineNum=11 then x.date else null end) date11,
		MAX(case when x.NewLineNum=11 then x.descr else null end) desc11,
		MAX(case when x.NewLineNum=11 then x.amnt else null end) amount11,
		MAX(case when x.NewLineNum=11 then x.BillStat else null end) BillStat11,
		MAX(case when x.NewLineNum=11 then x.BillError else null end) BillError11,
		
		MAX(case when x.NewLineNum=12 then x.date else null end) date12,
		MAX(case when x.NewLineNum=12 then x.descr else null end) desc12,
		MAX(case when x.NewLineNum=12 then x.amnt else null end) amount12,
		MAX(case when x.NewLineNum=12 then x.BillStat else null end) BillStat12,
		MAX(case when x.NewLineNum=12 then x.BillError else null end) BillError12,
		
		case when 
			(select max(1) from Receivables where ContractID=x.ContractID)
			is null then 'No' else 'Yes' end as inUseLock
			
	from 
	(
		select 
			c.*,
			(Select COUNT(*) from contractnormalized cn 
				where (cn.date < c.date or (cn.date=c.date and cn.LineNum<c.LineNum)) 
					and cn.ContractID = c.ContractID) + 1 as NewLineNum,
			r.ReceivableID,
			ip.InvoicePeriodID,
			isnull(ip.Status,'') as BillStat,
			case 
				when c.TransactionTypeID != r.TransactionTypeID 
					then 'Error in Transaction Type (posted type: ' 
						+ (Select Title From TransactionTypes where TransactionTypeID=r.TransactionTypeID)
				when c.amnt != r.Amount 
					then 'Error in Amount (posted amount: $'+CAST(r.Amount as nvarchar(16))+')'
				else ''
			end as BillError
		from contractnormalized c
		left join Receivables r 
		on c.ContractID = r.ContractID and c.date = r.date
		left join InvoicePeriods ip
		on ip.SessionID = c.SessionID
		and r.Date between ip.FromDate and ip.ThruDate
	) x
	group by x.ContractID
) xx
inner join Contract c on xContractID = c.ContractID
left join PaymentPlans p on p.PaymentPlanID = c.PaymentPlanID
inner join Session s on s.SessionID = c.SessionID
inner join TransactionTypes t on t.TransactionTypeID = c.TransactionTypeID
union all 
select 
	-1 as ContractID,
	(Select SessionID from vSession where _Title like '%*') as SessionID,
	null PaymentPlanID,
	null StudentID, 
	getdate() ContractDate, 
	null TransactionTypeID, 
	null TotalAmount, 
	(Select Title from vSession where _Title like '%*') as  SessionTitle,
	null PaymentPlan, 
	null TransactionType, 
	null xContractID, 
	null date1, null desc1, null amount1, null BillStat1, null BillError1, 
	null date2, null desc2, null amount2, null BillStat2, null BillError2, 
	null date3, null desc3, null amount3, null BillStat3, null BillError3, null 
	date4, null desc4, null amount4, null BillStat4, null BillError4, null 
	date5, null desc5, null amount5, null BillStat5, null BillError5, null 
	date6, null desc6, null amount6, null BillStat6, null BillError6, null 
	date7, null desc7, null amount7, null BillStat7, null BillError7, null 
	date8, null desc8, null amount8, null BillStat8, null BillError8, null 
	date9, null desc9, null amount9, null BillStat9, null BillError9, null 
	date10, null desc10, null amount10, null BillStat10, null BillError10, null 
	date11, null desc11, null amount11, null BillStat11, null BillError11, null 
	date12, null desc12, null amount12, null BillStat12, null BillError12,
	'No' as inUseLock



GO
