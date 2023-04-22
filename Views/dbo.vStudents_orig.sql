SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   VIEW [dbo].[vStudents_orig]
AS

WITH WISE_CHOICE_RECS(StudentID,WISEDataResourcesCount) AS (
	SELECT StudentID, 
		COUNT(distinct ResourceType) as WISEDataResourcesCount 
	FROM AuditWISEdata
	WHERE AuditWISEdata.SnapshotPeriod = (select WISEdataSnapshotPeriod from settings)
	GROUP BY StudentID
)
SELECT     CASE WHEN z._Status not in ('Inactive','Alumnus') 
				THEN GradeLevX ELSE z._Status 
				END AS GradeLev, 
				z.*,
				
				CASE WHEN SchoolState='Wisconsin' 
					and (' '+Affiliations+';' like '% Choice;%' /*or WISEid is not null*/)
					THEN
						CASE 
						WHEN 						
								-- Don't color code Choice unless student was present 
								-- for snapshot year based on entry date (if available)...
								EntryDate is not null 
								and entrydate > cast(right((select WISEdataSnapshotPeriod from settings),4)+'-06-30' as date)
								THEN
							GradeLevX+'<br/>Choice'
						WHEN isnull(w.WISEDataResourcesCount,0)>=3 THEN
							GradeLevX+'<br/><span class="ChoiceDONE">Choice</span>'
						ELSE
							GradeLevX+'<br/><span class="ChoicePEND">Choice *</span>'
						END
					ELSE
						CASE WHEN z._Status not in ('Inactive','Alumnus') 
							THEN GradeLevX ELSE z._Status END 
						+ CASE WHEN SchoolState='Wisconsin' 
							THEN '<br/>&nbsp;' ELSE '' END
					END AS GradeLevWI,
				dbo.ConcatWithDelimiter(
	                FullName, 
					CASE 
					WHEN 						
							-- Don't color code Choice unless student was present 
							-- for snapshot year based on entry date (if available)...
							EntryDate is not null 
							and entrydate > cast(right((select WISEdataSnapshotPeriod from settings),4)+'-06-30' as date)
							THEN
						'<span style="float: right; margin-right: 5px; font-size: 10px;">Wise ID '+WISEid+'</span>'
					WHEN isnull(w.WISEDataResourcesCount,0)>=3 THEN
						'<span class="ChoiceDONE" style="float: right; margin-right: 5px; font-size: 10px;">Wise ID '+WISEid+'</span>'
					ELSE
						'<span class="ChoicePEND" style="float: right; margin-right: 5px; font-size: 10px;">Wise ID '+WISEid+'</span>'
					END
					, '<br/>') AS Full_Name
FROM         (SELECT     TOP (100) PERCENT dbo.Accounts.Access, dbo.Accounts.EncKey, dbo.Accounts.MissedPasswords, 
				dbo.Accounts.LanguageType, 
                dbo.Accounts.LastLoginTime, s.xStudentID, s.StudentID, s.FamilyID, s.Family2ID,
                case when FamilyID is null then -s.StudentID else FamilyID end as FamilyOrTempID, 
                s.Active, s.Lname, s.Mname, s.Fname, s.suffix, s.Nickname,
                CASE WHEN GradeLevel = 'K' THEN ' ' WHEN GradeLevel = 'K' OR
					GradeLevel = 'PS' THEN ' ' ELSE '&nbsp;' + replicate(' ', 2 - LEN(RTRIM(GradeLevel))) 
                    END + s.GradeLevel + CASE WHEN s.Class > ' ' THEN '-' ELSE '' END + RTRIM(s.Class) AS GradeLevX, 
                s.GradeLevel, s.Class, s.Father, s.Mother, 
                s.Phone1, s.Phone2, s.Phone3,
				s.Phone1OptIn,s.Phone2OptIn,s.Phone3OptIn,s.Family2Phone1OptIn,s.Family2Phone2OptIn,
				s.Email1, s.Email2, s.Email3,s.Email4, s.Email5, s.Email6,s.Email7, s.Email8, s.SchoolEmail,
				Family2Name1,Family2Name2,Family2Phone1,Family2Phone2,
				StudentLivesWithFather,	StudentLivesWithMother,StudentLivesWithStepfather,
				StudentLivesWithStepmother,StudentLivesWithGuardian1,	StudentLivesWithGuardian2,
				StudentLivesWithOther,	StudentLivesWithDesc,Divorced,Custody,
				s.BirthDate, s.Sex, 
                s.AddressDescription, s.AddressName, s.Street, s.City, s.State, s.Zip, 
                dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(s.City, s.State, ', '), s.Zip, ' ') AS CityStateZip1, 
                s.AddressDescription2, s.AddressName2, s.Street2, s.City2, s.State2, s.Zip2, 
                dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(s.City2, s.State2, ', '), s.Zip2, ' ') AS CityStateZip2, 
                s.EntryDate, s.WithdrawalDate, s.GraduationDate, 
                s.Comments, s.Comments2, s.Comments3, s.LockerNumber, s.LockerCode, s.AccountID, 
				s.glname AS FullName, 

				CASE WHEN Active = 1 THEN 'Active' ELSE 'Inactive' END AS ActiveOrInactive, 

