SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ClassLinkRosterOne]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Declare
	@MinGradeLevel int,
	@MaxGradeLevel int,
	@SchoolState varchar(10)

	Select
	@MinGradeLevel = 
		min(
		case GradeLevel
			when 'PS' then 1
			when 'PK' then 1
			when 'K' then 1
			else GradeLevel
		end
		),
	@MaxGradeLevel = 
		max(
		case GradeLevel
			when 'PS' then 1
			when 'PK' then 1
			when 'K' then 1
			else GradeLevel
		end
		)
	From Students 
	Where
	Active = 1


	Select
	@SchoolState = 
		CASE SchoolState
			WHEN 'ALABAMA' THEN 'AL'
			WHEN 'ALASKA' THEN 'AK'
			WHEN 'AMERICAN SAMOA' THEN 'AS'
			WHEN 'ARIZONA' THEN 'AZ'
			WHEN 'ARKANSAS' THEN 'AR'
			WHEN 'CALIFORNIA' THEN 'CA'
			WHEN 'COLORADO' THEN 'CO'
			WHEN 'CONNECTICUT' THEN 'CT'
			WHEN 'DELAWARE' THEN 'DE'
			WHEN 'DISTRICT OF COLUMBIA' THEN 'DC'
			WHEN 'FEDERATED STATES OF MICRONESIA' THEN 'FM'
			WHEN 'FLORIDA' THEN 'FL'
			WHEN 'GEORGIA' THEN 'GA'
			WHEN 'GUAM' THEN 'GU'
			WHEN 'HAWAII' THEN 'HI'
			WHEN 'IDAHO' THEN 'ID'
			WHEN 'ILLINOIS' THEN 'IL'
			WHEN 'INDIANA' THEN 'IN'
			WHEN 'IOWA' THEN 'IA'
			WHEN 'KANSAS' THEN 'KS'
			WHEN 'KENTUCKY' THEN 'KY'
			WHEN 'LOUISIANA' THEN 'LA'
			WHEN 'MAINE' THEN 'ME'
			WHEN 'MARSHALL ISLANDS' THEN 'MH'
			WHEN 'MARYLAND' THEN 'MD'
			WHEN 'MASSACHUSETTS' THEN 'MA'
			WHEN 'MICHIGAN' THEN 'MI'
			WHEN 'MINNESOTA' THEN 'MN'
			WHEN 'MISSISSIPPI' THEN 'MS'
			WHEN 'MISSOURI' THEN 'MO'
			WHEN 'MONTANA' THEN 'MT'
			WHEN 'NEBRASKA' THEN 'NE'
			WHEN 'NEVADA' THEN 'NV'
			WHEN 'NEW HAMPSHIRE' THEN 'NH'
			WHEN 'NEW JERSEY' THEN 'NJ'
			WHEN 'NEW MEXICO' THEN 'NM'
			WHEN 'NEW YORK' THEN 'NY'
			WHEN 'NORTH CAROLINA' THEN 'NC'
			WHEN 'NORTH DAKOTA' THEN 'ND'
			WHEN 'NORTHERN MARIANA ISLANDS' THEN 'MP'
			WHEN 'OHIO' THEN 'OH'
			WHEN 'OKLAHOMA' THEN 'OK'
			WHEN 'OREGON' THEN 'OR'
			WHEN 'PALAU' THEN 'PW'
			WHEN 'PENNSYLVANIA' THEN 'PA'
			WHEN 'PUERTO RICO' THEN 'PR'
			WHEN 'RHODE ISLAND' THEN 'RI'
			WHEN 'SOUTH CAROLINA' THEN 'SC'
			WHEN 'SOUTH DAKOTA' THEN 'SD'
			WHEN 'TENNESSEE' THEN 'TN'
			WHEN 'TEXAS' THEN 'TX'
			WHEN 'UTAH' THEN 'UT'
			WHEN 'VERMONT' THEN 'VT'
			WHEN 'VIRGIN ISLANDS' THEN 'VI'
			WHEN 'VIRGINIA' THEN 'VA'
			WHEN 'WASHINGTON' THEN 'WA'
			WHEN 'WEST VIRGINIA' THEN 'WV'
			WHEN 'WISCONSIN' THEN 'WI'
			WHEN 'WYOMING' THEN 'WY'
			ELSE ''
		END
	From Settings Where SettingID = 1


