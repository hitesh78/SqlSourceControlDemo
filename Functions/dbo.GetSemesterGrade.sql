SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetSemesterGrade]
(	@ClassID int,
	@StudentID int )
RETURNS decimal(5,2)
AS
BEGIN

	Declare @SemesterGrade decimal(5,2)
	Declare @CurrentTermGrade decimal(5,2)
	Declare @TermID int
	Declare @ParentTermID int
	Declare @ExamTermWeight decimal(5,2)
	Declare @IndSubTermWeight decimal(5,2)
	Declare @TotalSubTermWeight decimal(5,2)
	Declare @TotalSubTermCount int
	Declare @StudentSubTermCount int
	Declare @SubTermAvg decimal(5,2)
	Declare @ExamGrade decimal(5,2)
	Declare @ClassTitle nvarchar(100)
	Declare @SubTermGrades table (ClassID int, ExamTerm int, TermGrade decimal(5,2))

	Set @CurrentTermGrade = (Select StudentGrade From ClassesStudents Where ClassID = @ClassID and StudentID = @StudentID)
	Set @ClassTitle = (Select ReportTitle From Classes Where ClassID = @ClassID)
	Set @TermID = (Select TermID From Classes Where ClassID = @ClassID)
	Set @ParentTermID = (Select ParentTermID From Terms Where TermID = @TermID)
	Set @TotalSubTermCount = (Select count(*) From Terms Where ParentTermID = @ParentTermID and ExamTerm = 0)
	
	-- Add grades from concluded classes
	Insert into @SubTermGrades
	Select ClassID, ExamTerm, PercentageGrade
	From Transcript
	Where 
	StudentID = @StudentID 
	and 
	ClassTitle = @ClassTitle
	and
	ParentTermID = @ParentTermID 
	and
	ClassTypeID in (1,2,8)
	and
	PercentageGrade is not null	
	
	-- Add grades from unconcluded classes that have grades
	Insert into @SubTermGrades
	Select C.ClassID, T.ExamTerm, CS.StudentGrade
	From 
	Terms T
		inner join
	Classes C
		on C.TermID = T.TermID
		inner join 
	ClassesStudents CS
		on C.ClassID = CS.ClassID
	Where 
	CS.StudentID = @StudentID 
	and 
	C.ReportTitle = @ClassTitle
	and
	T.ParentTermID = @ParentTermID 
	and
	C.ClassTypeID in (1,2,8)
	and
	CS.StudentGrade is not null
	and
	C.ClassID not in (Select ClassID From @SubTermGrades)

	
	
	Set @StudentSubTermCount = (Select count(*) From @SubTermGrades Where ExamTerm = 0)

	Set @ExamTermWeight = (Select TermWeight From Terms Where ParentTermID = @ParentTermID and ExamTerm = 1)
	Set @IndSubTermWeight = (100 - @ExamTermWeight) / @TotalSubTermCount
	Set @TotalSubTermWeight = @IndSubTermWeight * @StudentSubTermCount


	Declare @EnableDoubleRounding bit = (Select EnableDoubleRoundingOnSemesterGrade From Settings Where SettingID = 1)

	if (@EnableDoubleRounding = 1)
	Begin
		Set @ExamGrade = (Select round(TermGrade,0) From @SubTermGrades Where ExamTerm = 1)
		Set @SubTermAvg = (Select convert(decimal(5,2),avg(round(TermGrade,0))) From @SubTermGrades Where ExamTerm = 0)
	End
	Else
	Begin
		Set @ExamGrade = (Select TermGrade From @SubTermGrades Where ExamTerm = 1)
		Set @SubTermAvg = (Select convert(decimal(5,2),avg(TermGrade)) From @SubTermGrades Where ExamTerm = 0)
	End

	If @ExamGrade is null -- if no exam grades then just use average of subgrades
	Begin
		Set @SemesterGrade = @SubTermAvg
	End
	Else
	Begin
		Set @SemesterGrade = (Select ((@SubTermAvg*@TotalSubTermWeight)+(@ExamGrade*@ExamTermWeight))/(@TotalSubTermWeight + @ExamTermWeight))
	End

	return @SemesterGrade

END




GO
