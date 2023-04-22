SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[getGradeScaleLegend2]
(
@CustomGradescaleID int
)
RETURNS nchar(2000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @GradeScaleLegend nvarchar(2000)

	-- Add the T-SQL statements to compute the return value here

Set @GradeScaleLegend = ' '
Declare 
@GradeSymbol nvarchar(20),
@GradeDescription nvarchar(100),
@PreviousGradeScaleLowPercentage int,
@GradeScaleLowPercentage int,
@GradeOrder int,
@GradeID int,
@CGID int,
@ShowPercentage bit,
@TopGradeID int


Declare @tmpCustomGradeScaleGrades table
(
GradeID int identity,
GradeSymbol nvarchar(20),
GradeDescription nvarchar(100),
LowPercentage decimal (5,2),
GradeOrder int
)


Set @ShowPercentage = (Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = @CustomGradescaleID)

Insert into @tmpCustomGradeScaleGrades
Select 
GradeSymbol, 
GradeDescription,
ceiling(LowPercentage) as LowPercentage, 
GradeOrder
from CustomGradeScaleGrades
Where CustomGradeScaleID = @CustomGradescaleID
Order By GradeOrder

Set @TopGradeID = (Select top 1 GradeID From @tmpCustomGradeScaleGrades)

While exists(Select * From @tmpCustomGradeScaleGrades)
Begin

	Select top 1
	@GradeID = GradeID,
	@GradeSymbol = GradeSymbol,
	@GradeDescription = GradeDescription,
	@GradeOrder = GradeOrder,
	@GradeScaleLowPercentage = LowPercentage
	From @tmpCustomGradeScaleGrades
	
	If @ShowPercentage = 0
		Begin
			Set @GradeScaleLegend = @GradeScaleLegend + '<span style="white-space:nowrap">' + @GradeSymbol + '=(' + @GradeDescription + ')</span>  '
		End
		Else
		Begin

			If @GradeID = @TopGradeID
			Begin
				Set @GradeScaleLegend = @GradeScaleLegend + '<span style="white-space:nowrap">' + @GradeSymbol + '=(' + convert(nvarchar(3),@GradeScaleLowPercentage) + '-100)</span>  '
			End
			Else
			Begin
				Set @GradeScaleLegend = @GradeScaleLegend + '<span style="white-space:nowrap">' + @GradeSymbol + '=(' + convert(nvarchar(3),@GradeScaleLowPercentage) + '-'+ convert(nvarchar(3),@PreviousGradeScaleLowPercentage) + ')</span>  '
			End

			Set @PreviousGradeScaleLowPercentage = @GradeScaleLowPercentage - 1

		End

	Delete From @tmpCustomGradeScaleGrades Where GradeID = @GradeID

	if LEN(@GradeScaleLegend)>=1900
	BEGIN
		SET @GradeScaleLegend = REPLACE(REPLACE(@GradeScaleLegend,'<span style="white-space:nowrap">',''),'</span>','')
	END

End	-- While Loop

	-- Return the result of the function
	RETURN @GradeScaleLegend

END
GO
