SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vReceivables]
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
inUseLock
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
cast(r1.Notes as nvarchar(MAX)) as Notes, 
tt.Title AS TransactionType,
case when tt.AttendanceCode is null then 0 else 1 end as AutomatedLunchFee,
r1.SortOrder, 
DATENAME(mm, r1.Date) + ' ' + DATENAME(year, r1.Date) AS month, 
ISNULL((SELECT     SUM(case when ttt.DB_CR_Code in ('Payment','Credit memo') then  -r2.Amount else r2.Amount end) AS Expr1
      FROM         dbo.Receivables AS r2
      inner join   TransactionTypes ttt on r2.TransactionTypeID = ttt.TransactionTypeID and ttt.SessionID = tt.SessionID
      WHERE     (SortOrder < r1.SortOrder) AND (StudentID = r1.StudentID)), 0) AS PriorBal,

case when tt.balanceTransferType=1 or tt.AttendanceCode is not null
	or isnull((select Status from InvoicePeriods ip  -- (not a performance hit if inUseLock is not referenced)
		where r1.date between ip.FromDate and ip.ThruDate and ip.SessionID=s.SessionID),'') = 'Closed'
		and (select EnableReceivablesEditsToClosedPeriods from settings) <> 1
	then 'Yes' else 'No' end as inUseLock 

FROM dbo.Receivables AS r1 
INNER JOIN dbo.TransactionTypes AS tt ON r1.TransactionTypeID = tt.TransactionTypeID
inner join vSession s on s.SessionID = tt.SessionID
) AS x

UNION
-- TODO: We may want to base reports on another view to avoid incurring this overhead...
SELECT     
-1 as ReceivableID, 
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
null as SortOrder,
'No' as inUseLock


GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[29] 4[20] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "x"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2190
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vReceivables', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vReceivables', NULL, NULL
GO
