SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Joey Guziejka
-- Create date: 05/20/2021
-- Modified dt: 10/28/2022
-- Description: adds the edfiSubmissionStatus and returns the edfi integration settings
-- Parameters: School Year, EK
-- =============================================
CREATE                       PROCEDURE [dbo].[edfiStartSubmissionJob]
@SchoolYear int,
@jobId uniqueidentifier,
@EK nvarchar(20),
@edfiResourceToSubmit nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @pendingStatus nvarchar(20) = 'Pending';
	DECLARE @inProcessStatus nvarchar(20) = 'InProcess';
	DECLARE @user nvarchar(50) = 
	isnull((
		Select T.glname
		From 
		Accounts A
			inner join
		Teachers T
			on A.AccountID = T.AccountID
		Where
		A.EncKey = @EK
	), 'user');

	DECLARE @apiVersion nvarchar(20) = (Select isnull(ApiVersion, '1.0') From EdfiODS where SchoolYear = @SchoolYear);

	If @edfiResourceToSubmit = 'all'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Calendars', 1, @inProcessStatus, 'Calendar'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'CalendarDates', 2, @pendingStatus, 'Calendar Dates'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'GradingPeriods', 3, @pendingStatus, 'Grading Periods'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Sessions', 4, @pendingStatus, 'Sessions'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Students', 5, @pendingStatus, 'Students'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentSchoolAssociations', 6, @pendingStatus, 'Student School Associations'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentsSchoolAttendanceEvents', 7, @pendingStatus, 'Attendance Dates'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentsEducationOrgAssociations', 8, @pendingStatus, 'Student Ed Org Associations'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentProgramAssociations', 9, @pendingStatus, 'Student Programs'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Staffs', 10, @pendingStatus, 'Staff Entries'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffEducationOrganizationEmploymentAssociations', 11, @pendingStatus, 'Staff EOEA Entries'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Parents', 12, @pendingStatus, 'Parents'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentParentAssociations', 13, @pendingStatus, 'Student Parent Associations'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffEducationOrganizationAssignmentAssociations', 14, @pendingStatus, 'Staff EOAA Entries'),
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffEducationOrganizationContactAssociations', 15, @pendingStatus, 'Staff EOCA Entries')

		
		If @apiVersion <> '1.0'
		Begin
			INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Locations', 16, @pendingStatus, 'Locations'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'ClassPeriods', 17, @pendingStatus, 'Class Periods'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'CourseOfferings', 18, @pendingStatus, 'Course Offerings'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Sections', 19, @pendingStatus, 'Sections'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentSectionAssociations', 20, @pendingStatus, 'Student Section Associations'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'DisciplineIncidents', 21, @pendingStatus, 'Discipline Incidents'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'DisciplineActions', 22, @pendingStatus, 'Discipline Actions'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentAcademicRecords', 23, @pendingStatus, 'Student Academic Records'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'CourseTranscripts', 24, @pendingStatus, 'Course Transcripts'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffSectionAssociations', 25, @pendingStatus, 'Staff Section Associations'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentAlternativeEducationProgramAssociations', 26, @pendingStatus, 'Student Alt Ed Programs'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentTitleIPartAProgramAssociations', 27, @pendingStatus, 'Student Title I Part A Programs'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentSpecialEducationProgramAssociations', 28, @pendingStatus, 'Student Special Ed Pgm Associations'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentCurricularMaterialProgramAssociations', 29, @pendingStatus, 'Student Curricular Material Pgr Associations'),
			(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentEducationOrganizationAssessmentAccommodations', 30, @pendingStatus, 'Student Assessment Accommodations')

		End
	End
	Else If @edfiResourceToSubmit = 'Calendars'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Calendars', 1, @inProcessStatus, 'Calendar');
	End
	Else If @edfiResourceToSubmit = 'CalendarDates'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'CalendarDates', 2, @inProcessStatus, 'Calendar Dates');
	End
	Else If @edfiResourceToSubmit = 'GradingPeriods'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'GradingPeriods', 3, @inProcessStatus, 'Grading Periods');
	End
	Else If @edfiResourceToSubmit = 'Sessions'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Sessions', 4, @inProcessStatus, 'Sessions');
	End
	Else If @edfiResourceToSubmit = 'Students'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Students', 5, @inProcessStatus, 'Students');
	End
	Else If @edfiResourceToSubmit = 'StudentSchoolAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentSchoolAssociations', 6, @inProcessStatus, 'Student School Associations');
	End
	Else If @edfiResourceToSubmit = 'StudentsSchoolAttendanceEvents'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentsSchoolAttendanceEvents', 7, @inProcessStatus, 'Attendance Dates');
	End
	Else If @edfiResourceToSubmit = 'StudentsEducationOrgAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentsEducationOrgAssociations', 8, @inProcessStatus, 'Student Ed Org Associations')
	End
	Else If @edfiResourceToSubmit = 'StudentProgramAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentProgramAssociations', 9, @inProcessStatus, 'Student Programs')
	End
	Else If @edfiResourceToSubmit = 'Staffs'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Staffs', 10, @inProcessStatus, 'Staff Entries')
	End
	Else If @edfiResourceToSubmit = 'StaffEducationOrganizationEmploymentAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffEducationOrganizationEmploymentAssociations', 11, @inProcessStatus, 'Staff EOEA Entries')
	End
	Else If @edfiResourceToSubmit = 'Parents'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Parents', 12, @inProcessStatus, 'Parents')
	End
	Else If @edfiResourceToSubmit = 'StudentParentAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentParentAssociations', 13, @inProcessStatus, 'Student Parent Associations')
	End
	Else If @edfiResourceToSubmit = 'StaffEducationOrganizationAssignmentAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffEducationOrganizationAssignmentAssociations', 14, @inProcessStatus, 'Staff EOAA Entries')
	End
	Else If @edfiResourceToSubmit = 'StaffEducationOrganizationContactAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffEducationOrganizationContactAssociations', 15, @inProcessStatus, 'Staff EOCA Entries')
	End
	--
	Else If @edfiResourceToSubmit = 'Locations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Locations', 16, @inProcessStatus, 'Locations')
	End
	Else If @edfiResourceToSubmit = 'ClassPeriods'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'ClassPeriods', 17, @inProcessStatus, 'Class Periods')
	End
	Else If @edfiResourceToSubmit = 'CourseOfferings'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'CourseOfferings', 18, @inProcessStatus, 'Course Offerings')
	End
	Else If @edfiResourceToSubmit = 'Sections'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'Sections', 19, @inProcessStatus, 'Sections')
	End
	Else If @edfiResourceToSubmit = 'StudentSectionAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentSectionAssociations', 20, @inProcessStatus, 'Student Section Associations')
	End
	Else If @edfiResourceToSubmit = 'DisciplineIncidents'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'DisciplineIncidents', 21, @inProcessStatus, 'Discipline Incidents')
	End
	Else If @edfiResourceToSubmit = 'DisciplineActions'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'DisciplineActions', 22, @inProcessStatus, 'Discipline Actions')
	End
	Else If @edfiResourceToSubmit = 'StudentAcademicRecords'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentAcademicRecords', 23, @inProcessStatus, 'Student Academic Records')
	End
	Else If @edfiResourceToSubmit = 'CourseTranscripts'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'CourseTranscripts', 24, @inProcessStatus, 'Course Transcripts')
	End
	Else If @edfiResourceToSubmit = 'StaffSectionAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StaffSectionAssociations', 25, @inProcessStatus, 'Staff Section Associations')
	End
	Else If @edfiResourceToSubmit = 'StudentAlternativeEducationProgramAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentAlternativeEducationProgramAssociations', 26, @inProcessStatus, 'Student Alt Ed Programs')
	End
	Else If @edfiResourceToSubmit = 'StudentTitleIPartAProgramAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentTitleIPartAProgramAssociations', 27, @inProcessStatus, 'Student Title I Part A Programs')
	End
	Else If @edfiResourceToSubmit = 'StudentSpecialEducationProgramAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentSpecialEducationProgramAssociations', 28, @inProcessStatus, 'Student Special Ed Pgm Associations')
	End
	Else If @edfiResourceToSubmit = 'StudentCurricularMaterialProgramAssociations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentCurricularMaterialProgramAssociations', 29, @inProcessStatus, 'Student Curricular Material Pgr Associations')	
	End
	Else If @edfiResourceToSubmit = 'StudentEducationOrganizationAssessmentAccommodations'
	Begin
		INSERT INTO EdfiSubmissionStatus (JobID, PostStartDateUTC, PostUser, CalendarYear, edfiResource, edfiResourceOrder, PostStatus, ResourceTitle) values
		(@jobId, GETUTCDATE(), @user, @SchoolYear, 'StudentEducationOrganizationAssessmentAccommodations', 30, @inProcessStatus, 'Student Assessment Accommodations')	
	End;
	--
	SELECT
		EdFiSecret, 
		EdFiKey, 
		EdFiDOESchoolID, 
		EdFiStateOrgID
	FROM IntegrationSettings 
	WHERE ID = 1;

END
GO
