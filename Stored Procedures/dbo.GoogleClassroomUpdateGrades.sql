SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 1/11/2021
-- Description:	This updated grades for Google Classroom assignments. It is called from APIGoogleClassroom.cs
-- =============================================
CREATE PROCEDURE [dbo].[GoogleClassroomUpdateGrades]
	@gcTableData gcTableType ReadOnly
AS
BEGIN
	UPDATE 
		Grades
	SET
		Grade = CASE 
					WHEN gcT.Completed = 1 THEN NULL
					WHEN isnull(gcT.PointsEarned,0) = 0  THEN 0
					WHEN isnull(a.OutOf,0) = 0  THEN 0
					ELSE (isnull(gcT.PointsEarned,0) / a.OutOf) * 100
				END,
		LetterGrade = 'NA',
		OutOfCorrect = gcT.PointsEarned,
		completed = gcT.Completed
	FROM 
	@gcTableData gcT
		inner join
	Accounts ac
		on ac.GoogleUserId = gcT.glUserID
		inner join	
	Students s
		on s.AccountID = ac.AccountID
		inner join
	ClassesStudents cs
		on cs.ClassID = gcT.ClassID and cs.StudentID = s.StudentID
		inner join 
	Assignments a
		on a.gcCourseWorkID = gcT.gcCourseWorkID
		inner join
	Grades g
		on g.CSID = CS.CSID and g.AssignmentID = a.AssignmentID
END
GO
