SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[AddAttendanceForAllClasses]
@ClassDate datetime,
@ClassID int,
@AddForAllMyClassesThisPeriod nvarchar(5)
AS

Declare @TermID int = (Select TermID From Classes Where ClassID = @ClassID)
Declare @TeacherID int = (Select TeacherID From Classes Where ClassID = @ClassID)
Declare @Period int = (Select Period From Classes Where ClassID = @ClassID)
Declare @TheSmallDateCalc datetime = dbo.toDBDate(@ClassDate)


Declare @FetchCSID int
Declare @FetchDefaultPresentValue decimal(5,2)


Declare CSIDCursor Cursor For
	Select CSID, DefaultPresentValue
	from 
		ClassesStudents CS
			inner join 
		Classes C
			on C.ClassID = CS.ClassID
			inner join
		Students S
			on S.StudentID = CS.StudentID
	where 
	C.TermID = @TermID 
	and 
	C.ClassTypeID in (1,2,5,8)
	and
	S.Active = 1
	and
	C.DisableClassAttendance = 0
	and
	CS.StudentConcludeDate is null
	and
	case
		when	
			@AddForAllMyClassesThisPeriod = 'yes'
			and 
			C.TeacherID = @TeacherID
			and
			C.Period = @Period
		then 1
		when @AddForAllMyClassesThisPeriod != 'yes' then 1
		else 0
	end = 1
	and
	case 

		when C.ScheduleType = 1 then 1

		when C.ScheduleType = 2 and datename(dw,@ClassDate) = 'Sunday' and C.PeriodOnSunday > 0 then 1
		when C.ScheduleType = 2 and datename(dw,@ClassDate) = 'Monday' and C.PeriodOnMonday > 0 then 1
		when C.ScheduleType = 2 and datename(dw,@ClassDate) = 'Tuesday' and C.PeriodOnTuesday > 0 then 1
		when C.ScheduleType = 2 and datename(dw,@ClassDate) = 'Wednesday' and C.PeriodOnWednesday > 0 then 1
		when C.ScheduleType = 2 and datename(dw,@ClassDate) = 'Thursday' and C.PeriodOnThursday > 0 then 1
		when C.ScheduleType = 2 and datename(dw,@ClassDate) = 'Friday' and C.PeriodOnFriday > 0 then 1
		when C.ScheduleType = 2 and datename(dw,@ClassDate) = 'Saturday' and C.PeriodOnSaturday > 0 then 1

		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Sunday' and C.PeriodOnSunday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Monday' and C.PeriodOnMonday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Tuesday' and C.PeriodOnTuesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Wednesday' and C.PeriodOnWednesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Thursday' and C.PeriodOnThursday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Friday' and C.PeriodOnFriday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Saturday' and C.PeriodOnSaturday > 0 then 1

		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Sunday' and C.PeriodOnSunday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Monday' and C.PeriodOnMonday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Tuesday' and C.PeriodOnTuesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Wednesday' and C.PeriodOnWednesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Thursday' and C.PeriodOnThursday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Friday' and C.PeriodOnFriday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Saturday' and C.PeriodOnSaturday > 0 then 1

		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Sunday' and C.BPeriodOnSunday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Monday' and C.BPeriodOnMonday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Tuesday' and C.BPeriodOnTuesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Wednesday' and C.BPeriodOnWednesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Thursday' and C.BPeriodOnThursday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Friday' and C.BPeriodOnFriday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @ClassDate) % 2 = 1 and datename(dw,@ClassDate) = 'Saturday' and C.BPeriodOnSaturday > 0 then 1

		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Sunday' and C.BPeriodOnSunday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Monday' and C.BPeriodOnMonday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Tuesday' and C.BPeriodOnTuesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Wednesday' and C.BPeriodOnWednesday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Thursday' and C.BPeriodOnThursday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Friday' and C.BPeriodOnFriday > 0 then 1
		when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @ClassDate) % 2 = 0 and datename(dw,@ClassDate) = 'Saturday' and C.BPeriodOnSaturday > 0 then 1

		else 0
	end = 1




Open CSIDCursor

FETCH NEXT FROM CSIDCursor INTO @FetchCSID, @FetchDefaultPresentValue
WHILE (@@FETCH_STATUS <> -1)
BEGIN

	If (Select ClassDate From Attendance Where ClassDate = @ClassDate and CSID = @FetchCSID) is null
	Begin
	 Insert Into Attendance (ClassDate, CSID, Att1)
		Values( @ClassDate,
				@FetchCSID,
				@FetchDefaultPresentValue)
	End

 FETCH NEXT FROM CSIDCursor INTO @FetchCSID, @FetchDefaultPresentValue
End

Close CSIDCursor

Deallocate CSIDCursor





GO
