SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[PrintableGradesheet]
(
@ClassID int,
@Orientation nvarchar(10),
@BlankAssignmentsToAdd int,
@PrintIDs nvarchar(10),
@GradeStyle nvarchar(20),
@EK Decimal(15,15)
)
as

-- Student Data
Create Table #StudentNames
(
StudentID int,
StudentName nvarchar(100)
)

Create Table #StudentNames2
(
StudentID int,
StudentName nvarchar(100)
)

Insert Into #StudentNames
Select
	S.StudentID, 
	case
		when @PrintIDs = 'on' Then convert(nvarchar(50), S.xStudentID)
		else S.glname
	end as StudentName
From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
Where CS.ClassID = @ClassID
Order By S.glname


-- Student's Grade Data
Create Table #TheGrades
(
GradeID int,
StudentID int,
StudentName nvarchar(100),
Grade nvarchar(10),
DueDate datetime,
AssignmentID int
)

Create Table #TheGrades2
(
GradeID int,
StudentID int,
StudentName nvarchar(100),
Grade nvarchar(10),
DueDate datetime
)

Insert Into #TheGrades
Select
	G.GradeID,
	S.StudentID,
	S.glname,
	case
		when isnull(G.GradeCode,'') != '' and G.LowestGrade = 0 then G.GradeCode
		when isnull(G.GradeCode,'') != '' and G.LowestGrade = 1 then '#LG#' + G.GradeCode
		when G.LowestGrade = 1 then 
			case
				when @GradeStyle = 'Percentage' then '#LG#' + Convert(nvarchar(10),Convert(Int,Round(G.Grade,0))) + '%'
				when @GradeStyle = 'LetterGrade' then '#LG#' + dbo.GetLetterGrade(@ClassID, G.Grade)
				when @GradeStyle = 'Points' then '#LG#' + Convert(nvarchar(10),G.OutOfCorrect)
			end
		when A.OutOf = 0 and A.GradeStyle = 3 and @GradeStyle = 'Points' then dbo.TrimZeros(G.OutOfCorrect)
		when A.OutOf = 0 and A.GradeStyle = 3 then dbo.TrimZeros(G.OutOfCorrect) + 'pts'			
		else 
			case
				when @GradeStyle = 'Percentage' then Convert(nvarchar(10),Convert(Int,Round(G.Grade,0))) + '%'
				when @GradeStyle = 'LetterGrade' then dbo.GetLetterGrade(@ClassID, G.Grade)
				when @GradeStyle = 'Points' then Convert(nvarchar(10), G.OutOfCorrect)
			end
	end as TheGrade,
	A.DueDate,
	A.AssignmentID
From 
	Grades G
		inner join 
	ClassesStudents CS
		on G.CSID = CS.CSID
		inner join
	Assignments A
		on A.AssignmentID = G.AssignmentID
		inner join
	Students S
		on S.StudentID = CS.StudentID
Where CS.ClassID = @ClassID


-- Insert Blank Grades into #TheGrades Table
Declare @BlankGradesCount int
Set @BlankGradesCount = 0

While @BlankGradesCount < @BlankAssignmentsToAdd
Begin
	Insert into #TheGrades
	Select 
		-100 * CS.StudentID + @BlankGradesCount as GradeID,
		CS.StudentID,
		S.glName,
		null,
		'3000/01/01' as DueDate,
		-1 as AssignmentID
	From 	ClassesStudents CS
				inner join
			Students S
				on S.StudentID = CS.StudentID
	Where ClassID = @ClassID

	Set @BlankGradesCount = @BlankGradesCount + 1
End



-- Insert Final Grades into #TheGrades Table
Insert into #TheGrades
Select 
	(CS.StudentID * -1) as GradeID,
	CS.StudentID,
	S.glName,
	case
		when CS.AlternativeGrade is not null then AlternativeGrade
		when @GradeStyle = 'Percentage' then convert(nvarchar(10),convert(Dec(4,1),CS.StudentGrade)) + '%'
		when @GradeStyle = 'LetterGrade' then dbo.GetLetterGrade(CS.ClassID, CS.StudentGrade)
		when @GradeStyle = 'Points' then convert(nvarchar(10),convert(Dec(4,1),CS.StudentGrade)) + '%'
	end,
	'4000/01/01' as DueDate,
	-1 as AssignmentID
