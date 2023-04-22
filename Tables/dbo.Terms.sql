CREATE TABLE [dbo].[Terms]
(
[TermID] [int] NOT NULL IDENTITY(1, 1),
[TermTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[Status] [bit] NOT NULL,
[ParentTermID] [int] NOT NULL CONSTRAINT [DF_Terms_ParentTermID] DEFAULT ((0)),
[TermWeight] [decimal] (5, 2) NULL,
[ExamTerm] [bit] NOT NULL CONSTRAINT [DF_Terms_ExamTerm] DEFAULT ((0)),
[TermCodeFilter] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdfiPeriodID] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Trigger [dbo].[AddTerm]
on [dbo].[Terms]
After Insert
As

Declare @ParentTermID int

Set @ParentTermID = (Select ParentTermID From Inserted)

If @ParentTermID != 0
Begin
	Execute UpdateTermWeights @ParentTermID
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[DeleteTerm]
on [dbo].[Terms]
After Delete
As

Declare @ParentTermID int

Set @ParentTermID = (Select ParentTermID From Deleted)

If @ParentTermID > 0
Begin
	Execute UpdateTermWeights @ParentTermID
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateTerm]
on [dbo].[Terms]
After Update
As

----------------------------------------------------------------------
--- Update NonSchoolDays attendance on this term's attendance classes
----------------------------------------------------------------------


	-- Get TermDateRange
	Declare @TermStartDeleted date
	Declare @TermEndDeleted date
	Declare @TermStartInserted date
	Declare @TermEndInserted date
	Declare @NonSchoolDaysItemsAffected int
	create table #NonSchoolDateItems (TheID int identity, DateID int)

	
	Set @TermStartDeleted = (Select StartDate From Deleted Where TermWeight = -1)
	Set @TermEndDeleted = (Select EndDate From Deleted Where TermWeight = -1)	
	Set @TermStartInserted = (Select StartDate From Inserted Where TermWeight = -1)
	Set @TermEndInserted = (Select EndDate From Inserted Where TermWeight = -1)	
	
	If (@TermStartDeleted != @TermStartInserted) or (@TermEndDeleted != @TermEndInserted)
	Begin
		
		-- Only get the DateItems if they were affected by a term date change
		Insert into #NonSchoolDateItems		
		Select DateID
		From dbo.NonSchoolDays
		Where 
		TheDate between @TermStartDeleted and @TermStartInserted
		or
		StartDate  between @TermStartDeleted and @TermStartInserted
		or
		EndDate  between @TermStartDeleted and @TermStartInserted
		or
		TheDate between @TermEndDeleted and @TermEndInserted
		or
		StartDate  between @TermEndDeleted and @TermEndInserted
		or
		EndDate  between @TermEndDeleted and @TermEndInserted
		or
		TheDate between @TermStartInserted and @TermStartDeleted
		or
		StartDate  between @TermStartInserted and @TermStartDeleted
		or
		EndDate  between @TermStartInserted and @TermStartDeleted
		or
		TheDate between @TermEndInserted and @TermEndDeleted
		or
		StartDate  between @TermEndInserted and @TermEndDeleted
		or
		EndDate  between @TermEndInserted and @TermEndDeleted		

	End

	If (Select count(*) From #NonSchoolDateItems) > 0
	Begin
	
	Alter table dbo.Attendance Disable trigger All
	
		Select 
		C.ClassID,
		C.ClassTypeID,
		I.TermID
		into #InsertedClasses
		From 
		Inserted I
			inner join
		Classes C
			on C.TermID = I.TermID	
		Where C.ClassTypeID = 5
		
		Select 
		C.ClassID,
		C.ClassTypeID,
		D.TermID
		into #DeletedClasses
		From 
		Deleted D
			inner join
		Classes C
			on C.TermID = D.TermID	
		Where C.ClassTypeID = 5
		
		
		Declare @ClassID int
		Declare @DateID int
		Declare @TheIDCount int
		Declare @TheID int
		
		Set @TheID = (Select min(TheID) From #NonSchoolDateItems)	
		Set @TheIDCount = (Select max(TheID) From #NonSchoolDateItems)	
	
		-- Delete NonSchoolDays Attendance
		While (Select count(*) From #DeletedClasses) > 0
		Begin

			Set @ClassID = (Select top 1 ClassID From #DeletedClasses)

			While @TheID <= @TheIDCount
			Begin			
				Set @DateID = (Select DateID From #NonSchoolDateItems Where TheID = @TheID)
				Execute dbo.DeleteNonSchoolDaysAttendance @DateID, @ClassID
				Set @TheID = @TheID + 1
			End
			
			Set @TheID = 1
			Delete From #DeletedClasses Where ClassID = @ClassID
			
		End
		
		Set @TheID = 1

		-- Add NonSchoolDays Attendance
		While (Select count(*) From #InsertedClasses) > 0
		Begin

			Set @ClassID = (Select top 1 ClassID From #InsertedClasses)

			While @TheID <= @TheIDCount
			Begin	
				Set @DateID = (Select DateID From #NonSchoolDateItems Where TheID = @TheID)
				Execute dbo.AddNonSchoolDaysAttendance @DateID, @ClassID
				Set @TheID = @TheID + 1
			End
			
			Set @TheID = 1
			Delete From #InsertedClasses Where ClassID = @ClassID

		End	
		
		drop table #NonSchoolDateItems
		drop table #InsertedClasses
		drop table #DeletedClasses
		
		Alter table dbo.Attendance Enable trigger All
	
	End -- if

--------------------------------------------------------------------------------------
------------------ Update Term Weights if Terms are a subterm ------------------------
--------------------------------------------------------------------------------------

Declare @InsertedParentTermID int
Declare @DeletedParentTermID int

Set @InsertedParentTermID = (Select Distinct ParentTermID From Inserted)
Set @DeletedParentTermID = (Select Distinct ParentTermID From Deleted)

If @InsertedParentTermID = @DeletedParentTermID
Begin
	Execute UpdateTermWeights @InsertedParentTermID
End
Else
Begin
	Execute UpdateTermWeights @InsertedParentTermID
	Execute UpdateTermWeights @DeletedParentTermID
End
GO
ALTER TABLE [dbo].[Terms] ADD CONSTRAINT [PK_Terms] PRIMARY KEY CLUSTERED ([TermID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Terms] ADD CONSTRAINT [FK_Terms_EdfiPeriods] FOREIGN KEY ([EdfiPeriodID]) REFERENCES [dbo].[EdfiPeriods] ([EdfiPeriodID])
GO
