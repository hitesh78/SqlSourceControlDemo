SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 6/9/2014
-- Description:	Returns PercentageGrade When only LetterGrade Exists
-- =============================================
CREATE FUNCTION [dbo].[getPercentageGradeFromLetterGrade]
(
	@LetterGrade nvarchar(10),
	@CustomGradeScaleID int
)
RETURNS decimal(6,3)
AS
BEGIN

Declare @PercentageGrade decimal(6,3) = 
(
	Select top 1 LetterGradeConversion 
	From CustomGradeScaleGrades
	Where
	CustomGradeScaleID = @CustomGradeScaleID
	and
	GradeSymbol = @LetterGrade
)

return @PercentageGrade

END


GO
