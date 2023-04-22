SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ================================================================
-- Author:		Joey/Freddy
-- Create date: 8/31/2021
-- Modified dt: 9/29/2022 
-- Description:	This returns the edfi Staffs JSON 
-- Rev. Notes:  added publicschool sentinel, removed 3rd union
-- ================================================================

CREATE   PROCEDURE [dbo].[edfiStaffEducationOrganizationContactAssociationsJSON]
@StaffEoeaJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);
	Declare @StateOrgID nvarchar(50) = (SELECT EdFiStateOrgID FROM IntegrationSettings Where ID = 1);
	
	Declare @SchoolType nvarchar(50) = (Select SchoolType From Settings Where SettingID = 1);

	set @StaffEoeaJSON = (
		select distinct A.* from (
			select
				@SchoolID as [educationOrganizationReference.educationOrganizationId],
				StatePersonnelNumber as [staffReference.staffUniqueId],
				'Unified Access' as [contactTitle],
				coalesce(Email, Email2, Email3) as [electronicMailAddress]
			from Teachers T
				inner join dbo.fnEdfiValidTeachers() vt
					on T.TeacherID = vt.TeacherID
			union all
			select
				@StateOrgID as [educationOrganizationReference.educationOrganizationId],
				StatePersonnelNumber as [staffReference.staffUniqueId],
				'Unified Access' as [contactTitle],
				coalesce(Email, Email2, Email3) as [electronicMailAddress]
			from Teachers T
				inner join dbo.fnEdfiValidTeachers() vt
					on T.TeacherID = vt.TeacherID
			where @SchoolType = 'PublicSchool' 
				and ISNUMERIC(@StateOrgID) = 1
		) A
		FOR JSON PATH
	);

END
GO
