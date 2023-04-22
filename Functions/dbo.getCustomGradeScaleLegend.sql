SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[getCustomGradeScaleLegend]
(
@ClassTypeID int
)
RETURNS nchar(1000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @GradeScaleLegend nvarchar(1000)

	-- Add the T-SQL statements to compute the return value here

	Set @GradeScaleLegend = ' '
	Declare 
	@GradeID int,
	@GradeScaleItem nvarchar(50),
	@GradeScaleItemDescription nvarchar(200),
	@GradeScaleOrder int

	Declare @tmpGradeScaleGrades table
	(
	GradeID int identity,
	GradeScaleItem nvarchar(50),
	GradeScaleItemDescription nvarchar(200),
	GradeScaleOrder int
	)

	Insert into @tmpGradeScaleGrades
	Select 
	GradeScaleItem, 
	GradeScaleItemDescription,
	GradeScaleOrder
	from GradeScale
	Where ClassTypeID = @ClassTypeID
	Order By GradeScaleOrder

	While exists(Select * From @tmpGradeScaleGrades)
	Begin

		Select top 1
		@GradeID = GradeID,
		@GradeScaleItem = GradeScaleItem,
		@GradeScaleItemDescription = GradeScaleItemDescription
		From @tmpGradeScaleGrades
		
		Set @GradeScaleLegend = @GradeScaleLegend + '(' + @GradeScaleItem + ')' + '=' + @GradeScaleItemDescription + '  '

		Delete From @tmpGradeScaleGrades Where GradeID = @GradeID

	End	-- While Loop

	-- Return the result of the function
	RETURN @GradeScaleLegend

END

GO