-- School CSV Results
	select
	'SIS ID' as [SIS ID],
	'Name' as [Name],
	'School Number' as [School Number],
	'School NCES_ID' as [School NCES_ID],
	'State ID' as [State ID],
	'Grade Low' as [Grade Low],
	'Grade High' as [Grade High],
	'Principal SIS ID' as [Principal SIS ID],
	'Principal Name' as [Principal Name],
	'Principal Secondary Email' as [Principal Secondary Email],
	'Address' as [Address],
	'City' as [City],
	'State' as [State],
	'Country' as [Country],
	'Zip' as [Zip],
	'Phone' as [Phone],
	'Zone' as [Zone]
	From
	Settings
	Where SettingID = 1
union
	select
	DB_Name() as [SIS ID],
	SchoolName as [Name],
	DB_Name() as [School Number],
	'' as [School NCES_ID],
	@SchoolState as [State ID],
	CONVERT(nvarchar(20), @MinGradeLevel) as [Grade Low],
	CONVERT(nvarchar(20), @MaxGradeLevel) as [Grade High],
	'' as [Principal SIS ID],
	SchoolPrincipal as [Principal Name],
	'' as [Principal Secondary Email],
	SchoolStreet as [Address],
	SchoolCity as [City],
	@SchoolState as [State],
	'USA' as [Country],
	SchoolZip as [Zip],
	SchoolPhone as [Phone],
	'' as [Zone]
	From
	Settings
	Where SettingID = 1
	Order by [SIS ID] desc



-- Section CSV Results
	select distinct
	'SIS ID' as [SIS ID],
	'School SIS ID' as [School SIS ID],
	'Section Name' as [Section Name],
	'Section Number' as [Section Number],
	'Term SIS ID' as [Term SIS ID],
	'Term Name' as [Term Name],
	'Term StartDate' as [Term StartDate],
	'Term EndDate' as [Term EndDate],
	'Course SIS ID' as [Course SIS ID],
	'Course Name' as [Course Name],
	'Course Number' as [Course Number],
	'Course Description' as [Course Description],
	'Course Subject' as [Course Subject],
	'Periods' as [Periods],
	'Active' as Status
	From 
	Classes C
	inner join
	Terms T
		on T.TermID = C.TermID
		inner join
	ClassesStudents CS
		on C.ClassID = CS.ClassID
	Where
	T.Status = 1
union
	select distinct
	CONVERT(nvarchar(20), C.ClassID) as [SIS ID],
	DB_Name() as [School SIS ID],
	C.ClassTitle as [Section Name],
	C.ClassTitle + ' ' + (right(T.TermTitle,9)) as [Section Number],
	CONVERT(nvarchar(20), C.TermID) as [Term SIS ID],
	T.TermTitle as [Term Name],
	dbo.GLformatdate(T.StartDate) as [Term StartDate],
	dbo.GLformatdate(T.EndDate)  as [Term EndDate],
	CONVERT(nvarchar(20), C.ClassID) as [Course SIS ID],
	C.ClassTitle as [Course Name],
	C.CourseCode as [Course Number],
	C.ClassTitle as [Course Description],
	'' as [Course Subject],
	CONVERT(nvarchar(20), C.Period) as [Periods],
	'Active' as Status
	From 
	Classes C
		inner join
	Terms T
		on T.TermID = C.TermID
		inner join
	ClassesStudents CS
		on C.ClassID = CS.ClassID
	Where
	T.Status = 1
	Order by [SIS ID] desc


