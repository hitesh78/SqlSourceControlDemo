SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ========================================================================
-- Author:		Joey/Freddy
-- Create date: 7/30/2021
-- Modified dt: 9/29/2022
-- Description:	This returns the edfi Staffs JSON use [32]
-- Parameters: EdOrgID for School and State, refactored 
-- ========================================================================
CREATE   PROCEDURE [dbo].[edfiStaffEducationOrganizationEmploymentAssociationsJSON]
@StaffEoeaJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @EdFiStateOrgID nvarchar(50);
	Declare @SchoolID nvarchar(50);
	Declare @SchoolType nvarchar(50) = (select SchoolType from Settings Where SettingID = 1);
	
	SELECT 
		@EdFiStateOrgID = EdFiStateOrgID,
		@SchoolID = EdFiDOESchoolID
	FROM IntegrationSettings 
	Where ID = 1;

	Declare @empStatuses table(CodeValue nvarchar(30));
	insert into @empStatuses
	select CodeValue from Lkg.dbo.edfiDescriptorsAndTypes where [Name] = 'EmploymentStatusDescriptor';

	set @StaffEoeaJSON = (
		select A.* from (
			select
				@SchoolID as [educationOrganizationReference.educationOrganizationId],
				StatePersonnelNumber as [staffReference.staffUniqueId],
				'http://doe.in.gov/Descriptor/EmploymentStatusDescriptor.xml/' + EmploymentType as [employmentStatusDescriptor],
				HireDate as [hireDate],
				ReleaseDate as [endDate],
				Round(DATEDIFF(day, cast(T.StartDateAtJob as date), Getdate())/365,0) as [yearsOfPriorProfessionalExperience]
			from Teachers T
				inner join dbo.fnEdfiValidTeachers() vt
					on T.TeacherID = vt.TeacherID
			where EmploymentType IN (select CodeValue from @empStatuses)
			union all
			select
				@EdFiStateOrgID as [educationOrganizationReference.educationOrganizationId],
				StatePersonnelNumber as [staffReference.staffUniqueId],
				'http://doe.in.gov/Descriptor/EmploymentStatusDescriptor.xml/' + EmploymentType as [employmentStatusDescriptor],
				HireDate as [hireDate],
				ReleaseDate as [endDate],
				Round(DATEDIFF(day, cast(T.StartDateAtJob as date), Getdate())/365,0) as [yearsOfPriorProfessionalExperience]
			from Teachers T
				inner join dbo.fnEdfiValidTeachers() vt
					on T.TeacherID = vt.TeacherID
			where EmploymentType IN (select CodeValue from @empStatuses) 
				and @SchoolType = 'PublicSchool'
		) A
		FOR JSON PATH
	);


END
GO
