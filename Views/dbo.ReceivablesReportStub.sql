SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[ReceivablesReportStub]
as
select
--1 as ReceivablesReportStubID,
'103' as ReceivablesReportSelection,
(Select SessionID from vSession where _Title like '%*') as  SessionID,
(Select max(InvoicePeriodID) from InvoicePeriods 
	where cast(GETDATE() as date) -- remove time from date for proper endpoint matching since the dates we start have no time
			between FromDate and ThruDate) as PeriodFromID,
null as PeriodThruID,
'Periods' as ReceivablesReportsDateRange,
StudentID,
FamilyID
from Students
union 
select
'103' as ReceivablesReportSelection,
(Select SessionID from vSession where _Title like '%*') as  SessionID,
(Select max(InvoicePeriodID) from InvoicePeriods 
	where cast(GETDATE() as date) -- remove time from date for proper endpoint matching since the dates we start have no time
			between FromDate and ThruDate) as PeriodFromID,
null as PeriodThruID,
'Periods' as ReceivablesReportsDateRange,
-1 as StudentID,
-1 as FamilyID
from Students

GO
