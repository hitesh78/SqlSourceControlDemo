SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vContractReport] as
select c.StudentID,c.ContractID,
s.xStudentID, s.FamilyID,
s.fullname, s.GradeLevX, s._Status,
se._Title Session, pp.Title PaymentPlan, tt.Title TransactionType, tt.ReceivableCategory BillingCategory,
c.ContractDate,c.Date1 FirstInstallment,
(case when tt.DB_CR_Code in ('Payment','Credit memo') then  -c.TotalAmount else c.TotalAmount end) as TotalAmount
from contract c
inner join PaymentPlans pp
on c.PaymentPlanID = pp.PaymentPlanID
inner join vSession se
on c.SessionID = se.SessionID
inner join TransactionTypes tt 
on tt.TransactionTypeID = c.TransactionTypeID
inner join vstudents s
on s.studentid = c.studentid

GO
