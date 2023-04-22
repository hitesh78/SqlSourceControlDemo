SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--
-- Wisconsin DPI WISEId Export Query...
--
--
-- NOTE: This view is referenced in the [UpdateRaceCodesFromDpiEthnicity] trigger,
--       so test/update that trigger if this view changes...
--
CREATE VIEW [dbo].[vDPI_Export2] AS
-- FIRST, A FEW PREREQUISITES THAT WE'LL HANDLE WITH CTEs...
-- Such as the Crosswalk table from DPI...
WITH 
-- And another CTE to summarize our race patterns using our own 
-- binary encoding for quickly matching to Crosswalk...
StudentRaces(StudentID, BinaryRacesCode)
AS (
	SELECT 
		StudentID,
		-- Use binary to match identical sets of races between our race junction table and DPI Crosswalk table
		-- TODO: Following constants could be removed by leveraging VDPI_Crosswalk_Race_Tabl...
		SUM(case when FederalRaceMapping='Hispanic/Latino' then 1 else 0 end
			+ case when FederalRaceMapping='American Indian / Native Alaskan' then 2 else 0 end
			+ case when FederalRaceMapping='Asian' then 4 else 0 end
			+ case when FederalRaceMapping='Black / African American' then 8 else 0 end
			+ case when FederalRaceMapping='Native Hawaiian / Other Pacific Islander' then 16 else 0 end
			+ case when FederalRaceMapping='White' then 32 else 0 end) as BinaryRacesCode
	FROM Race R
	INNER JOIN StudentRace SR ON R.RaceID = SR.RaceID
	GROUP BY StudentID
),
PreParentNames(StudentID, Parent1LastName, Parent1FirstName, Parent2LastName, Parent2FirstName)
AS (
	SELECT
		StudentID,
			ISNULL(RTRIM(LTRIM(CASE
				WHEN (ISNULL(Father,'') != '') 
					THEN (SUBSTRING(Father, CHARINDEX(' ', Father)+1, LEN(Father)-(CHARINDEX(' ', Father)-1)))
				ELSE ''
			END)),''),
			ISNULL(RTRIM(LTRIM(CASE
				WHEN (ISNULL(Father,'') != '') 
					THEN (LEFT(Father, CHARINDEX(' ', Father)))
				ELSE ''
			END)),''),
			ISNULL(RTRIM(LTRIM(CASE
				WHEN (ISNULL(Mother,'') != '') 
					THEN (SUBSTRING(Mother, CHARINDEX(' ', Mother)+1, LEN(Mother)-(CHARINDEX(' ', Mother)-1)))
				ELSE ''
			END)),''),
			ISNULL(RTRIM(LTRIM(CASE
				WHEN (ISNULL(Mother,'') != '') 
					THEN (LEFT(Mother, CHARINDEX(' ', Mother)))
				ELSE ''
			END)),'')
	FROM Students
),
ParentNames(StudentID, Parent1LastName, Parent1FirstName, Parent2LastName, Parent2FirstName)
AS (
	SELECT
		StudentID,
		case when right(Parent1FirstName,1)=',' 
			then replace(Parent1FirstName+'$',',$','') -- $ clean comma @ end; used over substring for better unicode compatibility
			else Parent1LastName 
			end,
		case when right(Parent1FirstName,1)=',' 
			then Parent1LastName
			else Parent1FirstName end,
		case when right(Parent2FirstName,1)=',' 
			then replace(Parent2FirstName+'$',',$','') -- $ clean comma @ end; used over substring for better unicode compatibility
			else Parent2LastName 
			end,
		case when right(Parent2FirstName,1)=',' 
			then Parent2LastName
			else Parent2FirstName end
	FROM PreParentNames
),
BirthPlace(StudentID,BornOutsideUS,BirthCity,BirthState,BirthCountyOrCountry,BirthZip)
AS (
	SELECT	StudentID, 
			case when isnull(BirthState,'')='' then 
				case when isnull(BirthCounty,'')='' then null else 'Y' end 
			else
			case when BirthState 
				in (
					select code COLLATE DATABASE_DEFAULT 
					from LKG.dbo.SelectOptions
					where SelectListID=22 
						and Code!=Title 
						and Code COLLATE DATABASE_DEFAULT not in ('MX','VI','BC')
				) then 'N' else 'Y' end end as BornOutsideUS,
			BirthCity,
			BirthState,
			BirthCounty as BirthCountyOrCountry,
			BirthZip
	FROM StudentMiscFields
)

