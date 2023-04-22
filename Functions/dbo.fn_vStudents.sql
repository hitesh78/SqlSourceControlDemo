SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- =============================================
-- Author:		Joey
-- Create date: 9/30/2021
-- Description:	moved vStudents into a function
-- Modify by Freddy on 05/11/2022
-- =============================================
CREATE   FUNCTION [dbo].[fn_vStudents]()
RETURNS 
@Students TABLE
(
	GradeLev nvarchar(20),
	Access nvarchar(10),
	EncKey decimal(15,15),
	MissedPasswords	tinyint,
	LanguageType nvarchar(30),
	LastLoginTime nvarchar(30),	
	xStudentID bigint,
	StudentID int,
	FamilyID int,
	Family2ID int,
	FamilyOrTempID int,
	Active bit,
	Lname nvarchar(30),	
	Mname nvarchar(30),
	Fname nvarchar(30),
	Suffix nvarchar(100),
	Nickname nvarchar(16),
	GradeLevX nvarchar(20),
	GradeLevel nvarchar(20),
	Class nchar(1),
	Father nvarchar(50),
	Mother nvarchar(50),
	Phone1 nvarchar(100),
	Phone2 nvarchar(100),
	Phone3 nvarchar(100),	
	Phone1OptIn bit,
	Phone2OptIn bit,
	Phone3OptIn bit,
	Family2Phone1OptIn bit,
	Family2Phone2OptIn bit,
	Email1 nvarchar(70),
	Email2 nvarchar(70),
	Email3 nvarchar(70),
	Email4 nvarchar(70),
	Email5 nvarchar(70),
	Email6 nvarchar(70),
	Email7 nvarchar(70),
	Email8 nvarchar(70),
	SchoolEmail nvarchar(100),
	Family2Name1 nvarchar(50),
	Family2Name2 nvarchar(50),
	Family2Phone1 nvarchar(100),
	Family2Phone2 nvarchar(100),
	StudentLivesWithFather bit,
	StudentLivesWithMother bit,
	StudentLivesWithStepfather bit,
	StudentLivesWithStepmother bit,
	StudentLivesWithGuardian1 bit,
	StudentLivesWithGuardian2 bit,
	StudentLivesWithOther bit,
	StudentLivesWithDesc nvarchar(30),
	Divorced nvarchar(3),
	Custody nvarchar(20),
	BirthDate smalldatetime,
	Sex nvarchar(12),
	AddressDescription nvarchar(100),
	AddressName nvarchar(100),
	Street nvarchar(100),
	City nvarchar(50),
	[State] nvarchar(50),
	Zip nvarchar(50),
	CountryRegion nvarchar(100),
	CityStateZip1 nvarchar(1000),
	AddressDescription2 nvarchar(100),
	AddressName2 nvarchar(100),
	Street2 nvarchar(100),
	City2 nvarchar(50),
	State2 nvarchar(50),
	Zip2 nvarchar(50),
	CountryRegion2 nvarchar(100),
	CityStateZip2 nvarchar(1000),
	EntryDate smalldatetime,
	WithdrawalDate smalldatetime,
	GraduationDate smalldatetime,
	Comments nvarchar(max),	
	Comments2 nvarchar(max),
	Comments3 nvarchar(max),
	LockerNumber nvarchar(20),
	LockerCode nvarchar(20),
	AccountID nvarchar(50),
	FullName nvarchar(186), 
	ActiveOrInactive nvarchar(20),
	_Status nvarchar(20),
	Affiliations nvarchar(max),
	[Status] nvarchar(50),
	Parents nvarchar(1000),
	Emails nvarchar(1000),
	Phones nvarchar(1000),
	isHispanicLatino bit,
	isCatholic bit,
	isTitle1Eligible bit,
	isTitle1Receiving bit,
	isNSLPBreakfast bit,
	isLunchEligible bit,
	isNSLPLunch bit,
	isSubsidizedTrans bit,
	isPromoteToCatholicHS bit,
	isSpecialEdReceiving bit,
	isDiagnosedDisability bit,
	isInternational bit,
	isChoiceProgram bit,
	Degree nvarchar(50),
	Major nvarchar(50),
	WithdrawReason nvarchar(50),
	EnableStudentLockerInfo	int,
	EnableHispanicEthnicityQuestion bit,
	isCatholicSchool bit,
	isADLACensus bit,
	showSISlabels bit,
	AdultSchool bit,
	GeneralizeGuardianLabels bit,
	EnableDegreeAndMajor bit,
	SchoolState nvarchar(100),
	ShowEthnicityRace bit,
	WISEid nvarchar(10),
	CountyName nvarchar(50),
	CountyName2 nvarchar(50),	
	GradeLevWI nvarchar(1000),
	Full_Name nvarchar(1000)
)
AS
BEGIN


