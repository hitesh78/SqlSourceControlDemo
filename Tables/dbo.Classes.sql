CREATE TABLE [dbo].[Classes]
(
[ClassID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NOT NULL,
[ClassTitle] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportTitle] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpanishTitle] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportOrder] [int] NOT NULL CONSTRAINT [DF_Classes_ReportOrder] DEFAULT ((0)),
[Units] [decimal] (10, 6) NOT NULL,
[ClassTypeID] [int] NOT NULL,
[CustomGradeScaleID] [int] NOT NULL CONSTRAINT [DF_Classes_CustomGradeScaleID] DEFAULT ((0)),
[ParentClassID] [int] NOT NULL CONSTRAINT [DF_Classes_ParentClassID] DEFAULT ((0)),
[SubCommentClassTypeID] [int] NOT NULL CONSTRAINT [DF_Classes_SubCommentClassTypeID] DEFAULT ((0)),
[Concluded] [bit] NOT NULL CONSTRAINT [DF_Classes_Concluded] DEFAULT ((0)),
[CoachEmailAlert] [bit] NOT NULL CONSTRAINT [DF_Classes_CoachEmailAlert] DEFAULT ((0)),
[TermID] [int] NULL,
[AverageGrade] [decimal] (10, 4) NULL,
[Period] [int] NOT NULL,
[Location] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Curve] [int] NOT NULL CONSTRAINT [DF_Classes_Curve] DEFAULT ((0)),
[NonAcademic] [bit] NOT NULL CONSTRAINT [DF_Classes_Non-Academic] DEFAULT ((0)),
[TermCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IgnoreTranscriptGradeLevelFilter] [bit] NOT NULL CONSTRAINT [DF_Classes_IgnoreTranscriptGradeLevelFilter] DEFAULT ((0)),
[PointsWeightedAssignmentTypes] [bit] NOT NULL CONSTRAINT [DF_Classes_PointsWeightedAssignmentTypes] DEFAULT ((0)),
[CategoryID] [int] NULL,
[AddAssignmentTypesAsReportCardSubgrades] [bit] NOT NULL CONSTRAINT [DF_Classes_AddAssignmentTypesAsReportCardSubgrades] DEFAULT ((0)),
[CalendarId] [int] NULL,
[StandardsGroupID] [int] NULL,
[DefaultPresentValue] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Classes_DefaultPresentValue] DEFAULT ((1.00)),
[ShowBillingValueColumns] [bit] NOT NULL CONSTRAINT [DF_Classes_ShowBillingValueColumns] DEFAULT ((1)),
[PostCollectionID] [int] NULL CONSTRAINT [DF_Classes_PostCollectionID] DEFAULT (NULL),
[StdMinNumAssignmentsToMeet] [int] NOT NULL CONSTRAINT [DF_Classes_StdMinNumAssignmentsToMeet] DEFAULT ((2)),
[StdMinPercAvgToMeet] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Classes_StdMinPercAvgToMeet] DEFAULT ((85.0)),
[StdMinNumStudentsMeetingAvg] [int] NOT NULL CONSTRAINT [DF_Classes_StdMinNumStudentsMeetingAvg] DEFAULT ((85)),
[StdAverageAllAssignments] [bit] NOT NULL CONSTRAINT [DF_Classes_StdAverageAllAssignments] DEFAULT ((0)),
[StdRCShowOverallGrade] [bit] NOT NULL CONSTRAINT [DF_Classes_StdRCShowOverallGrade] DEFAULT ((1)),
[StdRCShowCategoryGrade] [bit] NOT NULL CONSTRAINT [DF_Classes_StdRCShowCategoryGrade] DEFAULT ((0)),
[StdRCShowSubCategoryGrade] [bit] NOT NULL CONSTRAINT [DF_Classes_StdRCShowSubCategoryGrade] DEFAULT ((1)),
[StdRCShowStandardGrade] [bit] NOT NULL CONSTRAINT [DF_Classes_StdRCShowStandardGrade] DEFAULT ((0)),
[ShowStandardsDataOnReportCards] [bit] NOT NULL CONSTRAINT [DF_Classes_ShowStandardsDataOnReportCards] DEFAULT ((0)),
[ShowStandardIDOnReportCards] [bit] NOT NULL CONSTRAINT [DF_Classes_ShowStandardIDOnReportCards] DEFAULT ((0)),
[LPClassColor] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BiWeeklySchedule] [bit] NOT NULL CONSTRAINT [DF_Classes_BiWeeklySchedule] DEFAULT ((0)),
[BiWeeklySchedStart2ndWeek] [bit] NOT NULL CONSTRAINT [DF_Classes_BiWeeklySchedStart2ndWeek] DEFAULT ((0)),
[PeriodOnSunday] [int] NOT NULL CONSTRAINT [DF_Classes_PeriodOnSunday] DEFAULT ((0)),
[PeriodOnMonday] [int] NOT NULL CONSTRAINT [DF_Classes_PeriodOnMonday] DEFAULT ((0)),
[PeriodOnTuesday] [int] NOT NULL CONSTRAINT [DF_Classes_PeriodOnTuesday] DEFAULT ((0)),
[PeriodOnWednesday] [int] NOT NULL CONSTRAINT [DF_Classes_PeriodOnWednesday] DEFAULT ((0)),
[PeriodOnThursday] [int] NOT NULL CONSTRAINT [DF_Classes_PeriodOnThursday] DEFAULT ((0)),
[PeriodOnFriday] [int] NOT NULL CONSTRAINT [DF_Classes_PeriodOnFriday] DEFAULT ((0)),
[PeriodOnSaturday] [int] NOT NULL CONSTRAINT [DF_Classes_PeriodOnSaturday] DEFAULT ((0)),
[BPeriodOnSunday] [int] NOT NULL CONSTRAINT [DF_Classes_BPeriodOnSunday] DEFAULT ((0)),
[BPeriodOnMonday] [int] NOT NULL CONSTRAINT [DF_Classes_BPeriodOnMonday] DEFAULT ((0)),
[BPeriodOnTuesday] [int] NOT NULL CONSTRAINT [DF_Classes_BPeriodOnTuesday] DEFAULT ((0)),
[BPeriodOnWednesday] [int] NOT NULL CONSTRAINT [DF_Classes_BPeriodOnWednesday] DEFAULT ((0)),
[BPeriodOnThursday] [int] NOT NULL CONSTRAINT [DF_Classes_BPeriodOnThursday] DEFAULT ((0)),
[BPeriodOnFriday] [int] NOT NULL CONSTRAINT [DF_Classes_BPeriodOnFriday] DEFAULT ((0)),
[BPeriodOnSaturday] [int] NOT NULL CONSTRAINT [DF_Classes_BPeriodOnSaturday] DEFAULT ((0)),
[CourseCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rigor] [bit] NULL,
[DualEnrollment] [bit] NULL,
[StandardsGradeScaleID] [tinyint] NOT NULL CONSTRAINT [DF_Classes_StandardsGradeScaleID] DEFAULT ((0)),
[EnablePSHourRounding] [bit] NOT NULL CONSTRAINT [DF_Classes_EnablePreschoolHourRounding] DEFAULT ((0)),
[PSRoundToNextHourPart] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Classes_PSRoundHourToNext] DEFAULT ('Quarter'),
[PSRoundHourAfterXMinutes] [tinyint] NOT NULL CONSTRAINT [DF_Classes_PSRoundHourAfterXMinutes] DEFAULT ((10)),
[PSAutoCheckoutTime] [time] (0) NOT NULL CONSTRAINT [DF_Classes_PSAutoCheckoutTime] DEFAULT ('23:59:00'),
[LocationOnSunday] [int] NOT NULL CONSTRAINT [DF_Classes_LocationOnSunday] DEFAULT ((0)),
[LocationOnMonday] [int] NOT NULL CONSTRAINT [DF_Classes_LocationOnMonday] DEFAULT ((0)),
[LocationOnTuesday] [int] NOT NULL CONSTRAINT [DF_Classes_LocationOnTuesday] DEFAULT ((0)),
[LocationOnWednesday] [int] NOT NULL CONSTRAINT [DF_Classes_LocationOnWednesday] DEFAULT ((0)),
[LocationOnThursday] [int] NOT NULL CONSTRAINT [DF_Classes_LocationOnThursday] DEFAULT ((0)),
[LocationOnFriday] [int] NOT NULL CONSTRAINT [DF_Classes_LocationOnFriday] DEFAULT ((0)),
[LocationOnSaturday] [int] NOT NULL CONSTRAINT [DF_Classes_LocationOnSaturday] DEFAULT ((0)),
[BLocationOnSunday] [int] NOT NULL CONSTRAINT [DF_Classes_BLocationOnSunday] DEFAULT ((0)),
[BLocationOnMonday] [int] NOT NULL CONSTRAINT [DF_Classes_BLocationOnMonday] DEFAULT ((0)),
[BLocationOnTuesday] [int] NOT NULL CONSTRAINT [DF_Classes_BLocationOnTuesday] DEFAULT ((0)),
[BLocationOnWednesday] [int] NOT NULL CONSTRAINT [DF_Classes_BLocationOnWednesday] DEFAULT ((0)),
[BLocationOnThursday] [int] NOT NULL CONSTRAINT [DF_Classes_BLocationOnThursday] DEFAULT ((0)),
[BLocationOnFriday] [int] NOT NULL CONSTRAINT [DF_Classes_BLocationOnFriday] DEFAULT ((0)),
[BLocationOnSaturday] [int] NOT NULL CONSTRAINT [DF_Classes_BLocationOnSaturday] DEFAULT ((0)),
[ScheduleType] [smallint] NOT NULL CONSTRAINT [DF_Classes_ScheduleType] DEFAULT ((1)),
[ShowOnSchedule] [bit] NOT NULL CONSTRAINT [DF_Classes_ShowOnSchedule] DEFAULT ((0)),
[EnableMarzanoTopics] [bit] NOT NULL CONSTRAINT [DF_Classes_EnableMarzanoTopics] DEFAULT ((0)),
[ShowMarzanoTopicsOnReportCard] [bit] NOT NULL CONSTRAINT [DF_Classes_ShowMarzanoTopicsOnReportCard] DEFAULT ((0)),
[DisableClassAttendance] [bit] NOT NULL CONSTRAINT [DF__Classes__Disable__6B123DEE] DEFAULT ((0)),
[gcCourseID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gcAssignmentTypeID] [int] NULL,
[gcExcludeNoDueDate] [bit] NULL,
[gcAutoSync] [bit] NULL,
[gcSyncEnabled] [bit] NOT NULL CONSTRAINT [DF_Classes_gcSyncEnabled] DEFAULT ((0)),
[gcMarkingCodeGradeID] [int] NULL CONSTRAINT [DF_Classes_gcMarkingCodeGradeID] DEFAULT (NULL),
[gcAllowEdits] [bit] NOT NULL CONSTRAINT [DF_Classes_gcAllowEdits] DEFAULT ((0)),
[MediumOfInstruction] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TeacherRole] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostSecondaryInstitution] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[AddNonSchoolDaysForAttendanceClasses]
 on [dbo].[Classes]
 After update
