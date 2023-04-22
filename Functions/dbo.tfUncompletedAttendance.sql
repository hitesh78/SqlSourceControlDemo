SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[tfUncompletedAttendance]
(
	@TheSmallDate date, -- e.g. "1/17/2019"
	@Period int -- e.g. -1 for all
)
RETURNS 
@UncompletedAttendance table
(
	ClassID int,
	TeacherID int,
	ClassTypeID int,
	ClassTitle nvarchar(80),
	Period nvarchar(20), -- based on Periods.PeriodSymbol but may override to W or BW
	PeriodStartTime time(0),
	PeriodOrder int,
	TermTitle nvarchar(50),
	Teacher nvarchar(100) -- based on Teachers.glName
)
AS 
BEGIN

Declare @TheSmallDateCalc datetime = dbo.toDBDate(@TheSmallDate)

Declare @DailyAttendance bit = (Select DailyAttendance From Settings Where SettingID = 1)

Declare @ClassAttendance bit = (Select ClassAttendance From Settings Where SettingID = 1);

insert into @UncompletedAttendance
     Select 
	 C.ClassID, T.TeacherID, C.ClassTypeID,
     C.ClassTitle as [Class!2!ClassTitle],	
	case 
		when C.ScheduleType = 1 then P.PeriodSymbol
		when C.ScheduleType = 2 then 'W - ' + P.PeriodSymbol
		when C.ScheduleType = 3 then 'BW - ' + P.PeriodSymbol
	end as [Class!2!Period],
	P.PeriodStartTime as [Class!2!PeriodStartTime],
	p.PeriodOrder as [Class!2!PeriodOrder],
	TM.TermTitle as [Class!2!TermTitle],
	T.glName as [Class!2!Teacher]
	From 
	Teachers T 
		inner join 
	Classes C
		on T.TeacherID = C.TeacherID 
		left join -- SF #00110674	2022-10-28 - changed from inner join to left for school that don't use periods (their periods where set to "N/A"), see comments below for more detials - dp
	Periods P
		on 	(P.PeriodID = C.Period and C.Period != 0 and C.ScheduleType = 1)
			or
			(P.PeriodID = C.PeriodOnSunday and C.PeriodOnSunday != 0 and C.ScheduleType > 1
				and datename(dw,@TheSmallDateCalc) = 'Sunday')
			or
			(P.PeriodID = C.PeriodOnMonday and C.PeriodOnMonday != 0 and C.ScheduleType > 1
				and datename(dw,@TheSmallDateCalc) = 'Monday')
			or
			(P.PeriodID = C.PeriodOnTuesday and C.PeriodOnTuesday != 0 and C.ScheduleType > 1
				and datename(dw,@TheSmallDateCalc) = 'Tuesday')
			or
			(P.PeriodID = C.PeriodOnWednesday and C.PeriodOnWednesday != 0 and C.ScheduleType > 1
				and datename(dw,@TheSmallDateCalc) = 'Wednesday')
			or
			(P.PeriodID = C.PeriodOnThursday and C.PeriodOnThursday != 0 and C.ScheduleType > 1
				and datename(dw,@TheSmallDateCalc) = 'Thursday')
			or
			(P.PeriodID = C.PeriodOnFriday and C.PeriodOnFriday != 0 and C.ScheduleType > 1
				and datename(dw,@TheSmallDateCalc) = 'Friday')
			or
			(P.PeriodID = C.PeriodOnSaturday and C.PeriodOnSaturday != 0 and C.ScheduleType > 1
				and datename(dw,@TheSmallDateCalc) = 'Saturday')
			or
			(P.PeriodID = C.BPeriodOnSunday and C.BPeriodOnSunday != 0 and C.ScheduleType = 3
				and datename(dw,@TheSmallDateCalc) = 'Sunday')
			or
			(P.PeriodID = C.BPeriodOnMonday and C.BPeriodOnMonday != 0 and C.ScheduleType = 3
				and datename(dw,@TheSmallDateCalc) = 'Monday')
			or
			(P.PeriodID = C.BPeriodOnTuesday and C.BPeriodOnTuesday != 0 and C.ScheduleType = 3
				and datename(dw,@TheSmallDateCalc) = 'Tuesday')
			or
			(P.PeriodID = C.BPeriodOnWednesday and C.BPeriodOnWednesday != 0 and C.ScheduleType = 3
				and datename(dw,@TheSmallDateCalc) = 'Wednesday')
			or
			(P.PeriodID = C.BPeriodOnThursday and C.BPeriodOnThursday != 0 and C.ScheduleType = 3
				and datename(dw,@TheSmallDateCalc) = 'Thursday')
			or
			(P.PeriodID = C.BPeriodOnFriday and C.BPeriodOnFriday != 0 and C.ScheduleType = 3
				and datename(dw,@TheSmallDateCalc) = 'Friday')
			or
			(P.PeriodID = C.BPeriodOnSaturday and C.BPeriodOnSaturday != 0 and C.ScheduleType = 3
				and datename(dw,@TheSmallDateCalc) = 'Saturday')
		inner join 
	Terms TM
		on TM.TermID = C.TermID
     where 	
	 dbo.ClassHasAttendanceOnThisDate(C.ClassID, @TheSmallDate) = 1
	 and
	 -- SF #00110674	2022-10-28 - School #658 was on simple schedule running Uncompleted report 
	 -- for all periods and nothing was showing on the report even though attendance was not done 
	 -- for some classes.  
	 -- Changed the above join to periods table from inner to left and copied the logic below 
	 -- Along with adding the first line below (C.ScheduleType = 1 and @Period = -1)  - dp
	 (
		C.ScheduleType = 1 and @Period = -1
		or
		(P.PeriodID = C.Period and C.Period != 0 and C.ScheduleType = 1)
		or
		(P.PeriodID = C.PeriodOnSunday and C.PeriodOnSunday != 0 and C.ScheduleType > 1
			and datename(dw,@TheSmallDateCalc) = 'Sunday')
		or
		(P.PeriodID = C.PeriodOnMonday and C.PeriodOnMonday != 0 and C.ScheduleType > 1
			and datename(dw,@TheSmallDateCalc) = 'Monday')
		or
		(P.PeriodID = C.PeriodOnTuesday and C.PeriodOnTuesday != 0 and C.ScheduleType > 1
			and datename(dw,@TheSmallDateCalc) = 'Tuesday')
		or
		(P.PeriodID = C.PeriodOnWednesday and C.PeriodOnWednesday != 0 and C.ScheduleType > 1
			and datename(dw,@TheSmallDateCalc) = 'Wednesday')
		or
		(P.PeriodID = C.PeriodOnThursday and C.PeriodOnThursday != 0 and C.ScheduleType > 1
			and datename(dw,@TheSmallDateCalc) = 'Thursday')
		or
		(P.PeriodID = C.PeriodOnFriday and C.PeriodOnFriday != 0 and C.ScheduleType > 1
			and datename(dw,@TheSmallDateCalc) = 'Friday')
		or
		(P.PeriodID = C.PeriodOnSaturday and C.PeriodOnSaturday != 0 and C.ScheduleType > 1
			and datename(dw,@TheSmallDateCalc) = 'Saturday')
		or
		(P.PeriodID = C.BPeriodOnSunday and C.BPeriodOnSunday != 0 and C.ScheduleType = 3
			and datename(dw,@TheSmallDateCalc) = 'Sunday')
		or
		(P.PeriodID = C.BPeriodOnMonday and C.BPeriodOnMonday != 0 and C.ScheduleType = 3
			and datename(dw,@TheSmallDateCalc) = 'Monday')
		or
		(P.PeriodID = C.BPeriodOnTuesday and C.BPeriodOnTuesday != 0 and C.ScheduleType = 3
			and datename(dw,@TheSmallDateCalc) = 'Tuesday')
		or
		(P.PeriodID = C.BPeriodOnWednesday and C.BPeriodOnWednesday != 0 and C.ScheduleType = 3
			and datename(dw,@TheSmallDateCalc) = 'Wednesday')
		or
		(P.PeriodID = C.BPeriodOnThursday and C.BPeriodOnThursday != 0 and C.ScheduleType = 3
			and datename(dw,@TheSmallDateCalc) = 'Thursday')
		or
		(P.PeriodID = C.BPeriodOnFriday and C.BPeriodOnFriday != 0 and C.ScheduleType = 3
			and datename(dw,@TheSmallDateCalc) = 'Friday')
		or
		(P.PeriodID = C.BPeriodOnSaturday and C.BPeriodOnSaturday != 0 and C.ScheduleType = 3
			and datename(dw,@TheSmallDateCalc) = 'Saturday')
	 )
	 and
     TM.Status = 1	-- FD #351574	2021-11-08 dp
	 and
	 TM.TermID in (Select TermID From Terms where @TheSmallDateCalc >= StartDate and @TheSmallDateCalc <= EndDate)
     and
     C.ClassTypeID != 7
	 and
	 C.DefaultPresentValue != 0
	 AND
	 c.DisableClassAttendance = 0
     and
     C.ClassID not in 	(
		 Select Distinct C.ClassID
		 From Classes C inner join ClassesStudents CS
		 on C.ClassID = CS.ClassID inner join Attendance A
		 on CS.CSID = A.CSID
		 Where A.ClassDate = @TheSmallDateCalc
	 )
     and
     C.ParentClassID = 0
     and
     (case
     when @DailyAttendance = 1 and C.ClassTypeID = 5 then 1
     when @ClassAttendance = 1 and C.ClassTypeID in (1,2,8) then 1
     else 0
     end) = 1
	 and (select -- FD 132136 / DS-722
		case datename(dw,@TheSmallDate)
		when 'Sunday' then AttSunday
		when 'Monday' then AttMonday
		when 'Tuesday' then AttTuesday
		when 'Wednesday' then AttWednesday
		when 'Thursday' then AttThursday
		when 'Friday' then AttFriday
		when 'Saturday' then AttSaturday
		end
		from Settings) = 1
	 RETURN
END
GO
