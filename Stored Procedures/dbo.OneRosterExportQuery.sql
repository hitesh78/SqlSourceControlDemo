SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* ============================================= 
** Author:		Joey Guziejka
** Created:		04/05/2021
** Modified:	03/03/2023
** Description:	create export for oneroster 1.1 
** Rev. Notes:	Adds Grade Level Selection 
** Run:			EXEC [OneRosterExportQuery]
** ============================================= */
CREATE   PROCEDURE [dbo].[OneRosterExportQuery]
AS
BEGIN

SET NOCOUNT ON;

Declare @GradeLevels nvarchar(100) = (
	select GradeLevels
	From [LKG].dbo.glSchoolServices
	Where SchoolID = DB_NAME()
		and ServiceID = 26
);

Declare @GradeLevelsTable table (GradeLevel nvarchar(50)) 
Insert into @GradeLevelsTable
Select TheString
From dbo.SplitCSVStrings(@GradeLevels);
--select * from @GradeLevelsTable

Declare @UseAllGradeLevels bit = 0;
DECLARE @includeStaff bit = 0;
DECLARE @includeParents bit = 0;

Set @UseAllGradeLevels = (select ISNULL((Select 1 From @GradeLevelsTable where GradeLevel = 'All'), 0));
Set @includeStaff = (select ISNULL((Select 1 From @GradeLevelsTable where GradeLevel IN ('All', 'Staff')), 0));
Set @includeParents = (select ISNULL((Select 1 From @GradeLevelsTable where GradeLevel IN ('All', 'Parents/Guardians')), 0));
--select @UseAllGradeLevels, @includeStaff, @includeParents 

DECLARE @StudentPasswordWarningAcknowledged bit;
DECLARE @ShowPKasTK bit; 

select 
	@StudentPasswordWarningAcknowledged = [StudentPasswordWarningAcknowledged],
	@ShowPKasTK = [ShowPKasTK]
from Settings 
Where SettingID = 1;

DECLARE @currentTerms TABLE (termId int);

INSERT INTO @currentTerms 
SELECT TermID
FROM Terms te
WHERE TermID in (SELECT TermID FROM dbo.GetYearTermIDsByDate(getdate()))
and TermID not in (SELECT DISTINCT ParentTermID FROM Terms)
	and ExamTerm = 0
	and [Status] = 1

--"academicSessions.csv",
SELECT
	'sourcedId' as [sourcedId],
	'status' as [status],
	'dateLastModified' as [dateLastModified],
	'title' as [title],
	'type' as [type],
	'startDate' as [startDate],
	'endDate' as [endDate],
	'parentSourcedId' as [parentSourcedId],
	'schoolYear' as [schoolYear]
