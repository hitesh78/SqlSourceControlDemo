SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[getUnitGPA]
(
@ClassID int,
@PercentageGrade decimal(6,2)
)
RETURNS decimal(7,4)
AS
BEGIN


	RETURN
	(
	Select top 1 
	case
		when CGG.GPAValue = 0 then 0
		else (CGG.GPAValue + CG.GPABoost) * C.Units
	end as GPAValue
	From 
	Classes C
		inner join
	CustomGradeScale CG
		on C.CustomGradeScaleID = CG.CustomGradeScaleID
		inner join
	CustomGradeScaleGrades CGG
		on CG.CustomGradeScaleID = CGG.CustomGradeScaleID
	where 
	C.ClassID = @ClassID
	and
	CGG.LowPercentage <= @PercentageGrade
	Order By CGG.LowPercentage desc
	)


END



GO
