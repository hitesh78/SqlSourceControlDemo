CREATE TABLE [dbo].[Assignments]
(
[AssignmentID] [int] NOT NULL IDENTITY(1, 1),
[ClassID] [int] NOT NULL,
[AssignmentTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DueDate] [smalldatetime] NOT NULL,
[DateAssigned] [smalldatetime] NOT NULL,
[Weight] [decimal] (10, 4) NOT NULL CONSTRAINT [DF_Assignments_Weight] DEFAULT ((0)),
[Curve] [decimal] (10, 4) NOT NULL CONSTRAINT [DF_Assignments_Curve] DEFAULT ((0)),
[ADescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AverageGrade] [decimal] (10, 4) NULL,
[AverageGradeScore] [decimal] (10, 4) NULL,
[EC] [bit] NOT NULL CONSTRAINT [DF_Assignments_EC] DEFAULT ((0)),
[GradeStyle] [tinyint] NOT NULL CONSTRAINT [DF_Assignments_GradeStyle] DEFAULT ((1)),
[OutOf] [smallint] NULL,
[TypeID] [int] NOT NULL,
[NongradedAssignment] [bit] NOT NULL CONSTRAINT [DF_Assignments_UngradedAssignment] DEFAULT ((0)),
[gcCourseWorkID] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[AddAssignment]
on [dbo].[Assignments]
After Insert
As

Insert into Grades (CSID, AssignmentID)
Select CS.CSID, I.AssignmentID
From ClassesStudents CS inner join Inserted I
on CS.ClassID = I.ClassID
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[DeleteAssignment]
on [dbo].[Assignments]
Instead of Delete
AS

-- Delete Grades for the Assignments
ALTER TABLE Grades DISABLE TRIGGER ALL 
Delete Grades
From 
Grades G 
	inner join 
Deleted D
	on G.AssignmentID = D.AssignmentID
ALTER TABLE Grades ENABLE TRIGGER ALL

-- Delete Attachements


Declare @BinFileIDs table (FileID int)

Insert into @BinFileIDs
Select 
FileID
From AssignmentBinFiles
Where 
AssignmentID in (Select AssignmentID From Deleted)

Delete AssignmentBinFiles
Where AssignmentID in (Select AssignmentID From Deleted)


Delete From BinFiles
Where FileID in (Select FileID From @BinFileIDs)

Update LPAssignmentCollections
Set AssignmentID = null
Where
AssignmentID in (Select AssignmentID From Deleted)

-- Delete Assignments
Delete From Assignments
Where AssignmentID in (Select AssignmentID From Deleted)

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[LogAssignmentDeletes]
on [dbo].[Assignments]
After delete
As
Begin

	Declare @CalcDate datetime = dbo.GLgetdatetime()

	If (Select ClassID from Deleted) is not null
	Begin
	  Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
	  SELECT 
	  ClassID as ClassID,
	  DATENAME(weekday, @CalcDate) as TheWeekday,
	  @CalcDate as LogDate,
	  dbo.T(-0.1, 'Assignment')+ ': '+ AssignmentTitle + ' ' + dbo.T(-0.1, 'Deleted') as Item,
	  dbo.T(-0.1, 'N/A') as BeforeChange,
	  dbo.T(-0.1, 'N/A')  as AfterChange
	  From Deleted
	End
End





GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[LogAssignmentInserts]
on [dbo].[Assignments]
After Insert
As

Begin
  Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
  SELECT 
	ClassID,
  	DATENAME(weekday, dbo.GLgetdatetime()) as TheWeekday,
  	dbo.GLgetdatetime() as LogDate,
  	dbo.T(-0.1, 'Assignment') + ': ' + AssignmentTitle + ' ' + dbo.T(-0.1, 'Added') as Item,
  	dbo.T(-0.1, 'N/A') as BeforeChange,
  	dbo.T(-0.1, 'N/A') as AfterChange
  From Inserted
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[LogAssignmentUpdates]
on [dbo].[Assignments]
After Update
As
Begin

Declare @ClassID int
Set @ClassID = (Select top 1 ClassID from Inserted)

-- Get Date Info
Declare @TheWeekday nvarchar(15)
Declare @LogDate datetime

Set @TheWeekday = DATENAME(weekday, dbo.GLgetdatetime())
Set @LogDate = dbo.GLgetdatetime()

-- Log AssignmentName changes
Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
Select 	@ClassID as ClassID,
		@TheWeekday as TheWeekday,
		@LogDate as LogDate,
		dbo.T(-0.1, 'Assignment Name') as Item,
		D.AssignmentTitle,
		I.AssignmentTitle
From 	Deleted D
			inner join
		Inserted I
			on D.AssignmentID = I.AssignmentID
Where D.AssignmentTitle != I.AssignmentTitle


-- Log Due Date changes
Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
Select 	@ClassID as ClassID,
		@TheWeekday as TheWeekday,
		@LogDate as LogDate,
		dbo.T(-0.1, 'Due Date for')  + ' ' +  I.AssignmentTitle as Item,
		D.DueDate,
		I.DueDate
From 	Deleted D
			inner join
		Inserted I
			on D.AssignmentID = I.AssignmentID
Where D.DueDate != I.DueDate


-- Log Date Assigned changes
Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
Select 	@ClassID as ClassID,
		@TheWeekday as TheWeekday,
		@LogDate as LogDate,
		dbo.T(-0.1, 'Date Assigned for')  + ' ' +  I.AssignmentTitle as Item,
		D.DateAssigned,
		I.DateAssigned
From 	Deleted D
			inner join
		Inserted I
			on D.AssignmentID = I.AssignmentID
Where D.DateAssigned != I.DateAssigned


-- Log Weight changes
Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
Select 	@ClassID as ClassID,
		@TheWeekday as TheWeekday,
		@LogDate as LogDate,
		dbo.T(-0.1, 'Weight for')  + ' ' +  I.AssignmentTitle as Item,
		Convert(decimal(7,2),Round(D.Weight,3)),
		Convert(decimal(7,2),Round(I.Weight,3))
From 	Deleted D
			inner join
		Inserted I
			on D.AssignmentID = I.AssignmentID
Where D.Weight != I.Weight


-- Log Curve changes
Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
Select 	@ClassID as ClassID,
		@TheWeekday as TheWeekday,
		@LogDate as LogDate,
		dbo.T(-0.1, 'Curve for')  + ' ' +  I.AssignmentTitle as Item,
		Convert(Int,Round(D.Curve,0)),
		Convert(Int,Round(I.Curve,0))
From 	Deleted D
			inner join
		Inserted I
			on D.AssignmentID = I.AssignmentID
Where D.Curve != I.Curve


-- Log Assignment Description changes
Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
Select 	@ClassID as ClassID,
		@TheWeekday as TheWeekday,
		@LogDate as LogDate,
		dbo.T(-0.1, 'Description for')  + ' ' +  I.AssignmentTitle as Item,
		D.ADescription,
		I.ADescription
From 	Deleted D
			inner join
		Inserted I
			on D.AssignmentID = I.AssignmentID
Where D.ADescription != I.ADescription


-- Log Assignment Type changes
Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
Select 	@ClassID as ClassID,
		@TheWeekday as TheWeekday,
		@LogDate as LogDate,
		dbo.T(-0.1, 'Assignment Type for')  + ' ' +  I.AssignmentTitle as Item,
		(Select TypeTitle From AssignmentType Where TypeID = D.TypeID),
		(Select TypeTitle From AssignmentType Where TypeID = I.TypeID)
From 	Deleted D
			inner join
		Inserted I
			on D.AssignmentID = I.AssignmentID
Where D.TypeID != I.TypeID

End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateCurve]
 on [dbo].[Assignments]
 After Update
