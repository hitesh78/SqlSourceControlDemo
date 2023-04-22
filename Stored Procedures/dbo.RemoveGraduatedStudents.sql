SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE Procedure [dbo].[RemoveGraduatedStudents]
@GradeLevel nvarchar(20)
as


--Declare @FetchStudentID int

--Declare StudentCursor Cursor For
--Select StudentID
--from Students
--where GradeLevel = @GradeLevel

--Open  StudentCursor

--FETCH NEXT FROM StudentCursor INTO @FetchStudentID
--WHILE (@@FETCH_STATUS <> -1)
--BEGIN

--Update Students
--Set Active = 0, Status='Alumnus'
--Where StudentID = @FetchStudentID


-- FETCH NEXT FROM StudentCursor INTO @FetchStudentID

--End

--Close StudentCursor
--Deallocate StudentCursor

Update Students
Set Active = 0, Status='Alumnus'
Where StudentID in (Select StudentID
from Students
where GradeLevel = @GradeLevel)


GO
