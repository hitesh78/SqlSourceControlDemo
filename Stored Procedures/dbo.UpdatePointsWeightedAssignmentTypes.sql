SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/11/2012
-- Description:	Used to Calculate and Update Assignment Type Weight
-- When using PointsWeightedAssignmentTypes
-- =============================================
CREATE Procedure [dbo].[UpdatePointsWeightedAssignmentTypes]
	@ClassID int
AS
BEGIN

	SET NOCOUNT ON;

	Declare @TypeIDs table(ID int identity(1,1), TypeID int, TypeEC bit, TypeTotalPoints real)
	Declare @TotalPoints real

	Insert into @TypeIDs
	Select 
	AT.TypeID,
	AT.TypeEC,
	isnull((Select Sum(OutOf) From Assignments Where TypeID = AT.TypeID and NongradedAssignment = 0),0)
	From AssignmentType AT
	Where
	ClassID = @ClassID

	Declare @NumLines int = @@RowCount

	Set @TotalPoints = (Select Sum(TypeTotalPoints)	From @TypeIDs Where TypeEC = 0)


	Declare @LineNumber int = 1
	Declare @TypeTotalPoints real
	Declare @TypeID int


	While @LineNumber <= @NumLines
	Begin

		Select
		@TypeID = TypeID,
		@TypeTotalPoints = TypeTotalPoints
		From @TypeIDs 
		Where ID = @LineNumber
		
		Update AssignmentType
		Set TypeWeight = @TypeTotalPoints / @TotalPoints * 100
		Where
		TypeID  = @TypeID		

		Set @LineNumber = @LineNumber + 1

	End

END

GO
