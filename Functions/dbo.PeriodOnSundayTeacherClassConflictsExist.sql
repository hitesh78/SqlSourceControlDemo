SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/15/2017
-- Description:	Return 1 if Class Time Conflicts exist for a given class that a student has
-- =============================================
CREATE FUNCTION [dbo].[PeriodOnSundayTeacherClassConflictsExist]
(
	@TermID int,
	@ClassID int,
	@TeacherID int,
	@WeekType nchar(5)
)
RETURNS bit
AS
BEGIN

return
case 
	when exists(
		Select
		y.ClassID
		From
		(
			Select 
			C2.ClassID,
			'WeekA' as WeekType,
			C2.BiWeeklySchedStart2ndWeek,
			P2.PeriodStartTime,
			P2.PeriodEndTime
			From 
			Classes C2
				inner join
			Periods P2
				on	(C2.ScheduleType = 1 and C2.Period > 0 and C2.Period = P2.PeriodID)
					or
					(C2.ScheduleType > 1 and C2.PeriodOnSunday > 0 and C2.PeriodOnSunday = P2.PeriodID)
			Where
			C2.ClassID = @ClassID

			Union

			Select 
			C2.ClassID,
			'WeekB' as WeekType,
			C2.BiWeeklySchedStart2ndWeek,
			P2.PeriodStartTime,
			P2.PeriodEndTime
			From 
			Classes C2
				inner join
			Periods P2
			on	
				(C2.ScheduleType = 1 and C2.Period > 0 and C2.Period = P2.PeriodID)
				or
				(C2.ScheduleType = 2 and C2.PeriodOnSunday > 0 and C2.PeriodOnSunday = P2.PeriodID)
				or
				(C2.ScheduleType = 3 and C2.BPeriodOnSunday > 0 and C2.BPeriodOnSunday = P2.PeriodID)
			Where
			C2.ClassID = @ClassID
		) x
			inner join
		(
			Select 
			C2.ClassID,
			'WeekA' as WeekType,
			C2.BiWeeklySchedStart2ndWeek,
			P2.PeriodStartTime,
			P2.PeriodEndTime
			From 
			Classes C2
				inner join
			Periods P2
				on	(C2.ScheduleType = 1 and C2.Period > 0 and C2.Period = P2.PeriodID)
					or
					(C2.ScheduleType > 1 and C2.PeriodOnSunday > 0 and C2.PeriodOnSunday = P2.PeriodID)
			Where
			C2.TermID = @TermID
			and
			C2.TeacherID = @TeacherID
			and
			C2.ParentClassID = 0

			Union

			Select 
			C2.ClassID,
			'WeekB' as WeekType,
			C2.BiWeeklySchedStart2ndWeek,
			P2.PeriodStartTime,
			P2.PeriodEndTime
			From 
			Classes C2
				inner join
			Periods P2
			on	
				(C2.ScheduleType = 1 and C2.Period > 0 and C2.Period = P2.PeriodID)
				or
				(C2.ScheduleType = 2 and C2.PeriodOnSunday > 0 and C2.PeriodOnSunday = P2.PeriodID)
				or
				(C2.ScheduleType = 3 and C2.BPeriodOnSunday > 0 and C2.BPeriodOnSunday = P2.PeriodID)
			Where
			C2.TermID = @TermID
			and
			C2.TeacherID = @TeacherID
			and
			C2.ParentClassID = 0
		) y
			on
			(x.PeriodStartTime < y.PeriodEndTime) 
			and 
			(x.PeriodEndTime > y.PeriodStartTime)
			and
			y.ClassID != @ClassID
			and
			(
			(x.BiWeeklySchedStart2ndWeek = 0 and x.WeekType = @WeekType)
			or 
			(x.BiWeeklySchedStart2ndWeek = 1 and x.WeekType != @WeekType)
			)
			and
			(
			x.BiWeeklySchedStart2ndWeek = y.BiWeeklySchedStart2ndWeek and x.WeekType = y.WeekType
			or
			x.BiWeeklySchedStart2ndWeek != y.BiWeeklySchedStart2ndWeek and x.WeekType != y.WeekType
			)
	) then 1
	else 0
end

END

GO
