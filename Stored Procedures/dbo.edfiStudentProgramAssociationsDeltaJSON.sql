SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 08/10/2021
-- Modified dt: 09/27/2022 
-- Description:	This returns the edfi Students program JSON 
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStudentProgramAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewSSAssnsJSONstr nvarchar(max);
	Declare @NewSSAssnsJSON table (studentProgramKey nvarchar(100) PRIMARY KEY, ssAssnJSON nvarchar(1000));
	Declare @OldSSAssnsJSON table (studentProgramKey nvarchar(100) PRIMARY KEY, ssAssnJSON nvarchar(1000));

	exec edfiStudentProgramAssociationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewSSAssnsJSONstr output;

	insert into @NewSSAssnsJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.programReference."name"') + ':' + JSON_VALUE(value, '$."beginDate"') as studentProgramKey,
	value as ssAssnJSON
	From
	OPENJSON(@NewSSAssnsJSONstr);

	insert into @OldSSAssnsJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.programReference."name"') + ':' + JSON_VALUE(value, '$."beginDate"') as studentProgramKey,
	value as ssAssnJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentProgramAssociations'
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
			SELECT N',' + O.ssAssnJSON 
			From 
			@OldSSAssnsJSON O
				left join
			@NewSSAssnsJSON N
				on N.studentProgramKey = O.studentProgramKey
			Where
			N.ssAssnJSON is null
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + NN.ssAssnJSON 
			From (
				select 
					ISNULL(N.studentProgramKey, O.studentProgramKey) as studentProgramKey,
					ISNULL(N.ssAssnJSON, O.ssAssnJSON) as ssAssnJSON
				from @OldSSAssnsJSON O
					FULL OUTER JOIN @NewSSAssnsJSON N
						on O.studentProgramKey = N.studentProgramKey
			) NN
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'StudentProgramAssociations';

	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentProgramAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentProgramAssociations'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + N.ssAssnJSON 
			From 
			@NewSSAssnsJSON N
				left join
			@OldSSAssnsJSON O
				on N.studentProgramKey = O.studentProgramKey
			Where
			N.ssAssnJSON != isnull(O.ssAssnJSON,'')
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;


END
GO
