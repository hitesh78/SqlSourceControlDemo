SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[MasterUpdateStudentGrade] @ClassID int
As


Declare @GradeAverageBasedonTypeWeight int
Set @GradeAverageBasedonTypeWeight = (Select GradeAverageBasedonTypeWeight From Settings Where SettingID = 1)

If @GradeAverageBasedonTypeWeight = 1
Begin
		
	Update ClassesStudents
	Set StudentGrade = 	SG.ClassGradeAvg + isnull(C.Curve,0)
	From 
	Classes C
		inner join
	ClassesStudents CS
		on C.ClassID = CS.ClassID
		inner join
	(
		Select 
		CS.CSID,
		Sum(TypeAvg) / sum(TypeWeight)
		+
		isnull(	-- Then add extra credit assignments averge
			(
				Select Sum(G.Grade*(.01*A.Weight))
				From 
				Grades G 
					inner join 
				Assignments A
					on G.AssignmentID = A.AssignmentID
				Where 
				G.CSID = CS.CSID 
				and 
				G.Grade is not null 
				and 
				A.EC = 1
				and 
				A.NongradedAssignment = 0				
			)
		,0) as ClassGradeAvg

		From 
		ClassesStudents CS
			left join
		(
			Select 
			CSID,
			(Sum((G.Grade*A.Weight)) / Sum(A.Weight))*AT.TypeWeight as TypeAvg,
			AT.TypeWeight as TypeWeight
			from 
			Grades G 
				inner join 
			Assignments A
				on G.AssignmentID = A.AssignmentID
				inner join 
			AssignmentType AT
				on A.TypeID = AT.TypeID
				inner join
			Classes C
				on C.ClassID = AT.ClassID
			Where 
			C.ClassID = @ClassID
			and 
			G.Grade is not null
			and 
			G.LowestGrade = 0
			and
			A.EC = 0
			and
			AT.TypeWeight != 0	
			and 
			A.NongradedAssignment = 0			
			Group by AT.TypeWeight, AT.TypeID, G.CSID
		)T
			on CS.CSID = T.CSID 
		Where CS.ClassID = @ClassID
		Group By CS.CSID
	) SG
		on CS.CSID = SG.CSID
	Where 
	CS.StudentConcludeDate is null
	
End
Else
Begin

	Update ClassesStudents
	Set StudentGrade = 	SG.ClassGradeAvg + isnull(C.Curve,0)
	From 
	Classes C
		inner join
	ClassesStudents CS
		on C.ClassID = CS.ClassID
		inner join
	(
		Select
		CS.CSID,
		(	-- get overall Average excluding extra credit assignments
			Select (Sum((G.Grade*A.Weight)) / Sum(A.Weight))
			From 
			Grades G 
				inner join 
			Assignments A
				on G.AssignmentID = A.AssignmentID
			Where 
			G.CSID = CS.CSID 
			and 
			G.Grade is not null
			and 
			G.LowestGrade = 0
			and
			A.EC = 0
			and
			A.Weight != 0
			and 
			A.NongradedAssignment = 0			
		) 
		+
		isnull(	-- Then add extra credit assignments averge
			(
				Select Sum(G.Grade*(.01*A.Weight))
				From 
				Grades G 
					inner join 
				Assignments A
					on G.AssignmentID = A.AssignmentID
				Where 
				G.CSID = CS.CSID 
				and 
				G.Grade is not null 
				and 
				A.EC = 1
				and 
				A.NongradedAssignment = 0				
			)
		,0) as ClassGradeAvg
		From ClassesStudents CS
		Where
		CS.ClassID = @ClassID
	) SG
		on CS.CSID = SG.CSID
	Where 
	CS.StudentConcludeDate is null		

End

GO
