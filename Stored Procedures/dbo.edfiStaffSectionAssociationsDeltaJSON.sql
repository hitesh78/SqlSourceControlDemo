SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--=============================================
-- Author:		Joey
-- Create date: 01/13/2022
-- Modified dt: 09/27/2022 
-- Description:	edfi staffsectionassociations Delta 
-- Rev. Notes:	changed how datasnapshot logic works
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStaffSectionAssociationsDeltaJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@JobID Uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	Declare @NewCoTrJSONstr nvarchar(max);
	Declare @NewCoTrJSON table (code nvarchar(400) PRIMARY KEY, cpJSON nvarchar(2000));
	Declare @OldCoTrJSON table (code nvarchar(400) PRIMARY KEY, cpJSON nvarchar(2000));

	exec edfiStaffSectionAssociationsJSON @SchoolYear, @CalendarStartDate, @CalendarEndDate, @NewCoTrJSONstr output;

	insert into @NewCoTrJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."uniqueSectionCode"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."classroomIdentificationCode"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."classPeriodName"') + ':' + 
	substring(JSON_VALUE(value, '$.sectionReference."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.sectionReference."termDescriptor"')) + 5, 100) as code,
	value as cpJSON
	From
	OPENJSON(@NewCoTrJSONstr);


	insert into @OldCoTrJSON
	Select
	JSON_VALUE(value, '$.staffReference."staffUniqueId"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."uniqueSectionCode"') + ':' + 
	JSON_VALUE(value, '$.sectionReference."classroomIdentificationCode"') + ':' + 
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
			edfiResource = 'StaffSectionAssociations'
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
			select
				ISNULL(N.code, O.code) as code,
				ISNULL(N.cpJSON, O.cpJSON) as cpJSON
			from @OldCoTrJSON O
				FULL OUTER JOIN @NewCoTrJSON N
					on O.code = N.code
		  ) NN
		  FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
	)
	Where JobID = @JobID
		and edfiResource = 'StaffSectionAssociations';

	-- clears out the old snapshots if real JobID is passed
	IF EXISTS(
		Select 0
		FROM EdfiSubmissionStatus 
		Where edfiResource = 'StaffSectionAssociations'
			and CalendarYear = @SchoolYear
			and JobID = @JobID)
	BEGIN
		Update EdfiSubmissionStatus
		Set dataDeleted = null,
			dataSnapshot = null
		Where edfiResource = 'StaffSectionAssociations'
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
