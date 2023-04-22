SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 10/14/2021
-- Modified dt: 09/23/2022 
-- Description:	locations
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE   PROCEDURE [dbo].[edfiLocationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewLocJSONstr nvarchar(max);
	Declare @NewLocJSON table (locCode nvarchar(40) PRIMARY KEY, locJSON nvarchar(1000));
	Declare @OldLocJSON table (locCode nvarchar(40) PRIMARY KEY, locJSON nvarchar(1000));

	exec edfiLocationsJSON @NewLocJSONstr output; 

	insert into @NewLocJSON
	Select
	JSON_VALUE(value, '$."classroomIdentificationCode"') as locCode,
	value as locJSON
	From
	OPENJSON(@NewLocJSONstr);


	insert into @OldLocJSON
	Select
	JSON_VALUE(value, '$."classroomIdentificationCode"') as locCode,
	value as locJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'Locations'
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
			SELECT N',' + O.locJSON 
			From @OldLocJSON O
				left join @NewLocJSON N
					on N.locCode = O.locCode
			Where N.locJSON is null  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
		  SELECT N',' + NN.locJSON
		  From (
			select 
				ISNULL(N.locCode, O.locCode) as locCode,
				ISNULL(N.locJSON, O.locJSON) as locJSON		
			from @OldLocJSON O 
				FULL OUTER JOIN @NewLocJSON N
					on O.locCode = N.locCode
		  ) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'Locations';

	-- clears out the old snapshots is real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'Locations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'Locations'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.locJSON 
			From @NewLocJSON N
				left join @OldLocJSON O
				on N.locCode = O.locCode
			Where N.locJSON != isnull(O.locJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
