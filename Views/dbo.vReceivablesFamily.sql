SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vReceivablesFamily]
AS
SELECT     
ReceivableID, 
x.FamilyOrTempID,
x.StudentID, 
x.Date, 
x.TransactionTypeID, 
x.ContractID, 
x.TransactionMethod, 
x.ReferenceNumber, 
x.Amount, 
x.DB_CR_Code,
x.SignedAmount, 
x.Notes, 
x.SessionID,
x.SessionTitle,
x._SessionTitle,
x.TransactionType, 
x.AutomatedLunchFee,
x.month, 
x.PriorBal, 
x.PriorBal + SignedAmount AS Balance,
s.glname as StudentName,
cast(x.SessionID as nvarchar(16))+'-'+cast(x.SortOrder as nvarchar(32)) as SortOrder,
inUseLock
FROM         
(SELECT     
r1.ReceivableID, 
r1.FamilyOrTempID,
r1.StudentID, 
r1.Date, 
r1.TransactionTypeID, 
r1.ContractID, 
r1.TransactionMethod, 
r1.ReferenceNumber, 
tt.DB_CR_Code, 
s.SessionID,
s.Title as SessionTitle,
s._Title as _SessionTitle,
r1.Amount, 
(case when tt.DB_CR_Code in ('Payment','Credit memo') then  -r1.Amount else r1.Amount end) as SignedAmount, 
cast(r1.Notes as nvarchar(max)) as Notes, 
tt.Title AS TransactionType,
case when tt.AttendanceCode is null then 0 else 1 end as AutomatedLunchFee,
r1.SortOrder, 
DATENAME(mm, r1.Date) + ' ' + DATENAME(year, r1.Date) AS month, 
ISNULL((SELECT     SUM(case when ttt.DB_CR_Code in ('Payment','Credit memo') then  -r2.Amount else r2.Amount end) AS Expr1
      FROM         dbo.ReceivablesFamily AS r2
      inner join   TransactionTypes ttt on r2.TransactionTypeID = ttt.TransactionTypeID and ttt.SessionID = tt.SessionID
      WHERE     (SortOrder < r1.SortOrder) AND (FamilyOrTempID = r1.FamilyOrTempID)), 0) AS PriorBal,

case when tt.balanceTransferType=1 or tt.AttendanceCode is not null
	or isnull((select Status from InvoicePeriods ip  -- (not a performance hit if inUseLock is not referenced)
		where r1.date between ip.FromDate and ip.ThruDate and ip.SessionID=s.SessionID),'') = 'Closed'
		and (select EnableReceivablesEditsToClosedPeriods from settings) <> 1
	then 'Yes' else 'No' end as inUseLock 

FROM dbo.ReceivablesFamily AS r1 
INNER JOIN dbo.TransactionTypes AS tt ON r1.TransactionTypeID = tt.TransactionTypeID
inner join vSession s on s.SessionID = tt.SessionID
) AS x
inner join Students s 
on x.StudentID = s.StudentID

UNION
-- TODO: We may want to base reports on another view to avoid incurring this overhead...
SELECT     
-1 as ReceivableID, 
null as FamilyOrTempID,
null as StudentID, 
null as Date, 
null as TransactionTypeID, 
null as ContractID, 
'' as TransactionMethod, 
'' as ReferenceNumber, 
null as Amount, 
null as DB_CR_Code,
null as SignedAmount, 
null as Notes, 
-- TODO: We may want to base reports on another view to avoid incurring this overhead...
(Select SessionID from vSession where _Title like '%*') as SessionID,
(Select Title from vSession where _Title like '%*') as  SessionTitle,
(Select _Title from vSession where _Title like '%*') as  _SessionTitle,
--
null as TransactionType, 
null as AutomatedLunchFee,
null as month, 
null as PriorBal, 
null AS Balance,
null as StudentName,
null as SortOrder,
'No' as inUseLock

GO
