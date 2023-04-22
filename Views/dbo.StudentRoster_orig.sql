SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[StudentRoster_orig]
AS
select case when z.Active=1 then GradeLevX else z._Status end as GradeLev,
--dbo.ConcatWithDelimiter(GradeLevX,_Status,'<br/>') GradeAndStatus,
dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	AddressName,Street,'<br/>'),CityStateZip1,'<br/>') as Address1,
dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	AddressName2,Street2,'<br/>'),CityStateZip2,'<br/>') as Address2,
dbo.ConcatWithDelimiter(
	case when rtrim(isnull(AddressDescription,''))>'' then 'Addr#1 - ' + rtrim(AddressDescription) else '' end,
	case when rtrim(isnull(AddressDescription2,''))>'' then 'Addr#2 - ' + rtrim(AddressDescription2) else '' end,
	'<br/>') as AddressDescriptions,
--dbo.ConcatWithDelimiter(
--	CAST(xStudentID as nvarchar(20)), AccountID, '<br/>') as xStudentIdAndAccountId,
* from (
SELECT TOP (100) PERCENT dbo.Accounts.Access, dbo.Accounts.EncKey, dbo.Accounts.MissedPasswords,  
    dbo.Accounts.LanguageType, dbo.Accounts.LastLoginTime, s.xStudentID, s.StudentID, 
    s.FamilyID, s.Active, s.Lname, 
    s.Mname, s.Fname, s.suffix,
	CASE WHEN s.GradeLevel = 'K' THEN ' ' WHEN s.GradeLevel = 'PK' OR
    s.GradeLevel = 'PS' THEN ' ' ELSE '&nbsp;'+replicate(' ', 2 - LEN(RTRIM(s.GradeLevel))) END + s.GradeLevel + case when s.Class>' ' then '-' else '' end + RTRIM(s.Class) AS GradeLevX, s.GradeLevel, s.Class, 
    s.Father, s.Mother, s.Family2Name1, s.Family2Name2,
	s.Phone1, s.Phone2, s.Phone3, s.Family2Phone1, s.Family2Phone2,
	s.Email1, s.Email2, s.Email3, s.Email4, s.Email5, s.Email6, s.Email7, s.Email8,
	isnull(convert(varchar,s.birthdate,101),'') as BirthDate, 
    s.Sex, 
	
	STUFF((SELECT '; ' + CAST(Name as nvarchar(50))
        FROM StudentRace sr
        INNER JOIN race on sr.RaceID = race.raceid
        where sr.StudentID = s.StudentID
        FOR XML PATH('')) ,1,2,'') Ethnicity,
  
	dbo.ConcatWithDelimiter(s.Sex,
	replace(
		STUFF((SELECT ';' + CAST(Name as nvarchar(50))
			FROM StudentRace sr
			INNER JOIN race on sr.RaceID = race.raceid
			where sr.StudentID = s.StudentID
			FOR XML PATH('')) ,1,1,'')
			,';','<br/>')
        ,'<br/>') 	
		as SexAndEthnicity,
			
	dbo.ConcatWithDelimiter(smf.campus,smf.nationality,'<br/>') as CampusAndNationality,
    s.AddressDescription, 
    s.AddressName, 
    s.Street, 
    s.City, 
    s.State, 
    s.Zip, 
    dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	s.City,s.State,', '),s.Zip,' ') as CityStateZip1,
    s.AddressDescription2, 
    s.AddressName2, 
    s.Street2, 
    s.City2, 
    s.State2, 
    s.Zip2, 
    dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	s.City2,s.State2,', '),s.Zip2,' ') as CityStateZip2,
    isnull(convert(varchar,s.EntryDate,101),'') as EntryDate,
    isnull(convert(varchar,s.WithdrawalDate,101),'') as WithdrawalDate,
    isnull(convert(varchar,s.GraduationDate,101),'') as GraduationDate,
    s.Comments, s.LockerNumber, 
    s.LockerCode, 
    s.AccountID, 

	s.glName AS FullName, 

    (SELECT     COUNT(*) AS Expr2
    FROM          dbo.Discipline
    WHERE      (StudentID = s.StudentID)) AS NumDisciplineLogRecs,
    (SELECT     COUNT(*) AS Expr3
    FROM          dbo.MedicalLog
    WHERE      (StudentID = s.StudentID)) AS numMedicalLogRecs, 
	CASE WHEN s.Active = 1 THEN 'Active' ELSE 'Inactive' END AS ActiveOrInactive, 

