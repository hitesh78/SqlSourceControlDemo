SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 9/4/2018
-- Description:	Used to get a single line schedule for Simple, Weekly, and Bi-Weekly schedules
-- It show the day of the week followed by the location in parenthesis; simple schedule just show PeriodSymbol
-- Example output for weekly schedule: Monday(10b), Wednesday(10b), Friday(10b)
-- Just do a left join on this funciton on ClassID
-- =============================================
Create   FUNCTION [dbo].[getClassScheduleString] ()
RETURNS @ClassSchedules TABLE (ClassID int, Schedule nvarchar(200))
AS
BEGIN

	Declare 
	@AttSunday bit,
	@AttMonday bit,
	@AttTuesday bit,
	@AttWednesday bit,
	@AttThursday bit,
	@AttFriday bit,
	@AttSaturday bit

	Select
	@AttSunday = AttSunday,
	@AttMonday = AttMonday,
	@AttTuesday = AttTuesday,
	@AttWednesday = AttWednesday,
	@AttThursday = AttThursday,
	@AttFriday = AttFriday,
	@AttSaturday = AttSaturday
	From Settings
	Where 
	SettingID = 1


	Declare @Sunday nvarchar(100) = (Select dbo.t(0, 'Sun'));
	Declare @Monday nvarchar(100) = (Select dbo.t(0, 'Mon'));
	Declare @Tuesday nvarchar(100) = (Select dbo.t(0, 'Tue'));
	Declare @Wednesday nvarchar(100) = (Select dbo.t(0, 'Wed'));
	Declare @Thursday nvarchar(100) = (Select dbo.t(0, 'Thu'));
	Declare @Friday nvarchar(100) = (Select dbo.t(0, 'Fri'));
	Declare @Saturday nvarchar(100) = (Select dbo.t(0, 'Sat'));


	Insert into @ClassSchedules (ClassID, Schedule)
	Select
	ClassID,
	case ScheduleType
		when 1 then P.PeriodSymbol + ' / ' + C.Location
		when 2 then
			reverse(stuff(reverse(
			isnull(case when @AttSunday = 1 and PeriodOnSunday != 0 then @Sunday + '(' + isnull(PSun.PeriodSymbol,'') + '/' + isnull(LSun.Location,'') + '), ' end,'') + 
			isnull(case when @AttMonday = 1 and PeriodOnMonday != 0 then @Monday + '(' + isnull(PMon.PeriodSymbol,'') + '/' + isnull(LMon.Location,'') + '), ' end,'') + 
			isnull(case when @AttTuesday = 1 and PeriodOnTuesday != 0 then @Tuesday + '(' + isnull(PTue.PeriodSymbol,'') + '/' + isnull(LTue.Location,'') + '), ' end,'') + 
			isnull(case when @AttWednesday = 1 and PeriodOnWednesday != 0 then @Wednesday + '(' + isnull(PWed.PeriodSymbol,'') + '/' + isnull(LWed.Location,'') + '), ' end,'') + 
			isnull(case when @AttThursday = 1 and PeriodOnThursday != 0 then @Thursday + '(' + isnull(PThu.PeriodSymbol,'') + '/' + isnull(LThu.Location,'') + '), ' end,'') + 
			isnull(case when @AttFriday = 1 and PeriodOnFriday != 0 then @Friday + '(' + isnull(PFri.PeriodSymbol,'') + '/' + isnull(LFri.Location,'') + '), ' end,'') + 
			isnull(case when @AttSaturday = 1 and PeriodOnSaturday != 0 then @Saturday + '(' + isnull(PSat.PeriodSymbol,'') + '/' + isnull(LSat.Location,'') + '), ' end,'')
			), 1, 2, ''))
		When 3 then 
			'Week1: ' +
			isnull(
			reverse(stuff(reverse(
				isnull(case when @AttSunday = 1 and PeriodOnSunday != 0 then @Sunday + '(' + isnull(PSun.PeriodSymbol,'') + '/' + isnull(LSun.Location,'') + '), ' end,'') + 
				isnull(case when @AttMonday = 1 and PeriodOnMonday != 0 then @Monday + '(' + isnull(PMon.PeriodSymbol,'') + '/' + isnull(LMon.Location,'') + '), ' end,'') + 
				isnull(case when @AttTuesday = 1 and PeriodOnTuesday != 0 then @Tuesday + '(' + isnull(PTue.PeriodSymbol,'') + '/' + isnull(LTue.Location,'') + '), ' end,'') + 
				isnull(case when @AttWednesday = 1 and PeriodOnWednesday != 0 then @Wednesday + '(' + isnull(PWed.PeriodSymbol,'') + '/' + isnull(LWed.Location,'') + '), ' end,'') + 
				isnull(case when @AttThursday = 1 and PeriodOnThursday != 0 then @Thursday + '(' + isnull(PThu.PeriodSymbol,'') + '/' + isnull(LThu.Location,'') + '), ' end,'') + 
				isnull(case when @AttFriday = 1 and PeriodOnFriday != 0 then @Friday + '(' + isnull(PFri.PeriodSymbol,'') + '/' + isnull(LFri.Location,'') + '), ' end,'') + 
				isnull(case when @AttSaturday = 1 and PeriodOnSaturday != 0 then @Saturday + '(' + isnull(PSat.PeriodSymbol,'') + '/' + isnull(LSat.Location,'') + '), ' end,'') 
			), 1, 2, ''))	
			,'')
			+ '<br/>' +
			'Week2: ' +
			isnull(
			reverse(stuff(reverse(
			isnull(case when @AttSunday = 1 and BPeriodOnSunday != 0 then @Sunday + '(' + isnull(BPSun.PeriodSymbol,'') + '/' + isnull(BLSun.Location,'') + '), ' end,'') + 
			isnull(case when @AttMonday = 1 and BPeriodOnMonday != 0 then @Monday + '(' + isnull(BPMon.PeriodSymbol,'') + '/' + isnull(BLMon.Location,'') + '), ' end,'') + 
			isnull(case when @AttTuesday = 1 and BPeriodOnTuesday != 0 then @Tuesday + '(' + isnull(BPTue.PeriodSymbol,'') + '/' + isnull(BLTue.Location,'') + '), ' end,'') + 
			isnull(case when @AttWednesday = 1 and BPeriodOnWednesday != 0 then @Wednesday + '(' + isnull(BPWed.PeriodSymbol,'') + '/' + isnull(BLWed.Location,'') + '), ' end,'') + 
			isnull(case when @AttThursday = 1 and BPeriodOnThursday != 0 then @Thursday + '(' + isnull(BPThu.PeriodSymbol,'') + '/' + isnull(BLThu.Location,'') + '), ' end,'') + 
			isnull(case when @AttFriday = 1 and BPeriodOnFriday != 0 then @Friday + '(' + isnull(BPFri.PeriodSymbol,'') + '/' + isnull(BLFri.Location,'') + '), ' end,'') + 
			isnull(case when @AttSaturday = 1 and BPeriodOnSaturday != 0 then @Saturday + '(' + isnull(BPSat.PeriodSymbol,'') + '/' + isnull(BLSat.Location,'') + '), ' end,'')
			), 1, 2, ''))
			,'')
	end as StringSchedule
	From
	Classes C
		inner join
	Periods P
		on P.PeriodID = C.Period
		left join
	Periods PSun
		on PSun.PeriodID = C.PeriodOnSunday
		left join
	Periods PMon
		on PMon.PeriodID = C.PeriodOnMonday
		left join
	Periods PTue
		on PTue.PeriodID = C.PeriodOnTuesday
		left join
	Periods PWed
		on PWed.PeriodID = C.PeriodOnWednesday
		left join
	Periods PThu
		on PThu.PeriodID = C.PeriodOnThursday
		left join
	Periods PFri
		on PFri.PeriodID = C.PeriodOnFriday
		left join
	Periods PSat
		on PSat.PeriodID = C.PeriodOnSaturday
		left join
	Periods BPSun
		on BPSun.PeriodID = C.BPeriodOnSunday
		left join
	Periods BPMon
		on BPMon.PeriodID = C.BPeriodOnMonday
		left join
	Periods BPTue
		on BPTue.PeriodID = C.BPeriodOnTuesday
		left join
	Periods BPWed
		on BPWed.PeriodID = C.BPeriodOnWednesday
		left join
	Periods BPThu
		on BPThu.PeriodID = C.BPeriodOnThursday
		left join
	Periods BPFri
		on BPFri.PeriodID = C.BPeriodOnFriday
		left join
	Periods BPSat
		on BPSat.PeriodID = C.BPeriodOnSaturday
		left join
	Locations LSun
		on C.LocationOnSunday = LSun.LocationID
		left join
	Locations LMon
		on C.LocationOnMonday = LMon.LocationID	
		left join
	Locations LTue
		on C.LocationOnTuesday = LTue.LocationID
		left join
	Locations LWed
		on C.LocationOnWednesday = LWed.LocationID	
		left join
	Locations LThu
		on C.LocationOnThursday = LThu.LocationID
		left join
	Locations LFri
		on C.LocationOnFriday = LFri.LocationID	
		left join
	Locations LSat
		on C.LocationOnSaturday = LSat.LocationID
		left join
	Locations BLSun
		on C.BLocationOnSunday = BLSun.LocationID
		left join
	Locations BLMon
		on C.BLocationOnMonday = BLMon.LocationID	
		left join
	Locations BLTue
		on C.BLocationOnTuesday = BLTue.LocationID
		left join
	Locations BLWed
		on C.BLocationOnWednesday = BLWed.LocationID	
		left join
	Locations BLThu
		on C.BLocationOnThursday = BLThu.LocationID
		left join
	Locations BLFri
		on C.BLocationOnFriday = BLFri.LocationID	
		left join
	Locations BLSat
		on C.BLocationOnSaturday = BLSat.LocationID			
	Where
	ParentClassID = 0;
	
	return;

End
GO
