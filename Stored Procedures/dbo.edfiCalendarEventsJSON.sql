SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls/Joey G
-- Create date: 05/10/2021
-- Modified dt: 10/11/2022
-- Description:	Takes three parameters and returns the edfi Calendar Events
-- Rev. Notes:	filter out Custom Event type
-- =============================================
CREATE   PROCEDURE [dbo].[edfiCalendarEventsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@CalendarEventsJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);
	
	CREATE TABLE #CalendarEventsTable
	(
		[date] date,
		[event] nvarchar(30),
		[duration] int
	)
	
	-- add school days
	insert into #CalendarEventsTable
	SELECT 
		theDate as [date],
		'Student Calendar' as [event],
		1 as [duration]
	From dbo.getSchoolDates(@CalendarStartDate, @CalendarEndDate)

	-- add Instructional Day dates added to Non-school Days
	insert into #CalendarEventsTable
	SELECT 
		theDate as [date],
		'Student Calendar' as [event],
		1 as [duration]
	From dbo.getEdFiInstructionalDayDates(@CalendarStartDate, @CalendarEndDate);

	-- add non school days
	insert into #CalendarEventsTable
	Select 
		a.theDate as [date],
		E.CalendarEvent as [event],
		1 as [duration]
	from (
		Select
			theDate
		From dbo.GetDates(@CalendarStartDate, @CalendarEndDate)
		Where datename(weekday, theDate) in (
			Select * 
			From dbo.SplitCSVStrings(
				(Select
					case when AttSunday = 1 then 'Sunday,' else '' end + 
					case when AttMonday = 1 then 'Monday,' else '' end +
					case when AttTuesday = 1 then 'Tuesday,' else '' end +
					case when AttWednesday = 1 then 'Wednesday,' else '' end +
					case when AttThursday = 1 then 'Thursday,' else '' end +
					case when AttFriday = 1 then 'Friday,' else '' end +
					case when AttSaturday = 1 then 'Saturday' else '' end as weekdays
				From Settings Where SettingID = 1))
		)
	) a -- all school calendar dates
	inner join NonSchoolDays n
		on (
			a.theDate = n.TheDate
			or 
			a.theDate BETWEEN n.StartDate AND n.EndDate
			)
	inner join EdFiCalendarEvents E
		on n.EventID = E.EventID
	inner join EdFiEventTypes ET
		on E.EventTypeID = ET.EventTypeID
	where ET.EventType <> 'Instructional day' and ET.EventType <> 'Custom Event';

	Declare @edfiDailyInstructionalMinutes int = (Select DailyInstructionalMinutes From EdFiODS Where SchoolYear = @SchoolYear);

	set @CalendarEventsJSON = (
		SELECT
		@SchoolID as [schoolReference.schoolId],
		[date],
		@edfiDailyInstructionalMinutes * [duration] as [eventMinutes], -- TBD
		(
			Select
			'http://doe.in.gov/Descriptor/CalendarEventDescriptor.xml/' + [event] as [calendarEventDescriptor],
			[duration] as [eventDuration]
			FOR JSON PATH
		) as [calendarEvents]
		From #CalendarEventsTable	
		FOR JSON PATH
	);

	drop table #CalendarEventsTable;


END
GO