----------------------------------------------------------------
				/*
				** The following code block matches code in StudentRoster.  The code was copied rather
				** rather than referenced there for performance reasons.  Whenever code is changed here
				** is must be changed in the StudentRoster view too.
				*/
				CASE WHEN Active = 1 AND sett.OnlineEnrollment = 1 -- active, enrollme schools cases only...
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
							Active = (CASE WHEN s.Status IN ('Active', 'Reenrollment') THEN 1 ELSE 0 END) 
						THEN isnull(s.Status, 
							CASE WHEN Active = 1 THEN 'Active' ELSE 'Inactive' END) 
						ELSE 
							CASE WHEN Active = 1 THEN 'Active' ELSE 'Inactive' END 
					END 
				END AS _Status, 
----------------------------------------------------------------

				s.Affiliations, s.Status,  dbo.ConcatWithDelimiter(s.Father, s.Mother, '<br />') 
                AS Parents, dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(s.Email1, s.Email2, '<br />'), s.Email3, '<br />') AS Emails, 
                dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(s.Phone1, s.Phone2, '<br />'), s.Phone3, '<br />') 
                AS Phones,
				s.isHispanicLatino,
				s.isCatholic,
				s.isTitle1eligible,
				s.isTitle1receiving,
				s.isNSLPbreakfast,
				s.isNSLPlunch,
				s.isSubsidizedTrans,
				s.isPromoteToCatholicHS,
				s.isSpecialEdReceiving,
				s.Degree, s.Major,

				-- Locker and hispanic question not supported for Adult schools (not used, and allows space for Degree & Major)...
				case when sett.AdultSchool=0 and sett.EnableStudentLockerInfo=1 then 1 else 0 end EnableStudentLockerInfo,
				case when Sett.ShowEthnicityRace=1 and sett.AdultSchool=0 and sett.EnableHispanicEthnicityQuestion=1 then 1 else 0 end EnableHispanicEthnicityQuestion,
				
				case when sett.SchoolType='catholic' then 1 else 0 end as isCatholicSchool,

				case when Sett.ShowEthnicityRace=0 or Sett.EnableHispanicEthnicityQuestion=0 or sett.AdultSchool=1 -- note: locker/hispanic N/A for adult schools...
					or Sett.EnableStudentLockerInfo=0 then 1 else 0 end as showSISlabels,

				Sett.AdultSchool,
				Sett.GeneralizeGuardianLabels,
				Sett.EnableDegreeAndMajor,
				Sett.SchoolState,
				Sett.ShowEthnicityRace,
				s.WISEid
			FROM dbo.Students s 
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
/* was prior to 1/28//16:						
				SELECT es.ImportStudentID, min(es.StudentID) StudentID, 
						max(cast(isnull(efs.PromoteReenrollsToActive,0) as int)) as PromoteReenrollsToActive
					FROM EnrollmentStudent es
					INNER JOIN EnrollmentFormSettings efs 
					on efs.SessionID = es.SessionID
   now: */
				SELECT case when es.ImportStudentID is not null
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
/* was prior to 1/28//16:						
					GROUP BY es.ImportStudentID
   now: */
					GROUP BY case when es.ImportStudentID is not null
								then es.ImportStudentID
								else es.StudentID end
			) 
/* was prior to 1/28//16:						
			   x ON x.StudentID = s.StudentID or x.ImportStudentID = s.StudentID
   now: */
			   x on x.relatedStudentID = s.StudentID
