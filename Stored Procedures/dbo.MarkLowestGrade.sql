SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 11/13/2012
-- Description:	Updates Lowest Grade Column indicator for all assignments of a specific Assignmenttype
-- =============================================
CREATE Procedure [dbo].[MarkLowestGrade] @AssignmentType int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Declare @tmpGradeIDs table (GradeID int, NewLowestGradeID int, NewHighestGradeID int)

	Insert into @tmpGradeIDs
	Select
	GradeID,
	(
		Select top 1 G.GradeID
		From 
		Grades G 
			inner join
		Assignments A
			on G.AssignmentID = A.AssignmentID 
		where 
		A.TypeID = @AssignmentType 
		and 
		G.CSID = G2.CSID
		and 
		G.Grade is not null
		and 
		A.NongradedAssignment = 0
		Order By G.Grade, A.DueDate
	) as NewLowestGradeID,
	(
		Select top 1 G.GradeID
		From 
		Grades G 
			inner join
		Assignments A
			on G.AssignmentID = A.AssignmentID 
		where 
		A.TypeID = @AssignmentType 
		and 
		G.CSID = G2.CSID
		and 
		G.Grade is not null
		and 
		A.NongradedAssignment = 0		
		Order By G.Grade Desc, A.DueDate Desc
	) as NewHighestGradeID
	From
	Grades G2
		inner join
	Assignments A
		on G2.AssignmentID = A.AssignmentID
	Where
	A.TypeID = @AssignmentType
	and 
	A.NongradedAssignment = 0	


	ALTER TABLE Grades DISABLE TRIGGER ALL 
	Update Grades
	Set LowestGrade = 
	case
		when T.NewLowestGradeID = T.NewHighestGradeID then 0 -- if only one assignment Don't set
		when G.GradeID = T.NewLowestGradeID then 1 
		else 0
	end
	From
	Grades G
		inner join
	@tmpGradeIDs T
		on G.GradeID = T.GradeID
	ALTER TABLE Grades ENABLE TRIGGER ALL


END

GO
