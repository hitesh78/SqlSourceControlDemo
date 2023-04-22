SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Joey
-- Create date: 7/14/2021
-- Modified dt: 8/30/2021
-- Description:	This returns the edfi Staffs JSON 
-- Parameters: output
-- =============================================
CREATE   PROCEDURE [dbo].[edfiStaffsJSON]
@StaffsJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @empStatuses table(CodeValue nvarchar(30));
	insert into @empStatuses
	select CodeValue from Lkg.dbo.edfiDescriptorsAndTypes where [Name] = 'EmploymentStatusDescriptor'
	
	set @StaffsJSON = (
		select
			Fname as [firstName],
			Lname as [lastSurname],
			isnull(HispanicEthnicity,0) as [hispanicLatinoEthnicity],
			StatePersonnelNumber as [staffUniqueId],
			Gender as [sexType],
			BirthDate as [birthDate],
			(
				SELECT DISTINCT
				CASE
					WHEN _r.race like '%hispanic%' or _r.race like '%latino%'
					THEN 'Hispanic Ethnicity and of any race'
					WHEN _r.race = 'Two or more races'
					THEN 'Multiracial (two or more races)'
					WHEN _r.race like '%american indian%' or _r.race like '%native american%' or _r.race like '%alaska%'
					THEN 'American Indian - Alaskan Native'
					WHEN _r.race IN ('asian', 'filipino', 'chinese', 'japanese', 'korean', 'thai')
					THEN 'Asian'
					WHEN _r.race like '%black%' or _r.race like '%african%'
					THEN 'Black - African American'
					WHEN _r.race like '%hawaiian%' or _r.race like '%pacific island%'
					THEN 'Native Hawaiian - Pacific Islander'
					WHEN _r.race like '%Middle East%'
					THEN 'White'
					WHEN _r.race IN ('white','caucasian')
					THEN 'White'
					ELSE 'Multiracial (two or more races)'
				END as [raceType]
				from (
					select 
						isnull(r.FederalRaceMapping, r.[Name]) as race
					FROM TeacherRace tr
					inner join Race r
					on tr.RaceID = r.RaceID
					WHERE tr.TeacherID = T.TeacherID
				) as _r
			FOR JSON PATH
			) as [races],
		(
			Select Coalesce(T.Email, T.Email2, T.Email3) as [electronicMailAddress],
			'Organization' as [electronicMailType]
			FOR JSON PATH
		) as [electronicMails]
		from 
		Teachers T
			inner join
		dbo.fnEdfiValidTeachers() vt
			on T.TeacherID = vt.TeacherID
		FOR JSON PATH
	);


END
GO
