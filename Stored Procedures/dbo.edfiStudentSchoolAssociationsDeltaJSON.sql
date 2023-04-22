SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Don Puls/Joey
-- Create date: 5/26/2021
-- Modified dt: 9/27/2022 
-- Description:	This returns the edfi Students JSON - This was initially done for Indiana 
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE         PROCEDURE [dbo].[edfiStudentSchoolAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewSSAssnsJSONstr nvarchar(max);
	Declare @NewSSAssnsJSON table (studentUniqueID nvarchar(30) PRIMARY KEY, ssAssnJSON nvarchar(1000));
	Declare @OldSSAssnsJSON table (studentUniqueID nvarchar(30) PRIMARY KEY, ssAssnJSON nvarchar(1000));

	exec edfiStudentSchoolAssociationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewSSAssnsJSONstr output;

	insert into @NewSSAssnsJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as ssAssnJSON
	From
	OPENJSON(@NewSSAssnsJSONstr);


	insert into @OldSSAssnsJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as ssAssnJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentSchoolAssociations'
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
				on N.studentUniqueID = O.studentUniqueID
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
					ISNULL(N.studentUniqueId, O.studentUniqueId) as studentUniqueID,
					ISNULL(N.ssAssnJSON, O.ssAssnJSON) as ssAssnJSON
				from @OldSSAssnsJSON O 
					FULL OUTER JOIN @NewSSAssnsJSON N
						on O.studentUniqueID = N.studentUniqueID
			) NN
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'StudentSchoolAssociations';
	
	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentSchoolAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentSchoolAssociations'
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
				on N.studentUniqueID = O.studentUniqueID
			Where
			N.ssAssnJSON != isnull(O.ssAssnJSON,'')
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
