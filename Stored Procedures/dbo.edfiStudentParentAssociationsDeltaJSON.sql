SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 08/16/2021
-- Modified dt: 02/17/2022
-- Description:	This returns the edfi edfiStudentParentAssociationsJSON delta
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE     PROCEDURE [dbo].[edfiStudentParentAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;


	Declare @NewSPAJSONstr nvarchar(max);
	Declare @NewSPAJSON table (spaUniqueId nvarchar(100) PRIMARY KEY, spaJSON nvarchar(1000));
	Declare @OldSPAJSON table (spaUniqueId nvarchar(100) PRIMARY KEY, spaJSON nvarchar(1000));

	exec edfiStudentParentAssociationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewSPAJSONstr output;

	insert into @NewSPAJSON
	Select
	JSON_VALUE(value, '$.parentReference."parentUniqueId"') + ':' + JSON_VALUE(value, '$.studentReference."studentUniqueId"') as spaUniqueId,
	value as spaJSON
	From
	OPENJSON(@NewSPAJSONstr);

	insert into @OldSPAJSON
	Select
	JSON_VALUE(value, '$.parentReference."parentUniqueId"') + ':' + JSON_VALUE(value, '$.studentReference."studentUniqueId"') as spaUniqueId,
	value as spaJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentParentAssociations'
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
			SELECT N',' + O.spaJSON 
			From 
			@OldSPAJSON O
				left join
			@NewSPAJSON N
				on N.spaUniqueId = O.spaUniqueId
			Where
			N.spaJSON is null
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + NN.spaJSON 
			From (
				Select 
					ISNULL(N.spaUniqueId, O.spaUniqueId) as spaUniqueId,
					ISNULL(N.spaJSON, O.spaJSON) as spaJSON
				from @OldSPAJSON O
					FULL OUTER JOIN @NewSPAJSON N
						on O.spaUniqueId = N.spaUniqueId
			) NN
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'StudentParentAssociations';

	-- clears out the old snapshots is real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentParentAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentParentAssociations'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;


	Select
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + N.spaJSON 
			From 
			@NewSPAJSON N
				left join
			@OldSPAJSON O
				on N.spaUniqueId = O.spaUniqueId
			Where
			N.spaJSON != isnull(O.spaJSON,'')
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
