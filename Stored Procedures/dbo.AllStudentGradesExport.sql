SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Don Puls. Kirk Wurffell>
-- Create date: <03-5-2020>
-- Description:	<Paid Custom Update for School #2359>
-- https://gradelink.atlassian.net/browse/GC-4732
-- =============================================
CREATE PROCEDURE [dbo].[AllStudentGradesExport] 

AS
BEGIN

Declare @TermID int = (
Select top 1 TermID
From Terms
Where
TermID not in (Select ParentTermID From Terms)
and
Status = 1
Order By EndDate desc
)

Declare @theTermDate date = (Select StartDate From Terms Where TermID = @TermID)
Declare @SchoolYear nvarchar(10) =
(
Select
(
Select top 1 convert(nchar(4),datepart(year,StartDate))
From
dbo.GetYearTermIDsByDate(@theTermDate) T1
inner join
Terms T
on T.TermID = T1.TermID
Order By T.StartDate
)
+ '-' +
(
Select top 1 convert(nchar(4),datepart(year,EndDate))
From
dbo.GetYearTermIDsByDate(@theTermDate) T1
inner join
Terms T
on T.TermID = T1.TermID
Order By T.EndDate desc
)
)

Select
@SchoolYear as SchoolYear,
Tms.TermTitle,
C.ClassTitle,
T.glname as Teacher,
S.xStudentID,
S.glname as Student,
S.GradeLevel,
dbo.TrimZeros(CS.StudentGrade) as PercentageGrade,
dbo.GetLetterGrade(CS.ClassID, StudentGrade) as LetterGrade
From
Terms Tms
inner join
Classes C
on Tms.TermID = C.TermID
inner join
Teachers T
on C.TeacherID = T.TeacherID
inner join
ClassesStudents CS
on CS.ClassID = C.ClassID
inner join
Students S
on S.StudentID = CS.StudentID
Where
C.ClassTypeID in (1,8)
and
Tms.TermID = @TermID
Order By ClassTitle, T.glname, S.glname

END
GO
