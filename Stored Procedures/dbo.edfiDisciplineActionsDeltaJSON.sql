SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 01/07/2022
-- Modified dt: 09/23/2022 
-- Description:	edfi Discipline Actions Delta 
-- Rev. Notes: changed how datasnapshot logic works
-- =============================================
CREATE       PROCEDURE [dbo].[edfiDisciplineActionsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewDisActJSONstr nvarchar(max);
	Declare @NewDisActJSON table (code nvarchar(40) PRIMARY KEY, cpJSON nvarchar(1000));
	Declare @OldDisActJSON table (code nvarchar(40) PRIMARY KEY, cpJSON nvarchar(1000));

	exec edfiDisciplineActionsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewDisActJSONstr output;

	insert into @NewDisActJSON
	Select
	JSON_VALUE(value, '$."identifier"') as code,
	value as cpJSON
	From
	OPENJSON(@NewDisActJSONstr);


	insert into @OldDisActJSON
	Select
	JSON_VALUE(value, '$."identifier"') as code,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'DisciplineActions'
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
			SELECT N',' + O.cpJSON 
			From @OldDisActJSON O
				left join @NewDisActJSON N
					on N.code = O.code
			Where N.cpJSON is null  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
		  SELECT N',' + NN.cpJSON
		  From (
			select 
				ISNULL(N.code, O.code) as code,
				ISNULL(N.cpJSON, O.cpJSON) as cpJSON
			from @OldDisActJSON O
				FULL OUTER JOIN @NewDisActJSON N
					on O.code = N.code
		  ) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'DisciplineActions';

	-- clears out the old snapshots is real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'DisciplineActions'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'DisciplineActions'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.cpJSON 
			From @NewDisActJSON N
				left join @OldDisActJSON O
				on N.code = O.code
			Where N.cpJSON != isnull(O.cpJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
