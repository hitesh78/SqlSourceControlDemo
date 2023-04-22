SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Freddy
-- Create date: 08/10/2022
-- Modified dt: 10/6/2022
-- Description:	This returns the edfi StudentCurricularMaterialProgramAssociationsJSON 
-- Parameters: Calendar Year
-- Modifications: Filter out null contact IDs
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStudentCurricularMaterialProgramAssociationsJSON]
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
		,@SchoolID + '_' + convert(nvarchar(20), sc.ContactID) as [livesWithParentReference.parentUniqueId]
		,~sc.livesWith as [studentDoesNotLiveWithParent] -- "~" reverses the bit value
	from StudentEdFiPrograms sep
		inner join Students s
			on s.StudentID = sep.StudentID
		left join StudentMiscFields sm
			on sm.StudentID = s.StudentID
		left join LKG.dbo.EdFiPrograms ep
			on ep.ProgID = sep.ProgID
		left join (
			select 
				c.StudentID,
				c.ContactID,
				c.livesWith
			from (
				select 
					sca.StudentID,
					sca.ContactID,
					sca.livesWith,
					ROW_NUMBER() OVER(PARTITION BY sca.StudentID ORDER BY sca.livesWith DESC) as rn
				from (
					select 
						ssc.StudentID,
						ssc.ContactID,
						case
							when ssc.Relationship = 'Father'
							then ss.StudentLivesWithFather
							when ssc.Relationship = 'Mother'
							then ss.StudentLivesWithMother
							else CAST(0 as bit)
						end as livesWith
					from StudentContacts ssc
						inner join Students ss
							on ss.StudentID = ssc.StudentID
					where 	
						ssc.Relationship in ('Father', 'Mother')		 
						and ssc.RolesAndPermissions = '(SIS Parent Contact)'
				) sca
			) c
			where c.rn = 1
			) sc
		on s.StudentID = sc.StudentID
	Where sep.StudentID in (select StudentID from @ValidStudentIDs)
	and ep.ProgramType = 'Curricular Material Reimbursement'  --and sc.ContactID is not null
	FOR JSON PATH
	);

END
GO
