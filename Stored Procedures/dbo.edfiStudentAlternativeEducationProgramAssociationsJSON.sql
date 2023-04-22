SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 02/07/2022
-- Modified dt: 09/30/2022
-- Description:	edfi Student Alternative Education Program Associations
-- Rev. Notes:	programref edorg id changed
-- =============================================
CREATE     PROCEDURE [dbo].[edfiStudentAlternativeEducationProgramAssociationsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@StudentJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50);
	Declare @EdFiStateOrgID nvarchar(50); 
	
	SELECT 
		@SchoolID = EdFiDOESchoolID, 
		@EdFiStateOrgID = EdFiStateOrgID 
	FROM IntegrationSettings Where ID = 1;

	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	set @StudentJSON = (
		Select 
			@EdFiStateOrgID as [educationOrganizationReference.educationOrganizationId],
			ep.ProgramType as [programReference.type],
			ep.ProgramName as [programReference.name],
			ep.EdOrgID as [programReference.educationOrganizationId],
			sm.StandTestID as [studentReference.studentUniqueId],
			case
				when sp.AltEdEligibilityReason is not null
				then 'http://doe.in.gov/Descriptor/AlternativeEducationEligibilityReasonDescriptor.xml/' + sp.AltEdEligibilityReason
				else ''
			end as [alternativeEducationEligibilityReasonDescriptor],
			isnull(cast(sp.BeginDate as nvarchar(12)), '') as [beginDate],
			isnull(cast(sp.EndDate as nvarchar(12)), '') as [endDate],
			case
				when sp.ExitReason is not null
				then 'http://doe.in.gov/Descriptor/ReasonExitedDescriptor.xml/' + sp.ExitReason
				else ''
			end as [reasonExitedDescriptor],
			(
				select
					'http://doe.in.gov/Descriptor/ProgramMeetingTimeDescriptor.xml/' + value as [programMeetingTimeDescriptor]
				from OPENJSON(
					IIF(sp.ProgMeetingTime IS NULL, NULL, '["') + sp.ProgMeetingTime + IIF(sp.ProgMeetingTime IS NULL, NULL, '"]')
				)
				FOR JSON PATH
			) as [programMeetingTimes]
		From StudentEdFiPrograms sp
			inner join LKG.dbo.EdFiPrograms ep
				on ep.ProgID = sp.ProgID
			inner join Students s
				on s.StudentID = sp.StudentID
			left join StudentMiscFields sm
				on sm.StudentID = s.StudentID
		where sp.StudentID in (select StudentID from @ValidStudentIDs)
			and isnull(sp.AltEdEligibilityReason, '') <> ''
			and sp.BeginDate >= @CalendarStartDate
			and sp.BeginDate <= @CalendarEndDate
			and (sp.EndDate is null or sp.EndDate <= @CalendarEndDate)
			and @SchoolType = 'PublicSchool'
		FOR JSON PATH
	);


END
GO
