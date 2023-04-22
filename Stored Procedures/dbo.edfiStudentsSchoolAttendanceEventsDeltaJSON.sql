SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Don Puls/Joey
-- Create date: 05/27/2021
-- Modified dt: 03/07/2023
-- Description:	This returns the delta edfi StudentsSchoolAttendance JSON
-- Rev. Notes:	adds distinct to data snapshot query
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStudentsSchoolAttendanceEventsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewAttendanceEventsJSONstr nvarchar(max);
	Create table #NewAttendanceEventsJSON (StudentIDdateEvent nvarchar(150), AttendanceEventJSON nvarchar(1000));
	Create table #OldAttendanceEventsJSON (StudentIDdateEvent nvarchar(150), AttendanceEventJSON nvarchar(1000));
	create clustered index c_New on #NewAttendanceEventsJSON (StudentIDdateEvent);
	create clustered index c_New on #OldAttendanceEventsJSON (StudentIDdateEvent);

	exec edfiStudentsSchoolAttendanceEvents @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewAttendanceEventsJSONstr output;

	insert into #NewAttendanceEventsJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$."eventDate"') + ':' +
	substring(JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"')) + 5, 100) + ':' + 
	substring(JSON_VALUE(value, '$.sessionReference."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.sessionReference."termDescriptor"')) + 5, 100) as StudentIDdateEvent,
	value as ssAssnJSON
	From
	OPENJSON(@NewAttendanceEventsJSONstr);


	insert into #OldAttendanceEventsJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$."eventDate"') + ':' +
	substring(JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."attendanceEventCategoryDescriptor"')) + 5, 100) + ':' + 
	substring(JSON_VALUE(value, '$.sessionReference."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.sessionReference."termDescriptor"')) + 5, 100) as StudentIDdateEvent,
	value as ssAssnJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentsSchoolAttendanceEvents'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc
		)
	);

	Update EdfiSubmissionStatus
	Set
	dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + O.AttendanceEventJSON 
			From 
			#OldAttendanceEventsJSON O
				left join
			#NewAttendanceEventsJSON N
				on N.StudentIDdateEvent = O.StudentIDdateEvent
			Where
			N.AttendanceEventJSON is null
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + NN.AttendanceEventJSON 
			From (
				select distinct
					ISNULL(N.StudentIDdateEvent, O.StudentIDdateEvent) as StudentIDdateEvent,
					ISNULL(N.AttendanceEventJSON, O.AttendanceEventJSON) as AttendanceEventJSON
				from #OldAttendanceEventsJSON O
					FULL OUTER JOIN #NewAttendanceEventsJSON N
						on O.StudentIDdateEvent = N.StudentIDdateEvent
			) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'StudentsSchoolAttendanceEvents';

	-- clears out the old snapshots if real JobID is passed
	IF @@ROWCOUNT > 0 AND EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentsSchoolAttendanceEvents'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentsSchoolAttendanceEvents'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;
	
	Select 
	(
		SELECT '[' + Stuff(
		(
			SELECT N',' + N.AttendanceEventJSON 
			From #NewAttendanceEventsJSON N
				left join #OldAttendanceEventsJSON O
					on N.StudentIDdateEvent = O.StudentIDdateEvent
			Where N.AttendanceEventJSON != isnull(O.AttendanceEventJSON,'')
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

	drop table #NewAttendanceEventsJSON;
	drop table #OldAttendanceEventsJSON;

END
GO
