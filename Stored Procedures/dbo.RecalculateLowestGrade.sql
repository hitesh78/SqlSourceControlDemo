SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[RecalculateLowestGrade]
	@TypeID int
as
	
	Declare @LowestGradeOption int
	Declare @ClassID int

	Set @ClassID = (Select ClassID from AssignmentType where TypeID = @TypeID)
	Set @LowestGradeOption = (Select DropLowestGrade from AssignmentType where TypeID = @TypeID)

	If @LowestGradeOption = 0
	Begin
		Update Grades
		Set LowestGrade = 0
		From 
		Grades G 
			inner join 
		Assignments A
			on A.AssignmentID = G.AssignmentID
		where A.TypeID = @TypeID
	End
	Else
	Begin
		Execute MarkLowestGrade @TypeID
	End
	
	Execute MasterUpdateStudentGrade @ClassID


GO
