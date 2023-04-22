SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetLowGradeOrder]
(	@CustomGradeScaleID int,
	@GradeSymbol nvarchar(3) )
RETURNS int
AS
BEGIN

RETURN 
(
	Select
	MIN(GradeOrder)
	From CustomGradeScaleGrades
	Where 
	CustomGradeScaleID = @CustomGradeScaleID
	and
	(
		GradeSymbol = @GradeSymbol
		or	
		(isnumeric(GradeSymbol) = 1 and GradeDescription = @GradeSymbol)
		-- Added the above line to support SC schools that use a 0-100 GradeScale and A-F 
		-- Gradescale for there Sports Elligibility Students.  In which case they were
		-- putting the Actual letter grade symbol in the GradeDescription
		-- School 1674 is the school that needed this.
	)
)
END




GO
