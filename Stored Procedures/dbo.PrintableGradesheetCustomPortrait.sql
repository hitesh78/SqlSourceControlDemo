SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[PrintableGradesheetCustomPortrait]
(
@ClassID int,
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
StudentName nvarchar(50)
)

Create Table #StudentNames2
(
StudentID int,
StudentName nvarchar(50)
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
CSCFID int,
StudentID int,
StudentName nvarchar(100),
Grade nvarchar(10),
CustomFieldOrder int
)

Create Table #TheGrades2
(
CSCFID int,
StudentID int,
StudentName nvarchar(100),
Grade nvarchar(10),
CustomFieldOrder int
)



Insert Into #TheGrades
Select
	CSCF.CSCFID,
	S.StudentID,
	S.glname,
	CSCF.CFGrade,
	CF.CustomFieldOrder
From 
	ClassesStudentsCF CSCF
		inner join 
	ClassesStudents CS
		on CSCF.CSID = CS.CSID
		inner join
	Students S
		on S.StudentID = CS.StudentID
		inner join
	CustomFields CF
		on CF.CustomFieldID = CSCF.CustomFieldID
Where 
CS.ClassID = @ClassID
and
CF.FieldNotGraded = 0
Order By S.glname, StudentID, CustomFieldOrder




-- Order #TheGrades data into table #TheGrades2
Insert into #TheGrades2
Select
	CSCFID,
	StudentID,
	StudentName,
	Grade,
	CustomFieldOrder
From #TheGrades
Order By StudentName, StudentID, CustomFieldOrder

--Select * From #TheGrades2



