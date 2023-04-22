SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- =============================================
-- Author:		Don Puls
-- Create date: 05/20/2021
-- Modified dt: 08/10/2022
-- Description: updates the edfiSubmissionStatus dataSnapshot Column to remove records that had errors on the post 
-- =============================================
CREATE      PROCEDURE [dbo].[edfiUpdateSnapshotDataOnError]
@PostID int,
@edfiResource nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	--***********************************************************************************************
	If @edfiResource = 'CalendarDates'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."date"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."date"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else if @edfiResource = 'Students'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."studentUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."studentUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else if @edfiResource = 'StudentSchoolAssociations'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else if @edfiResource = 'StudentsSchoolAttendanceEvents'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + JSON_VALUE(value, '$."eventDate"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + JSON_VALUE(value, '$.post."eventDate"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else if @edfiResource = 'StudentsEducationOrgAssociations'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StudentProgramAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.programReference."name"') + ':' + JSON_VALUE(value, '$."beginDate"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.post.programReference."name"') + ':' + JSON_VALUE(value, '$.post."beginDate"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else if @edfiResource = 'Staffs'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."staffUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."staffUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StaffEducationOrganizationEmploymentAssociations'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.staffReference."staffUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.staffReference."staffUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'Parents'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."parentUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."parentUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StudentParentAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.parentReference."parentUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.parentReference."parentUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StaffEducationOrganizationAssignmentAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.staffReference."staffUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.staffReference."staffUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StaffEducationOrganizationContactAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.staffReference."staffUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.staffReference."staffUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'Locations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."classroomIdentificationCode"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."classroomIdentificationCode"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'ClassPeriods'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."name"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."name"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'CourseOfferings'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."localCourseCode"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."localCourseCode"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'Sections'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."uniqueSectionCode"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."uniqueSectionCode"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StudentSectionAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.sectionReference."uniqueSectionCode"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + JSON_VALUE(value, '$.post.sectionReference."uniqueSectionCode"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'DisciplineIncidents'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."incidentIdentifier"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."incidentIdentifier"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'DisciplineActions'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."identifier"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."identifier"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StudentAcademicRecords'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
			substring(JSON_VALUE(value, '$."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."termDescriptor"')) + 5, 100) not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + 
				substring(JSON_VALUE(value, '$.post."termDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.post."termDescriptor"')) + 5, 100)
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'CourseTranscripts'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$."alternativeCourseCode"') not in
			(
				Select 
				JSON_VALUE(value, '$.post."alternativeCourseCode"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StaffSectionAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.staffReference."staffUniqueId"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.staffReference."staffUniqueId"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StudentAlternativeEducationProgramAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
			JSON_VALUE(value, '$.programReference."name"') + ':' + 
			JSON_VALUE(value, '$."beginDate"') + ':' + 
			substring(JSON_VALUE(value, '$."alternativeEducationEligibilityReasonDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$."alternativeEducationEligibilityReasonDescriptor"')) + 5, 100) not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + 
				JSON_VALUE(value, '$.post.programReference."name"') + ':' + 
				JSON_VALUE(value, '$.post."beginDate"') + ':' + 
				substring(JSON_VALUE(value, '$.post."alternativeEducationEligibilityReasonDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.post."alternativeEducationEligibilityReasonDescriptor"')) + 5, 100)
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
	Else If @edfiResource = 'StudentTitleIPartAProgramAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
			JSON_VALUE(value, '$.programReference."name"') + ':' + 
			JSON_VALUE(value, '$."beginDate"') + ':' + 
			substring(JSON_VALUE(value, '$.services[0]."serviceDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.services[0]."serviceDescriptor"')) + 5, 100) not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + 
				JSON_VALUE(value, '$.post.programReference."name"') + ':' + 
				JSON_VALUE(value, '$.post."beginDate"') + ':' + 
				substring(JSON_VALUE(value, '$.post.services[0]."serviceDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.services[0]."serviceDescriptor"')) + 5, 100)
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
		Else if @edfiResource = 'StudentSpecialEducationProgramAssociations'
	Begin
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
			JSON_VALUE(value, '$.programReference."name"') + ':' + 
			JSON_VALUE(value, '$."beginDate"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + 
				JSON_VALUE(value, '$.post.programReference."name"') + ':' + 
				JSON_VALUE(value, '$.post."beginDate"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End
	--***********************************************************************************************
		Else if @edfiResource = 'StudentCurricularMaterialProgramAssociations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 
			JSON_VALUE(value, '$.programReference."name"') + ':' + 
			JSON_VALUE(value, '$.livesWithParentReference."parentUniqueId"') + ':' + 
			JSON_VALUE(value, '$."beginDate"') not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + 
				JSON_VALUE(value, '$.post.programReference."name"') + ':' + 
				JSON_VALUE(value, '$.post.livesWithParentReference."parentUniqueId"') + ':' + 
				JSON_VALUE(value, '$.post."beginDate"')
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End;
	--***********************************************************************************************
		Else if @edfiResource = 'StudentEducationOrganizationAssessmentAccommodations'
	Begin 
		Update EdfiSubmissionStatus
		Set dataSnapshot = 
		(
			SELECT '[' + Stuff(
			(
			Select N',' + value
			From
			OPENJSON(
				(
			select dataSnapshot from EdfiSubmissionStatus where PostID = @PostID
				)
			)
			Where
			JSON_VALUE(value, '$.studentReference."studentUniqueId"') + ':' + 	
			JSON_VALUE(value, '$.assessmentAccommodationReference."assessmentIdentifier"') + ':' + 	
			substring(JSON_VALUE(value, '$.assessmentAccommodationReference."academicSubjectDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."academicSubjectDescriptor"')) +5, 100) + ':' +
			substring(JSON_VALUE(value, '$.assessmentAccommodationReference."accommodationDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."accommodationDescriptor"')) +5, 100) not in
			(
				Select 
				JSON_VALUE(value, '$.post.studentReference."studentUniqueId"') + ':' + 	
				JSON_VALUE(value, '$.post.assessmentAccommodationReference."assessmentIdentifier"') + ':' + 	
				substring(JSON_VALUE(value, '$.post.assessmentAccommodationReference."academicSubjectDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."academicSubjectDescriptor"')) +5, 100) + ':' +
				substring(JSON_VALUE(value, '$.post.assessmentAccommodationReference."accommodationDescriptor"'), PATINDEX('%.xml%', JSON_VALUE(value, '$.assessmentAccommodationReference."accommodationDescriptor"')) +5, 100)
				From
				OPENJSON(
					(
				select PostResults from EdfiSubmissionStatus where PostID = @PostID
					)
				)
				Where 
				JSON_VALUE(value, '$."success"') = 'false'
			)
  
			FOR XML PATH(''),TYPE)
			.value('text()[1]','nvarchar(max)'),1,1,N'') + ']'
		)
		Where
		PostID = @PostID
	End;

END

GO
