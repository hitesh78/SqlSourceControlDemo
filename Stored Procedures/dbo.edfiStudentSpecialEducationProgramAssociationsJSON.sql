SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Freddy/Joey
-- Create date: 08/05/2022
-- Modified dt: 12/07/2022
-- Description:	This returns the edfi StudentSpecialEducationProgramAssociations JSON 
-- Rev. Notes:	remove beginDate filter , reversed the ideal Eligibility logic
-- =============================================
CREATE     PROCEDURE [dbo].[edfiStudentSpecialEducationProgramAssociationsJSON]
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
			,case
				when isnull(sep.SpEdSetting,'') = ''
				then NULL
				else 'http://doe.in.gov/Descriptor/SpecialEducationSettingDescriptor.xml/' + sep.SpEdSetting
			end as [specialEducationSettingDescriptor]
			,case
				when isnull(sm.IEPCodes,'') = ''
				then cast(0 as bit)
				else cast(1 as bit)
			 end as [ideaEligibility]
			,case
				when isnull(sep.CircumstancesRelevantToTimeline,'') = ''
				then NULL
				else 'http://doe.in.gov/Descriptor/CircumstancesRelevantToTimelineDescriptor.xml/' + sep.CircumstancesRelevantToTimeline
			end as [circumstancesRelevantToTimelineDescriptor]
			,case
				when isnull(sep.TimelineCompliance,'') = ''
				then NULL
				else 'http://doe.in.gov/Descriptor/TimelineComplianceDescriptor.xml/' + sep.TimelineCompliance
			end as [timelineComplianceDescriptor]			
			,(select iep.[Date] from IEP_Report iep
				inner join 
				(
				Select PKID
					From (
						select 
							d.table_pk_id as PKID
							,t.c.value('local-name(.)', 'nvarchar(100)') as tag
							,t.c.value('(.)[1]', 'nvarchar(100)') as val
						From (
						select 
							table_pk_id,
							xml_fields
						from xml_records 
						where table_name = 'IEP_Report'
					) d
					outer apply d.xml_fields.nodes('/*') t(c)
				) as sourceTable
					Where sourceTable.tag = 'Area' and sourceTable.val ='7. Special Education-IEP Review Date'
			) xmld on iep.IEP_Report_ID = xmld.PKID
			Where iep.StudentID = s.StudentID) as [iEPReviewDate]
			,(select iep.[Date] from IEP_Report iep
				inner join 
				(
				Select PKID
					From (
						select 
							d.table_pk_id as PKID
							,t.c.value('local-name(.)', 'nvarchar(100)') as tag
							,t.c.value('(.)[1]', 'nvarchar(100)') as val
						From (
						select 
							table_pk_id,
							xml_fields
						from xml_records 
						where table_name = 'IEP_Report'
					) d
					outer apply d.xml_fields.nodes('/*') t(c)
				) as sourceTable
					Where sourceTable.tag = 'Area' and sourceTable.val ='8. Special Education-LastEvaluationDate'
			) xmld on iep.IEP_Report_ID = xmld.PKID
			Where iep.StudentID = s.StudentID) as [lastEvaluationDate]
			,(select iep.[Date] from IEP_Report iep
				inner join 
				(
				Select PKID
					From (
						select 
							d.table_pk_id as PKID
							,t.c.value('local-name(.)', 'nvarchar(100)') as tag
							,t.c.value('(.)[1]', 'nvarchar(100)') as val
						From (
						select 
							table_pk_id,
							xml_fields
						from xml_records 
						where table_name = 'IEP_Report'
					) d
					outer apply d.xml_fields.nodes('/*') t(c)
				) as sourceTable
					Where sourceTable.tag = 'Area' and sourceTable.val ='9. Special Education-ParentalConsentDate'
			) xmld on iep.IEP_Report_ID = xmld.PKID
			Where iep.StudentID = s.StudentID) as [parentalConsentDate]			
			,(select iep.[Date] from IEP_Report iep
				inner join 
				(
				Select PKID
					From (
						select 
							d.table_pk_id as PKID
							,t.c.value('local-name(.)', 'nvarchar(100)') as tag
							,t.c.value('(.)[1]', 'nvarchar(100)') as val
						From (
						select 
							table_pk_id,
							xml_fields
						from xml_records 
						where table_name = 'IEP_Report'
					) d
					outer apply d.xml_fields.nodes('/*') t(c)
				) as sourceTable
					Where sourceTable.tag = 'Area' and sourceTable.val ='10. Special Education-FirstStepsTransitionDate'
			) xmld on iep.IEP_Report_ID = xmld.PKID
			Where iep.StudentID = s.StudentID) as [firstStepsTransitionDate]
			,(SELECT (
				select 
					'http://doe.in.gov/Descriptor/DisabilityDescriptor.xml/' + 	substring(replace(a.TheString,' ',''),0,3) as [disabilityDescriptor]
					,ROW_NUMBER() OVER (ORDER BY (Select 0)) as [orderOfDisability]
					from dbo.SplitCSVStringsDelimiter(
					(
						select sm.IEPCodes 
						from StudentMiscFields sm
						Where sm.StudentID = s.StudentID
					),';'
					) a
					FOR JSON PATH
				) 
				)as [disabilities]					
		from StudentEdFiPrograms sep
			inner join Students s
				on s.StudentID = sep.StudentID
			left join StudentMiscFields sm
				on sm.StudentID = s.StudentID
			left join LKG.dbo.EdFiPrograms ep
				on ep.ProgID = sep.ProgID		
		Where sep.StudentID in (select StudentID from @ValidStudentIDs)
		and ep.ProgramType = 'Special Education'
		and s.Active = 1
		--and sep.BeginDate > = @CalendarStartDate
		FOR JSON PATH
	);

END
GO