Create Table #StudentsAndGrades
(
IDCol int IDENTITY(1,1),
Col1 nvarchar(50),
Col2 nvarchar(50),
Col3 nvarchar(50),
Col4 nvarchar(50),
Col5 nvarchar(50),
Col6 nvarchar(50)
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
Declare @StudentID int
Declare @CSCFID int

	While (Select Count(*) From #StudentNames2) > 0
	Begin
	
		Set @SGCol1 = '#Blank#'
		Set @SGCol2 = '#Blank#'
		Set @SGCol3 = '#Blank#'
		Set @SGCol4 = '#Blank#'
		Set @SGCol5 = '#Blank#'
		Set @SGCol6 = '#Blank#'

		Select top 1
			@StudentID = StudentID,
			@SGCol1 = StudentName
		From #StudentNames2
		Order By StudentName, StudentID;
		Delete From #StudentNames2 Where StudentID = @StudentID;
	
		Select top 1
			@CSCFID = CSCFID,
			@SGCol2 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, CustomFieldOrder;
		Delete From #TheGrades2 Where CSCFID = @CSCFID;
	
	
		Select top 1
			@CSCFID = CSCFID,
			@SGCol3 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, CustomFieldOrder;
		Delete From #TheGrades2 Where CSCFID = @CSCFID;
	
	
		Select top 1
			@CSCFID = CSCFID,
			@SGCol4 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, CustomFieldOrder;
		Delete From #TheGrades2 Where CSCFID = @CSCFID;


		Select top 1
			@CSCFID = CSCFID,
			@SGCol5 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, CustomFieldOrder;
		Delete From #TheGrades2 Where CSCFID = @CSCFID;


		Select top 1
			@CSCFID = CSCFID,
			@SGCol6 = Grade
		From #TheGrades2
		Where StudentID = @StudentID
		Order By StudentName, StudentID, CustomFieldOrder;
		Delete From #TheGrades2 Where CSCFID = @CSCFID;
	
	
		Insert into #StudentsAndGrades (Col1, Col2, Col3, Col4, Col5, Col6)
		Values
		(
			@SGCol1,
			@SGCol2,
			@SGCol3,
			@SGCol4,
			@SGCol5,
			@SGCol6
		)

	
	End
		Insert into #StudentsAndGrades (Col1, Col2, Col3, Col4, Col5, Col6)
		Values
		(
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak'
		)

End


-- Compile Assignments Table and Avg Assignments Table
Create Table #CustomFieldsH
(
IDCol int IDENTITY(1,1),
Col1 nvarchar(200),
Col2 nvarchar(200),
Col3 nvarchar(200),
Col4 nvarchar(200),
Col5 nvarchar(200),
Col6 nvarchar(200)
)


Create Table #CustomFieldsV
(
CustomFieldID int,
CustomFieldName nvarchar(200),
CustomFieldOrder int
)

Declare @ClassTypeID int
Set @ClassTypeID = (Select ClassTypeID From Classes Where ClassID = @ClassID)

Insert into #CustomFieldsV
Select 	CustomFieldID, 
		CustomFieldName,
		CustomFieldOrder
From 	CustomFields
Where 
ClassTypeID = @ClassTypeID
and
FieldNotGraded = 0
Order By CustomFieldOrder



Declare @CFCol1 nvarchar(200)
Declare @CFCol2 nvarchar(200)
Declare @CFCol3 nvarchar(200)
Declare @CFCol4 nvarchar(200)
Declare @CFCol5 nvarchar(200)
Declare @CFCol6 nvarchar(200)
Declare @CustomFieldID int


Set @CFCol1 = 'Teacher/Class'


While (Select Count(*) From #CustomFieldsV) > 0
Begin

	Set @CFCol2 = '#Blank#'
	Set @CFCol3 = '#Blank#'
	Set @CFCol4 = '#Blank#'
	Set @CFCol5 = '#Blank#'
	Set @CFCol6 = '#Blank#'

	Select top 1
		@CFCol2 = replace(replace(replace(replace(CustomFieldName, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@CustomFieldID = CustomFieldID
	From #CustomFieldsV
	Order By CustomFieldOrder;
	Delete From #CustomFieldsV Where CustomFieldID = @CustomFieldID;

	Select top 1
		@CFCol3 = replace(replace(replace(replace(CustomFieldName, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@CustomFieldID = CustomFieldID
	From #CustomFieldsV
	Order By CustomFieldOrder;
	Delete From #CustomFieldsV Where CustomFieldID = @CustomFieldID;

	Select top 1
		@CFCol4 = replace(replace(replace(replace(CustomFieldName, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@CustomFieldID = CustomFieldID
	From #CustomFieldsV
	Order By CustomFieldOrder;
	Delete From #CustomFieldsV Where CustomFieldID = @CustomFieldID;

	Select top 1
		@CFCol5 = replace(replace(replace(replace(CustomFieldName, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@CustomFieldID = CustomFieldID
	From #CustomFieldsV
	Order By CustomFieldOrder;
	Delete From #CustomFieldsV Where CustomFieldID = @CustomFieldID;

	Select top 1
		@CFCol6 = replace(replace(replace(replace(CustomFieldName, char(10), ''), char(13), ''), '''', '\'''), '"', '\"'),
		@CustomFieldID = CustomFieldID
	From #CustomFieldsV
	Order By CustomFieldOrder;
	Delete From #CustomFieldsV Where CustomFieldID = @CustomFieldID;

	Insert into #CustomFieldsH (Col1, Col2, Col3, Col4, Col5, Col6)
	values
	(
	@CFCol1,
	@CFCol2,
	@CFCol3,
	@CFCol4,
	@CFCol5,
	@CFCol6
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
Col6 nvarchar(100)
)


While (Select Count(*) From #CustomFieldsH) > 0
Begin

	Insert Into #Gradesheet
	Select top 1 Col1, Col2, Col3, Col4, Col5, Col6 From #CustomFieldsH
	Delete From #CustomFieldsH Where IDCol = (Select top 1 IDCol From #CustomFieldsH)

	While (Select top 1 Col1 From #StudentsAndGrades) != 'PageBreak'
	Begin

		Insert Into #Gradesheet
		Select top 1 Col1, Col2, Col3, Col4, Col5, Col6 From #StudentsAndGrades
		Delete From #StudentsAndGrades Where IDCol = (Select top 1 IDCol From #StudentsAndGrades)

	End

	Delete From #StudentsAndGrades Where IDCol = (Select top 1 IDCol From #StudentsAndGrades)


	If (Select Count(*) From #CustomFieldsH) > 0
	Begin
		Insert into #Gradesheet (Col1, Col2, Col3, Col4, Col5, Col6)
		Values
		(
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak',
			'PageBreak'
		)
	End

End




Select 	1 as tag,
		null as parent,
		@ClassID as [Head!1!ClassID],
		@EK as [Head!1!EK],
		'Portrait' as [Head!1!Orientation],
		@GradeStyle as [Head!1!GradeStyle],
		@BlankAssignmentsToAdd as [Head!1!BlankAssignments],
		'Custom' as [Head!1!ClassType],
		C.ClassTitle + ' (' + Tm.TermTitle + ')' as [Head!1!Class],
		T.Fname + ' ' + T.Lname as [Head!1!Teacher],
		CONVERT(char(8), dbo.GLgetdatetime(), 1) as [Head!1!TheDate],
		null as [Data!2!Col1],
		null as [Data!2!Col2],
		null as [Data!2!Col3],
		null as [Data!2!Col4],
		null as [Data!2!Col5],
		null as [Data!2!Col6]

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
		null as [Head!1!ClassType],
		null as [Head!1!Class],
		null as [Head!1!Teacher],
		null as [Head!1!TheDate],
		Col1 as [Data!2!Col1],
		Col2 as [Data!2!Col2],
		Col3 as [Data!2!Col3],
		Col4 as [Data!2!Col4],
		Col5 as [Data!2!Col5],
		Col6 as [Data!2!Col6]

From #Gradesheet 

FOR XML EXPLICIT


Drop table #CustomFieldsV
Drop table #CustomFieldsH
Drop table #StudentNames
Drop table #Gradesheet
Drop table #TheGrades
Drop table #TheGrades2
Drop table #StudentNames2
Drop table #StudentsAndGrades









GO
