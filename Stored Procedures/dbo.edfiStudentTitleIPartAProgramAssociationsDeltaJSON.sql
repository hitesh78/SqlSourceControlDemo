SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 02/11/2022
-- Modified dt: 09/27/2022 
-- Description:	student title I Part A prog asc
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE       PROCEDURE [dbo].[edfiStudentTitleIPartAProgramAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewSaepaJSONstr nvarchar(max);
	Declare @NewSaepaJSON table (code nvarchar(100) PRIMARY KEY, cpJSON nvarchar(4000));
	Declare @OldSaepaJSON table (code nvarchar(100) PRIMARY KEY, cpJSON nvarchar(4000));

	exec edfiStudentTitleIPartAProgramAssociationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewSaepaJSONstr output;

	insert into @NewSaepaJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
	JSON_VALUE(value, '$.programReference."name"') + ':' + 
	JSON_VALUE(value, '$."beginDate"') + ':' + 
	substring(JSON_VALUE(value, '$.services[0]."serviceDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.services[0]."serviceDescriptor"')) + 5, 100) as code,
	value as cpJSON
	From
	OPENJSON(@NewSaepaJSONstr);


	insert into @OldSaepaJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
	JSON_VALUE(value, '$.programReference."name"') + ':' + 
	JSON_VALUE(value, '$."beginDate"') + ':' + 
	substring(JSON_VALUE(value, '$.services[0]."serviceDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.services[0]."serviceDescriptor"')) + 5, 100) as code,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentTitleIPartAProgramAssociations'
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
			From @OldSaepaJSON O
				left join @NewSaepaJSON N
					on N.code = O.code
			Where N.cpJSON is null  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
		  (
		  SELECT N',' + N.cpJSON
		  From @NewSaepaJSON N
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'StudentTitleIPartAProgramAssociations';
		
	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentTitleIPartAProgramAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentTitleIPartAProgramAssociations'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.cpJSON 
			From @NewSaepaJSON N
				left join @OldSaepaJSON O
				on N.code = O.code
			Where N.cpJSON != isnull(O.cpJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