As
Begin
	
	Declare @CountInserted int
	Set @CountInserted = (Select count(*) From Inserted)

	If @CountInserted <= 1 -- only run if updating one class, not needed for copying classees from one term to the next
	Begin
	
		Declare @ClassTypeIDInserted int
		Declare @ClassTypeIDDeleted int

		Set @ClassTypeIDInserted = (Select ClassTypeID From Inserted)
		Set @ClassTypeIDDeleted = (Select ClassTypeID From Deleted)

		
		If ((Select count(*) From Inserted) > 0) and ((@ClassTypeIDInserted = 5) or (@ClassTypeIDDeleted = 5))
		Begin
		
			Declare @ClassID int
			Declare @TermID int
			Declare @DateID int
			Declare @TheID int
			Declare @TheIDCount int
			Declare @TermStart date
			Declare @TermEnd date	
			create table #NonSchoolDateItems (TheID int identity, DateID int)
			
			Alter table dbo.Attendance Disable trigger All
		
			-- Delete NonSchoolDays Attendance	
			Set @ClassID = (Select ClassID From Deleted)
			Set @TermID = (Select TermID From Deleted)

			-- Get TermDateRange
			Set @TermStart = (Select StartDate From Terms Where TermID = @TermID)
			Set @TermEnd = (Select EndDate From Terms Where TermID = @TermID)
			
			
			-- Delete Non School Days
			Insert into #NonSchoolDateItems
			Select DateID
			From dbo.NonSchoolDays
			Where
			TheDate between @TermStart and @TermEnd
			or
			StartDate  between @TermStart and @TermEnd
			or
			EndDate  between @TermStart and @TermEnd
			
			Set @TheID = (Select min(TheID) From #NonSchoolDateItems)	
			Set @TheIDCount = (Select max(TheID) From #NonSchoolDateItems)	

			While @TheID <= @TheIDCount
			Begin			
				Set @DateID = (Select DateID From #NonSchoolDateItems Where TheID = @TheID)
				Execute dbo.DeleteNonSchoolDaysAttendance @DateID, @ClassID
				Set @TheID = @TheID + 1
			End

			-- Add NonSchoolDays Attendance
			Set @ClassID = (Select ClassID From Inserted)
			Set @TermID = (Select TermID From Inserted)

			-- Get TermDateRange
			Set @TermStart = (Select StartDate From Terms Where TermID = @TermID)
			Set @TermEnd = (Select EndDate From Terms Where TermID = @TermID)
			
			
			-- Delete Non School Days
			Insert into #NonSchoolDateItems
			Select DateID
			From dbo.NonSchoolDays
			Where
			TheDate between @TermStart and @TermEnd
			or
			StartDate  between @TermStart and @TermEnd
			or
			EndDate  between @TermStart and @TermEnd
			
			Set @TheID = (Select min(TheID) From #NonSchoolDateItems)	
			Set @TheIDCount = (Select max(TheID) From #NonSchoolDateItems)	

			While @TheID <= @TheIDCount
			Begin	
				Set @DateID = (Select DateID From #NonSchoolDateItems Where TheID = @TheID)
				Execute dbo.AddNonSchoolDaysAttendance @DateID, @ClassID
				Set @TheID = @TheID + 1
			End
				
			drop table #NonSchoolDateItems
			
			Alter table dbo.Attendance Enable trigger All
		
		End -- if
	
	End -- if


End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[BlockCrosslinkedTeacherPages]
ON [dbo].[Classes]
AFTER Insert, Update AS
BEGIN
	SET NOCOUNT ON

	DECLARE @DUP INT;

	IF UPDATE(PostCollectionID) OR UPDATE(TermID) OR UPDATE(ClassTitle)
	BEGIN
		DECLARE @ClassID INT
		--
		-- Query to find Teacher Pages cross links
		--
		;WITH TeacherPageCrossLinks AS (
			SELECT 
				c.TermID, 
				c.PostCollectionID,							-- uncomment to test subquery and present more info
--				MAX(c.ClassTitle) ClassTitle,				-- uncomment to test subquery and present more info
				MAX(ISNULL(i.ClassID,-1)) ClassID --,		-- comment out to test cross link finding subquery
--				MIN(c.ClassTitle) minClassTitle,			-- uncomment to test subquery and present more info
--				MIN(c.ClassID) minClassID					-- uncomment to test subquery and present more info
			FROM classes c
			LEFT JOIN Inserted i ON c.ClassID = i.ClassID	-- comment out to test cross link finding subquery
			WHERE c.PostCollectionID is not null			-- Following 3 lines scope to currently updated row(s)...
				AND c.PostCollectionID						-- comment out to test cross link finding subquery
					IN (SELECT PostCollectionID				-- comment out to test cross link finding subquery
						FROM Inserted)						-- comment out to test cross link finding subquery
			GROUP BY c.TermID, c.PostCollectionID
			HAVING COUNT(DISTINCT c.ClassTitle)>1
		)
		SELECT @ClassID = ClassID
		FROM TeacherPageCrossLinks

		IF @ClassID IS NOT NULL
		BEGIN
			IF UPDATE(PostCollectionID) -- This would be an unexpected failure of Teacher Pages...
			BEGIN
				RAISERROR ('Teacher Page not save. A duplicate PostCollectionID would have been assigned for this term and class title.',16,1);
				ROLLBACK
			END
			ELSE IF @ClassID<>-1
			BEGIN 
				-- Normal use-cases of editing class titles or terms could cause cross link duplicates,
				-- so go ahead and nullify the reference to the new class title...
				-- NOTE: The trigger will not error out on multi-row updates, but
				-- this code only handles nullification of a single (cross linked) teacher page...
				-- This should be good enough since GL doesn't have any batch class editing,
				-- and data conversions that may involve mass edits probably don't have teach pages yet...
				UPDATE Classes SET PostCollectionID = NULL WHERE ClassID = @ClassID
			END
		END
	END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[LogClassCurveUpdates]
on [dbo].[Classes]
After Update
As
Begin
	Declare @CalcDate datetime = dbo.GLgetdatetime()

	If Update(Curve)
	Begin
	  Insert Into ActivityLog(ClassID, TheWeekday, LogDate, Item, BeforeChange, AfterChange)
	  SELECT (Select ClassID from Inserted) as ClassID,
		  DATENAME(weekday, @CalcDate) as TheWeekday,
		  @CalcDate as LogDate,
		 dbo.T(-0.1, 'Class Curve') as Item,
		 (Select Curve from Deleted) as BeforeChange,
		 (Select Curve from Inserted) as AfterChange
	End
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   TRIGGER [dbo].[ReplaceBackSlash]    
ON [dbo].[Classes]
    After insert, Update
As
BEGIN 
Update Classes
set ReportTitle = replace(ReportTitle, '\','/'),
ClassTitle = replace(ClassTitle, '\','/')
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateClassType]
 on [dbo].[Classes]
 After Update
As


If Update(ClassTypeID)
Begin

Declare @InsertedClassTypeID int
Declare @DeletedClassTypeID int

Set @InsertedClassTypeID = (Select ClassTypeID From Inserted)
Set @DeletedClassTypeID = (Select ClassTypeID From Deleted)

If (@InsertedClassTypeID != @DeletedClassTypeID)
Begin

	Declare @InsertedClassTypeCategory nvarchar(20)
	Declare @DeletedClassTypeCategory nvarchar(20)
	Declare @ClassID int
	
	Set @InsertedClassTypeCategory = (Select ClassTypeCategory From ClassType Where ClassTypeID = @InsertedClassTypeID)
	Set @DeletedClassTypeCategory = (Select ClassTypeCategory From ClassType Where ClassTypeID = @DeletedClassTypeID)
	Set @ClassID = (Select ClassID From Inserted)
	

	
	If @InsertedClassTypeCategory = 'Custom' and @DeletedClassTypeCategory = 'Builtin'
	Begin	-- Add Records to ClassesStudentsCF


		Insert into ClassesStudentsCF (CSID, CustomFieldID)
		Select 	CS.CSID,
				CF.CustomFieldID
		From 
			ClassesStudents CS, CustomFields CF
		Where 	CS.ClassID = @ClassID
				and
				CF.ClassTypeID = @InsertedClassTypeID
	
	End
	
	If @InsertedClassTypeCategory = 'Builtin' and @DeletedClassTypeCategory = 'Custom'
	Begin -- Remove Records from ClassesStudentsCF
	
		Delete ClassesStudentsCF
		Where CSID in (Select CSID From ClassesStudents Where ClassID = @ClassID)
	
	
	End
	
	If @InsertedClassTypeCategory = 'Custom' and @DeletedClassTypeCategory = 'Custom'
	Begin -- Remove and Add Records to ClassesStudentsCF
	
		-- Remove the old records
		Delete ClassesStudentsCF
		Where CSID in (Select CSID From ClassesStudents Where ClassID = @ClassID)
		
		-- Add the New records
		Insert into ClassesStudentsCF (CSID, CustomFieldID)
		Select 	CS.CSID,
				CF.CustomFieldID
		From 
			ClassesStudents CS, CustomFields CF
		Where 	CS.ClassID = @ClassID
				and
				CF.ClassTypeID = @InsertedClassTypeID
	
	End



End -- If (@InsertedClassTypeID != @DeletedClassTypeID)

End  -- IF Update
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateLPClassView]
 on [dbo].[Classes]
 After Update
As

-- First Update the New Teacher's CalendarDisplayClasses value
Update TeacherTerms
Set 
CalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
),
AdminCalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)
From
TeacherTerms TT
	inner join
(
	Select I.TeacherID, I.TermID
	From 
	Inserted I
		inner join
	Deleted D
		on I.ClassID = D.ClassID
	Where
	I.TeacherID != D.TeacherID		-- Update if the Teacher Changes
	or
	I.ClassTitle != D.ClassTitle	-- Update if the ClassTitle Changes
) I
on
	TT.TeacherID = I.TeacherID 


-- Second Update the Old Teacher's CalendarDisplayClasses value
Update TeacherTerms
Set 
CalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = D.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = D.TeacherID)
	)
	and
	TermID = D.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
),
AdminCalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = D.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = D.TeacherID)
	)
	and
	TermID = D.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)