Declare @RelatedStudent TABLE (relatedStudentID int, StudentID int, PromoteReenrollsToActive bit)
Insert into @RelatedStudent
SELECT 
	case 
		when es.ImportStudentID is not null
		then es.ImportStudentID
		else es.StudentID 
	end relatedStudentID, 
	min(es.StudentID) StudentID, 
	max(cast(isnull(efs.PromoteReenrollsToActive,0) as int)) as PromoteReenrollsToActive
FROM EnrollmentStudent es
	INNER JOIN EnrollmentFormSettings efs 
		on efs.SessionID = es.SessionID
WHERE (
	FormStatus IN ('Submitted', 'Pending', 'Approved', 'In-Process') 
	and isnull(efs.PromoteReenrollsToActive,0) = 0
	) or es.StudentID > 1000000000
GROUP BY case when es.ImportStudentID is not null
	then es.ImportStudentID else es.StudentID end


Declare @WISEdataSnapshotPeriod nvarchar(20) = (select WISEdataSnapshotPeriod from Settings where SettingID = 1);
Declare @SnapshotPeriodDate date = cast(right(@WISEdataSnapshotPeriod, 4)+'-06-30' as date);


Declare @WISE_CHOICE_RECS TABLE (StudentID int, WISEDataResourcesCount int) 
Insert into @WISE_CHOICE_RECS
SELECT StudentID, 
	COUNT(distinct ResourceType) as WISEDataResourcesCount 
FROM AuditWISEdata
WHERE AuditWISEdata.SnapshotPeriod = @WISEdataSnapshotPeriod
GROUP BY StudentID;

Insert into @Students
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
								and entrydate > @SnapshotPeriodDate
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
							and entrydate > @SnapshotPeriodDate
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
                dbo.Accounts.LastLoginTime, s.xStudentID, s.StudentID, s.FamilyID,s.Family2ID,
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
                s.AddressDescription, 
				case rtrim(ltrim(isnull(AddressName,'')))
					when '' then sa.AddressTitle
					else s.AddressName
				end as AddressName, 
				s.Street, s.City, s.State, s.Zip, s.CountryRegion,
                dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(s.City, s.State, ', '), s.Zip, ' ') AS CityStateZip1, 
                s.AddressDescription2,
				case rtrim(ltrim(isnull(AddressName2,'')))
					when '' then sa.AddressTitle
					else s.AddressName2
				end as AddressName2, 
				s.Street2, s.City2, s.State2, s.Zip2, s.CountryRegion2,
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
				s.isLunchEligible,
				s.isNSLPlunch,
				s.isSubsidizedTrans,
				s.isPromoteToCatholicHS,
				s.isSpecialEdReceiving,
				s.isDiagnosedDisability,
				s.isInternational,
				s.isChoiceProgram,
				s.Degree, s.Major,
				s.WithdrawReason as WithdrawReason,

				-- Locker and hispanic question not supported for Adult schools (not used, and allows space for Degree & Major)...
				case when sett.AdultSchool=0 and sett.EnableStudentLockerInfo=1 then 1 else 0 end EnableStudentLockerInfo,
				case when Sett.ShowEthnicityRace=1 and sett.AdultSchool=0 and sett.EnableHispanicEthnicityQuestion=1 then 1 else 0 end EnableHispanicEthnicityQuestion,				
				case when sett.SchoolType='catholic' then 1 else 0 end as isCatholicSchool,
				case 
					when sett.SchoolType='ADLACensusOnly' then 1 
					when sett.SchoolType='catholic' then 1
					else 0 
				end as isADLACensus, -- This is for NCEA survey
				case when Sett.ShowEthnicityRace=0 or Sett.EnableHispanicEthnicityQuestion=0 or sett.AdultSchool=1 -- note: locker/hispanic N/A for adult schools...
					or Sett.EnableStudentLockerInfo=0 then 1 else 0 end as showSISlabels,

				Sett.AdultSchool,
				Sett.GeneralizeGuardianLabels,
				Sett.EnableDegreeAndMajor,
				Sett.SchoolState,
				Sett.ShowEthnicityRace,
				s.WISEid,
				s.CountyName,
				s.CountyName2

			FROM 
			dbo.Students s
				inner join
			dbo.getStudentAddressTitle() sa
				on s.StudentID = Sa.StudentID	 
				LEFT JOIN 
			dbo.Accounts 
				ON s.AccountID = dbo.Accounts.AccountID

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
			LEFT JOIN @RelatedStudent x 
				on x.relatedStudentID = s.StudentID
