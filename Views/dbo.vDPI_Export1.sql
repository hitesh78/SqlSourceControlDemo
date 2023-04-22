SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--
-- Wisconsin DPI WISEId Export Query
--
CREATE VIEW [dbo].[vDPI_Export1] AS
-- FIRST, A FEW PREREQUISITES THAT WE'LL HANDLE WITH CTEs...
-- Such as the Crosswalk table from DPI...
WITH Crosswalk (Individual_Race_Key, BinaryRacesCode) AS (
	SELECT 
		-- Don't mix null and 0 since report grids handle null nicely...
		CASE 
			WHEN Individual_Race_Key=0
			THEN Null ELSE Individual_Race_Key 
		END AS Individual_Race_Key,
		-- Use binary to match identical sets of races between our race junction table and DPI Crosswalk table
		Hispanic 
			+ Indian_Alaskan*2 
			+ Asian*4 
			+ Black*8 
			+ Pacific*16 
			+ White*32 AS BinaryRacesCode
	FROM (values
		('0001',1,1,0,0,0,0,'H'),
		('0002',1,0,1,0,0,0,'H'),
		('0003',1,0,0,1,0,0,'H'),
		('0004',1,0,0,0,1,0,'H'),
		('0005',1,0,0,0,0,1,'H'),
		('0006',1,1,1,0,0,0,'H'),
		('0007',1,1,0,1,0,0,'H'),
		('0008',1,1,0,0,1,0,'H'),
		('0009',1,1,0,0,0,1,'H'),
		('0010',1,0,1,1,0,0,'H'),
		('0011',1,0,1,0,1,0,'H'),
		('0012',1,0,1,0,0,1,'H'),
		('0013',1,0,0,1,1,0,'H'),
		('0014',1,0,0,1,0,1,'H'),
		('0015',1,0,0,0,1,1,'H'),
		('0016',1,1,1,1,0,0,'H'),
		('0017',1,1,1,0,1,0,'H'),
		('0018',1,1,1,0,0,1,'H'),
		('0019',1,1,0,1,1,0,'H'),
		('0020',1,1,0,1,0,1,'H'),
		('0021',1,1,0,0,1,1,'H'),
		('0022',1,0,1,1,1,0,'H'),
		('0023',1,0,1,1,0,1,'H'),
		('0024',1,0,1,0,1,1,'H'),
		('0025',1,0,0,1,1,1,'H'),
		('0026',1,1,1,1,1,0,'H'),
		('0027',1,1,1,1,0,1,'H'),
		('0028',1,1,1,0,1,1,'H'),
		('0029',1,1,0,1,1,1,'H'),
		('0030',1,0,1,1,1,1,'H'),
		('0031',1,1,1,1,1,1,'H'),
		('0033',0,1,0,0,0,0,'I'),
		('0034',0,0,1,0,0,0,'A'),
		('0035',0,0,0,1,0,0,'B'),
		('0036',0,0,0,0,1,0,'P'),
		('0037',0,0,0,0,0,1,'W'),
		('0038',0,1,1,0,0,0,'T'),
		('0039',0,1,0,1,0,0,'T'),
		('0040',0,1,0,0,1,0,'T'),
		('0041',0,1,0,0,0,1,'T'),
		('0042',0,0,1,1,0,0,'T'),
		('0043',0,0,1,0,1,0,'T'),
		('0044',0,0,1,0,0,1,'T'),
		('0045',0,0,0,1,1,0,'T'),
		('0046',0,0,0,1,0,1,'T'),
		('0047',0,0,0,0,1,1,'T'),
		('0048',0,1,1,1,0,0,'T'),
		('0049',0,1,1,0,1,0,'T'),
		('0050',0,1,1,0,0,1,'T'),
		('0051',0,1,0,1,1,0,'T'),
		('0052',0,1,0,1,0,1,'T'),
		('0053',0,1,0,0,1,1,'T'),
		('0054',0,0,1,1,1,0,'T'),
		('0055',0,0,1,1,0,1,'T'),
		('0056',0,0,1,0,1,1,'T'),
		('0057',0,0,0,1,1,1,'T'),
		('0058',0,1,1,1,1,0,'T'),
		('0059',0,1,1,1,0,1,'T'),
		('0060',0,1,1,0,1,1,'T'),
		('0061',0,1,0,1,1,1,'T'),
		('0062',0,0,1,1,1,1,'T'),
		('0063',0,1,1,1,1,1,'T')) 
	as Crosswalk_Data (
		Individual_Race_Key,
		Hispanic,
		Indian_Alaskan,
		Asian,
		Black,
		Pacific,
		White,
		Aggregate_Reporting_Category)
),
-- And another CTE to summarize our race patterns using our own 
-- binary encoding for quickly matching to Crosswalk...
StudentRaces(StudentID, BinaryRacesCode)
AS (
	SELECT 
		StudentID,
		-- Use binary to match identical sets of races between our race junction table and DPI Crosswalk table
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
ParentNames(StudentID, Parent1LastName, Parent1FirstName, Parent2LastName, Parent2FirstName)
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

select 
	StudentID,
	Tags_no_export,
	WiseId, 
	LocalPersonID, 
	LastName, 
	FirstName, 
	MiddleName, 
	Suffix, 
	Grade_no_export,
	Birthdate, 
	GenderID, 
	RaceKey, 
	OtherNameLastName, 
	OtherNameFirstName, 
	OtherNameMiddleName, 
	OtherNameSuffix, 
	EntityID, 
	LocalPersonIDKeyType, 
	Parent1Type, 
	Parent1LastName, 
	Parent1FirstName as Parent1NameFirstName, 
	Parent1MiddleName as Parent1NameMiddleName, 
	Parent1NameSuffix, 
	Parent2Type, 
	Parent2LastName, 
	Parent2FirstName as Parent2NameFirstName, 
	Parent2MiddleName as Parent2NameMiddleName, 
	Parent2NameSuffix,
	_Status_no_export
FROM (
	-- NOW THE FINAL QUERY...
	SELECT
		s.StudentID,
		s.AffiliationsHTML Tags_no_export,
    
		s.WISEid as WiseId,
	
		xStudentID as LocalPersonID,
		replace(Lname,'’','''') as LastName,
		replace(Fname,'’','''') as FirstName,	
		replace(Mname,'’','''') as MiddleName,
		s.suffix as Suffix,

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
				(select title 
					from LKG.dbo.SelectOptions
					where SelectListID=22 
						and Code COLLATE DATABASE_DEFAULT = bp.BirthState)
			end 
		else null end as BirthCountry,

		null as EntityID,
	
		'Student' as LocalPersonIDKeyType,
		case when Parent1LastName='' and Parent1FirstName='' 
			then 'M' else 'F' 
		end as Parent1Type,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then Parent2LastName else Parent1LastName 
		end,'’','''') as Parent1LastName,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then Parent2FirstName else Parent1FirstName 
		end,'’','''') as Parent1FirstName,

		null as Parent1MiddleName,
		null as Parent1NameSuffix,	

		case when (Parent1LastName='' and Parent1FirstName='') 
				or (Parent2FirstName='' and Parent2LastName='')
			then null else 'M' end as Parent2Type,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then null else Parent2LastName end,'’','''') as Parent2LastName,

		replace(case when Parent1LastName='' and Parent1FirstName='' 
			then null else Parent2FirstName end,'’','''') as Parent2FirstName,

		null as Parent2MiddleName,
		null as Parent2NameSuffix,	

		s._status as _Status_no_export -- include SIS student status for basic active/inactive grid filtering...

	FROM
		StudentRoster s
	INNER JOIN
		ParentNames p
		ON s.StudentID = p.StudentID
	LEFT JOIN 
		StudentRaces sr
		ON s.StudentID = sr.StudentID
	LEFT JOIN
		Crosswalk cw
		ON cw.BinaryRacesCode = sr.BinaryRacesCode
	LEFT JOIN
		Birthplace bp
		ON s.StudentID = bp.StudentID
	WHERE
		LName != ''
	-- Instead of filtering this view, we will default the 'Choice' filter in our report/export grid,
	-- in order to allow for greater flexibility in the use of that feature.  For example, users could
	-- clean race exceptions prior to assigning students to 'Choice'...
	-- AND ' '+Affiliations+';' like '% Choice;%'
) ver1
GO
