SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vMedications]
AS
SELECT 
	m.*,
	s.xStudentID, 
	s.FullName, 
	s.GradeLevel, 
	s.GradeLevX,
	s._Status as Status,
	s._Status as _Status_no_export
FROM Medications m
INNER JOIN vstudents s 
ON m.StudentID = s.StudentID

GO
