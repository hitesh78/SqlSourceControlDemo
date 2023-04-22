SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 05/23/2016
-- Description:	Adds recuring Lesson Plan records per the Lesson Plan Automation
-- =============================================
CREATE Procedure [dbo].[SaveLPRepeat] 
@LPID int,
@StartDate date,
@EndDate date,
@wkDays nvarchar(100)
AS
BEGIN



--Declare
--@LPID int = 490,
--@StartDate date = '2016-03-29',
--@EndDate date = '2016-04-26',
--@wkDays nvarchar(100) = 'Tuesday'


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Declare @LPIDDate date
	Declare @theClassID int
	
	Select 
	@LPIDDate = theDate,
	@theClassID = ClassID 
	From LessonPlans 
	Where LPID = @LPID
	
	Declare @OutputLPIDs table (LPID int)
	
	
		-- Get ClassSchedule
		Declare @ClassSchedule table (ClassID int, BiWeeklySchedule bit, BiWeeklySchedStart2ndWeek bit, wkDay nvarchar(10), Period int)
		insert into @ClassSchedule
		SELECT
		ClassID,
		BiWeeklySchedule,
		BiWeeklySchedStart2ndWeek,
		wkDay,
		Period
		FROM 
		(
		  SELECT 
		  ClassID,
		  BiWeeklySchedule,
		  BiWeeklySchedStart2ndWeek,
		  substring(ClassPeriods,9,10) as wkDay,
		  Period
		  FROM
		  (
			SELECT	C.ClassID, 
					C.BiWeeklySchedule,
					C.BiWeeklySchedStart2ndWeek,
					PeriodOnSunday, PeriodOnMonday, PeriodOnTuesday, PeriodOnWednesday, PeriodOnThursday, PeriodOnFriday, PeriodOnSaturday
			From
			Classes C
			Where ClassID = @theClassID
		  ) AS cp
		  UNPIVOT
		  (
			Period FOR ClassPeriods IN (PeriodOnSunday, PeriodOnMonday, PeriodOnTuesday, PeriodOnWednesday, PeriodOnThursday, PeriodOnFriday, PeriodOnSaturday)
		  ) AS p
		) AS x	
		Where
		Period > 0				
			
		-- Get ClassScheduleB
		Declare @ClassScheduleB table (ClassID int, BiWeeklySchedule bit, BiWeeklySchedStart2ndWeek bit, wkDay nvarchar(10), Period int)
		insert into @ClassScheduleB
		SELECT
		ClassID,
		BiWeeklySchedule,
		BiWeeklySchedStart2ndWeek,
		wkDay,
		Period
		FROM 
		(
		  SELECT 
		  ClassID,
		  BiWeeklySchedule,
		  BiWeeklySchedStart2ndWeek,
		  substring(ClassPeriods,10,11) as wkDay,
		  Period
		  FROM
		  (
			SELECT	C.ClassID,
					C.BiWeeklySchedule,
					C.BiWeeklySchedStart2ndWeek,
					BPeriodOnSunday, BPeriodOnMonday, BPeriodOnTuesday, BPeriodOnWednesday, BPeriodOnThursday, BPeriodOnFriday, BPeriodOnSaturday
			From
			Classes C
			Where ClassID = @theClassID
		  ) AS cp
		  UNPIVOT
		  (
			Period FOR ClassPeriods IN (BPeriodOnSunday, BPeriodOnMonday, BPeriodOnTuesday, BPeriodOnWednesday, BPeriodOnThursday, BPeriodOnFriday, BPeriodOnSaturday)
		  ) AS p
		) AS x	
		Where
		Period > 0		
	
	
	
	
	

	Insert into LessonPlans
	(
		TTID,
		ClassID,
		Title,
		theDate,
		Tab1Content,
		Tab2Content,
		Tab3Content,
		Tab4Content,
		Tab5Content,
		Tab6Content,
		Tab7Content,
		Tab8Content
		)
	Output inserted.LPID into @OutputLPIDs(LPID)    
	Select
		TTID,
		ClassID,
		Title,
		d.theDate,
		Tab1Content,
		Tab2Content,
		Tab3Content,
		Tab4Content,
		Tab5Content,
		Tab6Content,
		Tab7Content,
		Tab8Content
	From 
	LessonPlans LP
		cross join
	(
		Select
		theDate
		From 
		dbo.GetDates(@StartDate, @EndDate)
		Where
		theDate in 
		(
		Select 
		D.theDate
		From
		dbo.GetDates(@StartDate, @EndDate) D
			inner join        
		@ClassSchedule CS
			on	datename(weekday,D.theDate) = CS.wkDay 
				and 
				case 
					when BiWeeklySchedule = 0 then 1
					when BiWeeklySchedStart2ndWeek = 0 and DATEPART(wk, D.theDate) % 2 != 0 then 1
					when BiWeeklySchedStart2ndWeek = 1 and DATEPART(wk, D.theDate) % 2 = 0 then 1
					else 0
				end	= 1
		
		Union
		
		Select 
		D.theDate
		From
		dbo.GetDates(@StartDate, @EndDate) D
			inner join        
		@ClassScheduleB CS
			on	datename(weekday,D.theDate)= CS.wkDay 
				and 
				case 
					when BiWeeklySchedule = 0 then 0
					when BiWeeklySchedStart2ndWeek = 1 and DATEPART(wk, D.theDate) % 2 != 0 then 1
					when BiWeeklySchedStart2ndWeek = 0 and DATEPART(wk, D.theDate) % 2 = 0 then 1
					else 0
				end	= 1	
		)		
		and
		datename(weekday, theDate) in (Select * From dbo.SplitCSVStrings(@wkDays))
		and
		theDate != @LPIDDate	-- Exclude this Date since it is already added
		and
		1 = 1		-- Add code to Exclude other Non-school Days.
	) d
	Where LPID = @LPID




	Declare @NewLessonsAdded int = @@RowCount;

	-- Insert LPStandards records
	Insert into LPStandards(LPID, StandardID)
	Select 
	O.LPID,
	S.StandardID
	From
	LPStandards S
		cross join
	@OutputLPIDs O
	Where
	S.LPID = @LPID


	-- Insert LessonPlanBinFiles records
	Insert into LessonPlanBinFiles(LPID, FileID)
	Select 
	O.LPID,
	F.FileID
	From
	LessonPlanBinFiles F
		cross join
	@OutputLPIDs O
	Where
	F.LPID = @LPID


	-- Insert AssignmentCollections records
	Declare @OutputIDs table (LPID int, ACID int)

	Insert into AssignmentCollections
	(
	TeacherID,
	AssignmentTitle,
	Description,
	AssignmentTypeName,
	GradeStyle,
	OutOf,
	DateAssigned,
	DateDue,
	MiscID
	)
	Output inserted.MiscID, inserted.ACID into @OutputIDs(LPID, ACID)  
	Select 
	TeacherID,
	AssignmentTitle,
	Description,
	AssignmentTypeName,
	GradeStyle,
	OutOf,
	DateAssigned,
	DateDue,
	O.LPID
	FROM 
	AssignmentCollections AC
		cross join
	@OutputLPIDs O
	Where
	AC.ACID in (Select ACID From LPAssignmentCollections Where LPID = @LPID)


	-- Insert LPAssignmentCollections records
	Insert into LPAssignmentCollections(LPID, ACID)
	Select 
	LPID,
	ACID
	From
	@OutputIDs


	-- Insert AssignmentCollectionStandards records
	Insert into AssignmentCollectionStandards(ACID, StandardID)
	Select distinct
	O.ACID,
	S.StandardID
	From
	AssignmentCollectionStandards S
		cross join
	@OutputIDs O
	Where
	S.ACID in (Select ACID From LPAssignmentCollections Where LPID = @LPID)

	-- Insert AssignmentCollectionBinFiles records
	Insert into AssignmentCollectionBinFiles(ACID, FileID)
	Select distinct
	O.ACID,
	F.FileID
	From
	AssignmentCollectionBinFiles F
		cross join
	@OutputIDs O
	Where
	F.ACID in (Select ACID From LPAssignmentCollections Where LPID = @LPID)


	Select @NewLessonsAdded as NewLessonsAdded
	FOR XML RAW

END

GO