As

If Update(Curve)

Begin

	Declare @InsertedCurve decimal(10,4) = (Select Curve From Inserted);
	Declare @DeletedCurve decimal(10,4) = (Select Curve From Deleted);
	Declare @InsertedOutOf smallint = (Select OutOf From Inserted);
	Declare @InsertedGradeStyle tinyint = (Select GradeStyle From Inserted);
	Declare @InsertedClassID int = (Select ClassID From Inserted);
	Declare @CustomGradeScaleID int = (Select CustomGradeScaleID From Classes where ClassID = @InsertedClassID)

	If @InsertedCurve != @DeletedCurve
	Begin

		Update Grades
		Set Grade = 
		case 
			when @InsertedGradeStyle = 3 then ((OutOfCorrect / @InsertedOutOf * 100) + @InsertedCurve)
			when @InsertedGradeStyle = 2 then (dbo.getPercentageGradeFromLetterGrade(LetterGrade, @CustomGradeScaleID) + @InsertedCurve)
			else ((Grade - @DeletedCurve) + @InsertedCurve)
		end
		From 
		Grades G 
			inner join 
		Inserted I
			on G.AssignmentID = I.AssignmentID
	
	End

End

--GO
--EXEC sp_settriggerorder @triggername=N'[dbo].[UpdateCurve]', @order=N'Last', @stmttype=N'UPDATE'


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateGradingStyle]
 on [dbo].[Assignments]
 After Update
