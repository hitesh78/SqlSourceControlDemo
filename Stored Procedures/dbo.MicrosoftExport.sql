SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/19/2018
-- Description:	This is an Export requested by #1274 for a Microsoft System, not sure which one
-- =============================================
CREATE PROCEDURE [dbo].[MicrosoftExport]
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
	DB_Name() as [SIS ID],
	SchoolName as [Name],
	DB_Name() as [School Number],
	'' as [School NCES_ID],
	@SchoolState as [State ID],
	@MinGradeLevel as [Grade Low],
	@MaxGradeLevel as [Grade High],
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




	-- Section CSV Results
	select distinct
	C.ClassID as [SIS ID],
	DB_Name() as [School SIS ID],
	C.ClassTitle as [Section Name],
	C.ClassID as [Section Number],
	C.TermID as [Term SIS ID],
	T.TermTitle as [Term Name],
	dbo.GLformatdate(T.StartDate) as [Term StartDate],
	dbo.GLformatdate(T.EndDate)  as [Term EndDate],
	C.ClassID as [Course SIS ID],
	C.ClassTitle as [Course Name],
	C.CourseCode as [Course Number],
	C.ClassTitle as [Course Description],
	'' as [Course Subject],
	C.Period as [Periods],
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


	-- Student CSV Results
	select distinct
	S.StudentID as [SIS ID],
	DB_Name() as [School SIS ID],
	Fname as [First Name],
	Lname as [Last Name],
	AccountID as [Username],
	'' as [Password],
	State as [State ID],
	'' as [Secondary Email],
	xStudentID as [Student Number],
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
	year(GraduationDate) as [Graduation Year]
	From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
	Where
	Active = 1


	-- StudentEnrollment CSV Results
	Select
	CS.ClassID as [Section SIS ID],
	CS.StudentID as [SIS ID]
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

	-- Teacher CSV Results
	Select distinct
	T.TeacherID as [SIS ID],
	DB_Name() as [School SIS ID],
	T.Fname as [First Name],
	T.Lname as [Last Name],
	T.AccountID as [Username],
	T.State as [State ID],
	'' as [TeacherNumber],
	T.Active as [Status],
	T.Mname as [Middle Name],
	'' as [Secondary Email],
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
	Where
	Tm.Status = 1



	-- TeacherRoster CSV Results
	Select distinct
	CS.ClassID as [Section SIS ID],
	C.TeacherID as [SIS ID]
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

	Union

	Select distinct
	TC.ClassID as [Section SIS ID],
	TC.TeacherID as [SIS ID]
	From
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on T.TermID = C.TermID
		inner join
	TeachersClasses TC
		on C.ClassID = TC.ClassID
	Where
	T.Status = 1
	Order By 1

END

GO
