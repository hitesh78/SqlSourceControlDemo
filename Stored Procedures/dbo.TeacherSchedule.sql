SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/17/2017
-- Description:	Used for the Teacher Schedule report
-- =============================================
CREATE Procedure [dbo].[TeacherSchedule]
@Admin nvarchar(3),
@ShowAllClasses nvarchar(3),
@ShowTimeMap nvarchar(3),
@TimeHeightFactor decimal(2,1),
@ShowClassColor nvarchar(3),
@ShowBiWeeklySchedule nvarchar(3),
@ClassID int,
@EK decimal(15,15),
@TermID int,
@TeacherID int,
@Sort int

AS
BEGIN


--Declare
--@TermID nvarchar(100) = '61',
--@Admin nvarchar(100) = 'yes',
--@Sort nvarchar(100) = '1',
--@TeacherID nvarchar(100) = '1026',
--@ShowAllClasses nvarchar(100) = 'no',
--@ShowTimeMap nvarchar(100) = 'yes',
--@TimeHeightFactor decimal(5,1) = 1.0,
--@ShowClassColor nvarchar(100) = 'yes',
--@ShowBiWeeklySchedule nvarchar(100) = 'no',
--@ClassID nvarchar(100) = '298',
--@EK nvarchar(100) = '.301485935061607'



	SET NOCOUNT ON;


	Declare @ClassDivAdditionalHeightSpacing int = 6; 
	Declare @TwoLineThreshold int = 44;
	Declare @SingleLineThreshold int = 29;
	Declare @SmallFontThreshold int = 13;	
	Declare @ActiveTermID int = (Select top 1 TermID From Terms where Status = 1 and TermID in (Select TermID From Classes) Order By EndDate desc)
	Declare @TermTitle nvarchar(50) = (Select TermTitle From Terms Where TermID = @TermID)
	 
	 
	Declare @Periods table (PeriodID int, PeriodString nvarchar(30))
	Insert into @Periods
	select
	PeriodID,
	case
		when PeriodID = 0 then ''
		else
			LOWER(
			LEFT(
			CONVERT(nvarchar(7), PeriodStartTime, 0)
			,LEN(CONVERT(nvarchar(7), PeriodStartTime, 0)) - 1)
			+ '-' +
			LEFT(
			CONVERT(nvarchar(7), PeriodEndTime, 0)
			,LEN(CONVERT(nvarchar(7), PeriodEndTime, 0)) - 1)
			) 
	end as PeriodString
	From 
	Periods   

	 


	Declare @HoursHTML table (hrInt int, hrDiv nvarchar(40))

	;with   Hours as
			(
			select  
			0 as hrInt
			union all
			select  hrInt + 1
			from Hours
			where   hrInt < 23
			)
	Insert into @HoursHTML
	Select
	hrInt,
	--lower(STUFF(RIGHT(' ' + CONVERT(nvarchar(7), CONVERT(time, DATEADD(hh,hrInt,'00:00:00')), 0), 7), 6, 0, '')) as thetime,
	'<div class="timeDiv">' +
	REPLACE(lower(STUFF(RIGHT(' ' + CONVERT(nvarchar(7), CONVERT(time, DATEADD(hh,hrInt,'00:00:00')), 0), 7), 6, 0, '')),':00', '') +
	'</div>' as TimeLegend
	From Hours

	Declare
	@AttSunday tinyint,
	@AttMonday tinyint,
	@AttTuesday tinyint,
	@AttWednesday tinyint,
	@AttThursday tinyint,
	@AttFriday tinyint,
	@AttSaturday tinyint


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

	Create table #TeacherInfo
	(
	TeacherID int, 
	StartTimePadding int, 
	TimeLegendHTML nvarchar(1000)
	)
	CREATE CLUSTERED INDEX IDX_C_TeacherID ON #TeacherInfo(TeacherID)
	
	
	insert into #TeacherInfo
	Select distinct
	TC.TeacherID,
	convert(int,left(min(P.PeriodStartTime),2)) * 60 * @TimeHeightFactor as StartTimePadding,
	(
		SELECT 
		  (
		  SELECT N'' + hrDiv FROM @HoursHTML 
		  Where 
		  hrInt between 
		  (convert(int,left(min(P.PeriodStartTime),2))) 
		  and 
		  (convert(int,left(max(P.PeriodEndTime),2))) 
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(1000)')
	) as TimeLegendHTML
	From 
	(
		Select TeacherID, ClassID 
		From Classes
		Where
		ParentClassID = 0
		and
		TermID = @TermID
		and 
		case
			when @TeacherID = -1 then 1
			when TeacherID = @TeacherID then 1
			else 0
		end = 1	
		Union
		Select TC2.TeacherID, TC2.ClassID 
		From 
		TeachersClasses TC2
			inner join
		Classes C2
			on TC2.ClassID = C2.ClassID
		Where
		C2.ParentClassID = 0
		and
		C2.TermID = @TermID
		and 
		case
			when @TeacherID = -1 then 1
			when TC2.TeacherID = @TeacherID then 1
			else 0
		end = 1	
	) TC
		inner join
	(
		Select distinct
		C.ClassID,
		CP.PeriodID
		From 
		Classes C
			inner join
		(
		Select ClassID, Period as PeriodID From Classes Where ScheduleType = 1 Union
		Select ClassID, PeriodOnSunday as PeriodID From Classes Where ScheduleType > 1 and @AttSunday = 1 Union
		Select ClassID, PeriodOnMonday as PeriodID From Classes Where ScheduleType > 1 and @AttMonday = 1 Union
		Select ClassID, PeriodOnTuesday as PeriodID From Classes Where ScheduleType > 1 and @AttTuesday = 1 Union
		Select ClassID, PeriodOnWednesday as PeriodID From Classes Where ScheduleType > 1 and @AttWednesday = 1 Union
		Select ClassID, PeriodOnThursday as PeriodID From Classes Where ScheduleType > 1 and @AttThursday = 1 Union
		Select ClassID, PeriodOnFriday as PeriodID From Classes Where ScheduleType > 1 and @AttFriday = 1 Union
		Select ClassID, PeriodOnSaturday as PeriodID From Classes Where ScheduleType > 1 and @AttSaturday = 1 Union
		Select ClassID, BPeriodOnSunday as PeriodID From Classes Where ScheduleType = 3 and @AttSunday = 1 Union
		Select ClassID, BPeriodOnMonday as PeriodID From Classes Where ScheduleType = 3 and @AttMonday = 1 Union
		Select ClassID, BPeriodOnTuesday as PeriodID From Classes Where ScheduleType = 3 and @AttTuesday = 1 Union
		Select ClassID, BPeriodOnWednesday as PeriodID From Classes Where ScheduleType = 3 and @AttWednesday = 1 Union
		Select ClassID, BPeriodOnThursday as PeriodID From Classes Where ScheduleType = 3 and @AttThursday = 1 Union
		Select ClassID, BPeriodOnFriday as PeriodID From Classes Where ScheduleType = 3 and @AttFriday = 1 Union
		Select ClassID, BPeriodOnSaturday as PeriodID From Classes Where ScheduleType = 3 and @AttSaturday = 1
		) CP
			on CP.ClassID = C.ClassID
		Where
		C.TermID = @TermID
		and
		C.ParentClassID = 0
		and
		CP.PeriodID != 0
	) TP
		on	TP.ClassID = TC.ClassID
		inner join
	Periods P
		on TP.PeriodID = P.PeriodID
	Where
	case
		when @TeacherID = -1 then 1
		when TC.TeacherID = @TeacherID then 1
		else 0
	end = 1		
	Group By TC.TeacherID	


	
	--Select * From #TeacherInfo




	Select
		1 as tag,
		Null as parent,
		@ActiveTermID as [General!1!ActiveTermID],
		@Admin as [General!1!Admin],		
		datename(month,dbo.GLgetdatetime()) + ' ' + datename(day,dbo.GLgetdatetime()) + ', ' + datename(year,dbo.GLgetdatetime()) As [General!1!TheDate],
		@TermTitle AS [General!1!TermTitle],
		@TermID AS [General!1!TermID],
		@TeacherID AS [General!1!selectedTeacherID],
		@Sort AS [General!1!Sort],
		@ClassID AS [General!1!ClassID],
		@EK AS [General!1!EK],
		@ShowAllClasses AS [General!1!ShowAllClasses],
		@ShowTimeMap AS [General!1!ShowTimeMap],
		@ShowClassColor AS [General!1!ShowClassColor],
		@ShowBiWeeklySchedule AS [General!1!ShowBiWeeklySchedule],
		@TimeHeightFactor as [General!1!TimeHeightFactor],
		@AttSunday as [General!1!AttSunday],
		@AttMonday as [General!1!AttMonday],
		@AttTuesday as [General!1!AttTuesday],
		@AttWednesday as [General!1!AttWednesday],
		@AttThursday as [General!1!AttThursday],
		@AttFriday as [General!1!AttFriday],
		@AttSaturday as [General!1!AttSaturday],
        
		Null AS [Teacher!2!TeacherID],
		Null AS [Teacher!2!Lname],
		Null AS [Teacher!2!Fname],
		Null AS [Teacher!2!Mname],
		Null AS [Teacher!2!Tname],
		Null as [Teacher!2!TimeLegendHTML],

	 	Null As [Class!3!Period],
		Null As [Class!3!ClassTitle],
		Null As [Class!3!Teacher],
		Null As [Class!3!Location],
		Null as [Class!3!LPClassColor],
		Null as [Class!3!PeriodOnSunday],
		Null as [Class!3!PeriodOnSundayConflicts],
		Null as [Class!3!PeriodOnSundayStartMinute],
		Null as [Class!3!PeriodOnSundayEndMinute],
		Null as [Class!3!PeriodOnSundayTime],
		Null as [Class!3!BPeriodOnSunday],
		Null as [Class!3!BPeriodOnSundayConflicts],
		Null as [Class!3!BPeriodOnSundayStartMinute],
		Null as [Class!3!BPeriodOnSundayEndMinute],
		Null as [Class!3!BPeriodOnSundayTime],
		Null as [Class!3!PeriodOnMonday],
		Null as [Class!3!PeriodOnMondayConflicts],
		Null as [Class!3!PeriodOnMondayStartMinute],
		Null as [Class!3!PeriodOnMondayEndMinute],
		Null as [Class!3!PeriodOnMondayTime],			
		Null as [Class!3!BPeriodOnMonday],
		Null as [Class!3!BPeriodOnMondayConflicts],
		Null as [Class!3!BPeriodOnMondayStartMinute],
		Null as [Class!3!BPeriodOnMondayEndMinute],
		Null as [Class!3!BPeriodOnMondayTime],			
		Null as [Class!3!PeriodOnTuesday],
		Null as [Class!3!PeriodOnTuesdayConflicts],
		Null as [Class!3!PeriodOnTuesdayStartMinute],
		Null as [Class!3!PeriodOnTuesdayEndMinute],
		Null as [Class!3!PeriodOnTuesdayTime],
		Null as [Class!3!BPeriodOnTuesday],
		Null as [Class!3!BPeriodOnTuesdayConflicts],
		Null as [Class!3!BPeriodOnTuesdayStartMinute],
		Null as [Class!3!BPeriodOnTuesdayEndMinute],	
		Null as [Class!3!BPeriodOnTuesdayTime],
		Null as [Class!3!PeriodOnWednesday],
		Null as [Class!3!PeriodOnWednesdayConflicts],
		Null as [Class!3!PeriodOnWednesdayStartMinute],
		Null as [Class!3!PeriodOnWednesdayEndMinute],
		Null as [Class!3!PeriodOnWednesdayTime],
		Null as [Class!3!BPeriodOnWednesday],
		Null as [Class!3!BPeriodOnWednesdayConflicts],
		Null as [Class!3!BPeriodOnWednesdayStartMinute],
		Null as [Class!3!BPeriodOnWednesdayEndMinute],	
		Null as [Class!3!BPeriodOnWednesdayTime],
		Null as [Class!3!PeriodOnThursday],
		Null as [Class!3!PeriodOnThursdayConflicts],
		Null as [Class!3!PeriodOnThursdayStartMinute],
		Null as [Class!3!PeriodOnThursdayEndMinute],	
		Null as [Class!3!PeriodOnThursdayTime],
		Null as [Class!3!BPeriodOnThursday],
		Null as [Class!3!BPeriodOnThursdayConflicts],
		Null as [Class!3!BPeriodOnThursdayStartMinute],
		Null as [Class!3!BPeriodOnThursdayEndMinute],
		Null as [Class!3!BPeriodOnThursdayTime],
		Null as [Class!3!PeriodOnFriday],
		Null as [Class!3!PeriodOnFridayConflicts],
		Null as [Class!3!PeriodOnFridayStartMinute],
		Null as [Class!3!PeriodOnFridayEndMinute],	
		Null as [Class!3!PeriodOnFridayTime],
		Null as [Class!3!BPeriodOnFriday],
		Null as [Class!3!BPeriodOnFridayConflicts],
		Null as [Class!3!BPeriodOnFridayStartMinute],
		Null as [Class!3!BPeriodOnFridayEndMinute],
		Null as [Class!3!BPeriodOnFridayTime],
		Null as [Class!3!PeriodOnSaturday],
		Null as [Class!3!PeriodOnSaturdayConflicts],
		Null as [Class!3!PeriodOnSaturdayStartMinute],
		Null as [Class!3!PeriodOnSaturdayEndMinute],
		Null as [Class!3!PeriodOnSaturdayTime],
		Null as [Class!3!BPeriodOnSaturday],
		Null as [Class!3!BPeriodOnSaturdayConflicts],
		Null as [Class!3!BPeriodOnSaturdayStartMinute],
		Null as [Class!3!BPeriodOnSaturdayEndMinute],
		Null as [Class!3!BPeriodOnSaturdayTime],
		Null as [Class!3!LocationOnSunday],
		Null as [Class!3!LocationOnMonday],
		Null as [Class!3!LocationOnTuesday],
		Null as [Class!3!LocationOnWednesday],
		Null as [Class!3!LocationOnThursday],
		Null as [Class!3!LocationOnFriday],
		Null as [Class!3!LocationOnSaturday],
		Null as [Class!3!BLocationOnSunday],
		Null as [Class!3!BLocationOnMonday],
		Null as [Class!3!BLocationOnTuesday],
		Null as [Class!3!BLocationOnWednesday],
		Null as [Class!3!BLocationOnThursday],
		Null as [Class!3!BLocationOnFriday],
		Null as [Class!3!BLocationOnSaturday]
		
	Union All

	Select Distinct	
		2 as tag,
		1 as parent,
		null as [General!1!ActiveTermID],
		null as [General!1!Admin],
 		Null As [General!1!TheDate],
 		Null AS [General!1!TermTitle],
 		Null AS [General!1!TermID],
		Null AS [General!1!selectedTeacherID],
		Null AS [General!1!Sort], 		
		Null AS [General!1!ClassID],
		Null AS [General!1!EK],
		Null as [General!1!ShowAllClasses],
		Null AS [General!1!ShowTimeMap],
		Null AS [General!1!ShowClassColor],
		Null AS [General!1!ShowBiWeeklySchedule],
		Null as [General!1!TimeHeightFactor],
		Null as [General!1!AttSunday],
		Null as [General!1!AttMonday],
		Null as [General!1!AttTuesday],
		Null as [General!1!AttWednesday],
		Null as [General!1!AttThursday],
		Null as [General!1!AttFriday],
		Null as [General!1!AttSaturday],

		T.TeacherID AS [Teacher!2!TeacherID],
		T.Lname AS [Teacher!2!Lname],
		T.Fname AS [Teacher!2!Fname],
		T.Mname AS [Teacher!2!Mname],
		T.glname AS [Teacher!2!Tname],
		TI.TimeLegendHTML as [Teacher!2!TimeLegendHTML],

	 	Null As [Class!3!Period],
		Null As [Class!3!ClassTitle],
		Null As [Class!3!Teacher],
		Null As [Class!3!Location],
		Null as [Class!3!LPClassColor],
		Null as [Class!3!PeriodOnSunday],
		Null as [Class!3!PeriodOnSundayConflicts],
		Null as [Class!3!PeriodOnSundayStartMinute],
		Null as [Class!3!PeriodOnSundayEndMinute],
		Null as [Class!3!PeriodOnSundayTime],
		Null as [Class!3!BPeriodOnSunday],
		Null as [Class!3!BPeriodOnSundayConflicts],
		Null as [Class!3!BPeriodOnSundayStartMinute],
		Null as [Class!3!BPeriodOnSundayEndMinute],
		Null as [Class!3!BPeriodOnSundayTime],
		Null as [Class!3!PeriodOnMonday],
		Null as [Class!3!PeriodOnMondayConflicts],
		Null as [Class!3!PeriodOnMondayStartMinute],
		Null as [Class!3!PeriodOnMondayEndMinute],
		Null as [Class!3!PeriodOnMondayTime],			
		Null as [Class!3!BPeriodOnMonday],
		Null as [Class!3!BPeriodOnMondayConflicts],
		Null as [Class!3!BPeriodOnMondayStartMinute],
		Null as [Class!3!BPeriodOnMondayEndMinute],
		Null as [Class!3!BPeriodOnMondayTime],			
		Null as [Class!3!PeriodOnTuesday],
		Null as [Class!3!PeriodOnTuesdayConflicts],
		Null as [Class!3!PeriodOnTuesdayStartMinute],
		Null as [Class!3!PeriodOnTuesdayEndMinute],
		Null as [Class!3!PeriodOnTuesdayTime],
		Null as [Class!3!BPeriodOnTuesday],
		Null as [Class!3!BPeriodOnTuesdayConflicts],
		Null as [Class!3!BPeriodOnTuesdayStartMinute],
		Null as [Class!3!BPeriodOnTuesdayEndMinute],	
		Null as [Class!3!BPeriodOnTuesdayTime],
		Null as [Class!3!PeriodOnWednesday],
		Null as [Class!3!PeriodOnWednesdayConflicts],
		Null as [Class!3!PeriodOnWednesdayStartMinute],
		Null as [Class!3!PeriodOnWednesdayEndMinute],
		Null as [Class!3!PeriodOnWednesdayTime],
		Null as [Class!3!BPeriodOnWednesday],
		Null as [Class!3!BPeriodOnWednesdayConflicts],
		Null as [Class!3!BPeriodOnWednesdayStartMinute],
		Null as [Class!3!BPeriodOnWednesdayEndMinute],	
		Null as [Class!3!BPeriodOnWednesdayTime],
		Null as [Class!3!PeriodOnThursday],
		Null as [Class!3!PeriodOnThursdayConflicts],
		Null as [Class!3!PeriodOnThursdayStartMinute],
		Null as [Class!3!PeriodOnThursdayEndMinute],	
		Null as [Class!3!PeriodOnThursdayTime],
		Null as [Class!3!BPeriodOnThursday],
		Null as [Class!3!BPeriodOnThursdayConflicts],
		Null as [Class!3!BPeriodOnThursdayStartMinute],
		Null as [Class!3!BPeriodOnThursdayEndMinute],
		Null as [Class!3!BPeriodOnThursdayTime],
		Null as [Class!3!PeriodOnFriday],
		Null as [Class!3!PeriodOnFridayConflicts],
		Null as [Class!3!PeriodOnFridayStartMinute],
		Null as [Class!3!PeriodOnFridayEndMinute],	
		Null as [Class!3!PeriodOnFridayTime],
		Null as [Class!3!BPeriodOnFriday],
		Null as [Class!3!BPeriodOnFridayConflicts],
		Null as [Class!3!BPeriodOnFridayStartMinute],
		Null as [Class!3!BPeriodOnFridayEndMinute],
		Null as [Class!3!BPeriodOnFridayTime],
		Null as [Class!3!PeriodOnSaturday],
		Null as [Class!3!PeriodOnSaturdayConflicts],
		Null as [Class!3!PeriodOnSaturdayStartMinute],
		Null as [Class!3!PeriodOnSaturdayEndMinute],
		Null as [Class!3!PeriodOnSaturdayTime],
		Null as [Class!3!BPeriodOnSaturday],
		Null as [Class!3!BPeriodOnSaturdayConflicts],
		Null as [Class!3!BPeriodOnSaturdayStartMinute],
		Null as [Class!3!BPeriodOnSaturdayEndMinute],
		Null as [Class!3!BPeriodOnSaturdayTime],
		Null as [Class!3!LocationOnSunday],
		Null as [Class!3!LocationOnMonday],
		Null as [Class!3!LocationOnTuesday],
		Null as [Class!3!LocationOnWednesday],
		Null as [Class!3!LocationOnThursday],
		Null as [Class!3!LocationOnFriday],
		Null as [Class!3!LocationOnSaturday],
		Null as [Class!3!BLocationOnSunday],
		Null as [Class!3!BLocationOnMonday],
		Null as [Class!3!BLocationOnTuesday],
		Null as [Class!3!BLocationOnWednesday],
		Null as [Class!3!BLocationOnThursday],
		Null as [Class!3!BLocationOnFriday],
		Null as [Class!3!BLocationOnSaturday]

	From 
	(
		Select TeacherID, ClassID 
		From Classes
		Where
		ParentClassID = 0
		and
		TermID = @TermID
		and 
		case
			when @TeacherID = -1 then 1
			when TeacherID = @TeacherID then 1
			else 0
		end = 1	
		Union
		Select TC2.TeacherID, TC2.ClassID 
		From 
		TeachersClasses TC2
			inner join
		Classes C2
			on TC2.ClassID = C2.ClassID
		Where
		C2.ParentClassID = 0
		and
		C2.TermID = @TermID
		and 
		case
			when @TeacherID = -1 then 1
			when TC2.TeacherID = @TeacherID then 1
			else 0
		end = 1	
	) TC	
		inner join
	Classes C 
		on TC.ClassID = C.ClassID
		inner join 
	Teachers T
		on TC.TeacherID = T.TeacherID 
		inner join
	#TeacherInfo TI
		on T.TeacherID = TI.TeacherID
	Where 	
	C.ClassTitle is not null 
	and
	C.TermID = @TermID	
	and
	C.ParentClassID = 0	
	and
	case
		when C.ShowOnSchedule = 1 then 1
		when @ShowAllClasses = 'yes' then 1
		when C.ClassTypeID in (1,8) then 1
		else 0
	end = 1
	and 
	case
		when @TeacherID = -1 then 1
		when T.TeacherID = @TeacherID then 1
		else 0
	end = 1	

	Union All

	Select
		3 as tag,
		2 as parent,
		null as [General!1!ActiveTermID],
		null as [General!1!Admin],
 		Null As [General!1!TheDate],
 		Null AS [General!1!TermTitle],
 		Null AS [General!1!TermID],
		Null AS [General!1!selectedTeacherID],
		Null AS [General!1!Sort], 		
		Null AS [General!1!ClassID],
		Null AS [General!1!EK],
		Null as [General!1!ShowAllClasses],
		Null AS [General!1!ShowTimeMap],
		Null AS [General!1!ShowClassColor],
		Null AS [General!1!ShowBiWeeklySchedule],
		Null as [General!1!TimeHeightFactor],
		Null as [General!1!AttSunday],
		Null as [General!1!AttMonday],
		Null as [General!1!AttTuesday],
		Null as [General!1!AttWednesday],
		Null as [General!1!AttThursday],
		Null as [General!1!AttFriday],
		Null as [General!1!AttSaturday],
        
		T.TeacherID AS [Teacher!2!TeacherID],
		T.Lname AS [Teacher!2!Lname],
		T.Fname AS [Teacher!2!Fname],
		T.Mname AS [Teacher!2!Mname],
		T.glname AS [Teacher!2!Tname],
		Null as [Teacher!2!TimeLegendHTML],
		
	 	C.Period as [Class!3!Period],
		C.ClassTitle as [Class!3!ClassTitle],
		case
			when isnull(ltrim(rtrim(T.StaffTitle)),'') = '' then T.glname
			else ltrim(rtrim(T.StaffTitle)) + ' ' + T.glname
		end as [Class!3!Teacher],
		C.Location as [Class!3!Location],
		C.LPClassColor as [Class!3!LPClassColor],
		-- Sunday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end as [Class!3!PeriodOnSunday],
		dbo.PeriodOnSundayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekA') as [Class!3!PeriodOnSundayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end)  as [Class!3!PeriodOnSundayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end)  as [Class!3!PeriodOnSundayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end)  as [Class!3!PeriodOnSundayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end as [Class!3!BPeriodOnSunday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnSundayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekB') 
		end as [Class!3!BPeriodOnSundayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end)  as [Class!3!BPeriodOnSundayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end)  as [Class!3!BPeriodOnSundayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end)  as [Class!3!BPeriodOnSundayTime],
		-- Monday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end as [Class!3!PeriodOnMonday],
		dbo.PeriodOnMondayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekA') as [Class!3!PeriodOnMondayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end)  as [Class!3!PeriodOnMondayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end)  as [Class!3!PeriodOnMondayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end)  as [Class!3!PeriodOnMondayTime],			
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end as [Class!3!BPeriodOnMonday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnMondayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekB') 
		end as [Class!3!BPeriodOnMondayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end)  as [Class!3!BPeriodOnMondayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end)  as [Class!3!BPeriodOnMondayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end)  as [Class!3!BPeriodOnMondayTime],			
		-- Tuesday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end as [Class!3!PeriodOnTuesday],
		dbo.PeriodOnTuesdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekA')	as [Class!3!PeriodOnTuesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end)  as [Class!3!PeriodOnTuesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end)  as [Class!3!PeriodOnTuesdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end)  as [Class!3!PeriodOnTuesdayTime],		
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end as [Class!3!BPeriodOnTuesday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnTuesdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekB') 
		end as [Class!3!BPeriodOnTuesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end)  as [Class!3!BPeriodOnTuesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end)  as [Class!3!BPeriodOnTuesdayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end)  as [Class!3!BPeriodOnTuesdayTime],
		-- Wednesday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end as [Class!3!PeriodOnWednesday],
		dbo.PeriodOnWednesdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekA') as [Class!3!PeriodOnWednesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end)  as [Class!3!PeriodOnWednesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end)  as [Class!3!PeriodOnWednesdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end)  as [Class!3!PeriodOnWednesdayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end as [Class!3!BPeriodOnWednesday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnWednesdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekB') 
		end as [Class!3!BPeriodOnWednesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end)  as [Class!3!BPeriodOnWednesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end)  as [Class!3!BPeriodOnWednesdayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end)  as [Class!3!BPeriodOnWednesdayTime],
		-- Thursday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end as [Class!3!PeriodOnThursday],
		dbo.PeriodOnThursdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekA') as [Class!3!PeriodOnThursdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end)  as [Class!3!PeriodOnThursdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end)  as [Class!3!PeriodOnThursdayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end)  as [Class!3!PeriodOnThursdayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end as [Class!3!BPeriodOnThursday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnThursdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekB') 
		end as [Class!3!BPeriodOnThursdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end)  as [Class!3!BPeriodOnThursdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end)  as [Class!3!BPeriodOnThursdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end)  as [Class!3!BPeriodOnThursdayTime],
		-- Friday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end as [Class!3!PeriodOnFriday],
		dbo.PeriodOnFridayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekA') as [Class!3!PeriodOnFridayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end)  as [Class!3!PeriodOnFridayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end)  as [Class!3!PeriodOnFridayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end)  as [Class!3!PeriodOnFridayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end as [Class!3!BPeriodOnFriday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnFridayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekB') 
		end as [Class!3!BPeriodOnFridayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end)  as [Class!3!BPeriodOnFridayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end)  as [Class!3!BPeriodOnFridayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end)  as [Class!3!BPeriodOnFridayTime],
		-- Saturday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end as [Class!3!PeriodOnSaturday],
		dbo.PeriodOnSaturdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekA') as [Class!3!PeriodOnSaturdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end)  as [Class!3!PeriodOnSaturdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end)  as [Class!3!PeriodOnSaturdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end)  as [Class!3!PeriodOnSaturdayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end as [Class!3!BPeriodOnSaturday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnSaturdayTeacherClassConflictsExist(@TermID, C.ClassID, T.TeacherID, 'WeekB') 
		end as [Class!3!BPeriodOnSaturdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- TI.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end)  as [Class!3!BPeriodOnSaturdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end)  as [Class!3!BPeriodOnSaturdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end)  as [Class!3!BPeriodOnSaturdayTime],
	
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnSunday)
		end as [Class!3!LocationOnSunday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnMonday) 
		end as [Class!3!LocationOnMonday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnTuesday) 
		end as [Class!3!LocationOnTuesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnWednesday) 
		end as [Class!3!LocationOnWednesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnThursday) 
		end as [Class!3!LocationOnThursday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnFriday) 
		end as [Class!3!LocationOnFriday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnSaturday) 
		end as [Class!3!LocationOnSaturday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnSunday) 
		end as [Class!3!BLocationOnSunday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnMonday) 
		end as [Class!3!BLocationOnMonday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnTuesday) 
		end as [Class!3!BLocationOnTuesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnWednesday) 
		end as [Class!3!BLocationOnWednesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnThursday) 
		end as [Class!3!BLocationOnThursday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnFriday) 
		end as [Class!3!BLocationOnFriday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnSaturday) 
		end as [Class!3!BLocationOnSaturday]
		
	From 
	(
		Select TeacherID, ClassID 
		From Classes
		Where
		ParentClassID = 0
		and
		TermID = @TermID
		and 
		case
			when @TeacherID = -1 then 1
			when TeacherID = @TeacherID then 1
			else 0
		end = 1	
		Union
		Select TC2.TeacherID, TC2.ClassID 
		From 
		TeachersClasses TC2
			inner join
		Classes C2
			on TC2.ClassID = C2.ClassID
		Where
		C2.ParentClassID = 0
		and
		C2.TermID = @TermID
		and 
		case
			when @TeacherID = -1 then 1
			when TC2.TeacherID = @TeacherID then 1
			else 0
		end = 1	
	) TC	
		inner join
	Classes C 
		on TC.ClassID = C.ClassID
		inner join 
	Teachers T
		on TC.TeacherID = T.TeacherID 
		inner join
	#TeacherInfo TI
		on T.TeacherID = TI.TeacherID
	Where 	
	C.ClassTitle is not null 
	and
	C.TermID = @TermID	
	and
	C.ParentClassID = 0	
	and
	case
		when C.ShowOnSchedule = 1 then 1
		when @ShowAllClasses = 'yes' then 1
		when C.ClassTypeID in (1,8) then 1
		else 0
	end = 1
	and 
	case
		when @TeacherID = -1 then 1
		when T.TeacherID = @TeacherID then 1
		else 0
	end = 1				

	Order By [Teacher!2!Lname], [Teacher!2!Fname], [Teacher!2!Mname], [Teacher!2!TeacherID], [Class!3!Period], [Class!3!ClassTitle], tag
	FOR XML EXPLICIT



	Select
	(
		Select
		convert(tinyint, AttSunday) +
		convert(tinyint, AttMonday ) +
		convert(tinyint, AttTuesday ) +
		convert(tinyint, AttWednesday ) +
		convert(tinyint, AttThursday ) +
		convert(tinyint, AttFriday ) +
		convert(tinyint, AttSaturday)
		From Settings
		Where
		SettingID = 1
	) as NumberOfDays,
	AttSunday,
	AttMonday,
	AttTuesday,
	AttWednesday,
	AttThursday,
	AttFriday,
	AttSaturday
	From Settings
	Where
	SettingID = 1
	FOR XML RAW	


	drop table #TeacherInfo;

END
GO
