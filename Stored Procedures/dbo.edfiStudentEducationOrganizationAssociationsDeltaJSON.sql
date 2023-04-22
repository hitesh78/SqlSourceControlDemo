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
CREATE   PROCEDURE [dbo].[edfiStudentEducationOrganizationAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewSEOAJSONstr nvarchar(max);
	Declare @NewSEOAJSON table (studentUniqueID nvarchar(30) PRIMARY KEY, seoaJSON nvarchar(1000));
	Declare @OldSEOAJSON table (studentUniqueID nvarchar(30) PRIMARY KEY, seoaJSON nvarchar(1000));

	exec edfiStudentEducationOrganizationAssociationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewSEOAJSONstr output;

	insert into @NewSEOAJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as seoaJSON
	From
	OPENJSON(@NewSEOAJSONstr);

	insert into @OldSEOAJSON
	Select
	substring(JSON_VALUE(value, '$.studentReference."studentUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.studentReference."studentUniqueId"')) +1, 30)  as studentUniqueID,
	value as seoaJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentsEducationOrgAssociations'
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
			SELECT N',' + O.seoaJSON 
			From 
			@OldSEOAJSON O
				left join
			@NewSEOAJSON N
				on N.studentUniqueID = O.studentUniqueID
			Where
			N.seoaJSON is null
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + NN.seoaJSON 
			From (
				select 
					ISNULL(N.studentUniqueID, O.studentUniqueID) as studentUniqueID,
					ISNULL(N.seoaJSON, O.seoaJSON) as seoaJSON
				from @OldSEOAJSON O
					FULL OUTER JOIN @NewSEOAJSON N
						on O.studentUniqueID = N.studentUniqueID
			) NN
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'StudentsEducationOrgAssociations';

	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentsEducationOrgAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentsEducationOrgAssociations'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + N.seoaJSON 
			From 
			@NewSEOAJSON N
				left join
			@OldSEOAJSON O
				on N.studentUniqueID = O.studentUniqueID
			Where
			N.seoaJSON != isnull(O.seoaJSON,'')
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;



END
GO
