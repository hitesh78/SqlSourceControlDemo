SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vPPDtestsLatest] as
select * from vPPDtests
where CONVERT(nvarchar(20),isnull(ppd_given,ppd_read),21)+';'+CAST(studentID as nvarchar(20)) in
(Select MAX(CONVERT(nvarchar(20),isnull(ppd_given,ppd_read),21)+';'+CAST(studentID as nvarchar(20))) x
from vPPDtests group by StudentID)
GO
