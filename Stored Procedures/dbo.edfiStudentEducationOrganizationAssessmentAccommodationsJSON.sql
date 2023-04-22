SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Freddy
-- Create date: 10/19/2022
-- Modified dt: 10/19/2022
-- Description:	edfi student Education Organization Assessment Accommodations   
-- Rev. Notes:	
-- =============================================
CREATE        PROCEDURE [dbo].[edfiStudentEducationOrganizationAssessmentAccommodationsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SPAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);
		
	set @SPAJSON = (
		select
			 sm.StandTestID as [studentReference.studentUniqueId]
			,@SchoolID as [educationOrganizationReference.educationOrganizationId]
			,t.AssessmentIdentifier as [assessmentAccommodationReference.assessmentIdentifier]
			,'http://doe.in.gov/Descriptor/AcademicSubjectDescriptor.xml/' + t.AcademicSubjectDescriptor as [assessmentAccommodationReference.academicSubjectDescriptor]
			,'http://doe.in.gov/Descriptor/AccommodationDescriptor.xml/' + t.AccommodationDescriptor as [assessmentAccommodationReference.accommodationDescriptor]
		from Students s
			inner join StudentMiscFields sm
				on sm.StudentID = s.StudentID
			inner join Tests t
				on t.StudentID = s.StudentID	
		Where s.StudentID in (select StudentID from @ValidStudentIDs)
		and s.Active = 1 and t.AccommodationDescriptor is not null 
		and t.AssessmentIdentifier is not null 
		and t.AcademicSubjectDescriptor is not null
		FOR JSON PATH
	);

END
GO
