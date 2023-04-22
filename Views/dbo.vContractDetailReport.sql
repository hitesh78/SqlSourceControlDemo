SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vContractDetailReport] as
select c.StudentID, cn.ContractID*100 + cn.LineNum as ContractID_Line,
cn.ContractID,
s.xStudentID, s.FamilyID,
s.fullname, s.GradeLevX, s._Status,
se._Title Session, pp.Title PaymentPlan, tt.Title TransactionType, tt.ReceivableCategory BillingCategory,
(case when tt.DB_CR_Code in ('Payment','Credit memo') then  -c.TotalAmount else c.TotalAmount end) as TotalAmount, 
cn.date, cn.descr, 
(case when tt.DB_CR_Code in ('Payment','Credit memo') then  -cn.amnt else cn.amnt end) as amnt
from contract c
inner join PaymentPlans pp
on c.PaymentPlanID = pp.PaymentPlanID
inner join vSession se
on c.SessionID = se.SessionID
inner join TransactionTypes tt 
on tt.TransactionTypeID = c.TransactionTypeID
inner join vstudents s
on s.studentid = c.studentid
inner join ContractNormalized cn
on c.ContractID = cn.ContractID


GO
