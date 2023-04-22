SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vReceivablesBillCat]
AS
SELECT     
ReceivableID, 
StudentID, 
Date, 
TransactionTypeID, 
ContractID, 
TransactionMethod, 
ReferenceNumber, 
Amount, 
DB_CR_Code,
SignedAmount, 
Notes, 
SessionID,
SessionTitle,
_SessionTitle,
TransactionType, 
AutomatedLunchFee,
month, 
PriorBal, 
PriorBal + SignedAmount AS Balance,
cast(SessionID as nvarchar(16))+'-'+cast(SortOrder as nvarchar(32)) as SortOrder,
ReceivableCategory, 
GLAccount 
FROM         
(SELECT     
r1.ReceivableID, 
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
r1.Notes, 
tt.Title AS TransactionType,
tt.ReceivableCategory,
tt.GLAccount,
case when tt.AttendanceCode is null then 0 else 1 end as AutomatedLunchFee,
r1.SortOrder, 
DATENAME(mm, r1.Date) + ' ' + DATENAME(year, r1.Date) AS month, 
ISNULL((SELECT     SUM(case when ttt.DB_CR_Code in ('Payment','Credit memo') then  -r2.Amount else r2.Amount end) AS Expr1
      FROM         dbo.Receivables AS r2
      inner join   TransactionTypes ttt on r2.TransactionTypeID = ttt.TransactionTypeID and ttt.SessionID = tt.SessionID
      WHERE     (SortOrder < r1.SortOrder) AND (StudentID = r1.StudentID) 
				and (ttt.ReceivableCategory = tt.ReceivableCategory)), 0) AS PriorBal
FROM dbo.Receivables AS r1 
INNER JOIN dbo.TransactionTypes AS tt ON r1.TransactionTypeID = tt.TransactionTypeID
inner join vSession s on s.SessionID = tt.SessionID
) AS x



GO