From 	ClassesStudents CS
		inner join
	Students S
		on S.StudentID = CS.StudentID
Where ClassID = @ClassID



-- Order #TheGrades data into table #TheGrades2
Insert into #TheGrades2
Select
	GradeID,
	StudentID,
	StudentName as StudentName,
	Grade,
	DueDate
From #TheGrades
Order By StudentName, StudentID, DueDate, AssignmentID


Create Table #StudentsAndGrades
(
IDCol int IDENTITY(1,1),
Col1 nvarchar(50),
Col2 nvarchar(50),
Col3 nvarchar(50),
Col4 nvarchar(50),
Col5 nvarchar(50),
Col6 nvarchar(50),
Col7 nvarchar(50),
Col8 nvarchar(50),
Col9 nvarchar(50)
)

While (Select Count(*) From #TheGrades2) > 0
Begin

Insert into #StudentNames2
Select * From #StudentNames

Declare @SGCol1 nvarchar(50)
Declare @SGCol2 nvarchar(50)
Declare @SGCol3 nvarchar(50)
Declare @SGCol4 nvarchar(50)
Declare @SGCol5 nvarchar(50)
Declare @SGCol6 nvarchar(50)
Declare @SGCol7 nvarchar(50)
Declare @SGCol8 nvarchar(50)
Declare @SGCol9 nvarchar(50)
Declare @StudentID int
Declare @GradeID int

	While (Select Count(*) From #StudentNames2) > 0
	Begin
	
		Set @SGCol1 = '#Blank#'
		Set @SGCol2 = '#Blank#'
		Set @SGCol3 = '#Blank#'
		Set @SGCol4 = '#Blank#'
		Set @SGCol5 = '#Blank#'
		Set @SGCol6 = '#Blank#'
		Set @SGCol7 = '#Blank#'
		Set @SGCol8 = '#Blank#'
		Set @SGCol9 = '#Blank#'
	
		Select top 1
			@StudentID = StudentID,
			@SGCol1 = StudentName
		From #StudentNames2
		Order By StudentName, StudentID;
		Delete From #StudentNames2 Where StudentID = @StudentID;
	
		Select top 1
			@GradeID = GradeID,
			@SGCol2 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, DueDate, GradeID;
		Delete From #TheGrades2 Where GradeID = @GradeID;
	
		Select top 1
			@GradeID = GradeID,
			@SGCol3 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, DueDate, GradeID;
		Delete From #TheGrades2 Where GradeID = @GradeID;
	
		Select top 1
			@GradeID = GradeID,
			@SGCol4 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, DueDate, GradeID;
		Delete From #TheGrades2 Where GradeID = @GradeID;

		Select top 1
			@GradeID = GradeID,
			@SGCol5 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, DueDate, GradeID;
		Delete From #TheGrades2 Where GradeID = @GradeID;

		Select top 1
			@GradeID = GradeID,
			@SGCol6 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, DueDate, GradeID;
		Delete From #TheGrades2 Where GradeID = @GradeID;
		If @Orientation = 'Landscape'
		Begin

			Select top 1
				@GradeID = GradeID,
				@SGCol7 = Grade
			From #TheGrades2
			Where StudentID = @StudentID
			Order By StudentName, StudentID, DueDate, GradeID;
			Delete From #TheGrades2 Where GradeID = @GradeID;

			Select top 1
				@GradeID = GradeID,
				@SGCol8 = Grade
			From #TheGrades2
			Where StudentID = @StudentID
			Order By StudentName, StudentID, DueDate, GradeID;
			Delete From #TheGrades2 Where GradeID = @GradeID;

			Select top 1
				@GradeID = GradeID,
				@SGCol9 = Grade
			From #TheGrades2
			Where StudentID = @StudentID
			Order By StudentName, StudentID, DueDate, GradeID;
			Delete From #TheGrades2 Where GradeID = @GradeID;

		End
	
		Insert into #StudentsAndGrades (Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9)
		Values
		(
			@SGCol1,
			@SGCol2,
			@SGCol3,
			@SGCol4,
			@SGCol5,
			@SGCol6,
			@SGCol7,
			@SGCol8,
			@SGCol9
		)

	
	End
		Insert into #StudentsAndGrades (Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9)
		Values
		(
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak'
		)

End



-- Compile Assignments Table and Avg Assignments Table
Create Table #AssignmentsH
(
IDCol int IDENTITY(1,1),
Col1 nvarchar(200),
Col2 nvarchar(200),
Col3 nvarchar(200),
Col4 nvarchar(200),
Col5 nvarchar(200),
Col6 nvarchar(200),
Col7 nvarchar(200),
Col8 nvarchar(200),
Col9 nvarchar(200)
)

Create Table #AvgAssignmentGradesH
(
IDCol int IDENTITY(1,1),
Col1 nvarchar(20),
Col2 nvarchar(20),
Col3 nvarchar(20),
Col4 nvarchar(20),
Col5 nvarchar(20),
Col6 nvarchar(20),
Col7 nvarchar(20),
Col8 nvarchar(20),
Col9 nvarchar(20)
)

Create Table #AssignmentsV
(
AssignmentID int,
AssignmentTitle nvarchar(200),
rownumber int identity(1,1) not null
)

Declare @CountAT int = (Select count(*) From AssignmentType Where ClassID = @ClassID);

Insert into #AssignmentsV
Select 	AssignmentID, 
		case
			when GradeStyle = 3 and @GradeStyle = 'Points' then AssignmentTitle + '%NL1%' + Convert(Char(3), datename(weekday, DueDate)) + ' ' + CONVERT(char(5), DueDate, 1) + '%NL2%' + Convert(nvarchar(6),Convert(dec(5,2),Weight)) + '% (' + Convert(nvarchar(6), OutOf) + ')'  
			else AssignmentTitle + '%NL1%' + Convert(Char(3), datename(weekday, DueDate)) + ' ' + CONVERT(char(5), DueDate, 1) + '%NL2%' + Convert(nvarchar(6),Convert(dec(5,2),Weight)) + '%'
		end 
		+
		case 
			when NongradedAssignment = 1 then 'Not Graded'
			when @CountAT > 1 then (Select ' (' + left(TypeTitle,4) + ')' From AssignmentType Where TypeID = A.TypeID)
			else ''
		end	
		as AssignmentTitle
From Assignments A
Where ClassID = @ClassID
Order By DueDate, AssignmentID

-- Add Blank Assignments
Declare @BlankAssignmentCount int
Set @BlankAssignmentCount = 0

While @BlankAssignmentCount < @BlankAssignmentsToAdd
Begin
  Insert into #AssignmentsV (AssignmentID, AssignmentTitle)
  Values(-100 * @BlankAssignmentCount, '')

  Set @BlankAssignmentCount = @BlankAssignmentCount + 1
End

-- Add Final Class Grade
Insert into #AssignmentsV (AssignmentID, AssignmentTitle)
Values(-1, 'Class Grade')

Create Table #AvgV
(
AssignmentID int,
AverageGrade nvarchar(10),
rownumber int identity(1,1) not null
)


Insert into #AvgV (AssignmentID, AverageGrade)
Select 	A.AssignmentID, 
		case
			when AA.AvgGrade is null then ''
			when @GradeStyle = 'Percentage' then convert(nvarchar(10), convert(Dec(3,0),AA.AvgGrade)) + '%'
			when @GradeStyle = 'LetterGrade' then dbo.GetLetterGrade(@ClassID, AA.AvgGrade)
			when @GradeStyle = 'Points' then convert(nvarchar(10), convert(Dec(4,1),AA.AvgScore))
		end
From 
Assignments A
	inner join
(
	Select
	A.AssignmentID,
	AVG(G.Grade) as AvgGrade,
	AVG(G.OutOfCorrect) as AvgScore
	From
	Grades G
		inner join
	Assignments A
		on G.AssignmentID = A.AssignmentID
	Where
	A.ClassID = @ClassID
	--and
	--isnull(G.GradeCode,'') = ''
	Group By A.AssignmentID
) AA
	on A.AssignmentID = AA.AssignmentID

Where ClassID = @ClassID
Order By A.DueDate, A.AssignmentID

Declare @AvgClassGrade nvarchar(10)
Set @AvgClassGrade = (	Select 
							case
								when @GradeStyle = 'LetterGrade' then dbo.GetLetterGrade(@ClassID, avg(StudentGrade))
								else convert(nvarchar(10), convert(Dec(4,1),avg(StudentGrade))) + '%'
							end
						From ClassesStudents
						Where ClassID = @ClassID) 


-- Insert Blank Average Grades
Declare @BlankAvgAssignmentCount int
Set @BlankAvgAssignmentCount = 0

While @BlankAvgAssignmentCount < @BlankAssignmentsToAdd
Begin
  Insert into #AvgV (AssignmentID, AverageGrade)
  Values(-100 * @BlankAvgAssignmentCount, '')

  Set @BlankAvgAssignmentCount = @BlankAvgAssignmentCount + 1
End


-- Insert Average Final Class Grade
Insert into #AvgV (AssignmentID, AverageGrade)
Values(-1, convert(nvarchar(10), @AvgClassGrade))



Declare @AssignmentCol1 nvarchar(100)
Declare @AssignmentCol2 nvarchar(100)
Declare @AssignmentCol3 nvarchar(100)
Declare @AssignmentCol4 nvarchar(100)
Declare @AssignmentCol5 nvarchar(100)
Declare @AssignmentCol6 nvarchar(100)
Declare @AssignmentCol7 nvarchar(100)
Declare @AssignmentCol8 nvarchar(100)
Declare @AssignmentCol9 nvarchar(100)
Declare @AssignmentID int


Declare @AvgCol1 nvarchar(20)
Declare @AvgCol2 nvarchar(20)
Declare @AvgCol3 nvarchar(20)
Declare @AvgCol4 nvarchar(20)
Declare @AvgCol5 nvarchar(20)
Declare @AvgCol6 nvarchar(20)
Declare @AvgCol7 nvarchar(20)
Declare @AvgCol8 nvarchar(20)
Declare @AvgCol9 nvarchar(20)
Declare @AvgID int


Set @AssignmentCol1 = 'Teacher/Class'
Set @AvgCol1 = 'Average Grade'

While (Select Count(*) From #AssignmentsV) > 0
Begin

	Set @AssignmentCol2 = '#Blank#'
	Set @AssignmentCol3 = '#Blank#'
	Set @AssignmentCol4 = '#Blank#'
	Set @AssignmentCol5 = '#Blank#'
	Set @AssignmentCol6 = '#Blank#'
	Set @AssignmentCol7 = '#Blank#'
	Set @AssignmentCol8 = '#Blank#'
	Set @AssignmentCol9 = '#Blank#'

	Select top 1
	    @AssignmentCol2 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@AssignmentID = AssignmentID
	From #AssignmentsV order by rownumber
	Delete From #AssignmentsV Where AssignmentID = @AssignmentID

	Select top 1
		@AssignmentCol3 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@AssignmentID = AssignmentID
	From #AssignmentsV order by rownumber
	Delete From #AssignmentsV Where AssignmentID = @AssignmentID

	Select top 1
		@AssignmentCol4 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@AssignmentID = AssignmentID
	From #AssignmentsV order by rownumber
	Delete From #AssignmentsV Where AssignmentID = @AssignmentID

	Select top 1
		@AssignmentCol5 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@AssignmentID = AssignmentID
	From #AssignmentsV order by rownumber
	Delete From #AssignmentsV Where AssignmentID = @AssignmentID

	Select top 1
		@AssignmentCol6 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@AssignmentID = AssignmentID
	From #AssignmentsV order by rownumber
	Delete From #AssignmentsV Where AssignmentID = @AssignmentID

	If @Orientation = 'Landscape'
	Begin


		Select top 1
			@AssignmentCol7 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
			@AssignmentID = AssignmentID
		From #AssignmentsV order by rownumber
		Delete From #AssignmentsV Where AssignmentID = @AssignmentID

		Select top 1
			@AssignmentCol8 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
			@AssignmentID = AssignmentID
		From #AssignmentsV order by rownumber
		Delete From #AssignmentsV Where AssignmentID = @AssignmentID

		Select top 1
			@AssignmentCol9 = replace(replace(replace(replace(AssignmentTitle, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
			@AssignmentID = AssignmentID
		From #AssignmentsV order by rownumber
		Delete From #AssignmentsV Where AssignmentID = @AssignmentID

	End

	Insert into #AssignmentsH (Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9)
	values
	(
	@AssignmentCol1,
	@AssignmentCol2,
	@AssignmentCol3,
	@AssignmentCol4,
	@AssignmentCol5,
	@AssignmentCol6,
	@AssignmentCol7,
	@AssignmentCol8,
	@AssignmentCol9
	)

	Set @AvgCol2 = '#Blank#'
	Set @AvgCol3 = '#Blank#'
	Set @AvgCol4 = '#Blank#'
	Set @AvgCol5 = '#Blank#'
	Set @AvgCol6 = '#Blank#'
	Set @AvgCol7 = '#Blank#'
	Set @AvgCol8 = '#Blank#'
	Set @AvgCol9 = '#Blank#'

	Select top 1
		@AvgCol2 = AverageGrade,
		@AvgID = AssignmentID
	From #AvgV order by rownumber
	Delete From #AvgV Where AssignmentID = @AvgID

	Select top 1
		@AvgCol3 = AverageGrade,
		@AvgID = AssignmentID
	From #AvgV order by rownumber
	Delete From #AvgV Where AssignmentID = @AvgID

	Select top 1
		@AvgCol4 = AverageGrade,
		@AvgID = AssignmentID
	From #AvgV order by rownumber
	Delete From #AvgV Where AssignmentID = @AvgID

	Select top 1
		@AvgCol5 = AverageGrade,
		@AvgID = AssignmentID
	From #AvgV order by rownumber
	Delete From #AvgV Where AssignmentID = @AvgID

	Select top 1
		@AvgCol6 = AverageGrade,
		@AvgID = AssignmentID
	From #AvgV order by rownumber
	Delete From #AvgV Where AssignmentID = @AvgID

	If @Orientation = 'Landscape'
	Begin

		Select top 1
			@AvgCol7 = AverageGrade,
			@AvgID = AssignmentID
		From #AvgV order by rownumber
		Delete From #AvgV Where AssignmentID = @AvgID

		Select top 1
			@AvgCol8 = AverageGrade,
			@AvgID = AssignmentID
		From #AvgV order by rownumber
		Delete From #AvgV Where AssignmentID = @AvgID

		Select top 1
			@AvgCol9 = AverageGrade,
			@AvgID = AssignmentID
		From #AvgV order by rownumber
		Delete From #AvgV Where AssignmentID = @AvgID

	End

	Insert into #AvgAssignmentGradesH (Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9)
	values
	(
	@AvgCol1,
	@AvgCol2,
	@AvgCol3,
	@AvgCol4,
	@AvgCol5,
	@AvgCol6,
	@AvgCol7,
	@AvgCol8,
	@AvgCol9
	)

End


-- Compile Gradesheet Table

Create Table #Gradesheet
(
Col1 nvarchar(100),
Col2 nvarchar(100),
Col3 nvarchar(100),
Col4 nvarchar(100),
Col5 nvarchar(100),
Col6 nvarchar(100),
Col7 nvarchar(100),
Col8 nvarchar(100),
Col9 nvarchar(100),
rownumber int identity(1,1) not null    
)


While (Select Count(*) From #AssignmentsH) > 0
Begin

	Insert Into #Gradesheet
	Select top 1 Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9 From #AssignmentsH order by IDCol
	Delete From #AssignmentsH Where IDCol = (Select top 1 IDCol From #AssignmentsH order by IDCol)

	While (Select top 1 Col1 From #StudentsAndGrades order by IDCol) != 'PageBreak'
	Begin

		Insert Into #Gradesheet
		Select top 1 Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9 From #StudentsAndGrades order by IDCol
		Delete From #StudentsAndGrades Where IDCol = (Select top 1 IDCol From #StudentsAndGrades order by IDCol)

	End

	Delete From #StudentsAndGrades Where IDCol = (Select top 1 IDCol From #StudentsAndGrades order by IDCol)
	
	Insert Into #Gradesheet
	Select top 1 Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9 From #AvgAssignmentGradesH order by IDCol
	Delete From #AvgAssignmentGradesH Where IDCol = (Select top 1 IDCol From #AvgAssignmentGradesH order by IDCol)


	If (Select Count(*) From #AssignmentsH) > 0
	Begin
		Insert into #Gradesheet (Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9)
		Values
		(
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak'
		)
	End

End



select * from
(
	Select 	1 as tag,
			null as parent,
			@ClassID as [Head!1!ClassID],
			@EK as [Head!1!EK],
			@Orientation as [Head!1!Orientation],
			@GradeStyle as [Head!1!GradeStyle],
			@BlankAssignmentsToAdd as [Head!1!BlankAssignments],
			C.ClassTitle + ' (' + Tm.TermTitle + ')' as [Head!1!Class],
			T.Fname + ' ' + T.Lname as [Head!1!Teacher],
			CONVERT(char(8), dbo.GLgetdatetime(), 1) as [Head!1!TheDate],
			null as [Data!2!Col1],
			null as [Data!2!Col2],
			null as [Data!2!Col3],
			null as [Data!2!Col4],
			null as [Data!2!Col5],
			null as [Data!2!Col6],
			null as [Data!2!Col7],
			null as [Data!2!Col8],
			null as [Data!2!Col9],
			0 as [Data!2!rownumber]

	From 	Classes C
				inner join 
			Teachers T
				on C.TeacherID = T.TeacherID
				inner join
			Terms Tm
				on C.TermID = Tm.TermID
	Where C.ClassID = @ClassID

	Union All

	Select 	2 as tag,
			1 as parent,
			null as [Head!1!ClassID],
			null as [Head!1!EK],
			null as [Head!1!Orientation],
			null as [Head!1!GradeStyle],
			null as [Head!1!BlankAssignments],
			null as [Head!1!Class],
			null as [Head!1!Teacher],
			null as [Head!1!TheDate],
			Col1 as [Data!2!Col1],
			Col2 as [Data!2!Col2],
			Col3 as [Data!2!Col3],
			Col4 as [Data!2!Col4],
			Col5 as [Data!2!Col5],
			Col6 as [Data!2!Col6],
			Col7 as [Data!2!Col7],
			Col8 as [Data!2!Col8],
			Col9 as [Data!2!Col9],
			rownumber as [Data!2!rownumber]

	From #Gradesheet 

) x
-- Fresh Desk #83065 - following order by added to fix incorrect result caused by unspecified order
order by tag, isnull(parent,0), [Data!2!rownumber]

FOR XML EXPLICIT


Drop table #AssignmentsV
Drop table #AssignmentsH
Drop table #StudentNames
Drop table #Gradesheet
Drop table #TheGrades
Drop table #TheGrades2
Drop table #StudentNames2
Drop table #StudentsAndGrades
Drop table #AvgAssignmentGradesH
Drop table #AvgV










GO
