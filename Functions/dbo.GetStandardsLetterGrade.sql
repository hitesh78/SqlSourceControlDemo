SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetStandardsLetterGrade]
(	@ClassID int,
	@Grade decimal(10,4) )
RETURNS nvarchar(3)
AS
BEGIN
	Declare @LetterGrade nvarchar(6)

	Declare @StandardsGradeScaleID int
	Set @StandardsGradeScaleID = (Select StandardsGradeScaleID From Classes Where ClassID = @ClassID)
	
	If @StandardsGradeScaleID = 0
	Begin
		Set @StandardsGradeScaleID = (Select CustomGradeScaleID From Classes Where ClassID = @ClassID)
	End
	
	
	Set @LetterGrade =
	(
	Select top 1 GradeSymbol
	From CustomGradeScaleGrades
	where 
	CustomGradeScaleID = @StandardsGradeScaleID
	and
	LowPercentage <= @Grade
	Order By LowPercentage desc
	)

	If @LetterGrade is null and @Grade is not null
	Begin
		Select top 1 @LetterGrade = GradeSymbol
		From CustomGradeScaleGrades
		where 
		CustomGradeScaleID = @StandardsGradeScaleID
		Order By LowPercentage
	End	


RETURN (@LetterGrade)

END




GO
