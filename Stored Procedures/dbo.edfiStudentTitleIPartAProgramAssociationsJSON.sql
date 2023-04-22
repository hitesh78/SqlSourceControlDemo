SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 02/09/2022
-- Modified dt: 02/15/2022
-- Description:	Takes one parameter @SchoolYear and returns the edfi StudentTitleIPartAProgramAssociations JSON 
-- Parameters: Calendar Year  
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStudentTitleIPartAProgramAssociationsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@StudentJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);
	
	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	set @StudentJSON = (
		Select 
			@SchoolID as [educationOrganizationReference.educationOrganizationId],
			ep.ProgramType as [programReference.type],
			ep.ProgramName as [programReference.name],
			'1088000000' as [programReference.educationOrganizationId],
			sm.StandTestID as [studentReference.studentUniqueId],
			isnull(cast(sp.BeginDate as nvarchar(12)), '') as [beginDate],
			isnull(cast(sp.EndDate as nvarchar(12)), '') as [endDate],
			case
				when sp.ExitReason is not null
				then 'http://doe.in.gov/Descriptor/ReasonExitedDescriptor.xml/' + sp.ExitReason
				else ''
			end as [reasonExitedDescriptor],
			'Eligible' as [titleIPartAParticipantType],
			(
				Select 
					'http://doe.in.gov/Descriptor/ServiceDescriptor.xml/' + value as [serviceDescriptor]
				from OPENJSON(sp.[Services])
				FOR JSON PATH
			) as [services]
		From StudentEdFiPrograms sp
			inner join LKG.dbo.EdFiPrograms ep
				on ep.ProgID = sp.ProgID
			inner join Students s
				on s.StudentID = sp.StudentID
			left join StudentMiscFields sm
				on sm.StudentID = s.StudentID
		where sp.StudentID in (select StudentID from @ValidStudentIDs)
			and isnull(sp.[Services], '') <> ''
			and sp.BeginDate >= @CalendarStartDate
			and sp.BeginDate <= @CalendarEndDate
			and (sp.EndDate is null or sp.EndDate <= @CalendarEndDate)
			and @SchoolType = 'PublicSchool'
		FOR JSON PATH
	);


END
GO
