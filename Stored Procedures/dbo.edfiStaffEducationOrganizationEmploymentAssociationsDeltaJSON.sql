SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Don Puls/Joey
-- Create date: 8/9/2021
-- Modified dt: 9/29/2022 
-- Description:	This returns the edfi StaffEducationOrganizationEmploymentAssociationsDelta JSON delta
-- Rev. Notes:	changed how datasnapshot logic works, include educationOrganizationId
-- =============================================
CREATE     PROCEDURE [dbo].[edfiStaffEducationOrganizationEmploymentAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewSEOEAJSONstr nvarchar(max);
	Declare @NewSEOEAJSON table (staffUniqueId nvarchar(30) PRIMARY KEY, seoeaJSON nvarchar(1000));
	Declare @OldSEOEAJSON table (staffUniqueId nvarchar(30) PRIMARY KEY, seoeaJSON nvarchar(1000));

	exec edfiStaffEducationOrganizationEmploymentAssociationsJSON @NewSEOEAJSONstr output;

	insert into @NewSEOEAJSON
	Select
	substring(JSON_VALUE(value, '$.staffReference."staffUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.staffReference."staffUniqueId"')) +1, 30) +  
	JSON_VALUE(value, '$.educationOrganizationReference."educationOrganizationId"') as staffUniqueId,
	value as seoeaJSON
	From
	OPENJSON(@NewSEOEAJSONstr);


	insert into @OldSEOEAJSON
	Select
	substring(JSON_VALUE(value, '$.staffReference."staffUniqueId"'), PATINDEX('%-%', JSON_VALUE(value, '$.staffReference."staffUniqueId"')) +1, 30) +  
	JSON_VALUE(value, '$.educationOrganizationReference."educationOrganizationId"') as staffUniqueId,
	value as seoeaJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StaffEducationOrganizationEmploymentAssociations'
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
			SELECT N',' + O.seoeaJSON 
			From 
			@OldSEOEAJSON O
				left join
			@NewSEOEAJSON N
				on N.staffUniqueId = O.staffUniqueId
			Where
			N.seoeaJSON is null
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	),
	dataSnapshot =
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + NN.seoeaJSON 
			From (
				select 
					ISNULL(N.staffUniqueId, O.staffUniqueId) as staffUniqueId,
					ISNULL(N.seoeaJSON, O.seoeaJSON) as seoeaJSON
				from @OldSEOEAJSON O
					FULL OUTER JOIN @NewSEOEAJSON N
						on O.staffUniqueId = N.staffUniqueId
			) NN
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where
	JobID = @JobID
	and
	edfiResource = 'StaffEducationOrganizationEmploymentAssociations';
		
	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StaffEducationOrganizationEmploymentAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StaffEducationOrganizationEmploymentAssociations'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
			(
			SELECT N',' + N.seoeaJSON 
			From 
			@NewSEOEAJSON N
				left join
			@OldSEOEAJSON O
				on N.staffUniqueId = O.staffUniqueId
			Where
			N.seoeaJSON != isnull(O.seoeaJSON,'')
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;


END
GO
