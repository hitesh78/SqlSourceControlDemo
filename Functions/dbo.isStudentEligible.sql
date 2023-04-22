SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 5/1/2013
-- Description:	Returns 1 if student is eligible otherwise returns 0
-- =============================================
CREATE FUNCTION [dbo].[isStudentEligible]
(
	@StudentID int
)
RETURNS bit
AS
BEGIN

	Declare @EligibilityStatus bit
	Declare @SportsEligibilityLetterGrade nvarchar(5) = (Select SportsEligibilityLetterGrade From Settings Where SettingID = 1)
	Declare @SportEligibilityGPA decimal(3,2) = (Select SportEligibilityGPA From Settings where SettingID = 1)


	if exists
	(
	Select
	CS.StudentID
	From
	ClassesStudents CS
		inner join
	Classes C
		on CS.ClassID = C.ClassID
		inner join
	CustomGradeScale CG
		on C.CustomGradeScaleID = CG.CustomGradeScaleID
		inner join
	Terms T
		on C.TermID = T.TermID
	Where
	CS.StudentID = @StudentID
	and
	C.ClassTypeID = 1
	and
	C.Units > 0
	and
	CS.StudentGrade is not null
	and
	CG.CalculateGPA = 1
	and  
	T.Status = 1
	and
	GETDATE() between T.StartDate and T.EndDate
	Group By CS.StudentID
	Having (
	convert(decimal(6,2),round((sum(dbo.getUnitGPA(C.ClassID, CS.StudentGrade)) / sum(C.Units)),4))
	) < @SportEligibilityGPA

	Union

	Select
	CS.StudentID
	From
	ClassesStudents CS
		inner join
	Classes C
		on CS.ClassID = C.ClassID
		inner join
	Terms T
		on C.TermID = T.TermID
		inner join
	CustomGradeScaleGrades CGG
		on	C.CustomGradeScaleID = CGG.CustomGradeScaleID
			and
			CGG.GradeSymbol = dbo.GetLetterGrade(CS.ClassID, CS.StudentGrade)
			and
			CGG.GradeOrder >= dbo.GetLowGradeOrder(C.CustomGradeScaleID, @SportsEligibilityLetterGrade)	
	Where
	CS.StudentID = @StudentID
	and
	T.Status = 1
	and
	GETDATE() between T.StartDate and T.EndDate
	and
	C.ClassTypeID in (1,8)
	and
	CS.StudentGrade is not null
	Group By CS.StudentID
	)
	Begin
		Set @EligibilityStatus = 0
	End
	Else
	Begin
		Set @EligibilityStatus = 1
	End

	Return @EligibilityStatus

END

GO