----------------------------------------------------------------
				/*
				** The following code block matches code in vStudents.  The code was copied rather
				** rather than referenced there for performance reasons.  Whenever code is changed here
				** is must be changed in the vStudents view too.
				*/
				CASE WHEN s.Active = 1 AND (select OnlineEnrollment from Settings) = 1 -- active, enrollme schools cases only...
				THEN 
					CASE 
					-- new enrollments (incl. those mapped as re-enrolls) retain their imported (or post-promote) status
						WHEN x.studentid>=1000000000 THEN 
							CASE WHEN s.Status='Reenrollment' and x.PromoteReenrollsToActive=1 THEN 'Active' ELSE s.Status END 
					-- no associated re-enrollments will just keep their active (i.e. not reenrolled) status
						WHEN x.studentid is null then 'Active'
					-- and students associated with (submitted or higher status) re-enrollments will get the re-enroll status
						ELSE 'Reenrollment'
					END 
				ELSE CASE
						-- following rules are expressed in a trigger now but just in case 
						-- any old or restored school files don't have student status field set yet...
						WHEN 
							s.Active = (CASE WHEN s.Status IN ('Active', 'Reenrollment') THEN 1 ELSE 0 END) 
						THEN isnull(s.Status, 
							CASE WHEN s.Active = 1 THEN 'Active' ELSE 'Inactive' END) 
						ELSE 
							CASE WHEN s.Active = 1 THEN 'Active' ELSE 'Inactive' END 
					END 
				END AS _Status, 
----------------------------------------------------------------

        (SELECT     COUNT(*) AS Expr1
        FROM          dbo.Donations AS d
        WHERE      (StudentID = s.StudentID)) AS Num_Donations,
        (SELECT     SUM(Amount) AS Expr1
        FROM          dbo.Donations AS d
        WHERE      (StudentID = s.StudentID)) AS Total_Donated,
        (SELECT     MAX(Date) AS Expr1
        FROM          dbo.Donations AS d
        WHERE      (StudentID = s.StudentID)) AS Last_Donation_Date,
         
        s.Affiliations, 
        s.Status,
        REPLACE(s.Affiliations,'; ','<br />') as AffiliationsHTML,

		dbo.ConcatWithDelimiter(
			case when isnull(s.father,'')+isnull(s.Email1,'')+isnull(s.Phone1,'')>'' then isnull(s.father,'-') else null end,
			case when isnull(s.mother,'')+isnull(s.Email2,'')+isnull(s.Phone2,'')>'' then isnull(s.mother,'-') else null end, '<br />')
			as Parents,
        dbo.ConcatWithDelimiter(
			dbo.ConcatWithDelimiter(
				case when isnull(s.father,'')+isnull(s.Email1,'')+isnull(s.Phone1,'')>'' then isnull(s.Email1,'-') else null end,
				case when isnull(s.mother,'')+isnull(s.Email2,'')+isnull(s.Phone2,'')>'' then isnull(s.Email2,'-') else null end, '<br />'),
	        s.Email3,'<br />') as Emails,
        dbo.ConcatWithDelimiter(
			dbo.ConcatWithDelimiter(
				case when isnull(s.father,'')+isnull(s.Email1,'')+isnull(s.Phone1,'')>'' then isnull(s.Phone1,'-') else null end,
				case when isnull(s.mother,'')+isnull(s.Email2,'')+isnull(s.Phone2,'')>'' then isnull(s.Phone2,'-') else null end, '<br />'),
	        s.Phone3,'<br />') as Phones,

		case when isnull(s.Family2Name1,'')='' and isnull(s.Family2Name2,'')='' then '' 
		else
			dbo.ConcatWithDelimiter(
				case when isnull(s.Family2Name1,'')+isnull(s.Email6,'')+isnull(s.Family2Phone1,'')>'' then isnull(s.Family2Name1,'-') else null end,
				case when isnull(s.Family2Name2,'')+isnull(s.Email7,'')+isnull(s.Family2Phone2,'')>'' then isnull(s.Family2Name2,'-') else null end, '<br />')
		end	as Family2Parents,

		case when isnull(s.email6,'')='' and isnull(s.email7,'')='' then '' 
		else
			dbo.ConcatWithDelimiter(
				case when isnull(s.Family2Name1,'')+isnull(s.Email6,'')+isnull(s.Family2Phone1,'')>'' then isnull(s.Email6,'-') else null end,
				case when isnull(s.Family2Name2,'')+isnull(s.Email7,'')+isnull(s.Family2Phone2,'')>'' then isnull(s.Email7,'-') else null end, '<br />')
		end	as Family2Emails,

		case when isnull(s.Family2Phone1,'')='' and isnull(s.Family2Phone2,'')='' then '' 
		else
			dbo.ConcatWithDelimiter(
				case when isnull(s.Family2Name1,'')+isnull(s.Email6,'')+isnull(s.Family2Phone1,'')>'' then isnull(s.Family2Phone1,'-') else null end,
				case when isnull(s.Family2Name2,'')+isnull(s.Email7,'')+isnull(s.Family2Phone2,'')>'' then isnull(s.Family2Phone2,'-') else null end, '<br />')
		end	as Family2Phones,

	    smf.SchoolDistrict,
	    smf.FormerSchool,
		smf.campus,
		smf.nationality,
		smf.FinAid,

		case when s.isHispanicLatino=1 
		then 'Hispanic/Latino'
		else 
			case when (
				select count(*) 
				from StudentRace sr
				inner join race r
				on r.RaceID = sr.RaceID
				and sr.StudentID = s.StudentID)>1
			then 'Two or more races'
			else
				isnull((select 
					r.FederalRaceMapping 
				from StudentRace sr
				inner join race r
					on r.RaceID = sr.RaceID
					and sr.StudentID = s.StudentID
					and isnull(r.FederalRaceMapping,'')>''),'(undefined)')
			END
		END FederalRaceAndEthnicity,
		s.WISEid, s.Degree, s.Major