-- Student CSV Results
	select distinct
	'SIS ID' as [SIS ID],
	'School SIS ID' as [School SIS ID],
	'First Name' as [First Name],
	'Last Name' as [Last Name],
	'Username' as [Username],
	'Password' as [Password],
	'State ID' as [State ID],
	'Secondary Email' as [Secondary Email],
	'Student Number' as [Student Number],
	'Middle Name' as [Middle Name],
	'Grade' as [Grade],
	'Status' as [Status],
	'Mailing Address' as [Mailing Address],
	'Mailing City' as [Mailing City],
	'Mailing State' as [Mailing State],
	'Mailing Zip' as [Mailing Zip],
	'Mailing Latitude' as [Mailing Latitude],
	'Mailing Longitude' as [Mailing Longitude],
	'Mailing Country' as [Mailing Country],
	'Residence Address' as [Residence Address],
	'Residence City' as [Residence City],
	'Residence State' as [Residence State],
	'Residence Zip' as [Residence Zip],
	'Residence Latitude' as [Residence Latitude],
	'Residence Longitude' as [Residence Longitude],
	'Residence Country' as [Residence Country],
	'Gender' as [Gender],
	'Birthdate' as [Birthdate],
	'ELL Status' as [ELL Status],
	'FederalRace' as [FederalRace],
	'Graduation Year' as [Graduation Year]
	From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
	Where
	Active = 1
union
	select distinct
	CONVERT(nvarchar(20), S.StudentID) as [SIS ID],
	DB_Name() as [School SIS ID],
	Fname as [First Name],
	Lname as [Last Name],
	AccountID as [Username],
	'' as [Password],
	State as [State ID],
	SchoolEmail as [Secondary Email],
	CONVERT(nvarchar(20), xStudentID) as [Student Number],
	isnull(Mname,'') as [Middle Name],
	GradeLevel as [Grade],
	'Active'  as [Status],
	Street as [Mailing Address],
	City as [Mailing City],
	State as [Mailing State],
	Zip as [Mailing Zip],
	'' as [Mailing Latitude],
	'' as [Mailing Longitude],
	'USA' as [Mailing Country],
	Street as [Residence Address],
	City as [Residence City],
	State as [Residence State],
	Zip as [Residence Zip],
	'' as [Residence Latitude],
	'' as [Residence Longitude],
	'USA' as [Residence Country],
	Sex as [Gender],
	dbo.GLformatdate(BirthDate) as [Birthdate],
	'' as [ELL Status],
	'' as [FederalRace],
	CONVERT(nvarchar(20), year(GraduationDate)) as [Graduation Year]
	From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
	Where
	Active = 1
	Order by [SIS ID] desc

-- StudentEnrollment CSV Results
	Select
	'Section SIS ID' as [Section SIS ID],
	'SIS ID' as [SIS ID]
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on T.TermID = C.TermID
	Where
	T.Status = 1
union
	Select
	CONVERT(nvarchar(20), CS.ClassID) as [Section SIS ID],
	CONVERT(nvarchar(20), CS.StudentID) as [SIS ID]
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on T.TermID = C.TermID
	Where
	T.Status = 1
	Order by [SIS ID] desc

-- Teacher CSV Results
	Select distinct
	'SIS ID' as [SIS ID],
	'School SIS ID' as [School SIS ID],
	'First Name' as [First Name],
	'Last Name' as [Last Name],
	'Username' as [Username],
	'Staff Type' as [Staff Type],
	'State ID' as [State ID],
	'TeacherNumber' as [TeacherNumber],
	'Status' as [Status],
	'Middle Name' as [Middle Name],
	'Email' as [Email],
	'Title' as [Title],
	'Qualification' as [Qualification]
	From 
	Teachers T
	
union
	Select distinct
	CONVERT(nvarchar(20), T.TeacherID) as [SIS ID],
	DB_Name() as [School SIS ID],
	T.Fname as [First Name],
	T.Lname as [Last Name],
	T.AccountID as [Username],
	StaffType = case (T.StaffType) 
	when '1' then 'Teacher' 
	when '2' then 'Admin(Limited Access)' 
	when '3' then 'Admin(Full Access)' 
	when '4' then 'Other(No Access)'
	else 'No Access' end,
	T.State as [State ID],
	'' as [TeacherNumber],
	CONVERT(nvarchar(20), T.Active) as [Status],
	T.Mname as [Middle Name],
	Email as [Email],
	'' as [Title],
	'' as [Qualification]
	From 
	Teachers T
		inner join
	Classes C
		on C.TeacherID = T.TeacherID
		inner join
	Terms Tm
		on Tm.TermID = C.TermID
		inner join
	ClassesStudents CS
		on CS.ClassID = C.ClassID 
		Where T.Active = 1 and T.AccountID !='glinit'
	