From
TeacherTerms TT
	inner join
(
	Select D.TeacherID, D.TermID
	From 
	Inserted I
		inner join
	Deleted D
		on I.ClassID = D.ClassID
	Where
	I.TeacherID != D.TeacherID
) D
on
	TT.TeacherID = D.TeacherID 
	
	
-- Third Update CalendarDisplayClasses value for any Teachers this class is shared with
Update TeacherTerms
Set 
CalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
),
AdminCalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)
From
TeacherTerms TT
	inner join
(
	Select TC.TeacherID, I.TermID
	From 
	TeachersClasses TC
		inner join
	Inserted I
		on TC.ClassID = I.ClassID
		inner join
	Deleted D
		on I.ClassID = D.ClassID
	Where
	I.ClassTitle != D.ClassTitle	-- Update if the ClassTitle Changes
) I
on
	TT.TeacherID = I.TeacherID 	
	
	
	
-- Finally update the TTID on all Lesson Plans associated to affected classes
--Update LessonPlans
--Set TTID = 
--(
--Select TTID 
--From TeacherTerms 
--Where 
--TeacherID = x.TeacherID
--and
--TermID = (Select TermID From Classes Where ClassID = LP.ClassID)
--)
--From
--LessonPlans LP
--	inner join
--(
--	Select I.TeacherID, I.ClassID
--	From 
--	Inserted I
--		inner join
--	Deleted D
--		on I.ClassID = D.ClassID
--	Where
--	I.TeacherID != D.TeacherID
--) x
--on
--	LP.ClassID = x.ClassID 
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateLPClassViewOnInsert]
 on [dbo].[Classes]
 After Insert
