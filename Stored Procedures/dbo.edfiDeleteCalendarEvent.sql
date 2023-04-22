SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 6/25/2021
-- Modified dt: 6/25/2021
-- Description:	moves an entry from dataSnapshot to dataDeleted
-- Parameters: SchoolYear, Date
-- =============================================
Create   Procedure [dbo].[edfiDeleteCalendarEvent]
@SchoolYear int,
@Date date
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SnapshotEventsJSON table (theDate date PRIMARY KEY, eventJSON nvarchar(1000));
	Declare @DeletedEventsJSON table (theDate date PRIMARY KEY, eventJSON nvarchar(1000));
	Declare @PostID int;

	set @PostID = (Select top 1 PostID 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'CalendarDates'
			and
			dataSnapshot is not null
			order by PostStartDateUTC desc);

	insert into @SnapshotEventsJSON
	Select
	JSON_VALUE(value, '$."date"'),
	value as ssAssnJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			PostID = @PostID
		)
	);

	insert into @DeletedEventsJSON
	Select
	JSON_VALUE(value, '$."date"'),
	value as ssAssnJSON
	From
	OPENJSON(
		(
			Select top 1 dataDeleted 
			From EdfiSubmissionStatus 
			Where
			PostID = @PostID
		)
	)
	UNION
	Select theDate, eventJSON
	From @SnapshotEventsJSON S
	Where
	S.theDate = @Date;

	Update EdfiSubmissionStatus
	Set dataDeleted =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + D.eventJSON 
			From 
			@DeletedEventsJSON D
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + O.eventJSON 
			From 
			@SnapshotEventsJSON O
			Where
			O.theDate <> @Date
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where PostID = @PostID;

END

GO
