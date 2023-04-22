SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[EditTranscriptGrade]
	@TranscriptID int,
	@NewGrade nvarchar(12),
	@NewUnits Decimal(7,4),
	@NewAlternativegrade nvarchar(12),
	@NewGradeLevel nvarchar(5),
	@CustomGradeScaleID int,
	@IgnoreFilter bit,
	@CategoryID int,
	@CourseCode nvarchar(30)
as



Declare @ClassTypeID int
Declare @GPABoost decimal(5,3)

Declare @CalculateGPA bit = 0
If @CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1)
Begin
	Set @CalculateGPA = 1
End

Set @ClassTypeID = (Select ClassTypeID From Transcript Where TranscriptID = @TranscriptID)
Set @GPABoost = (Select GPABoost From CustomGradeScale Where CustomGradeScaleID = @CustomGradeScaleID)
	
If @ClassTypeID = 8
Begin
	Set @GPABoost = 0
End

if @CustomGradeScaleID is null  -- if entering a percentage grade or GradeScaleID not found then just use the **Standard gradescale
Begin
	Set @CustomGradeScaleID = (Select CustomGradeScaleID From CustomGradeScale Where GradeScaleName = '**Standard')
End

If ISNUMERIC(@NewGrade) = 1
Begin

	Declare @ParentLetterGrade nvarchar(5)
	Declare @NumGrade Decimal(6,3)
	Declare @CreditNoCreditPassingGrade int
	
	Set @NumGrade = convert(Decimal(6,3), @NewGrade)
	Set @CreditNoCreditPassingGrade = (Select CreditNoCreditPassingGrade From Settings Where SettingID = 1)
	
	If @ClassTypeID = 8
	Begin
		If @NumGrade < @CreditNoCreditPassingGrade
		Begin
		  Set @ParentLetterGrade = 'NC'
		End
		Else
		Begin
		  Set @ParentLetterGrade = 'CR'
		End
	End
	Else
	Begin -- if ClassTypeID = 1 or 2
		Set @ParentLetterGrade = dbo.GetLetterGrade2(@CustomGradeScaleID, @NumGrade)
	End

	Update Transcript
	Set 	PercentageGrade = @NewGrade
	where TranscriptID = @TranscriptID
	
	Set @NewGrade = @ParentLetterGrade

End


Declare @UnitsEarned decimal(7,4)
Declare @UnitGPA decimal(7,4)
Declare @LetterGradeGPAValue dec(5,3)





If ISNUMERIC(@NewGrade) = 1
Begin
	Set @LetterGradeGPAValue =
	(
	Select top 1 GPAValue
	From CustomGradeScaleGrades
	where 
	CustomGradeScaleID = @CustomGradeScaleID
	and
	LowPercentage <= @NumGrade
	Order By LowPercentage desc
	) + @GPABoost
End
Else
Begin
	Set @LetterGradeGPAValue =
	(
	Select top 1 GPAValue
	From CustomGradeScaleGrades
	where 
	CustomGradeScaleID = @CustomGradeScaleID
	and
	GradeSymbol = @NewGrade
	) + @GPABoost
End



if @NewGrade in ('F', 'NC') or (@LetterGradeGPAValue - @GPABoost) = 0
Begin
Set @UnitsEarned = 0
End
else
Begin
Set @UnitsEarned = @NewUnits
End


Set @UnitGPA = @LetterGradeGPAValue * @UnitsEarned

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

Set @GradReqCategoryHistoryID = (SELECT IDENT_CURRENT('GradReqCategoryHistory'))

-------------------------------------

If @ClassTypeID = 8
Begin
	Update Transcript
	Set 	LetterGrade = @NewGrade,
			AlternativeGrade = @NewAlternativeGrade,
			GradeLevel = @NewGradeLevel,
			ClassUnits = @NewUnits,
			UnitsEarned = @UnitsEarned,
			CustomGradeScaleID = @CustomGradeScaleID,
			GPABoost = @GPABoost,
			CalculateGPA = 0,
			IgnoreTranscriptGradeLevelFilter = @IgnoreFilter,
			GradReqCategoryID = @CategoryID,
			GradReqCategoryHistoryID = @GradReqCategoryHistoryID,
			CourseCode = @CourseCode
	where TranscriptID = @TranscriptID
End
Else
Begin
	Update Transcript
	Set 	LetterGrade = @NewGrade,
			AlternativeGrade = @NewAlternativeGrade,
			GradeLevel = @NewGradeLevel,		
			ClassUnits = @NewUnits,
			UnitsEarned = @UnitsEarned,
			UnitGPA = @UnitGPA,
			CustomGradeScaleID = @CustomGradeScaleID,
			GPABoost = @GPABoost,
			CalculateGPA = @CalculateGPA,
			IgnoreTranscriptGradeLevelFilter = @IgnoreFilter,
			GradReqCategoryID = @CategoryID,
			GradReqCategoryHistoryID = @GradReqCategoryHistoryID,
			CourseCode = @CourseCode			
	where TranscriptID = @TranscriptID
End

GO