----------------------------------------------------------------

			CROSS JOIN Settings sett
			) z
			LEFT JOIN WISE_CHOICE_RECS w
				on z.StudentID = w.StudentID
UNION
SELECT		NULL AS GradeLev, NULL AS Access, 
			NULL AS EncKey, NULL AS MissedPasswords, 'English' AS LanguageType, NULL
                AS LastLoginTime, isnull(dbo.MaxNumericStudentAndAccountID(), 1000) + 1 AS xStudentID, 
                - 1 AS StudentID, NULL AS FamilyID, NULL as Family2ID, NULL as FamilyOrTempID, 1 AS Active, '' AS Lname, NULL 
                AS Mname, '' AS Fname, NULL AS suffix, NULL AS Nickname,
				NULL AS GradeLevX, '' AS GradeLevel, '' AS Classes, 
                NULL AS Father, NULL AS Mother, NULL AS Phone1, NULL AS Phone2, NULL 
                AS Phone3,
				NULL AS Phone1OptIn,NULL AS Phone2OptIn,NULL AS Phone3OptIn,NULL AS Family2Phone1OptIn,NULL AS Family2Phone2OptIn,
				NULL AS Email1, NULL AS Email2, NULL AS Email3,NULL AS Email4,NULL AS Email5, NULL AS Email6, NULL AS Email7,NULL AS Email8,NULL AS SchoolEmail,
				NULL AS Family2Name1,	NULL AS Family2Name2,NULL AS Family2Phone1,NULL AS Family2Phone2,
				NULL AS StudentLivesWithFather,NULL AS StudentLivesWithMother,NULL AS StudentLivesWithStepfather,
				NULL AS StudentLivesWithStepmother,NULL AS StudentLivesWithGuardian1,NULL AS StudentLivesWithGuardian2,
				NULL AS StudentLivesWithOther,NULL AS StudentLivesWithDesc,NULL AS Divorced,NULL AS Custody,
				NULL AS BithDate, 
                NULL AS Sex, NULL AS AddressDescription, NULL AS AddressName, NULL AS Street, NULL AS City, 
                NULL AS State, NULL AS Zip, '' AS CityStateZip1, NULL AS AddressDescription2, NULL 
                AS AddressName2, NULL AS Street2, NULL AS City2, NULL AS State2, NULL AS Zip2, 
                '' AS CityStateZip2, NULL AS EntryDate, NULL AS WithdrawalDate, NULL 
                AS GraduationDate, NULL AS Comments, NULL as Comments2, NULL as Comments3,
                NULL AS LockerNumber, NULL AS LockerCode, 
                cast(dbo.MaxNumericStudentAndAccountID() + 1 AS varchar(20)) 
                AS AccountID, NULL AS FullName, 'Active' AS ActiveOrInactive, 
                'Active' AS _Status, NULL AS Affiliations, NULL AS Status, 
                '' AS Parents, '' AS Emails, '' AS Phones,
				null as isHispanicLatino,
				null as isCatholic,
				null as isTitle1eligible,
				null as isTitle1receiving,
				null as isNSLPbreakfast,
				null as isNSLPlunch,
				null as isSubsidizedTrans,
				null as isPromoteToCatholicHS,
				null as isSpecialEdReceiving,
				null as Degree, null as Major,

				-- Locker and hispanic question not supported for Adult schools (not used, and allows space for Degree & Major)...
				case when sett.AdultSchool=0 and sett.EnableStudentLockerInfo=1 then 1 else 0 end EnableStudentLockerInfo,
				case when Sett.ShowEthnicityRace=1 and sett.AdultSchool=0 and sett.EnableHispanicEthnicityQuestion=1 then 1 else 0 end EnableHispanicEthnicityQuestion,

				case when sett.SchoolType='catholic' then 1 else 0 end as isCatholicSchool,
				case when Sett.ShowEthnicityRace=0 or Sett.EnableHispanicEthnicityQuestion=0 or sett.AdultSchool=1 -- note: locker/hispanic N/A for adult schools...
					or Sett.EnableStudentLockerInfo=0 then 1 else 0 end as showSISlabels,
				Sett.AdultSchool,
				Sett.GeneralizeGuardianLabels,
				Sett.EnableDegreeAndMajor,
				Sett.SchoolState,
				Sett.ShowEthnicityRace,
				null as WISEid,
				null as GradeLevWI,
				NULL AS Full_Name
FROM Settings sett


GO