As

If (Update(GradeStyle))
Begin

	Update Grades
	Set OutOfCorrect = null
	From 
	Grades G 
		inner join 
	Inserted I
		on G.AssignmentID = I.AssignmentID
		inner join
	Deleted D
		on D.AssignmentID = I .AssignmentID
	Where
	D.GradeStyle != I.GradeStyle
	and
	I.GradeStyle != 3
	
End
-- =============================================
-- Author:		Duke/Don
-- Create date: 7/28/2014
-- Description:	Creates family and account records
--              for adds from SIS which need to be processed during
--              the update pass since I don't stores names on the 
--              initial student record insert (only a placeholder record is created). 
-- =============================================
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateOutOf]
 on [dbo].[Assignments]
 After Update
As

If Update(OutOf) and (Select OutOf from Inserted) != (Select OutOf from Deleted)
Begin

	Update Grades
	Set Grade = 
	case 
		when I.OutOf = 0 then (G.OutOfCorrect/.0001) / 100
		else (G.OutOfCorrect/I.OutOf) * 100
	end
	From 
	Grades G 
		inner join 
	Inserted I
		on G.AssignmentID = I.AssignmentID
		


	Declare @ClassID int = (Select ClassID From Inserted)
	Declare @TypeID int = (Select TypeID From Inserted)

	-- Set new weight if using RelativeWeighting
	Declare @AssignmentTypeRelativeWeighting int = (Select RelativeWeighting From AssignmentType Where TypeID = @TypeID)
	Declare @PointsWeightedAssignmentTypes bit = (Select PointsWeightedAssignmentTypes From Classes Where ClassID = @ClassID)

	If @AssignmentTypeRelativeWeighting = 1 or @PointsWeightedAssignmentTypes = 1
	Begin
		Execute MasterUpdateAssignmentWeight @TypeID
	End
	

	
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateWeightOnAddAssignment]
on [dbo].[Assignments]
After Insert
As
Begin
	Declare @TypeID int
	Set @TypeID = (Select top 1 TypeID from Inserted)

	Execute MasterUpdateAssignmentWeight @TypeID
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateWeightOnDeleteAssignment]
on [dbo].[Assignments]
After Delete
As
Begin
	Declare @TypeID int = (Select TypeID from Deleted)
	Execute MasterUpdateAssignmentWeight @TypeID
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateWeightOnEditAssignment]
on [dbo].[Assignments]
After Update
As
Begin
    If Update(TypeID) or Update(NongradedAssignment)
    Begin
		If (
			(Select TypeID from Inserted) != (Select TypeID from Deleted)
			or
			(Select NongradedAssignment from Inserted) != (Select NongradedAssignment from Deleted)	
		)
		Begin

			Declare @NewTypeID int = (Select TypeID from Inserted)
			Declare @OldTypeID int = (Select TypeID from Deleted)   

			-- Check for changes in DropLowestGrade in both the new and old Assignment Types
			Declare @NewTypeIDDLG int = (Select DropLowestGrade From AssignmentType Where TypeID = @NewTypeID)
			Declare @OldTypeIDDLG int = (Select DropLowestGrade From AssignmentType Where TypeID = @OldTypeID)

			If @OldTypeIDDLG = 1 or @NewTypeIDDLG = 1
			Begin
				Execute RecalculateLowestGrade @OldTypeID
				Execute RecalculateLowestGrade @NewTypeID
			End

			-- Change Weights for all assignments for both new and old Assignment Types
			if @NewTypeID = @OldTypeID
			Begin
				Execute MasterUpdateAssignmentWeight @NewTypeID
			End
			Else
			Begin
				Execute MasterUpdateAssignmentWeight @NewTypeID
				Execute MasterUpdateAssignmentWeight @OldTypeID
			End

		End
    End
End
GO
ALTER TABLE [dbo].[Assignments] ADD CONSTRAINT [PK_Assignments] PRIMARY KEY CLUSTERED ([AssignmentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassID] ON [dbo].[Assignments] ([ClassID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Assignments_ClassID_DueDate] ON [dbo].[Assignments] ([ClassID], [DueDate]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TypeID] ON [dbo].[Assignments] ([TypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Assignments] ADD CONSTRAINT [FK_Assignments_AssignmentType] FOREIGN KEY ([TypeID]) REFERENCES [dbo].[AssignmentType] ([TypeID])
GO
ALTER TABLE [dbo].[Assignments] ADD CONSTRAINT [FK_Assignments_Classes] FOREIGN KEY ([ClassID]) REFERENCES [dbo].[Classes] ([ClassID])
GO