----------------------------------------------------------------

			CROSS JOIN Settings sett
			) z
			LEFT JOIN @WISE_CHOICE_RECS w
				on z.StudentID = w.StudentID
UNION
SELECT		NULL AS GradeLev, NULL AS Access, 
			NULL AS EncKey, NULL AS MissedPasswords, 'English' AS LanguageType, NULL
                AS LastLoginTime, isnull(dbo.MaxNumericStudentAndAccountID(), 1000) + 1 AS xStudentID, 
                - 1 AS StudentID, NULL AS FamilyID,NULL AS Family2ID, NULL as FamilyOrTempID, 1 AS Active, '' AS Lname, NULL 
                AS Mname, '' AS Fname, NULL AS suffix, NULL AS Nickname,
				NULL AS GradeLevX, '' AS GradeLevel, '' AS Classes, 
                NULL AS Father, NULL AS Mother, NULL AS Phone1, NULL AS Phone2, NULL 
                AS Phone3,
				NULL AS Phone1OptIn,NULL AS Phone2OptIn,NULL AS Phone3OptIn,NULL AS Family2Phone1OptIn,NULL AS Family2Phone2OptIn,
				NULL AS Email1, NULL AS Email2, NULL AS Email3,NULL AS Email4,NULL AS Email5, NULL AS Email6, NULL AS Email7,NULL AS Email8, NULL as SchoolEmail,
				NULL AS Family2Name1,	NULL AS Family2Name2,NULL AS Family2Phone1,NULL AS Family2Phone2,
				NULL AS StudentLivesWithFather,NULL AS StudentLivesWithMother,NULL AS StudentLivesWithStepfather,
				NULL AS StudentLivesWithStepmother,NULL AS StudentLivesWithGuardian1,NULL AS StudentLivesWithGuardian2,
				NULL AS StudentLivesWithOther,NULL AS StudentLivesWithDesc,NULL AS Divorced,NULL AS Custody,
				NULL AS BithDate, 
                NULL AS Sex, NULL AS AddressDescription, NULL AS AddressName, NULL AS Street, NULL AS City, 
				NULL as CountryRegion,
                NULL AS State, NULL AS Zip, '' AS CityStateZip1, NULL AS AddressDescription2, NULL 
                AS AddressName2, NULL AS Street2, NULL AS City2, NULL AS State2, NULL AS Zip2, 
				NULL as CountryRegion2,
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
				null as isLunchEligible,
				null as isNSLPlunch,
				null as isSubsidizedTrans,
				null as isPromoteToCatholicHS,
				null as isSpecialEdReceiving,
				null as isDiagnosedDisability,
				null as isInternational,
				null as isChoiceProgram,
				null as Degree, null as Major,
				null as WithdrawReason,
				-- Locker and hispanic question not supported for Adult schools (not used, and allows space for Degree & Major)...
				case when sett.AdultSchool=0 and sett.EnableStudentLockerInfo=1 then 1 else 0 end EnableStudentLockerInfo,
				case when Sett.ShowEthnicityRace=1 and sett.AdultSchool=0 and sett.EnableHispanicEthnicityQuestion=1 then 1 else 0 end EnableHispanicEthnicityQuestion,
				case when sett.SchoolType='catholic' then 1 else 0 end as isCatholicSchool,
				case 
					when sett.SchoolType='ADLACensusOnly' then 1 
					when sett.SchoolType='catholic' then 1
					else 0 
				end as isADLACensus, -- This is for NCEA survey
				case when Sett.ShowEthnicityRace=0 or Sett.EnableHispanicEthnicityQuestion=0 or sett.AdultSchool=1 -- note: locker/hispanic N/A for adult schools...
					or Sett.EnableStudentLockerInfo=0 then 1 else 0 end as showSISlabels,
				Sett.AdultSchool,
				Sett.GeneralizeGuardianLabels,
				Sett.EnableDegreeAndMajor,
				Sett.SchoolState,
				Sett.ShowEthnicityRace,
				null as WISEid,
				null as CountyName,
				null as CountyName2,
				null as GradeLevWI,
				NULL AS Full_Name
FROM Settings sett


	RETURN

END
GO