As


--First add TeacherTerm record if one does not exist for Primary Teacher
insert into TeacherTerms (TeacherID, TermID, Tab1Name, Tab2Name, Tab3Name, Tab4Name, Tab5Name) 
Select distinct 
I.TeacherID, 
I.TermID,
dbo.t(0, 'Lesson'),
dbo.t(0, 'Objectives'),
dbo.t(0, 'Plan'),
dbo.t(0, 'Notes'),
dbo.t(0, 'Materials')
From 
Inserted I
Where
not exists
(
Select * From TeacherTerms
Where
TeacherID = I.TeacherID
and
TermID = I.TermID
)


-- Second Update the New Teacher's CalendarDisplayClasses value
Update TeacherTerms
Set 
CalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
),
AdminCalendarDisplayClasses = 
(
SELECT Stuff(
  (SELECT N', ' + ClassTitle From Classes 
	Where
	(
		TeacherID = I.TeacherID
		or
		ClassID in (Select ClassID From TeachersClasses Where TeacherID = I.TeacherID)
	)
	and
	TermID = I.TermID
	and
	ClassTypeID in (1,8)
  FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)
From
TeacherTerms TT
	inner join
(
	Select TeacherID, TermID
	From 
	Inserted
) I
on
	TT.TeacherID = I.TeacherID 


-- Note Secondary Teachers are handled via a trigger on TeacherTerms
	

GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [PK_Classes] PRIMARY KEY CLUSTERED ([ClassID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CalendarId] ON [dbo].[Classes] ([CalendarId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CategoryID] ON [dbo].[Classes] ([CategoryID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Classes_ClassID_CalendarId] ON [dbo].[Classes] ([ClassID], [CalendarId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassTypeID] ON [dbo].[Classes] ([ClassTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StandardsGroupID] ON [dbo].[Classes] ([StandardsGroupID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TeacherID] ON [dbo].[Classes] ([TeacherID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TermID] ON [dbo].[Classes] ([TermID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Calendar] FOREIGN KEY ([CalendarId]) REFERENCES [dbo].[Calendar] ([CalendarId])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_ClassType] FOREIGN KEY ([ClassTypeID]) REFERENCES [dbo].[ClassType] ([ClassTypeID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_CustomGradeScaleGrades] FOREIGN KEY ([gcMarkingCodeGradeID]) REFERENCES [dbo].[CustomGradeScaleGrades] ([GradeID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_GradReqCategories] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[GradReqCategories] ([CategoryID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations] FOREIGN KEY ([LocationOnSunday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations1] FOREIGN KEY ([LocationOnMonday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations10] FOREIGN KEY ([BLocationOnWednesday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations11] FOREIGN KEY ([BLocationOnThursday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations12] FOREIGN KEY ([BLocationOnFriday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations13] FOREIGN KEY ([BLocationOnSaturday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations2] FOREIGN KEY ([LocationOnTuesday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations3] FOREIGN KEY ([LocationOnWednesday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations4] FOREIGN KEY ([LocationOnThursday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations5] FOREIGN KEY ([LocationOnFriday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations6] FOREIGN KEY ([LocationOnSaturday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations7] FOREIGN KEY ([BLocationOnSunday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations8] FOREIGN KEY ([BLocationOnMonday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Locations9] FOREIGN KEY ([BLocationOnTuesday]) REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods] FOREIGN KEY ([Period]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods1] FOREIGN KEY ([PeriodOnSunday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods10] FOREIGN KEY ([BPeriodOnTuesday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods11] FOREIGN KEY ([BPeriodOnWednesday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods12] FOREIGN KEY ([BPeriodOnThursday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods13] FOREIGN KEY ([BPeriodOnFriday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods14] FOREIGN KEY ([BPeriodOnSaturday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods2] FOREIGN KEY ([PeriodOnMonday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods3] FOREIGN KEY ([PeriodOnTuesday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods4] FOREIGN KEY ([PeriodOnWednesday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods5] FOREIGN KEY ([PeriodOnThursday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods6] FOREIGN KEY ([PeriodOnFriday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods7] FOREIGN KEY ([PeriodOnSaturday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods8] FOREIGN KEY ([BPeriodOnSunday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Periods9] FOREIGN KEY ([BPeriodOnMonday]) REFERENCES [dbo].[Periods] ([PeriodID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_StandardsGroups] FOREIGN KEY ([StandardsGroupID]) REFERENCES [dbo].[StandardsGroups] ([SGID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID])
GO
ALTER TABLE [dbo].[Classes] ADD CONSTRAINT [FK_Classes_Terms] FOREIGN KEY ([TermID]) REFERENCES [dbo].[Terms] ([TermID])
GO