-- OLD REV 1:
-- WiseId, LocalPersonID, LastName, FirstName, MiddleName, Suffix, Birthdate, GenderID, RaceKey, OtherNameLastName, OtherNameFirstName, OtherNameMiddleName, OtherNameSuffix, EntityID, LocalPersonIDKeyType, Parent1Type, Parent1LastName, Parent1NameFirstName, Parent1NameMiddleName, Parent1NameSuffix, Parent2Type, Parent2LastName, Parent2NameFirstName, Parent2NameMiddleName, Parent2NameSuffix

	-- NOW THE FINAL QUERY...
	SELECT
		s.StudentID,
		s.AffiliationsHTML Tags_no_export,
    
		s.WISEid as WiseId,
	
		xStudentID as LocalPersonID,
		'N' as NoLocationRelease,
		replace(Lname,'â€™','''') as LastName,
		replace(Fname,'â€™','''') as FirstName,	
		replace(Mname,'â€™','''') as MiddleName,
		case when s.suffix like '%.' 
         then left(s.suffix, len(s.suffix) - 1) 
         else s.suffix 
        end as Suffix,

		s.GradeLevX as Grade_no_export,
	
		CONVERT(nvarchar(12), BirthDate, 101) as Birthdate,	
		substring(Sex,1,1) as GenderID,
	
		Individual_Race_Key as RaceKey,

		null as OtherNameLastName, 
		null as OtherNameFirstName, 
		null as OtherNameMiddleName, 
		null as OtherNameSuffix, 

		isnull(bp.BornOutsideUS,'N') as BornOutsideUS,
		bp.BirthCity,
		case when bp.BornOutsideUS='N' then bp.BirthState else null end as BirthState,
		case when bp.BornOutsideUS='N' then bp.BirthCountyOrCountry else null end as BirthCounty,
		case when bp.BornOutsideUS='Y' then 
			case when isnull(bp.BirthCountyOrCountry,'')!='' then bp.BirthCountyOrCountry 
			else 
				(select title COLLATE DATABASE_DEFAULT
					from LKG.dbo.SelectOptions
					where SelectListID=22 
					and Code COLLATE DATABASE_DEFAULT=bp.BirthState)	
			end 
		else null end as BirthCountry,
		null as EntityID,
	
		'Student' as LocalPersonIDKeyType,
		null as WISEsecureRole,
		null as MultipleBirthIndicator,
		case when SchoolEmail ='' then NULL else SchoolEmail end as EmailAddress,
		case when Parent1LastName='' and Parent1FirstName='' 
			then 'M' else 'F' 
		end as Parent1Type,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then Parent2LastName else Parent1LastName 
		end,'â€™','''') as Parent1LastName,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then Parent2FirstName else Parent1FirstName 
		end,'â€™','''') as Parent1FirstName,

		null as Parent1MiddleName,
		null as Parent1NameSuffix,	

		case when (Parent1LastName='' and Parent1FirstName='') 
				or (Parent2FirstName='' and Parent2LastName='')
			then null else 'M' end as Parent2Type,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then null else Parent2LastName end,'â€™','''') as Parent2LastName,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then null else Parent2FirstName end,'â€™','''') as Parent2FirstName,

		null as Parent2MiddleName,
		null as Parent2NameSuffix,	

		_Status as _Status_no_export,

		case when isnull(s.WISEID,'')='' then 'Active' else 'Inactive' end
			as _WiseStatus_no_export -- include SIS student status for basic active/inactive grid filtering...

	FROM
		StudentRoster s
	INNER JOIN
		ParentNames p
		ON s.StudentID = p.StudentID
	LEFT JOIN 
		StudentRaces sr
		ON s.StudentID = sr.StudentID
	LEFT JOIN
		vDPI_Crosswalk_Race_Table cw
		ON cw.BinaryRacesCode = sr.BinaryRacesCode
	LEFT JOIN
		Birthplace bp
		ON s.StudentID = bp.StudentID
	WHERE
		LName != '' -- and s.active = 1
	-- Instead of filtering this view, we will default the 'Choice' filter in our report/export grid,
	-- in order to allow for greater flexibility in the use of that feature.  For example, users could



/*
Deployment script for 0

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
