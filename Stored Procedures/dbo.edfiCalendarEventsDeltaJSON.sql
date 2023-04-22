SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Don Puls/Joey G
-- Create date: 05/26/2021
-- Modified dt: 09/20/2022
-- Description:	This returns the edfi Students JSON - This was initially done for Indiana 
-- Rev. Notes:	changed how datasnapshot logic works 
-- =============================================
CREATE   PROCEDURE [dbo].[edfiCalendarEventsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewEventsJSONstr nvarchar(max);
	Declare @NewEventsJSON table (theDate date PRIMARY KEY, eventJSON nvarchar(1000));
	Declare @OldEventsJSON table (theDate date PRIMARY KEY, eventJSON nvarchar(1000));

	exec edfiCalendarEventsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewEventsJSONstr output;

	insert into @NewEventsJSON
	Select
	JSON_VALUE(value, '$."date"'),
	value as eventJSON
	From
	OPENJSON(@NewEventsJSONstr);

	insert into @OldEventsJSON
	Select
	JSON_VALUE(value, '$."date"'),
	value as eventJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'CalendarDates'
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
			SELECT N',' + O.eventJSON 
			From 
			@OldEventsJSON O
				left join
			@NewEventsJSON N
				on N.theDate = O.theDate
			Where
			N.eventJSON is null
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + NN.eventJSON 
			From 
			(
				SELECT
					ISNULL(N.theDate, O.theDate) as theDate,
					ISNULL(N.eventJSON, O.eventJSON) as eventJSON
				from @OldEventsJSON O
					FULL OUTER JOIN @NewEventsJSON N
						on O.theDate = N.theDate
			) NN
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'CalendarDates';

	-- clears out the old snapshots is real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'CalendarDates'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'CalendarDates'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	-- return data
	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.eventJSON 
			From 
			@NewEventsJSON N
				left join
			@OldEventsJSON O
				on N.theDate = O.theDate
			Where
			N.eventJSON != isnull(O.eventJSON,'')
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
