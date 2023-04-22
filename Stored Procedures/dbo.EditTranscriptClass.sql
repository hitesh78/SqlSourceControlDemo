SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[EditTranscriptClass] 

@TermID int,
@ClassTeacher nvarchar(100),
@Class nvarchar(100),
@NewClassTitle nvarchar(100),
@Units decimal(7,4),
@CustomGradeScaleID int,
@CategoryID int,
@CourseCode nvarchar(30),
@Rigor nvarchar(3),
@DualEnrollment nvarchar(3)

as



Declare @UnitsEarned decimal(7,4)
Declare @UnitGPA decimal(7,4)
Declare @LetterGrade nvarchar(3)
Declare @PercentageGrade Decimal(5,2)
Declare @ClassID int
Declare @CreditNoCreditPassingGrade int
Declare @ClassTypeID int


-------------------------------------
-- Get GradReqCategoryHistoryID 
-------------------------------------
Declare 
@GradReqCategoryHistoryID int

Declare @CXML nvarchar(4000) =
(
Select
CategoryID,
CategoryName,
RequiredUnits
From GradReqCategories
FOR XML RAW
)

if (not exists (Select * From dbo.GradReqCategoryHistory where CXML = @CXML))
Begin
	insert into dbo.GradReqCategoryHistory (CDate, CXML)
	values(GETDATE(), @CXML)
End

Set @GradReqCategoryHistoryID = (SELECT Max(CHistoryID) From GradReqCategoryHistory)

-------------------------------------


Declare @CalculateGPA bit = 0
If @CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1)
Begin
	Set @CalculateGPA = 1
End

Declare @FetchTranscriptID int

Declare @TheClassTeacher nvarchar(100)
If @ClassTeacher = 'undefined'
Begin
Declare TranscriptCursor Cursor For
Select TranscriptID
from Transcript
Where
	TermID = @TermID
	and
	ClassTitle = @Class
	and
	TFname is null
End
Else
Begin
Declare TranscriptCursor Cursor For
Select TranscriptID
from Transcript
Where
	TermID = @TermID
	and
	ClassTitle = @Class
	and
	TFname + TLname = @ClassTeacher
End

Declare @ParentTermID int
Set @ParentTermID = (Select top 1 ParentTermID From Transcript Where TermID = @TermID)

Declare @LetterGradeGPA Decimal(5,2)
Declare @GPABoost Decimal(5,2)

Set @GPABoost = (Select GPABoost From CustomGradeScale Where CustomGradeScaleID = @CustomGradeScaleID)

Open  TranscriptCursor

FETCH NEXT FROM TranscriptCursor INTO @FetchTranscriptID
WHILE (@@FETCH_STATUS <> -1)
BEGIN

	Set @PercentageGrade = (Select PercentageGrade From Transcript Where TranscriptID = @FetchTranscriptID)
	Set @CreditNoCreditPassingGrade = (Select CreditNoCreditPassingGrade From Settings Where SettingID = 1)
	Set @ClassTypeID = (Select ClassTypeID From Transcript Where TranscriptID = @FetchTranscriptID)


	if @ClassTypeID = 1
	Begin

		Set @ClassID = (Select ClassID From Transcript Where TranscriptID = @FetchTranscriptID)


		If @ParentTermID = 0
		Begin
			Set @LetterGrade = (Select LetterGrade From Transcript Where TranscriptID = @FetchTranscriptID)
		End
		Else
		Begin
			  Set @LetterGrade = dbo.GetLetterGrade2(@CustomGradeScaleID, @PercentageGrade)
		End

		If isnull(@LetterGrade, '') = '' 
		Begin
			Set @LetterGrade = dbo.GetLetterGrade2(@CustomGradeScaleID, @PercentageGrade)
		End

		Print 'LetterGrade: ' + @LetterGrade


		if @LetterGrade = 'F'
		Begin
		  Set @UnitsEarned = 0
		End
		else
		Begin
		  Set @UnitsEarned = @Units
		End


		If @PercentageGrade is null
		Begin
			Select top 1 
			@LetterGradeGPA = GPAValue + @GPABoost
			From CustomGradeScaleGrades
			where 
			CustomGradeScaleID = @CustomGradeScaleID
			and
			GradeSymbol = @LetterGrade
			Order By LowPercentage desc
		End
		Else
		Begin
			Select top 1 
			@LetterGradeGPA = GPAValue + @GPABoost
			From CustomGradeScaleGrades
			where 
			CustomGradeScaleID = @CustomGradeScaleID
			and
			LowPercentage <= @PercentageGrade
			Order By LowPercentage desc
		End

		Set @UnitGPA = 	@LetterGradeGPA * @UnitsEarned

	End
	Else  
	Begin  -- For Credit / No Credit Classes


		If @ParentTermID = 0
		Begin
			Set @LetterGrade = (Select LetterGrade From Transcript Where TranscriptID = @FetchTranscriptID)
			
			If @LetterGrade = 'NC'
			Begin
				Set @UnitsEarned = 0
			End
			Else
			Begin
				Set @UnitsEarned = @Units
			End
		End
		Else
		Begin
			if @PercentageGrade < @CreditNoCreditPassingGrade
			Begin
			  Set @UnitsEarned = 0
			  Set @LetterGrade = 'NC'
			End
			Else
			Begin
			  Set @UnitsEarned = @Units
			  Set @LetterGrade = 'CR'
			End
		End

		
	End
		


		Update Transcript
		Set 
			ClassTitle = @NewClassTitle,
			CustomGradeScaleID = @CustomGradeScaleID,
			GPABoost = @GPABoost,
			ClassUnits = @Units,
			UnitsEarned = @UnitsEarned,
			LetterGrade = @LetterGrade,  
			UnitGPA = @UnitGPA,
			CalculateGPA = @CalculateGPA,
			GradReqCategoryID = @CategoryID,
			GradReqCategoryHistoryID = @GradReqCategoryHistoryID,
			CourseCode = @CourseCode,
			Rigor = case when @Rigor = 'on' then 1 else 0 end,
			DualEnrollment = case when @DualEnrollment = 'on' then 1 else 0 end
		Where TranscriptID = @FetchTranscriptID



FETCH NEXT FROM TranscriptCursor INTO @FetchTranscriptID

End


Close TranscriptCursor
Deallocate TranscriptCursor



	












GO
