SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vReportNameFilter] AS
SELECT s.StudentID as ID, --s.xStudentID, 
s.FullName + ' (' +cast(s.xStudentID as nvarchar(12))+ ')' as FullNameAndID
FROM vStudents_orig s
WHERE s.StudentID>-1
GO