union
	Select distinct
	CONVERT(nvarchar(20), T.TeacherID) as [SIS ID],
	DB_Name() as [School SIS ID],
	T.Fname as [First Name],
	T.Lname as [Last Name],
	T.AccountID as [Username],
	StaffType = case (T.StaffType) 
	when '1' then 'Teacher' 
	when '2' then 'Admin(Limited Access)' 
	when '3' then 'Admin(Full Access)' 
	when '4' then 'Other(No Access)'
	else 'No Access' end,
	T.State as [State ID],
	'' as [TeacherNumber],
	CONVERT(nvarchar(20), T.Active) as [Status],
	T.Mname as [Middle Name],
	Email as [Email],
	'' as [Title],
	'' as [Qualification]
	From 
	Teachers T  
	Where T.Active = 1 and T.AccountID !='glinit'
	Order By [SIS ID] desc

-- TeacherRoster CSV Results
	Select distinct
	'Section SIS ID' as [Section SIS ID],
	'SIS ID' as [SIS ID]
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on T.TermID = C.TermID
	Where
	T.Status = 1
union
		Select distinct
	CONVERT(nvarchar(20), CS.ClassID) as [Section SIS ID],
	CONVERT(nvarchar(20), C.TeacherID) as [SIS ID]
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on T.TermID = C.TermID
	Where
	T.Status = 1
	Order By [SIS ID] desc


-- Demographics CSV Results - Demographics.csv
	select distinct
	'sourcedId' as [Sourced ID],
	'status' as [Status],
	'datelastmodified' as [DateLast Modified],
	'birthdate' as [Birth Date],
	'sex' as [Sex],
	'americanindianoralaskanative' as [American Indian Or Alaska Native],
	'asian' as [Asian],
	'blackorafricanamerican' as [Black Or African American],
	'nativehawaiianorotherpacificislander' as [Native Hawaiian Or Other Pacific Islander],
	'white' as [White],
	'demographicracetwoormoreraces' as [Demographic Race Two Or More Races],
	'hispanicorlatinoethnicity' as [Hispanic Or Latino Ethnicity],
	'countryofbirthcode' as [Country Of Birth Code],
	'stateofbirthabbreviation' as [State Of Birth Abbreviation],
	'cityofbirth' as [City Of Birth],
	'publicschoolresidencestatus' as [Public School Residence Status]	
	From 
	Students S
	Where Active = 1
	
union
	select distinct
	CONVERT(nvarchar(20), S.xStudentID) as [sourcedId],
	''  as [Status],
	'' as [dateLastModified],
	format(S.BirthDate,'yyyy-MM-dd')  as  [Birth Date],
	S.Sex as [Sex],
	case
		When R.RaceID = 7 then 'True' else 'False' end as [American Indian Or Alaska Native],
	case
		When R.RaceID = 2 then 'True' else 'False' end as [Asian],
	case
		When R.RaceID = 5 then 'True' else 'False' end as [Black Or African American],
	case
		When R.RaceID = 10 then 'True' else 'False' end as [Native Hawaiian Or Other Pacific Islander],		
	case
		When R.RaceID = 1 then 'True' else 'False' end as [White],	
	case
		When R.RaceID = 11 or R.RaceID = 3  then 'True' else 'False' end as [Demographic Race Two Or More Races],	
	case
		When R.RaceID = 4 or R.RaceID = 9 or R.RaceID = 13 then 'True' else 'False' end as [Hispanic Or Latino Ethnicity],
	
	M.BirthCounty as [Country Of Birth Code],
	M.BirthState as [State Of Birth Abbreviation],
	M.BirthCity as [City Of Birth],
	'' as [Public School Residence Status]	
	From 
	Students S inner join StudentMiscFields M on S.StudentID = M.StudentID
	inner join StudentRace R on S.StudentID = R.StudentID
	Where
	S.Active = 1
	Order by [Sourced ID] desc
END
GO
