SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[SubmitAssignmentGrade] 
@INFO nvarchar(max), 
@AssignmentID int, 
@GradeStyle int, 
@ClassID int, 
@theView int, 
@EK decimal(15,15),
@ExamTerm int

AS


Declare @EndPosition int
Declare @GradeID int
Declare @Grade nvarchar(7)
Declare @LetterGrade nvarchar(3)
Declare @OutOfCorrect nvarchar(10)
Declare @GradeCode nvarchar(7)
Declare @NG nvarchar(7)
Declare @Comments nvarchar(300)
Declare @StrLength int
Declare @StartPosition int
Declare @PercentageGrade decimal(6,2)
Declare @Completed bit

Declare @OutOf decimal(6,2) = (Select OutOf From Assignments Where AssignmentID = @AssignmentID)

Declare @AssignmentGrades table 
(
GradeID int,
Grade nvarchar(7),
LetterGrade nvarchar(3),
OutOfCorrect real,
GradeCode nvarchar(7),
Comments nvarchar(1000)
)

Declare @NonGradedAssignment bit = (Select NongradedAssignment From Assignments Where AssignmentID = @AssignmentID)

While (LEN(@INFO) > 0)
Begin

--Get GradeID
Set @EndPosition = PATINDEX ('%(@%)%', @INFO) - 1
Set @StartPosition = PATINDEX ('%(@%)%', @INFO) + 4
Set @GradeID = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)


--Get Grade
Set @EndPosition = PATINDEX ('%(@%)%', @INFO) - 1
Set @StartPosition = PATINDEX ('%(@%)%', @INFO) + 4
Set @Grade = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
If (@GradeStyle = 2 and @NonGradedAssignment = 0)
Begin
	--Get LetterGrade
	Set @EndPosition = PATINDEX ('%(@%)%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%(@%)%', @INFO) + 4
	Set @LetterGrade = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
End
Else If (@GradeStyle = 3 and @NonGradedAssignment = 0)
Begin
	--Get OutOfCorrect
	Set @EndPosition = PATINDEX ('%(@%)%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%(@%)%', @INFO) + 4
	Set @OutOfCorrect = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	Set @PercentageGrade = 
			case
				when ISNULL(@Grade,'') = '' then null
				else @Grade
			end	
End


--Get GradeCode
Set @EndPosition = PATINDEX ('%(@%)%', @INFO) - 1
Set @StartPosition = PATINDEX ('%(@%)%', @INFO) + 4
Set @GradeCode = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
if @GradeCode = '' or @GradeCode = 'None'
Begin
	Set @GradeCode = null
End
--Get NG
Set @EndPosition = PATINDEX ('%(@%)%', @INFO) - 1
Set @StartPosition = PATINDEX ('%(@%)%', @INFO) + 4
Set @NG = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
--Get Comments
Set @EndPosition = PATINDEX ('%(@%)%', @INFO) - 1
Set @StartPosition = PATINDEX ('%(@%)%', @INFO) + 4
Set @Comments = SUBSTRING (@INFO, 1, @EndPosition)
Set @Comments = replace(@Comments, '=PercentageSymbol=', '%')  -- Translate =PercentageSymbol= back to %
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)


Insert into @AssignmentGrades 
(
GradeID,
Grade,
LetterGrade,
OutOfCorrect,
GradeCode,
Comments
)
values
(
@GradeID,
case
	when @NonGradedAssignment = 0 and (@NG = 'true' or ISNULL(@Grade,'') = '') then null 
	else @Grade		
end,
case
	when @NG = 'true' or ISNULL(@LetterGrade,'') = '' or @GradeStyle != 2 then null 
	else @LetterGrade		
end,
case
	when @GradeStyle = 3 and @GradeCode is not null then @OutOf * @PercentageGrade / 100.00
	when @NG = 'true' or ISNULL(@OutOfCorrect,'') = ''  or @GradeStyle != 3 then null 
	else @OutOfCorrect		
end,
@GradeCode,
@Comments
)


END


-- Update Grades Table with new Grades
Update Grades
Set 
	Grade = 
	case 
		when @NonGradedAssignment = 1 then null
		else AG.Grade
	end,
	LetterGrade = AG.LetterGrade,
	OutOfCorrect = AG.OutOfCorrect,
	Comments = AG.Comments,
	GradeCode = AG.GradeCode,
	Completed = 
	case 
		when @NonGradedAssignment = 1 then AG.Grade
		else 0
	end	
From 
Grades G
	inner join
@AssignmentGrades AG
	on G.GradeID = AG.GradeID




    
    Declare @TermID int
    Declare @ParentTermID int
    Declare @ClassTitle nvarchar(100)
    Declare @TFname nvarchar(50)
    Declare @TLname nvarchar(50)
    Declare @ShowSemesterGrade bit
    Declare @TeacherID int
    
    Set @TeacherID = (Select TeacherID From Classes Where ClassID = @ClassID)
    Set @TFname = (Select Fname From Teachers Where TeacherID = @TeacherID)
    Set @TLname = (Select Lname From Teachers Where TeacherID = @TeacherID)    
    Set @ClassTitle = (Select ReportTitle From Classes Where ClassID = @ClassID)
    Set @TermID = (Select TermID From Classes Where ClassID = @ClassID)
    Set @ParentTermID = (Select ParentTermID From Terms Where TermID = @TermID)
    
    If @ParentTermID != 0
    Begin
        Declare @ParentTermIDInTranscript int
        Set @ParentTermIDInTranscript = 
        (
        Select count(*) 
        From Transcript 
        Where 
        ParentTermID = @ParentTermID
        and
        ClassTitle = @ClassTitle
        and
        Tfname = @TFname
        and
        TLname = @TLname
        )
        
        if @ParentTermIDInTranscript > 0
        Begin
            Set @ShowSemesterGrade = 1
        End
        Else
        Begin
            Set @ShowSemesterGrade = 0
        End
    
    End
    Else
    Begin
        Set @ShowSemesterGrade = 0
    End      
    



	Declare @StudentCount int
	Declare @AssignmentCount int
	Declare @TypeCount int

	Set @StudentCount = (	select	count(CSID)
				From ClassesStudents
				Where ClassID = @ClassID)


	Set @AssignmentCount = (select	count(AssignmentID)
				From Assignments
				Where ClassID = @ClassID)

	Set @TypeCount = (Select Count(AST.TypeID)
			  from AssignmentType AST inner join Classes C
			  on AST.ClassID = C.ClassID
			  where C.ClassID = @ClassID)

	select
		@ShowSemesterGrade as ShowSemesterGrade, 	
		@ClassID as ClassID,
		@StudentCount as StudentCount,
		@TypeCount as TypeCount,
		@AssignmentCount as AssignmentCount,
		@theView as theView,
		@EK as EK,
		@ExamTerm as ExamTerm
	
	FOR XML RAW

GO
