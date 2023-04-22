SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Joey
-- Create date: 08/06/2021
-- Modified dt: 08/02/2022
-- Description:	This returns the edfi StudentProgramAssociations JSON 
-- Parameters: Calendar Year
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStudentProgramAssociationsJSON]
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
			@SchoolID as [educationOrganizationReference.educationOrganizationId]
			,1088000000 as [programReference.educationOrganizationId]
			,ep.ProgramType as [programReference.type]
			,ep.ProgramName as [programReference.name]
			,sm.StandTestID as [studentReference.studentUniqueId]
			,sep.BeginDate as [beginDate]
			,sep.EndDate as [endDate]
			,case
				when isnull(sep.ExitReason,'') = ''
				then NULL
				else 'http://doe.in.gov/Descriptor/ReasonExitedDescriptor.xml/' + sep.ExitReason
			end as [reasonExitedDescriptor]
		from StudentEdFiPrograms sep
			inner join Students s
				on s.StudentID = sep.StudentID
			left join StudentMiscFields sm
				on sm.StudentID = s.StudentID
			left join LKG.dbo.EdFiPrograms ep
				on ep.ProgID = sep.ProgID		
		Where sep.StudentID in (select StudentID from @ValidStudentIDs)
			and isnull(sep.[Services], '') = '' 
			and ISNULL(sep.AltEdEligibilityReason, '') = ''
			and ep.ProgramType not in ('Alternative Education', 'Title I Part A', 'Special Education', 'Curricular Material Reimbursement')
		FOR JSON PATH
	);

END
GO
