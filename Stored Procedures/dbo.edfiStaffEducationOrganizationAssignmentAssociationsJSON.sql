SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey/Freddy
-- Create date: 8/31/2021 
-- Modified dt: 9/28/2022
-- Description:	This returns the edfi Staffs JSON select * from Teachers 
-- Rev. Notes:	Updated staffClassificationDescriptor logic with muti-select option 
-- =============================================

CREATE     PROCEDURE [dbo].[edfiStaffEducationOrganizationAssignmentAssociationsJSON]
@StaffEoeaJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	declare @staffCodes table(CodeValue nvarchar(500));
	insert into @staffCodes
	select CodeValue from LKG.dbo.edfiDescriptorsAndTypes where [Name] = 'StaffClassificationDescriptor';

	Declare @EdFiStateOrgID nvarchar(20) = (SELECT EdFiStateOrgID FROM IntegrationSettings Where ID = 1) ;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);
	Declare @SchoolType nvarchar(50) = (select SchoolType from Settings Where SettingID = 1)
	set @StaffEoeaJSON = (
		Select distinct
			CASE
				WHEN @SchoolType = 'PublicSchool' and (
					a.TheString = 'Superintendent' or
					a.TheString = 'Assistant Superintendent' or
					a.TheString = 'LEA Administrator' or
					a.TheString = 'Chief Technology Officer' or
					a.TheString = 'Special Education Director' or
					a.TheString = 'Corporation Test Coordinator' or
					a.TheString = 'School Administrator') 
				THEN @EdFiStateOrgID
				ELSE @SchoolID 
			END as [educationOrganizationReference.educationOrganizationId],
			StatePersonnelNumber as [staffReference.staffUniqueId],
			CASE
				WHEN @SchoolType = 'PublicSchool' and (
					a.TheString = 'Superintendent' or
					a.TheString = 'Assistant Superintendent' or
					a.TheString = 'LEA Administrator' or
					a.TheString = 'Chief Technology Officer' or
					a.TheString = 'Special Education Director' or
					a.TheString = 'Corporation Test Coordinator' or
					a.TheString = 'School Administrator') 
				THEN @EdFiStateOrgID
				ELSE @SchoolID 
			END as [employmentStaffEducationOrganizationEmploymentAssociationReference.educationOrganizationId],
			StatePersonnelNumber as [employmentStaffEducationOrganizationEmploymentAssociationReference.staffUniqueId],
			'http://doe.in.gov/Descriptor/EmploymentStatusDescriptor.xml/' + 
				EmploymentType as [employmentStaffEducationOrganizationEmploymentAssociationReference.employmentStatusDescriptor],
			HireDate as [employmentStaffEducationOrganizationEmploymentAssociationReference.hireDate],
			HireDate as [beginDate],
			ReleaseDate as [endDate],
			1 as [orderOfAssignment],
			JobTitle as [positionTitle],
			'http://doe.in.gov/Descriptor/StaffClassificationDescriptor.xml/' + 
				CASE 
					WHEN isnull(a.TheString, '') IN (select CodeValue from @staffCodes)
					THEN a.TheString
					WHEN StaffType = 1
					THEN 'Teacher'
					WHEN StaffType = 2
					THEN 'School Administrator'
					WHEN StaffType = 3
					THEN 'Principal'
					ELSE 'Other' 
				END as [staffClassificationDescriptor]
		from dbo.fnEdfiValidTeachers() v 
			OUTER APPLY dbo.SplitCSVStrings(
				(
				Select EdFiRole 
				from Teachers t
				where t.TeacherID = v.TeacherID
				)
			) a
			inner join Teachers Te
				on Te.TeacherID = v.TeacherID
		FOR JSON PATH
	);

END
GO
