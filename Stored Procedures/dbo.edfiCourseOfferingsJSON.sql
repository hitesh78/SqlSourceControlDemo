SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 10/26/2021
-- Modified dt: 02/15/2022
-- Description:	This returns the edfi course offerings JSON 
-- Parameters: Calendar Year
-- =============================================
CREATE       PROCEDURE [dbo].[edfiCourseOfferingsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@SEOAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);
		
	set @SEOAJSON = (
		Select 
			1088000000 as [courseReference.educationOrganizationId],
			c.CourseCode as [courseReference.code],
			@SchoolID as [schoolReference.schoolId],
			@SchoolID as [sessionReference.schoolId],
			@SchoolYear as [sessionReference.schoolYear],
			'http://doe.in.gov/Descriptor/TermDescriptor.xml/' + ep.[Sessions] as [sessionReference.termDescriptor],
			c.CourseCode as [localCourseCode],
			(
				Select 'Other curriculum' as [curriculumUsedType]
				FOR JSON PATH
			) as [curriculumUseds]
		From Classes c
			inner join Terms t
				on t.TermID = c.TermID
			inner join EdfiPeriods ep
				on ep.EdfiPeriodID = t.EdfiPeriodID
		Where ISNULL(NULLIF(c.CourseCode, ''), 'N/A') <> 'N/A' -- covers 3 cases: null, blank and 'N/A'
			and c.ClassTypeID <> 5
			and t.StartDate >= @CalendarStartDate 
			and t.EndDate <= @CalendarEndDate
			and t.TermID not in (Select ParentTermID From Terms)
			and t.ExamTerm = 0
		Group by c.CourseCode, ep.[Sessions]
		FOR JSON PATH
	);


END
GO
