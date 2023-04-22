SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--=============================================
-- Author:		Freddy
-- Create date: 10/19/2022
-- Modified dt: 10/19/2022 
-- Description:	student Student Education Organization Assessment Accommodations DeltaJSON
-- Rev. Notes: 
-- =============================================
CREATE        PROCEDURE [dbo].[edfiStudentEducationOrganizationAssessmentAccommodationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewSaepaJSONstr nvarchar(max);
	Declare @NewSaepaJSON table (studentProgramKey nvarchar(200) PRIMARY KEY, cpJSON nvarchar(1000));
	Declare @OldSaepaJSON table (studentProgramKey nvarchar(200) PRIMARY KEY, cpJSON nvarchar(1000));

	exec edfiStudentEducationOrganizationAssessmentAccommodationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewSaepaJSONstr output;

	insert into @NewSaepaJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 	
	JSON_VALUE(value, '$.assessmentAccommodationReference."assessmentIdentifier"') + ':' + 	
	substring(JSON_VALUE(value, '$.assessmentAccommodationReference."academicSubjectDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."academicSubjectDescriptor"')) +5, 100) + ':' +
	substring(JSON_VALUE(value, '$.assessmentAccommodationReference."accommodationDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."accommodationDescriptor"')) +5, 100)
	as studentProgramKey,
	value as cpJSON
	From
	OPENJSON(@NewSaepaJSONstr);


	insert into @OldSaepaJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 	
	JSON_VALUE(value, '$.assessmentAccommodationReference."assessmentIdentifier"') + ':' + 	
	substring(JSON_VALUE(value, '$.assessmentAccommodationReference."academicSubjectDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."academicSubjectDescriptor"')) +5, 100) + ':' +
	substring(JSON_VALUE(value, '$.assessmentAccommodationReference."accommodationDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."accommodationDescriptor"')) +5, 100)
	as studentProgramKey,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentEducationOrganizationAssessmentAccommodations'
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
					on N.studentProgramKey = O.studentProgramKey
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
				ISNULL(N.studentProgramKey, O.studentProgramKey) as studentProgramKey,
				ISNULL(N.cpJSON, O.cpJSON) as cpJSON
			from @OldSaepaJSON O
				FULL OUTER JOIN @NewSaepaJSON N
					on O.studentProgramKey = N.studentProgramKey
		  ) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'StudentEducationOrganizationAssessmentAccommodations';

	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentEducationOrganizationAssessmentAccommodations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentEducationOrganizationAssessmentAccommodations'
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
				on N.studentProgramKey = O.studentProgramKey
			Where N.cpJSON != isnull(O.cpJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