UNION ALL
SELECT
	CONVERT(nvarchar(20), te.TermID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	te.TermTitle as [title],
	'term' as [type],
	CONVERT(nvarchar(20), CONVERT(date, te.StartDate)) as [startDate],
	CONVERT(nvarchar(20), CONVERT(date, te.EndDate)) as [endDate],
	'' as [parentSourcedId],
	CONVERT(nvarchar(20), (
		SELECT YEAR(MAX(EndDate))
		FROM Terms
		WHERE TermID in (Select TermID From dbo.GetYearTermIDsByDate(getdate()))
			and TermID not in (Select distinct ParentTermID From Terms)
			and ExamTerm = 0)
	) as [schoolYear]
FROM Terms te
WHERE TermID in (Select termId From @currentTerms)

--"classes.csv",
SELECT
	'sourcedId' as [sourcedId],
	'status' as [status],
	'dateLastModified' as [dateLastModified],
	'title' as [title],
	'grades' as [grades],
	'courseSourcedId' as [courseSourcedId],
	'classCode' as [classCode],
	'classType' as [classType],
	'location' as [location],
	'schoolSourcedId' as [schoolSourcedId],
	'termSourcedIds' as [termSourcedIds],
	'subjects' as [subjects],
	'subjectCodes' as [subjectCodes],
	'periods' as [periods]
UNION ALL
SELECT
	CONVERT(nvarchar(20), cl.ClassID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	cl.ClassTitle as [title],
	'' as [grades],
	CONVERT(nvarchar(20), cl.ClassID) as [courseSourcedId],
	'' as [classCode],
	CASE cl.ClassTypeID
		WHEN 5 THEN 'homeroom'
		ELSE 'scheduled'
	END as [classType],
	cl.[Location] as [location],
	DB_Name() as [schoolSourcedId],
	CONVERT(nvarchar(20), cl.TermID) as [termSourcedIds],
	'' as [subjects],
	'' as [subjectCodes],
	isnull(CASE
		WHEN cl.ScheduleType = 1 then (Select PeriodSymbol From [Periods] Where PeriodID = cl.[Period])
		WHEN cl.ScheduleType = 2 then 
		(
			Select
				LEFT(b.[Periods], LEN(b.[Periods])-1)
			From (
				Select
					distinct ClassID, 
					(
						Select 
							a.PeriodSymbol + ',' as [text()]
						From
							(Select
								distinct p.PeriodSymbol
							From (
								select 
									ClassID, PeriodOnSunday, PeriodOnMonday, PeriodOnTuesday, PeriodOnWednesday, PeriodOnThursday, PeriodOnFriday, PeriodOnSaturday
								from Classes C
								where C.ClassID = C2.ClassID
							) c
							UNPIVOT
								(PeriodId FOR SchoolDay IN 
									(PeriodOnSunday, PeriodOnMonday, PeriodOnTuesday, PeriodOnWednesday, PeriodOnThursday, PeriodOnFriday, PeriodOnSaturday) 
								) as unpvt
							left join [Periods] p
							on p.PeriodID = unpvt.PeriodId
							Where unpvt.PeriodId > 0
							and isnull(p.PeriodSymbol, '') <> ''
							) a
						FOR XML PATH('')
					) [Periods]
				From Classes C2
				where C2.ClassID = cl.ClassID
			) b
		)
		WHEN cl.ScheduleType = 3 then 
		(
			Select
				LEFT(b.[Periods], LEN(b.[Periods])-1)
			From (
				Select
					distinct ClassID, 
					(
						Select 
							a.PeriodSymbol + ',' as [text()]
						From
							(Select
								distinct p.PeriodSymbol
							From (
								select 
									ClassID, BPeriodOnSunday, BPeriodOnMonday, BPeriodOnTuesday, BPeriodOnWednesday, BPeriodOnThursday, BPeriodOnFriday, BPeriodOnSaturday
								from Classes C
								where C.ClassID = C2.ClassID
							) c
							UNPIVOT
								(PeriodId FOR SchoolDay IN 
									(BPeriodOnSunday, BPeriodOnMonday, BPeriodOnTuesday, BPeriodOnWednesday, BPeriodOnThursday, BPeriodOnFriday, BPeriodOnSaturday) 
								) as unpvt
							left join [Periods] p
							on p.PeriodID = unpvt.PeriodId
							Where unpvt.PeriodId > 0
							and isnull(p.PeriodSymbol, '') <> ''
							) a
						FOR XML PATH('')
					) [Periods]
				From Classes C2
				where C2.ClassID = cl.ClassID
			) b
		)
		ELSE ''
	END, '') as [periods]
FROM Classes cl
WHERE cl.ClassTypeID IN (1,5,8)
	and TermID IN (SELECT termId FROM @currentTerms)

--"courses.csv",
SELECT
	'sourcedId' as [sourcedId],
	'status' as [status],
	'dateLastModified' as [dateLastModified],
	'schoolYearSourcedId' as [schoolYearSourcedId],
	'title' as [title],
	'courseCode' as [courseCode],
	'grades' as [grades],
	'orgSourcedId' as [orgSourcedId],
	'subjects' as [subjects],
	'subjectCodes' as [subjectCodes]
UNION ALL
SELECT
	CONVERT(nvarchar(20), cl.ClassID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	'' as [schoolYearSourcedId],
	cl.ClassTitle as [title],
	ISNULL(cl.CourseCode, '') as [courseCode],
	'' as [grades],
	DB_Name() as [orgSourcedId],
	'' as [subjects],
	'' as [subjectCodes]
FROM Classes cl
WHERE TermID IN (SELECT termId from @currentTerms)

--"demographics.csv",
SELECT
	'sourcedId' as [sourcedId],
	'status' as [status],
	'dateLastModified' as [dateLastModified],
	'birthDate' as [birthDate],
	'sex' as [sex],
	'americanIndianOrAlaskaNative' as [americanIndianOrAlaskaNative],
	'asian' as [asian],
	'blackOrAfricanAmerican' as [blackOrAfricanAmerican],
	'nativeHawaiianOrOtherPacificIslander' as [nativeHawaiianOrOtherPacificIslander],
	'white' as [white],
	'demographicRaceTwoOrMoreRaces' as [demographicRaceTwoOrMoreRaces],
	'hispanicOrLatinoEthnicity' as [hispanicOrLatinoEthnicity],
	'countryOfBirthCode' as [countryOfBirthCode],
	'stateOfBirthAbbreviation' as [stateOfBirthAbbreviation],
	'cityOfBirth' as [cityOfBirth],
	'publicSchoolResidenceStatus' as [publicSchoolResidenceStatus]
UNION ALL
SELECT
	CONVERT(nvarchar(20), st.xStudentID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	CONVERT(nvarchar(20), CONVERT(date, ISNULL(st.BirthDate, getdate()))) as [birthDate],
	LOWER(ISNULL(st.Sex, '')) as [sex],
	IIF(rd.americanIndianOrAlaskaNative = 1, 'true', 'false') as [americanIndianOrAlaskaNative],
	IIF(rd.asian = 1, 'true', 'false') as [asian],
	IIF(rd.blackOrAfricanAmerican = 1, 'true', 'false') as [blackOrAfricanAmerican],
	IIF(rd.nativeHawaiianOrOtherPacificIslander = 1, 'true', 'false') as [nativeHawaiianOrOtherPacificIslander],
	IIF(rd.white = 1, 'true', 'false') as [white],
	IIF(rd.demographicRaceTwoOrMoreRaces = 1, 'true', 'false') as [demographicRaceTwoOrMoreRaces],
	IIF(rd.hispanicOrLatinoEthnicity = 1, 'true', 'false') as [hispanicOrLatinoEthnicity],
	'' as [countryOfBirthCode],
	'' as [stateOfBirthAbbreviation],
	ISNULL(smf.BirthCity, '') as [cityOfBirth],
	'' as [publicSchoolResidenceStatus]
FROM Students st
	left join StudentMiscFields smf
		on smf.StudentID = st.StudentID
	left join fnOneRosterRaceDemographics() rd
		on rd.StudentID = st.StudentID
WHERE st.Active = 1
and case
		when @UseAllGradeLevels = 1 
		then 1
		when GradeLevel in (Select GradeLevel From @GradeLevelsTable) 
		then 1
		else 0
	end = 1;

--"enrollments.csv",
SELECT
	'sourcedId' as [sourcedId],
	'status' as [status],
	'dateLastModified' as [dateLastModified],
	'classSourcedId' as [classSourcedId],
	'schoolSourcedId' as [schoolSourcedId],
	'userSourcedId' as [userSourcedId],
	'role' as [role],
	'primary' as [primary],
	'beginDate' as [beginDate],
	'endDate' as [endDate]
UNION ALL
-- students
SELECT 
	CONVERT(nvarchar(20), cl.ClassID) + CONVERT(nvarchar(20), st.xStudentID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	CONVERT(nvarchar(20), cl.ClassID) as [classSourcedId],
	DB_Name() as [schoolSourcedId],
	CONVERT(nvarchar(20), st.xStudentID) as [userSourcedId],
	'student' as [role],
	'false' as [primary],
	CONVERT(nvarchar(20), CONVERT(date, te.StartDate)) as [beginDate],
	CONVERT(nvarchar(20), CONVERT(date, te.EndDate)) as [endDate]
FROM Classes cl
	left join ClassesStudents cs
		on cs.ClassID = cl.ClassID
	left join Students st
		on st.StudentID = cs.StudentID
	left join Terms te
		on te.TermID = cl.TermID
WHERE cl.TermID IN (select termId from @currentTerms)
	and cl.ClassTypeID IN (1,5,8)
	and st.Active = 1
	and case
			when @UseAllGradeLevels = 1 
			then 1
			when GradeLevel in (Select GradeLevel From @GradeLevelsTable) 
			then 1
			else 0
		end = 1
UNION ALL
-- teachers: primary
SELECT 
	CONVERT(nvarchar(20), cl.ClassID) + 'SID_' +  CONVERT(nvarchar(20), ts.TeacherID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	CONVERT(nvarchar(20), cl.ClassID) as [classSourcedId],
	DB_Name() as [schoolSourcedId],
	'SID_' + CONVERT(nvarchar(20), ts.TeacherID) as [userSourcedId],
	'teacher' as [role],
	'true' as [primary],
	CONVERT(nvarchar(20), CONVERT(date, te.StartDate)) as [beginDate],
	CONVERT(nvarchar(20), CONVERT(date, te.EndDate)) as [endDate]
FROM Classes cl
	inner join Teachers ts
		on ts.TeacherID = cl.TeacherID
	inner join Terms te
		on te.TermID = cl.TermID
WHERE cl.TermID IN (select termId from @currentTerms)
	and cl.ClassTypeID IN (1,5,8)
	and ts.Active = 1
UNION ALL
-- teachers: secondary
SELECT 
	CONVERT(nvarchar(20), cl.ClassID) + 'SID_' + CONVERT(nvarchar(20), tc.TeacherID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	CONVERT(nvarchar(20), cl.ClassID) as [classSourcedId],
	DB_Name() as [schoolSourcedId],
	'SID_' + CONVERT(nvarchar(20), tc.TeacherID) as [userSourcedId],
	'teacher' as [role],
	'false' as [primary],
	CONVERT(nvarchar(20), CONVERT(date, te.StartDate)) as [beginDate],
	CONVERT(nvarchar(20), CONVERT(date, te.EndDate)) as [endDate]
FROM TeachersClasses tc
	inner join Teachers ts
		on ts.TeacherID = tc.TeacherID
	inner join Classes cl
		on cl.ClassID = tc.ClassID
	inner join Terms te
		on te.TermID = cl.TermID
WHERE cl.TermID IN (select termId from @currentTerms)
	and cl.ClassTypeID IN (1,5,8)
	and ts.Active = 1

--"manifest.csv",
SELECT 'propertyName' as [propertyName], 'value' as [value]
UNION ALL
SELECT 'manifest.version' as [propertyName], '1.0' as [value]
UNION ALL
SELECT 'oneroster.version' as [propertyName], '1.1' as [value]
UNION ALL
SELECT 'file.academicSessions' as [propertyName], 'bulk' as [value]
UNION ALL
SELECT 'file.categories' as [propertyName], 'absent' as [value]
UNION ALL
SELECT 'file.classes' as [propertyName], 'bulk' as [value]
UNION ALL
SELECT 'file.classResources' as [propertyName], 'absent' as [value]
UNION ALL
SELECT 'file.courses' as [propertyName], 'bulk' as [value]
UNION ALL
SELECT 'file.courseResources' as [propertyName], 'absent' as [value]
UNION ALL
SELECT 'file.demographics' as [propertyName], 'bulk' as [value]
UNION ALL
SELECT 'file.enrollments' as [propertyName], 'bulk' as [value]
UNION ALL
SELECT 'file.lineItems' as [propertyName], 'absent' as [value]
UNION ALL
SELECT 'file.orgs' as [propertyName], 'bulk' as [value]
UNION ALL
SELECT 'file.resources' as [propertyName], 'absent' as [value]
UNION ALL
SELECT 'file.results' as [propertyName], 'absent' as [value]
UNION ALL
SELECT 'file.users' as [propertyName], 'bulk' as [value]
UNION ALL
SELECT 'source.systemName' as [propertyName], 'Gradelink' as [value]
UNION ALL
SELECT 'source.systemCode' as [propertyName], 'ClasslinkExport2' as [value]

--"orgs.csv",
SELECT
	'sourcedId' as [sourcedId],
	'status' as [status],
	'dateLastModified' as [dateLastModified],
	'name' as [name],
	'type' as [type],
	'identifier' as [identifier],
	'parentSourcedId' as [parentSourcedId],
	'metadata.street' as [metadata.street],
	'metadata.state' as [metadata.state],
	'metadata.city' as [metadata.city],
	'metadata.zip' as [metadata.zip],
	'metadata.schoolcode' as [metadata.schoolcode]
UNION ALL
SELECT
	DB_Name() as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	se.SchoolName as [name],
	'school' as [type],
	'' as [identifier],
	'' as [parentSourcedId],
	se.SchoolStreet as [metadata.street],
	se.SchoolState as [metadata.state],
	se.SchoolCity as [metadata.city],
	se.SchoolZip as [metadata.zip],
	se.SchoolCode as [metadata.schoolcode]
FROM Settings se

--"users.csv",
SELECT
	'sourcedId' as [sourcedId],
	'status' as [status],
	'dateLastModified' as [dateLastModified],
	'enabledUser' as [enabledUser],
	'orgSourcedIds' as [orgSourcedIds],
	'role' as [role],
	'username' as [username],
	'userIds' as [userIds],
	'givenName' as [givenName],
	'familyName' as [familyName],
	'middleName' as [middleName],
	'identifier' as [identifier],
	'email' as [email],
	'sms' as [sms],
	'phone' as [phone],
	'agentSourcedIds' as [agentSourcedIds],
	'grades' as [grades],
	'password' as [password]
UNION ALL
-- students
SELECT
	CONVERT(nvarchar(20), st.xStudentID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	CASE ac.Lockout
		WHEN 0 THEN 'true'
		ELSE 'false'
	END as [enabledUser],
	DB_Name() as [orgSourcedIds],
	'student' as [role],
	st.AccountID as [username],
	'' as [userIds],
	Fname as [givenName],
	Lname as [familyName],
	ISNULL(Mname, '') as [middleName],
	CONVERT(nvarchar(20), st.StudentID) as [identifier],
	CASE
		WHEN (select AdultSchool from Settings) = 1 THEN COALESCE(nullif(st.SchoolEmail, ''), nullif(st.Email1, ''), '') 
		ELSE COALESCE(nullif(st.SchoolEmail, ''), nullif(st.Email8, ''), '')
	END as [email],
	CASE
		WHEN vp.LineType = 'Mobile'
		THEN vp.Phone
		ELSE ''
	END as [sms],
	ISNULL(vp.Phone, '') as [phone],
	'' as [agentSourcedIds],
	CASE
		WHEN [GradeLevel] = 'PS' 
		THEN 'PR'
		WHEN [GradeLevel] = 'K' 
		THEN 'KG'
		WHEN [GradeLevel] = 'PK' and @ShowPKasTK = 1 
		THEN 'TK'
		WHEN [GradeLevel] = 'PK' and @ShowPKasTK = 0
		THEN 'PK'
		WHEN ISNUMERIC([GradeLevel]) = 1 and len([GradeLevel]) = 1 
		THEN '0' + [GradeLevel]
		WHEN ISNUMERIC([GradeLevel]) = 1 and CONVERT(int, [GradeLevel]) > 13 -- max grade is 13
		THEN 'Other'
		ELSE [GradeLevel]
	END as [grades],
	CASE
		WHEN @StudentPasswordWarningAcknowledged = 1 then BackupPswd
		else '' 
		end as [password]
FROM Students st
	inner join Accounts ac
		on ac.AccountID = st.AccountID
	left join PhoneNumbers vp
		on vp.StudentID = st.StudentID
WHERE st.Active = 1
	and case
			when @UseAllGradeLevels = 1 
			then 1
			when GradeLevel in (Select GradeLevel From @GradeLevelsTable) 
			then 1
			else 0
		end = 1
UNION ALL
-- staff
SELECT
	'SID_' + CONVERT(nvarchar(20), te.TeacherID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	CASE ac.Lockout
		WHEN 0 THEN 'true'
		ELSE 'false'
	END as [enabledUser],
	DB_Name() as [orgSourcedIds],
	CASE te.StaffType
		WHEN 1 THEN 'teacher'
		WHEN 4 THEN NULL
		ELSE 'administrator'
	END as [role],
	te.AccountID as [username],
	'' as [userIds],
	Fname as [givenName],
	Lname as [familyName],
	ISNULL(Mname, '') as [middleName],
	'SID_' + CONVERT(nvarchar(20), te.TeacherID) as [identifier],
	COALESCE(te.Email, te.Email2, te.Email3, '') as [email],
	COALESCE(te.Phone2, '') as [sms],
	COALESCE(te.Phone, te.Phone2, te.Phone3, '') as [phone],
	'' as [agentSourcedIds],
	'' as [grades],
	'' as [password]
FROM Teachers te
	join Accounts ac
		on ac.AccountID = te.AccountID
WHERE te.Active = 1 
	and te.StaffType <> 4 
	and te.TeacherID <> -1
	and @includeStaff = 1
UNION ALL
--parents
SELECT
	CONVERT(nvarchar(20), sc.ContactID) as [sourcedId],
	'' as [status],
	'' as [dateLastModified],
	CASE ac.Lockout
		WHEN 0 
		THEN 'true'
		ELSE 'false'
	END as [enabledUser],
	DB_Name() as [orgSourcedIds],
	case
		when sc.Relationship in ('Father', 'Mother', 'Mom', 'Dad', 'Parent', 'Father/Parent 2', 'Mother/Parent 1', 'Father/Parent 2', 'Mother/Parent 1' ) 
		then 'parent'
		When sc.Relationship in ('Aunt', 'Uncle', 'Cousin', 'Daughter', 'Son', 'Brother','Grand Father', 'Grand Mother', 'Niece', 'Sibling', 'Sister', 'Nephew') 
		then 'relative'
		When sc.Relationship like '%Guardian%' 
		then 'guardian'
	end as [role],
	f.AccountID as [username],
	'' as [userIds],
	sc.Fname as [givenName],
	sc.Lname as [familyName],
	ISNULL(sc.Mname, '') as [middleName],
	'' as [identifier],
	sc.Email1 as [email],
	sc.Phone1Num as [sms],
	ISNULL(sc.Phone2Num, '') as [phone],
	'' as [agentSourcedIds],
	'' [grades],
	'' as [password]
FROM Students st
	inner join Accounts ac
		on ac.AccountID = st.AccountID
	left join StudentContacts sc
		on sc.StudentID = st.StudentID
	left join Families f on f.FamilyID = st.FamilyID
WHERE st.Active = 1
	and case
			when @UseAllGradeLevels = 1 
			then 1
			when GradeLevel in (Select GradeLevel From @GradeLevelsTable) 
			then 1
			else 0
		end = 1
	and @includeParents = 1 
	and sc.ContactID is not null

END
GO
