SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls/Joey
-- Create date: 05/10/2021
-- Modified dt: 10/14/2022(2) 
-- Description:	edfi Students JSON
-- Rev. Notes:	change limitedEnglishProficiency
-- =============================================
CREATE     PROCEDURE [dbo].[edfiStudentsJSON]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@StudentJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	set @StudentJSON = (
		Select
		sm.BirthCity as birthCity,
		'http://doe.in.gov/Descriptor/CountryDescriptor.xml/' + isnull(nullif(sm.edfiBirthCountryCodeValue, ''), 'USA') as birthCountryDescriptor,
		s.BirthDate as birthDate,
		'' as birthInternationalProvince,	
		case 
			when sm.edfiBirthCountryCodeValue is null then convert(date,sm.USEntryDate)
			else ''
		end as dateEnteredUS, 
		CAST(
		case 
			when sm.FinAid like '%low income%' then 1
			else 0
		end as bit) as economicDisadvantaged,
		s.fname as firstName,
		s.Suffix as generationCodeSuffix,
		isnull(s.isHispanicLatino, 0) as hispanicLatinoEthnicity,
		s.Lname as lastSurname,
		s.sex as sexType,
		sm.StandTestID as studentUniqueId,
		case
			when isnull(sm.ELLInstrument,'') <> ''
			then 'http://doe.in.gov/Descriptor/ELLInstrumentUsedDescriptor.xml/' + sm.ELLInstrument
			else ''
		end as [ellInstrumentUsedDescriptor],
		case
			when isnull(EnglishFluency, '') <> '' and sm.edfiLanguageCodeValue <> '211'
			then 'http://doe.in.gov/Descriptor/LimitedEnglishProficiencyDescriptor.xml/' + sm.EnglishFluency
			when isnull(EnglishFluency, '') <> '' and
				sm.BirthCounty <> 'USA' and
				sm.BirthCounty <> 'US' and
				sm.BirthCounty <> 'United States' and
				sm.BirthCounty <> 'United States of America'
			then 'http://doe.in.gov/Descriptor/LimitedEnglishProficiencyDescriptor.xml/' + sm.EnglishFluency
			else ''
		end as [limitedEnglishProficiencyDescriptor],
		case
			when sm.edfiBirthCountryCodeValue is null then convert(date,sm.USEntryDate)
			else ''
		end as usInitialSchoolEntry,
		(
			SELECT
			'Home' as addressType,
			s.StateAbbr as stateAbbreviationType,
			s.Street as streetNumberName,
			s.City as city,
			s.Zip as postalCode,
			s.CountyName as nameOfCounty
			From 
			Students st
			Where st.StudentID = s.StudentID
			FOR JSON PATH
		) as [addresses],
		(
			SELECT
			'http://doe.in.gov/Descriptor/LanguageDescriptor.xml/' + isnull(nullif(sm.edfiLanguageCodeValue, ''), '211') as languageDescriptor,
			(
				SELECT
				'Home language' as languageUseType
				FOR JSON PATH
			) as uses
			FOR JSON PATH
		) as [languages],
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
					FROM StudentRace sr
					inner join Race r
					on sr.RaceID = r.RaceID
					WHERE sr.StudentID = s.StudentID
				) as _r
			FOR JSON PATH
		) as races,
			(
			select 
			(
				SELECT distinct
					em.electronicMailType,
					em.electronicMailAddress
				FROM (
					select 
						'Organization' as [electronicMailType],
						s.SchoolEmail as [electronicMailAddress]
					from Students st
					Where st.StudentID = s.StudentID 
						and SchoolEmail like '%@%'
					union 
					select 
						'Home/Personal' as [electronicMailType],
						s.Email8 as [electronicMailAddress]
					from Students st
					Where st.StudentID = s.StudentID 
						and Email8 like '%@%'
				) em
				FOR JSON PATH
			) )as [electronicMails],
			(
			SELECT
			'Other' as [telephoneNumberType],
			isnull((
					Select top 1 Phone
					From (
						Select Phone 
						From PhoneNumbers 
						Where StudentID = st.StudentID
						Union
						Select P.Phone 
						From PhoneNumbers P
							inner join StudentContacts SC
							on SC.RolesAndPermissions = '(SIS Parent Contact)' and P.ContactID = SC.ContactID
						Where SC.StudentID = st.StudentID
					) x
			), '0000000000') as [telephoneNumber]
			From Students st
			Where st.StudentID = s.StudentID
			FOR JSON PATH
		) as [telephones]
		From Students s
			left join StudentMiscFields sm
			on s.StudentID = sm.StudentID
		Where s.StudentID in (select StudentID from @ValidStudentIDs)
		FOR JSON PATH
	);

END
GO
