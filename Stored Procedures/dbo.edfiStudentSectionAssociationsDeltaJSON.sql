SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 11/16/2021
-- Modified dt: 09/27/2022 
-- Description:	student section asc
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE         PROCEDURE [dbo].[edfiStudentSectionAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewCourseJSONstr nvarchar(max);
	Declare @NewCourseJSON table (code nvarchar(100) PRIMARY KEY, cpJSON nvarchar(1000));
	Declare @OldCourseJSON table (code nvarchar(100) PRIMARY KEY, cpJSON nvarchar(1000));

	exec edfiStudentSectionAssociationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewCourseJSONstr output;

	insert into @NewCourseJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."uniqueSectionCode"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."classPeriodName"') + ':' + 
	substring(JSON_VALUE(value, '$.sectionReference."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.sectionReference."termDescriptor"')) + 5, 100) as code,
	value as cpJSON
	From
	OPENJSON(@NewCourseJSONstr);


	insert into @OldCourseJSON
	Select
	JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."uniqueSectionCode"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."classPeriodName"') + ':' + 
	substring(JSON_VALUE(value, '$.sectionReference."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.sectionReference."termDescriptor"')) + 5, 100) as code,
	value as cpJSON
	From
	OPENJSON(
		(
			Select top 1 dataSnapshot 
			From EdfiSubmissionStatus 
			Where
			CalendarYear = @SchoolYear
			and
			edfiResource = 'StudentSectionAssociations'
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
			From @OldCourseJSON O
				left join @NewCourseJSON N
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
			from @OldCourseJSON O
				FULL OUTER JOIN @NewCourseJSON N
					on O.code = N.code 
		  ) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'StudentSectionAssociations';
	
	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StudentSectionAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StudentSectionAssociations'
			and CalendarYear = @SchoolYear
			and JobID <> @JobID
	END;

	Select
	(
		SELECT '[' + Stuff(
		  (
			SELECT N',' + N.cpJSON 
			From @NewCourseJSON N
				left join @OldCourseJSON O
				on N.code = O.code
			Where N.cpJSON != isnull(O.cpJSON,'')
  
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	) as dataToAddUpdate;

END
GO