FROM 
Students s
--	inner join
--vStudents vs
--	on s.StudentID = vs.StudentID	

LEFT JOIN dbo.Accounts ON s.AccountID = dbo.Accounts.AccountID

----------------------------------------------------------------
/*
** The following code block matches code in StudentRoster.  The code was copied rather
** rather than referenced there for performance reasons.  Whenever code is changed here
** is must be changed in the StudentRoster view too.
*/

--
-- 1/28/16 - Corrections related to Fresh Desk 16275:
-- Note: It appears that a bug was introduced with changeset 6806 on 7/8/15
--       to fix Fresh Desk 3039 where we lost the ability to detect re-enroll vs not re-enroll
--       status for enrollme schools upon a reenrollment form submission.  This feature was
--       broken and only worked if and when the form was imported...
--
LEFT JOIN (
	-- This is just used to pull promote flag only if re-enroll form present or new form mapped as reenroll,
	-- top 1 was added since we could have both scenarios present... (Fresh Desk #7576)
	-- NOTE: "top 1" fix for Fresh Desk 7576 reversed since it causes Not-Reenrolled report to fail, 
	--       i.e., see Fresh Desk #s 15985, 16046, ...  will need to find another solution if the 
	--       import scenario like #7576 presents itself again!!!
				SELECT /*top 1*/ case when es.ImportStudentID is not null
							then es.ImportStudentID
							else es.StudentID end relatedStudentID, 
						min(es.StudentID) StudentID, 
						max(cast(isnull(efs.PromoteReenrollsToActive,0) as int)) as PromoteReenrollsToActive
					FROM EnrollmentStudent es
					INNER JOIN EnrollmentFormSettings efs 
					on efs.SessionID = es.SessionID
					--
					WHERE (FormStatus IN ('Submitted', 'Pending', 'Approved', 'In-Process') 
							and isnull(efs.PromoteReenrollsToActive,0) = 0)
						or es.StudentID>1000000000
					GROUP BY case when es.ImportStudentID is not null
								then es.ImportStudentID
								else es.StudentID end
) x on x.relatedStudentID = s.StudentID

LEFT JOIN StudentMiscFields smf ON s.StudentID = smf.StudentID
) z
union 
--
-- I think the following new/dummy row is needed but I'm not sure why.
-- I'd think that we only 'add' from vStudents/Students view/table, but
-- perhaps we use this StudentRoster view in some places, like EnrollMe or ????
-- 1/25/2016 - Researching....
--
select null as GradeLev, 
	-- '' as GradeAndStatus,
	'' as Address1,
	'' as Address2,
	'' as AddressDescriptions,
	-- '' as xStudentIdAndAccountId,
	null as Access, 
	null as EncKey, 
	null as MissedPasswords,
	'English' as LanguageType, 
	null as LastLoginTime,
	isnull(dbo.MaxNumericStudentAndAccountID(),1000)+1 as xStudentID,
	-1 as StudentID,
	null as FamilyID,
	1 as Active, '' as Lname, null as Mname, '' as Fname, '' as Suffix,
	null as GradeLevX, '' as GradeLevel, '' as Classes,
    null as Father, null as Mother, null as Family2Name1, null as Family2Name2,
	null as Phone1, null as Phone2, null as Phone3, null as Family2Phone1, null as Family2Phone2, 
	null as Email1,null as Email2, null as Email3, null as Email4,
	null as Email5,null as Email6, null as Email7, null as Email8,
	'' as BithDate, null as Sex, null as Ethnicity, 
	'' as SexAndEthnicity,
	'' as CampusAndNationality,
	null as AddressDescription, null as AddressName,
	null as Street, null as City, null as State, null as Zip,
	'' as CityStateZip1,
	null as AddressDescription2, null as AddressName2,
	null as Street2, null as City2, null as State2, null as Zip2,
	'' as CityStateZip2,
	'' as EntryDate, '' as WithdrawalDate, '' as GraduationDate,
	null as Comments, null as LockerNumber, null as LockerCode, 
	cast(dbo.MaxNumericStudentAndAccountID()+1 as nvarchar(20)) as AccountID,
	null as FullName,null as NumDisciplineLogRecs, null as numMedicalLogRecs,
	'Active' as ActiveOrInactive, ''/*excluded from not-reenrolled*/ as _Status, null as Num_Donations, 
	null as Total_Donated, null as Last_Donation_Date, null as Affiliations, 
	null as AffiliationsHTML, null as Status, 
	'' as Parents, '' as Emails, '' as Phones,
	'' as Family2Parents, '' as Family2Emails, '' as Family2Phones,
	'' SchoolDistrict,
	'' FormerSchool,
	null Campus,
	null Nationality,
	null FinAid,
	null FederalRaceAndEthnicity,
	null WISEid,
	null Degree,
	null Major
GO
