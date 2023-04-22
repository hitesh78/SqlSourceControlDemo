CREATE TABLE [dbo].[AssignmentType]
(
[TypeID] [int] NOT NULL IDENTITY(1, 1),
[TypeTitle] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeWeight] [decimal] (5, 2) NOT NULL,
[TypeEC] [tinyint] NOT NULL CONSTRAINT [DF_AssignmentType_TypeEC] DEFAULT ((0)),
[DropLowestGrade] [bit] NOT NULL CONSTRAINT [DF_AssignmentType_DropLowestGrade] DEFAULT ((0)),
[RelativeWeighting] [bit] NOT NULL CONSTRAINT [DF_AssignmentType_RelativeWeighting] DEFAULT ((0)),
[ClassID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateDropLowestGrade]
on [dbo].[AssignmentType]
After Update
As
Begin

If Update(DropLowestGrade)
Begin

Declare @InsertedLowestGrade bit
Declare @DeletedLowestGrade bit
Declare @TypeID int
Declare @ClassID int

Set @TypeID = (Select TypeID from Inserted)
Set @InsertedLowestGrade = (Select DropLowestGrade from Inserted)
Set @DeletedLowestGrade = (Select DropLowestGrade from Deleted)
Set @ClassID = (Select ClassID from AssignmentType where TypeID = @TypeID)

If @InsertedLowestGrade != @DeletedLowestGrade
Begin

Execute RecalculateLowestGrade @TypeID

End

End -- If Update(DropLowestGrade)
End


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateTypeTitle]
on [dbo].[AssignmentType]
After Update
As
Begin

If Update(TypeTitle)
Begin

	Declare @InsertedTypeTitle nvarchar(100)
	Declare @DeletedTypeTitle nvarchar(100)
	Declare @ClassID int

	Set @InsertedTypeTitle = (Select TypeTitle from Inserted)
	Set @DeletedTypeTitle = (Select TypeTitle from Deleted)
	Set @ClassID = (Select ClassID from Inserted)

	If @InsertedTypeTitle != @DeletedTypeTitle
	Begin

		Update AssignmentCollections
		Set AssignmentTypeName = @InsertedTypeTitle
		From 
		AssignmentCollections AC
			inner join
		LPAssignmentCollections LC
			on AC.ACID = LC.ACID
			inner join
		LessonPlans LP
			on LP.LPID = LC.LPID	 
		Where
		AC.AssignmentTypeName = @DeletedTypeTitle
		and
		LP.ClassID = @ClassID

	End

End -- If Update(TypeTitle)
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateTypeWeightandEC]
on [dbo].[AssignmentType]
After Update
As
Begin

If Update(TypeWeight) or Update(TypeEC)
Begin

	Declare @OldWeight int
	Declare @NewWeight int
	Declare @OldEC int
	Declare @NewEC int
	Declare @AssignmentCount real
	Declare @TypeID int
	Declare @ClassID int


	Set @OldWeight = (Select TypeWeight from Deleted)
	Set @NewWeight = (Select TypeWeight from Inserted)
	Set @OldEC = (Select TypeEC from Deleted)
	Set @NewEC = (Select TypeEC from Inserted)
	Set @TypeID = (Select TypeID from Inserted)
	Set @ClassID = (Select ClassID from Inserted)
	Set @AssignmentCount = (Select count(AssignmentID) from Assignments where TypeID = @TypeID and ClassID = @ClassID)
 
 
 
 
 If(@NewEC != @OldEC and @NewEC = 1)
 Begin	-- move NongradedAssignments to another type
	Declare @theType int =
	(
		Select top 1 TypeID
		From AssignmentType
		Where
		ClassID = @ClassID
		and
		TypeEC = 0
	)
	
	ALTER TABLE Assignments DISABLE TRIGGER ALL 
	
	Update Assignments
	Set TypeID = @theType
	Where
	ClassID = @ClassID
	and
	NongradedAssignment = 1

	ALTER TABLE Assignments ENABLE TRIGGER ALL	
	
 End

 If (@NewWeight != @OldWeight or @NewEC != @OldEC)
 Begin

   If (@AssignmentCount != 0)
   Begin
     Execute MasterUpdateAssignmentWeight @TypeID
   End
 End


End -- If Update(TypeWeight) or Update(TypeEC)
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Trigger [dbo].[UpdateWeightOnEditRelativeWeightSetting]
on [dbo].[AssignmentType]
After Update
As
Begin

If Update(RelativeWeighting)
Begin
	Declare @TypeID int
	Set @TypeID = (Select TypeID from Deleted)

	Execute MasterUpdateAssignmentWeight @TypeID
End

End
GO
ALTER TABLE [dbo].[AssignmentType] ADD CONSTRAINT [PK_AssignmentType] PRIMARY KEY CLUSTERED ([TypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassID] ON [dbo].[AssignmentType] ([ClassID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentType] ADD CONSTRAINT [FK_AssignmentType_Classes] FOREIGN KEY ([ClassID]) REFERENCES [dbo].[Classes] ([ClassID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
