SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MasterUpdateAssignmentWeight] @TypeID int
As

Begin


ALTER TABLE Assignments DISABLE TRIGGER ALL 
ALTER TABLE AssignmentType DISABLE TRIGGER ALL 
ALTER TABLE Assignments Enable TRIGGER LogAssignmentUpdates 

	   Declare @AssignmentCount real
	   Declare @TypeWeight real
	   Declare @AssignmentWt real
   	   Declare @AssignmentEC int
	   Declare @DropLowestGrade int
	   Declare @RelativeWeighting int
	   Declare @ClassID int
	   Declare @TotalPoints real
	   Declare @PointsWeightedAssignmentTypes bit
	   Declare @ZeroPointAssignmentsCount int
	   Declare @WeightedAssignmentCount int
	   


		Select
			@AssignmentEC = TypeEC,
			@TypeWeight = TypeWeight,
			@DropLowestGrade = DropLowestGrade,
			@RelativeWeighting = RelativeWeighting,
			@ClassID = ClassID
		From AssignmentType 
		where TypeID = @TypeID


	   Set @PointsWeightedAssignmentTypes = (Select PointsWeightedAssignmentTypes From Classes Where ClassID = @ClassID)

		If @PointsWeightedAssignmentTypes = 1
		Begin
			Set @AssignmentCount = (Select count(AssignmentID) from Assignments where ClassID = @ClassID and NongradedAssignment = 0)
		End
		Else
		Begin
			Set @AssignmentCount = (Select count(AssignmentID) from Assignments where TypeID = @TypeID and NongradedAssignment = 0)
			Set @ZeroPointAssignmentsCount = (
												Select count(AssignmentID) 
												From Assignments 
												Where 
												TypeID = @TypeID
												and
												GradeStyle = 3
												and
												OutOf = 0
												and 
												NongradedAssignment = 0
											)
		End

	   If (@DropLowestGrade = 1)
	   Begin
		if @AssignmentCount > 1
		Begin
		   Set @AssignmentCount = @AssignmentCount - 1
		End
	   End
	   

	   If (@AssignmentCount > 0)
	   Begin
	   
			If (@PointsWeightedAssignmentTypes = 1)
			Begin
			
				Set @TotalPoints = 
				(
					Select Sum(OutOf)
					From 
						Assignments A
							inner join
						AssignmentType AT
							on A.TypeID = AT.TypeID
					Where 
					A.ClassID = @ClassID
					and
					AT.TypeEC = 0
					and
					NongradedAssignment = 0
				)
		
				If @TotalPoints is null	-- if the first assignments added are extra credit just use 100 for totalpoints
				Begin
					Set @TotalPoints = 100
					
					Update Assignments
					Set Weight = (OutOf/@TotalPoints)* 100
					From 	Assignments	
					Where 
					ClassID = @ClassID
					and 
					NongradedAssignment = 0
				End
				Else
				Begin

					Update Assignments
					Set EC = @AssignmentEC
					Where
					TypeID = @TypeID
					and 
					NongradedAssignment = 0					
					
					If @TotalPoints = 0
					Begin
						Update Assignments
						Set Weight = 0
						From 	Assignments	
						Where ClassID = @ClassID
						and 
						NongradedAssignment = 0						
						
						Update AssignmentType
						Set TypeWeight = 0
						Where 
						TypeID = @TypeID						
						
					End
					Else
					Begin
						Update Assignments
						Set Weight = (OutOf/@TotalPoints)* 100
						From 	Assignments	
						Where 
						ClassID = @ClassID
						and 
						NongradedAssignment = 0						
						
						
						Execute UpdatePointsWeightedAssignmentTypes @ClassID
					End
					
				End
				
			End
			Else If @RelativeWeighting = 1
			Begin
			
				Set @TotalPoints = (Select Sum(OutOf)From Assignments Where TypeID = @TypeID and NongradedAssignment = 0)
		
				Update Assignments
				Set Weight =
					case 
						when @TotalPoints = 0 then 0
						else (OutOf/@TotalPoints)* @TypeWeight
					end,
					 EC = @AssignmentEC
				From 	Assignments	
				Where 
				TypeID = @TypeID
				and 
				NongradedAssignment = 0
			End
			Else
			Begin
				
				set @WeightedAssignmentCount = @AssignmentCount - @ZeroPointAssignmentsCount
				
				If @WeightedAssignmentCount < 1
				Begin
					Set @AssignmentWt = 0
				End
				Else
				Begin
					Set @AssignmentWt = @TypeWeight / @WeightedAssignmentCount
				End
				
				 Update Assignments
				 Set Weight = 
					case
						when GradeStyle = 3 and OutOf = 0 then 0
						else @AssignmentWt
					end,
					EC = @AssignmentEC
				 Where 
				 TypeID = @TypeID
				 and 
				 NongradedAssignment = 0
			End

	   End
	   Else If (@PointsWeightedAssignmentTypes = 1)
	   Begin
			Update AssignmentType
			Set TypeWeight = 0
			Where 
			TypeID = @TypeID
	   End
	   
	   
	   If @DropLowestGrade = 1 
	   Begin
			Execute MarkLowestGrade @TypeID
	   End
	   
ALTER TABLE Assignments Enable TRIGGER ALL 
ALTER TABLE AssignmentType Enable TRIGGER ALL 

	-----------------Update Student Class Grade-----------------------
	Execute MasterUpdateStudentGrade @ClassID


End

GO
