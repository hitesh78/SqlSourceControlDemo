SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetLetterGrade]
(	@ClassID int,
	@Grade decimal(10,4) )
RETURNS nvarchar(6)
AS
BEGIN
	Declare @LetterGrade nvarchar(6)

	Declare @CustomGradeScaleID int
	Set @CustomGradeScaleID = (Select CustomGradeScaleID From Classes Where ClassID = @ClassID)
	
	Set @LetterGrade =
	(
	Select top 1 GradeSymbol
	From CustomGradeScaleGrades
	where 
	CustomGradeScaleID = @CustomGradeScaleID
	and
	LowPercentage <= @Grade
	Order By LowPercentage desc
	)

	If @LetterGrade is null and @Grade is not null
	Begin
		Select top 1 @LetterGrade = GradeSymbol
		From CustomGradeScaleGrades
		where 
		CustomGradeScaleID = @CustomGradeScaleID
		Order By LowPercentage
	End	


RETURN (@LetterGrade)

END




GO
