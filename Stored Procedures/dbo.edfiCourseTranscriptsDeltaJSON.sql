SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 01/11/2022
-- Modified dt: 09/23/2022 
-- Description:	edfi course transcripts Delta 
-- Rev. Notes: changed how datasnapshot logic works
-- =============================================
CREATE       PROCEDURE [dbo].[edfiCourseTranscriptsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewCoTrJSONstr nvarchar(max);
	Declare @NewCoTrJSON table (code nvarchar(40) PRIMARY KEY, cpJSON nvarchar(1000));
	Declare @OldCoTrJSON table (code nvarchar(40) PRIMARY KEY, cpJSON nvarchar(1000));

	exec edfiCourseTranscriptsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewCoTrJSONstr output;

	insert into @NewCoTrJSON
	Select
	JSON_VALUE(value, '$."alternativeCourseCode"') as code,
	value as cpJSON
	From
	OPENJSON(@NewCoTrJSONstr);


	insert into @OldCoTrJSON
	Select
	JSON_VALUE(value, '$."alternativeCourseCode"') as code,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'CourseTranscripts'
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
			From @OldCoTrJSON O
				left join @NewCoTrJSON N
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
			SELECT 
				ISNULL(N.code, O.code) as code,
				ISNULL(N.cpJSON, O.cpJSON) as cpJSON
			FROM @OldCoTrJSON O
				FULL OUTER JOIN @NewCoTrJSON N
					on O.code = N.code
		  ) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'CourseTranscripts';

	-- clears out the old snapshots is real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'CourseTranscripts'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'CourseTranscripts'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.cpJSON 
			From @NewCoTrJSON N
				left join @OldCoTrJSON O
				on N.code = O.code
			Where N.cpJSON != isnull(O.cpJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
