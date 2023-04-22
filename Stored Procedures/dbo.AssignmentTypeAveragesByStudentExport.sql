SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 2016-10-26
-- Description:	Exports Data that include the assignmentType averages for each student
--
-- 3/20/2017 Duke: (Fresh Desk #46806)
-- Used by #1532.  Note sure if used by other schools.  
-- Updated to add xStudentID and to place in TFS source control...
-- 1/4/2018 Updated to display Teacer First, M  and Last Names -- Freddy
-- 3/15/2018 Updated to add new columns DOB and CoTeachers - Don 
-- ===============================Script ==============
CREATE Procedure [dbo].[AssignmentTypeAveragesByStudentExport]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Declare @TermID int = (Select top 1 TermID From Terms Where Status = 1)
	
	Select
	S.xStudentID, S.Lname, S.Fname, -- Fresh Desk #46805, Restore fields that were in 'original' (#77) sample sent by client
	convert(date,S.BirthDate) as BirthDate,
	S.Lname +  ' ' + ISNULL(S.Mname, '') + ' ' + S.Fname +
	case 
		when PATINDEX('% %',C.ClassTitle) = 0 then ''
		when isnumeric(SUBSTRING(C.ClassTitle, 1, PATINDEX('% %',C.ClassTitle)-1)) = 0 then ''
		else SUBSTRING(C.ClassTitle, 1, PATINDEX('% %',C.ClassTitle)-1)
	end as NameAndSection,
	ClassTitle,
	S.Lname + ' ' + ISNULL(S.Mname, '') + ' ' + S.Fname as StudentName,
	S.Lname + ' ' + ISNULL(S.Mname, '')  + S.Fname + ' ' + C.ClassTitle as NameAndClass,
	'ELL' as ELL,
	S.GradeLevel as GradeLevel,
	case 
		when PATINDEX('% %',C.ClassTitle) = 0 then ''
		when isnumeric(SUBSTRING(C.ClassTitle, 1, PATINDEX('% %',C.ClassTitle)-1)) = 0 then ''
		else SUBSTRING(C.ClassTitle, 1, PATINDEX('% %',C.ClassTitle)-1)
	end as Section,
	C.ClassTitle as Class,
	AT.TypeTitle as AssignmentType,
	count(G.GradeID) As NumberOfAssignments,
	convert(decimal(4,1),AVG(G.Grade)) AS AssignmentTypeAvg,
	'Curriculum' as Curriculum,
	'Core' as Core,
	T.TermTitle as Term,
	CS.StudentGrade as Grade, 
	case 
		when ISNULL(Tc.Mname, '') = '' then Tc.Lname + ', ' + Tc.Fname
		else Tc.Lname + ', ' + Tc.Fname + ' ' + Tc.Mname
	end as TeacherName,
	isnull(
	(

		SELECT Stuff(
		  (
				SELECT N'' + 
				case 
					when ROW_NUMBER() OVER(ORDER BY TrC.TCID ASC) != 1 then ''
					when ISNULL(Tr.Mname, '') = '' then Tr.Lname + ', ' + Tr.Fname
					else Tr.Lname + ', ' + Tr.Fname + ' ' + Tr.Mname
				end
				From 
				TeachersClasses TrC
					inner join
				Teachers Tr
					on TrC.TeacherID = Tr.TeacherID
				Where
				TrC.TeacherID != Tc.TeacherID
				and
				TrC.ClassID = C.ClassID
				FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,0,N'')

	),'') as CoTeacher1,
	isnull(
	(

		SELECT Stuff(
		  (
				SELECT N'' + 
				case 
					when ROW_NUMBER() OVER(ORDER BY TrC.TCID ASC) != 2 then ''
					when ISNULL(Tr.Mname, '') = '' then Tr.Lname + ', ' + Tr.Fname
					else Tr.Lname + ', ' + Tr.Fname + ' ' + Tr.Mname
				end
				From 
				TeachersClasses TrC
					inner join
				Teachers Tr
					on TrC.TeacherID = Tr.TeacherID
				Where
				TrC.TeacherID != Tc.TeacherID
				and
				TrC.ClassID = C.ClassID
				FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,0,N'')

	),'') as CoTeacher2,
	isnull(
	(

		SELECT Stuff(
		  (
				SELECT N'' + 
				case 
					when ROW_NUMBER() OVER(ORDER BY TrC.TCID ASC) != 3 then ''
					when ISNULL(Tr.Mname, '') = '' then Tr.Lname + ', ' + Tr.Fname
					else Tr.Lname + ', ' + Tr.Fname + ' ' + Tr.Mname
				end
				From 
				TeachersClasses TrC
					inner join
				Teachers Tr
					on TrC.TeacherID = Tr.TeacherID
				Where
				TrC.TeacherID != Tc.TeacherID
				and
				TrC.ClassID = C.ClassID
				FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,0,N'')

	),'') as CoTeacher3,
	isnull(
	(

		SELECT Stuff(
		  (
				SELECT N'' + 
				case 
					when ROW_NUMBER() OVER(ORDER BY TrC.TCID ASC) != 4 then ''
					when ISNULL(Tr.Mname, '') = '' then Tr.Lname + ', ' + Tr.Fname
					else Tr.Lname + ', ' + Tr.Fname + ' ' + Tr.Mname
				end
				From 
				TeachersClasses TrC
					inner join
				Teachers Tr
					on TrC.TeacherID = Tr.TeacherID
				Where
				TrC.TeacherID != Tc.TeacherID
				and
				TrC.ClassID = C.ClassID
				FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,0,N'')

	),'') as CoTeacher4,
	isnull(
	(

		SELECT Stuff(
		  (
				SELECT N'' + 
				case 
					when ROW_NUMBER() OVER(ORDER BY TrC.TCID ASC) != 5 then ''
					when ISNULL(Tr.Mname, '') = '' then Tr.Lname + ', ' + Tr.Fname
					else Tr.Lname + ', ' + Tr.Fname + ' ' + Tr.Mname
				end
				From 
				TeachersClasses TrC
					inner join
				Teachers Tr
					on TrC.TeacherID = Tr.TeacherID
				Where
				TrC.TeacherID != Tc.TeacherID
				and
				TrC.ClassID = C.ClassID
				FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,0,N'')

	),'') as CoTeacher5
	From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
		inner join
	Classes C
		on C.ClassID = CS.ClassID
				
		inner join
	Terms T
		on T.TermID = C.TermID
		inner join
	Grades G
		on G.CSID = CS.CSID
		inner join
	Assignments A
		on A.AssignmentID = G.AssignmentID
		inner join
	AssignmentType AT
		on A.TypeID = AT.TypeID
		inner join
	Teachers Tc
		 on C.TeacherID = Tc.TeacherID
	Where
	T.TermID = @TermID
	and
	C.ClassTypeID in (1,8)
	and 
	G.Grade is not null
	Group By S.BirthDate, S.Lname, S.Mname, S.Fname, S.xStudentID, S.GradeLevel, C.ClassID, C.ClassTitle, Tc.TeacherID, Tc.Lname,Tc.Mname ,Tc.Fname, AT.TypeTitle, T.TermTitle, CS.StudentGrade, CS.CSID
	Order By NameAndSection, Class, AT.TypeTitle

END



GO
