SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 8/16/2021
-- Modified dt: 9/23/2022 
-- Description:	This returns the edfi Parents JSON
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE     PROCEDURE [dbo].[edfiParentsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewParentJSONstr nvarchar(max);
	Declare @NewParentJSON table (parentUniqueId nvarchar(40) PRIMARY KEY, parentJSON nvarchar(1000));
	Declare @OldParentJSON table (parentUniqueId nvarchar(40) PRIMARY KEY, parentJSON nvarchar(1000));

	exec edfiParentsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewParentJSONstr output;

	insert into @NewParentJSON
	Select
	JSON_VALUE(value, '$."parentUniqueId"') as parentUniqueId,
	value as parentJSON
	From
	OPENJSON(@NewParentJSONstr);


	insert into @OldParentJSON
	Select
	JSON_VALUE(value, '$."parentUniqueId"') as parentUniqueId,
	value as parentJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'Parents'
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
			SELECT N',' + O.parentJSON 
			From 
			@OldParentJSON O
				left join
			@NewParentJSON N
				on N.parentUniqueId = O.parentUniqueId
			Where
			N.parentJSON is null  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
		  SELECT N',' + NN.parentJSON
		  From (
			select 
				ISNULL(N.parentUniqueId, O.parentUniqueId) as parentUniqueId,
				ISNULL(N.parentJSON, O.parentJSON) as parentJSON
			from @OldParentJSON O
				FULL OUTER JOIN @NewParentJSON N
					on O.parentUniqueId = N.parentUniqueId
		  ) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'Parents';

	-- clears out the old snapshots is real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'Parents'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'Parents'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.parentJSON 
			From 
			@NewParentJSON N
				left join
			@OldParentJSON O
				on N.parentUniqueId = O.parentUniqueId
			Where
			N.parentJSON != isnull(O.parentJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
