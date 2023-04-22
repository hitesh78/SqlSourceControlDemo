SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[UpdateParentTermGrade]
@ParentTermID int,
@StudentID int,
@ClassTitle nvarchar(100)

as


Declare @TranscriptID int 
Declare @EnableDoubleRounding bit

Set @EnableDoubleRounding = (Select EnableDoubleRoundingOnSemesterGrade From Settings Where SettingID = 1)


Set @TranscriptID = 
(
Select top 1
	TranscriptID
From Transcript
Where
	TermID = @ParentTermID
	and
	StudentID = @StudentID
	and
	ClassTypeID in (1,2,8)
	and
	ClassTitle = @ClassTitle
)



Declare @SubTermCount Decimal(7,4)

Set @SubtermCount = (Select count(*) From Terms Where ParentTermID = @ParentTermID and ExamTerm = 0)


-- *******Update Subterm Weight on Changes*************
Declare @NewSubtermWeight Decimal(7,4)
Declare @ExamWeight Decimal(7,4)

Set @ExamWeight =
(
Select TermWeight
From Transcript
Where
	ParentTermID = @ParentTermID
	and
	StudentID = @StudentID
	and
	ClassTitle = @ClassTitle
	and
	ClassTypeID in (1,2,8)
	and
	ExamTerm = 1
)


If @ExamWeight is not null
Begin
  Set @NewSubtermWeight = (100 - @ExamWeight) / @SubtermCount
End
Else
Begin
  Set @NewSubtermWeight = 100 / @SubtermCount
End

Update Transcript
Set TermWeight =  @NewSubtermWeight
Where
	ParentTermID = @ParentTermID
	and
	StudentID = @StudentID
	and
	ClassTitle = @ClassTitle
	and
	ClassTypeID in (1,2,8)
	and
	ExamTerm = 0

-- ***************************************************

If @SubTermCount < 1
Begin
	Delete From Transcript Where TranscriptID = @TranscriptID
End

Else
Begin

	Declare @ParentLetterGrade nvarchar(6)
	Declare @ParentPercentageGrade Decimal(7,1)	-- Changed from 7,4 to 7,1 so it's rounded to 1 decimal and it matches the projected calc on the GradeSheet
	Declare @ParentUnitsEarned Decimal(7,4)
	Declare @ParentUnitGPA Decimal(7,4)
	Declare @ClassTypeID tinyint	
	Declare @NewParentGPAScore Decimal(7,4)
	Declare @GPABoost Decimal(5,2)

	

	Set @ParentPercentageGrade =
	(
	Select 
		case
			when @EnableDoubleRounding = 1 then sum(round(PercentageGrade, 0) * TermWeight) / Sum(TermWeight)
			else sum(PercentageGrade * TermWeight) / Sum(TermWeight)
		end
	From Transcript 
	Where 	StudentID = @StudentID
			and 
			ParentTermID = @ParentTermID
			and
			ClassTitle = @ClassTitle
			and
			ClassTypeID in (1,2,8)
			and
			PercentageGrade is not null
	)
	
	Declare @ClassID int
	Set @ClassID = (Select ClassID From Transcript Where TranscriptID = @TranscriptID)
	
	Declare @CustomGradeScaleID int
	

	if @ClassID not in (Select ClassID From Classes)
	Begin
		Declare @tempClassID int
		Set @CustomGradeScaleID = (Select top 1 CustomGradeScaleID From Transcript Where ClassID = @ClassID and ParentTermID != 0)
		Set @tempClassID = (Select top 1 ClassID From Classes Where CustomGradeScaleID = @CustomGradeScaleID and ClassTypeID = 1)
		Set @ParentLetterGrade = dbo.GetLetterGrade(@tempClassID, @ParentPercentageGrade)
	End
	Else
	Begin
		Set @ParentLetterGrade = dbo.GetLetterGrade(@ClassID, @ParentPercentageGrade)
		Set @CustomGradeScaleID = (Select CustomGradeScaleID From Classes Where ClassID = @ClassID)
	End

	
	Set @GPABoost = 
	(
	Select top 1 GPABoost 
	From Transcript 
	Where 
	ClassID = @ClassID 
	and 
	ParentTermID != 0
	and
	StudentID = @StudentID
	)

	
	Set @NewParentGPAScore =
	(
	Select top 1 GPAValue + @GPABoost
	From CustomGradeScaleGrades
	where 
	CustomGradeScaleID = @CustomGradeScaleID
	and
	LowPercentage <= @ParentPercentageGrade
	Order By LowPercentage desc
	)
		
	
	
	If (@ParentLetterGrade = 'F' or (@NewParentGPAScore - @GPABoost) = 0)
	Begin
		Set @ParentUnitsEarned = 0
	End
	Else
	Begin
		Set @ParentUnitsEarned = (Select ClassUnits From Transcript Where TranscriptID = @TranscriptID)
	End

	Set @ClassTypeID = (Select ClassTypeID From Transcript Where TranscriptID = @TranscriptID)

	if @ClassTypeID = 8
	Begin
		Declare @CreditNoCreditPassingGrade int
		Declare @ParentClassUnits decimal(7,4)
		Set @ParentClassUnits = (Select ClassUnits From Transcript Where TranscriptID = @TranscriptID)
		Set @CreditNoCreditPassingGrade = (Select CreditNoCreditPassingGrade From Settings Where SettingID = 1)
	
		if @ParentPercentageGrade < @CreditNoCreditPassingGrade
		Begin
			Set @ParentUnitsEarned = 0
			Set @ParentLetterGrade = 'NC'
		End
		Else
		Begin
			Set @ParentUnitsEarned = @ParentClassUnits
			Set @ParentLetterGrade = 'CR'
		End
	End
	


	
	Set @ParentUnitGPA = @ParentUnitsEarned * @NewParentGPAScore
	



-- Set the Semester Grade to an Alternative Grade 
-- if a child Term is set to an alternative Grade
 --One Caveate is that a child term AlternativeGrade could overwrite a
 --manually entered AlterntativeGrade that may have been entered via
 --Editing Grades from the Transcript tab. 
Declare @SemAlternativeGrade nvarchar(10) = 
(
Select top 1 AlternativeGrade
From Transcript
where 
	ParentTermID = @ParentTermID
	and
	StudentID = @StudentID
	and
	ClassTitle = @ClassTitle
	and
	ClassTypeID in (1,2,8)
	and
	ExamTerm = 0
	and
	(
	isnull(AlternativeGrade, '') != ''
	and
	AlternativeGrade != 'nm'
	)
	
)


	Update Transcript
	Set
		UnitsEarned = @ParentUnitsEarned,
		LetterGrade = @ParentLetterGrade,
		PercentageGrade = @ParentPercentageGrade,
		AlternativeGrade = @SemAlternativeGrade,
		UnitGPA = @ParentUnitGPA,
		GPABoost = isnull(@GPABoost,0)
	where TranscriptID = @TranscriptID

End

GO
