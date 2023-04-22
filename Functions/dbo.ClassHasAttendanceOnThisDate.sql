SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 10/02/2018
-- Description:	Checks if Class Has Attendance for a specific date
-- =============================================
CREATE FUNCTION [dbo].[ClassHasAttendanceOnThisDate]
(
	@ClassID int,
	@theDate date
)
RETURNS bit
AS
BEGIN

	Return
	(
		Select
		case 
		 when exists(
		Select
		* 
		From 
		Classes C
		Where
		C.ClassID = @ClassID
		and
		case 
			when C.ScheduleType = 1 then 1

			when C.ScheduleType = 2 and datename(dw,@theDate) = 'Sunday' and C.PeriodOnSunday > 0 then 1
			when C.ScheduleType = 2 and datename(dw,@theDate) = 'Monday' and C.PeriodOnMonday > 0 then 1
			when C.ScheduleType = 2 and datename(dw,@theDate) = 'Tuesday' and C.PeriodOnTuesday > 0 then 1
			when C.ScheduleType = 2 and datename(dw,@theDate) = 'Wednesday' and C.PeriodOnWednesday > 0 then 1
			when C.ScheduleType = 2 and datename(dw,@theDate) = 'Thursday' and C.PeriodOnThursday > 0 then 1
			when C.ScheduleType = 2 and datename(dw,@theDate) = 'Friday' and C.PeriodOnFriday > 0 then 1
			when C.ScheduleType = 2 and datename(dw,@theDate) = 'Saturday' and C.PeriodOnSaturday > 0 then 1

			When C.ScheduleType = 3  and (Select SettingValue From ReportSettings Where SettingName = 'Disable Bi-Weekly Attendance Validation') = 'yes' then 1

			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Sunday' and C.PeriodOnSunday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Monday' and C.PeriodOnMonday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Tuesday' and C.PeriodOnTuesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Wednesday' and C.PeriodOnWednesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Thursday' and C.PeriodOnThursday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Friday' and C.PeriodOnFriday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Saturday' and C.PeriodOnSaturday > 0 then 1

			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Sunday' and C.PeriodOnSunday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Monday' and C.PeriodOnMonday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Tuesday' and C.PeriodOnTuesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Wednesday' and C.PeriodOnWednesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Thursday' and C.PeriodOnThursday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Friday' and C.PeriodOnFriday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Saturday' and C.PeriodOnSaturday > 0 then 1

			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Sunday' and C.BPeriodOnSunday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Monday' and C.BPeriodOnMonday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Tuesday' and C.BPeriodOnTuesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Wednesday' and C.BPeriodOnWednesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Thursday' and C.BPeriodOnThursday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Friday' and C.BPeriodOnFriday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 0 and datepart(wk, @theDate) % 2 = 0 and datename(dw,@theDate) = 'Saturday' and C.BPeriodOnSaturday > 0 then 1

			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Sunday' and C.BPeriodOnSunday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Monday' and C.BPeriodOnMonday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Tuesday' and C.BPeriodOnTuesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Wednesday' and C.BPeriodOnWednesday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Thursday' and C.BPeriodOnThursday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Friday' and C.BPeriodOnFriday > 0 then 1
			when C.ScheduleType = 3 and C.BiWeeklySchedStart2ndWeek = 1 and datepart(wk, @theDate) % 2 = 1 and datename(dw,@theDate) = 'Saturday' and C.BPeriodOnSaturday > 0 then 1

			else 0
		end = 1
		) then 1
		else 0
		end
	)

END

GO
