SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 4/21/2021
-- Description:	returns all the dates for a specified class 
--				Excludes NonSchool Days and Weekdays that the school does not meet on  
-- =============================================

Create   FUNCTION [dbo].[getClassDates]
(
	@ClassID int
)
RETURNS 
@ClassDates table
(
	theDate date
)
AS
BEGIN


	declare 
	@TermStartDate date,
	@TermEndDate date

	Select
	@TermStartDate = StartDate,
	@TermEndDate = EndDate
	From 
	Terms T
		inner join
	Classes C
		on T.TermID = C.TermID
	Where
	C.ClassID = @ClassID


	Declare
	@ScheduleType tinyint,
	@BiWeeklySchedStart2ndWeek bit,
	@PeriodOnSunday nvarchar(20),
	@PeriodOnMonday nvarchar(20),
	@PeriodOnTuesday nvarchar(20),
	@PeriodOnWednesday nvarchar(20),
	@PeriodOnThursday nvarchar(20),
	@PeriodOnFriday nvarchar(20),
	@PeriodOnSaturday nvarchar(20),
	@BPeriodOnSunday nvarchar(20),
	@BPeriodOnMonday nvarchar(20),
	@BPeriodOnTuesday nvarchar(20),
	@BPeriodOnWednesday nvarchar(20),
	@BPeriodOnThursday nvarchar(20),
	@BPeriodOnFriday nvarchar(20),
	@BPeriodOnSaturday nvarchar(20)

	Select
	@ScheduleType = ScheduleType,
	@BiWeeklySchedStart2ndWeek = BiWeeklySchedStart2ndWeek,
	@PeriodOnSunday = case when PeriodOnSunday = 0 then '' else 'Sunday' end,
	@PeriodOnMonday = case when PeriodOnMonday = 0 then '' else 'Monday' end,
	@PeriodOnTuesday = case when PeriodOnTuesday = 0 then '' else 'Tuesday' end,
	@PeriodOnWednesday = case when PeriodOnWednesday = 0 then '' else 'Wednesday' end,
	@PeriodOnThursday = case when PeriodOnThursday = 0 then '' else 'Thursday' end,
	@PeriodOnFriday = case when PeriodOnFriday = 0 then '' else 'Friday' end,
	@PeriodOnSaturday = case when PeriodOnSaturday = 0 then '' else 'Saturday' end,
	@BPeriodOnSunday = case when  BPeriodOnSunday = 0 then '' else 'Sunday' end,
	@BPeriodOnMonday = case when BPeriodOnMonday = 0 then '' else 'Monday' end,
	@BPeriodOnTuesday = case when BPeriodOnTuesday = 0 then '' else 'Tuesday' end,
	@BPeriodOnWednesday = case when BPeriodOnWednesday = 0 then '' else 'Wednesday' end,
	@BPeriodOnThursday = case when BPeriodOnThursday = 0 then '' else 'Thursday' end,
	@BPeriodOnFriday = case when BPeriodOnFriday = 0 then '' else 'Friday' end,
	@BPeriodOnSaturday = case when BPeriodOnSaturday = 0 then '' else 'Saturday' end
	from
	Classes
	Where
	ClassID = @ClassID;

	Declare @TermDates table (theDate date, theWeek nvarchar(20), theWeekDay nvarchar(20))

	Insert into @TermDates
	select 
	theDate,
	datepart(wk, theDate) % 2 as theWeek,
	datename(weekday, theDate) as theWeekDay
	From 
	dbo.getSchoolDates(@TermStartDate, @TermEndDate);



	if @ScheduleType = 2
	Begin
		Insert into @ClassDates
		Select theDate From @TermDates
		Where
		case 
			when theWeekDay = @PeriodOnSunday then 1
			when theWeekDay = @PeriodOnMonday then 1
			when theWeekDay = @PeriodOnTuesday then 1
			when theWeekDay = @PeriodOnWednesday then 1
			when theWeekDay = @PeriodOnThursday then 1
			when theWeekDay = @PeriodOnFriday then 1
			when theWeekDay = @PeriodOnSaturday then 1
			else 0
		end = 1
	End
	Else if @ScheduleType = 3 and @BiWeeklySchedStart2ndWeek = 0
	Begin
		Insert into @ClassDates
		Select theDate From @TermDates
		Where
		case 
			when theWeek = 1 and theWeekDay = @PeriodOnSunday then 1
			when theWeek = 1 and theWeekDay = @PeriodOnMonday then 1
			when theWeek = 1 and theWeekDay = @PeriodOnTuesday then 1
			when theWeek = 1 and theWeekDay = @PeriodOnWednesday then 1
			when theWeek = 1 and theWeekDay = @PeriodOnThursday then 1
			when theWeek = 1 and theWeekDay = @PeriodOnFriday then 1
			when theWeek = 1 and theWeekDay = @PeriodOnSaturday then 1
			when theWeek = 0 and theWeekDay = @BPeriodOnSunday then 1
			when theWeek = 0 and theWeekDay = @BPeriodOnMonday then 1
			when theWeek = 0 and theWeekDay = @BPeriodOnTuesday then 1
			when theWeek = 0 and theWeekDay = @BPeriodOnWednesday then 1
			when theWeek = 0 and theWeekDay = @BPeriodOnThursday then 1
			when theWeek = 0 and theWeekDay = @BPeriodOnFriday then 1
			when theWeek = 0 and theWeekDay = @BPeriodOnSaturday then 1
			else 0
		end = 1
	End
	Else if @ScheduleType = 3 and @BiWeeklySchedStart2ndWeek = 1
	Begin
		Insert into @ClassDates
		Select theDate From @TermDates
		Where
		case 
			when theWeek = 0 and theWeekDay = @PeriodOnSunday then 1
			when theWeek = 0 and theWeekDay = @PeriodOnMonday then 1
			when theWeek = 0 and theWeekDay = @PeriodOnTuesday then 1
			when theWeek = 0 and theWeekDay = @PeriodOnWednesday then 1
			when theWeek = 0 and theWeekDay = @PeriodOnThursday then 1
			when theWeek = 0 and theWeekDay = @PeriodOnFriday then 1
			when theWeek = 0 and theWeekDay = @PeriodOnSaturday then 1
			when theWeek = 1 and theWeekDay = @BPeriodOnSunday then 1
			when theWeek = 1 and theWeekDay = @BPeriodOnMonday then 1
			when theWeek = 1 and theWeekDay = @BPeriodOnTuesday then 1
			when theWeek = 1 and theWeekDay = @BPeriodOnWednesday then 1
			when theWeek = 1 and theWeekDay = @BPeriodOnThursday then 1
			when theWeek = 1 and theWeekDay = @BPeriodOnFriday then 1
			when theWeek = 1 and theWeekDay = @BPeriodOnSaturday then 1
			else 0
		end = 1
	End;
	

	RETURN;
	
END


GO
