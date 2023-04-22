SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   VIEW [dbo].[EnrollmentStudentDefaults] as

select 

es.EnrollmentStudentID,es.ProcessingNotes,
case when es.StudentID>999999999 /*or isnull(s.Active,0)=0 */
then 'New Enrollment' else 'Reenrollment' end as FormType,

es.ManualReenrollStudentID as ManualReenrollStudentID,
es.ManualNewStudentLname as ManualNewStudentLname,
es.ManualNewStudentFname as ManualNewStudentFname,

es.ImportFamilyID, 

-- Only present ImportStudentID if ID actually joins with a Students row
(select StudentID from Students where StudentID = es.ImportStudentID) as ImportStudentID,

-- Dynamically hide/show pages based on program id and carrying forward other parameters...
-- TODO: May need to cover more pages and make session sensitive (???)...
REPLACE(
	REPLACE(
	   REPLACE(

	   case when es.StudentID>999999999 /*or isnull(s.Active,0)=0 */ then
		   (Select New_Enroll_Fields_To_Incl from EnrollmentFormSettings)
		else 
		  (Select Configurable_Fields_To_Incl from EnrollmentFormSettings)
		end +';',  
	   case when (
		   select 1 from OnlineFormPages ofp
			left join GradeLevelOptions glo on es.GradeLevelOptionID = glo.GradeLevelOptionID
			  where ofp.FormName='Enroll' and ofp.WizardPage='Info' and ofp.ShowOrHidePage='Hide'
				and (ofp.EnrollmentProgramID is null or ofp.EnrollmentProgramID = es.EnrollmentProgramID)

				and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
				CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
					>= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
				and ( ofp.GradeLevelThru is null or
				CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
					<= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
				and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )

				and (ofp.FormType is null or case when es.StudentID>999999999 
					then 'New Enrollment' else 'Reenrollment' end = ofp.FormType)
	   )=1 
	   then 'Page-Info;' else '' end, '') 
	,
	case when (
	   select 1 from OnlineFormPages ofp
		left join GradeLevelOptions glo on es.GradeLevelOptionID = glo.GradeLevelOptionID
		  where ofp.FormName='Enroll' and ofp.WizardPage='Info2' and ofp.ShowOrHidePage='Hide'
			and (ofp.EnrollmentProgramID is null or ofp.EnrollmentProgramID = es.EnrollmentProgramID)

			and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
			CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
				>= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
			and ( ofp.GradeLevelThru is null or
			CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
				<= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
			and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )

			and (ofp.FormType is null or case when es.StudentID>999999999 
			then 'New Enrollment' else 'Reenrollment' end = ofp.FormType)
	)=1 
	then 'Page-Info2;' else '' end, '') 
	,
	case when (
	   select 1 from OnlineFormPages ofp
		left join GradeLevelOptions glo on es.GradeLevelOptionID = glo.GradeLevelOptionID
		  where ofp.FormName='Enroll' and ofp.WizardPage='Tuition' and ofp.ShowOrHidePage='Hide'
			and (ofp.EnrollmentProgramID is null or ofp.EnrollmentProgramID = es.EnrollmentProgramID)

			and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
			CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
				>= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
			and ( ofp.GradeLevelThru is null or
			CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
				<= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
			and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )

			and (ofp.FormType is null or case when es.StudentID>999999999 
			then 'New Enrollment' else 'Reenrollment' end = ofp.FormType)
	)=1 
	then 'Page-Tuition;' else '' end, '') 
	as Hide_Show_CSS_Classes,
 
-- Change on 12/13/2013: (Duke)
-- Following code modifies StudentID to keep these unique among multiple years 
-- of re-enrollments for the same student.  Note that reenrollments store the actual
-- StudentID in the EnrollmentStudent file whereas new applicants get a temporary 
-- StudentID >= 1000000000.
-- The code below also adds an offset times 1000000000 to the StudentID but then
-- negates the entire value to avoid confusion with new enrollments with positive
-- StudentIDs >= 1000000000.  FOLLOWING EXPRESSION IS ALSO USED IN JOIN BELOW
--
isnull(
	case when es.StudentID>999999999 or es.SessionID 
		= (CurrentSession)		
	then es.StudentID
	else -(cast(es.SessionID as bigint) * 1000000000 + es.StudentID) end,
s.StudentID) as StudentID, 

es.SessionID,

es.FormName,
isnull(es.EnrollFamilyID,-s.FamilyID) as EnrollFamilyID, 

isnull(es.Fname,s.Fname) as Fname, 
isnull(es.Mname,s.Mname) as Mname, 
isnull(es.Lname,s.Lname) as Lname, 

isnull(es.Suffix, 
	case when es.Page_Student is not null 
	then null else ps.Suffix end) 
	as Suffix, 

isnull(es.AddressDescription,s.AddressDescription) as AddressDescription, 
isnull(es.AddressName,s.AddressName) as AddressName, 

isnull(es.AddressLine1, 
	case when es.Page_Student is not null 
	then null 
	else isnull(s.Street,isnull(sibling_es.AddressLine1,ps.AddressLine1)) end ) 
	as AddressLine1, 
isnull(es.AddressLine2, 
	case when es.Page_Student is not null 
	then null 
	else isnull(sibling_es.AddressLine2,ps.AddressLine2) end ) 
	as AddressLine2, 
isnull(es.City, 
	case when es.Page_Student is not null 
	then null 
	else isnull(s.City,isnull(sibling_es.City,ps.City)) end ) 
	as City, 
isnull(es.State, 
	case when es.Page_Student is not null 
	then null 
	else isnull(s.State,isnull(sibling_es.State,ps.State)) end ) 
	as State, 
isnull(es.Zip, 
	case when es.Page_Student is not null 
	then null 
	else isnull(s.Zip,isnull(sibling_es.Zip,ps.Zip)) end ) 
	as Zip, 
isnull(es.Country, -- Don't need to check Page_Student because we never want to have a blank country
	isnull(s.CountryRegion,
		isnull(sibling_es.Country,
			isnull(ps.Country,(select SchoolCountryRegion from settings)) ))) 
	as Country, 

isnull(
	isnull(es.StudentHomePhone, 
		case when (select AdultSchool from settings) = 1 then s.phone2 else s.phone3 end), 
	case when es.Page_Student is not null 
	then null else isnull(sibling_es.StudentHomePhone,ps.StudentHomePhone) end) 
	as StudentHomePhone, 

isnull(
	isnull(es.StudentCellPhone,
		case when (select AdultSchool from settings) = 1 then s.phone2 else s.phone3 end), 
	case when es.Page_Student is not null 
	then null else ps.StudentCellPhone end) 
		as StudentCellPhone, 

isnull(es.StudentWorkPhone, 
	case when es.Page_Student is not null 
	then null else ps.StudentWorkPhone end) 
		as StudentWorkPhone, 

isnull(
	isnull(es.StudentEmail,
		case when (select AdultSchool from settings) = 1 then s.email1 else s.email8 end), 
	case when es.Page_Student is not null 
	then null else ps.StudentEmail end) 
		as StudentEmail, 

isnull(es.StudentSSN, 
	case when es.Page_Student is not null 
	then null else ps.StudentSSN end) 
	as StudentSSN, 

 isnull(es.Nickname, s.Nickname) Nickname,
	

--isnull(es.Nickname, 
--	case when es.Page_Student is not null 
--	then null else ps.Nickname end) 
--	as Nickname,

isnull(es.ReferralSource,
	case when es.Page_Student is not null 
	then null else sibling_es.ReferralSource end) 
	as ReferralSource,

isnull(isnull(es.BirthDate, s.BirthDate), 
	case when es.Page_Student is not null 
	then null else ps.BirthDate end) 
	as BirthDate, 
isnull(isnull(es.Sex,s.Sex), 
	case when es.Page_Student is not null 
	then null else ps.Sex end) 
	as Sex, 
/*
isnull(es.DeclineRaceAndEthnicity, 
	case when es.Page_Student is not null 
	then null else ps.DeclineRaceAndEthnicity end) 
	as
*/
	es.DeclineRaceAndEthnicity,

isnull(es.HispanicLatino, 
	case when es.Page_Student is not null 
	then null else ps.HispanicLatino end) 
	as HispanicLatino, 

isnull(es.HispanicOrLatino, 
	case when es.Page_Student is not null 
	then null else ps.HispanicOrLatino end) 
	as HispanicOrLatino, 

isnull(es.AmericanIndianOrAlaskaNative, 
	case when es.Page_Student is not null 
	then null else ps.AmericanIndianOrAlaskaNative end) 
	as AmericanIndianOrAlaskaNative, 

isnull(es.Asian, 
	case when es.Page_Student is not null 
	then null else ps.Asian end) 
	as Asian, 

isnull(es.BlackOrAfricanAmerican, 
	case when es.Page_Student is not null 
	then null else ps.BlackOrAfricanAmerican end) 
	as BlackOrAfricanAmerican, 

isnull(es.NativeHawaiianOrPacificIslander, 
	case when es.Page_Student is not null 
	then null else ps.NativeHawaiianOrPacificIslander end) 
	as NativeHawaiianOrPacificIslander, 

isnull(es.White, 
	case when es.Page_Student is not null 
	then null else ps.White end) 
	as White, 

isnull(es.Filipino, 
	case when es.Page_Student is not null 
	then null else ps.Filipino end) 
	as Filipino, 

isnull(es.MiddleEasternSemitic, 
	case when es.Page_Student is not null 
	then null else ps.MiddleEasternSemitic end) 
	as MiddleEasternSemitic, 
	
isnull(es.BirthCity, 
	case when es.Page_Student is not null 
	then null else ps.BirthCity end) 
	as BirthCity, 

isnull(es.BirthState, 
	case when es.Page_Student is not null 
	then null else ps.BirthState end) 
	as BirthState, 

isnull(es.BirthZip, 
	case when es.Page_Student is not null 
	then null else ps.BirthZip end) 
	as BirthZip, 

isnull(es.BirthCountry, 
	case when es.Page_Student is not null 
	then null else ps.BirthCountry end) 
	as BirthCountry, 

-- todo: make following aware if page has been previously saved...
isnull(es.StudentBaptized,ps.StudentBaptized) as StudentBaptized,

case when isnull(es.StudentBaptized,ps.StudentBaptized)='Yes' 
	then isnull(es.BaptismChurch,
			case when es.Page_Worship is not null 
				then null else ps.BaptismChurch end)
	else null end BaptismChurch,

------------------------------------------------------------------------------------------------
-- FATHER block - identical to MOTHER block except for replacement of 'father' with 'mother'...
------------------------------------------------------------------------------------------------

isnull(es.NoFather, case when es.Page_Father is not null then null else isnull(sibling_es.NoFather,ps.NoFather) end) as NoFather,

isnull(es.FatherFname,case when es.Page_Father is not null then null else 
	isnull( isnull(sibling_es.FatherFname,ps.FatherFname) ,
		(CASE WHEN 0 = CHARINDEX(' ', s.Father) 
			then  s.Father 
			ELSE SUBSTRING(s.Father, 1, CHARINDEX(' ', s.Father)) end)
		) end) as FatherFname, 

isnull(es.FatherMname,case when es.Page_Father is not null then null 
	else isnull(sibling_es.FatherMname,ps.FatherMName) end) as FatherMname, 

isnull(es.FatherLname,case when es.Page_Father is not null then null else 
	isnull( isnull(sibling_es.FatherLname,ps.FatherLname),
		ltrim(rtrim((CASE WHEN 0 = CHARINDEX(' ', s.Father) 
			then  '' 
			ELSE SUBSTRING(s.father, CHARINDEX(' ', s.father), LEN(s.father) ) end)))
		) end) as FatherLname, 
 
isnull(es.FatherSuffix,case when es.Page_Father is not null then null else isnull(sibling_es.FatherSuffix,ps.FatherSuffix) end) as FatherSuffix, 
isnull(es.FatherAddressDescription,

case when es.Page_Father is not null then null else sibling_es.FatherAddressDescription end) as FatherAddressDescription, 
isnull(es.FatherAddressName,case when es.Page_Father is not null then null else sibling_es.FatherAddressName end) as FatherAddressName, 

isnull(es.FatherAddressLine1,case when es.Page_Father is not null then null else isnull(sibling_es.FatherAddressLine1,ps.FatherAddressLine1) end) as FatherAddressLine1, 
isnull(es.FatherAddressLine2,case when es.Page_Father is not null then null else isnull(sibling_es.FatherAddressLine2,ps.FatherAddressLine2) end) as FatherAddressLine2, 
isnull(es.FatherCity,case when es.Page_Father is not null then null else isnull(sibling_es.FatherCity,ps.FatherCity) end) as FatherCity, 
isnull(es.FatherState,case when es.Page_Father is not null then null else isnull(sibling_es.FatherState,ps.FatherState) end) as FatherState, 
isnull(es.FatherZip,case when es.Page_Father is not null then null else isnull(sibling_es.FatherZip,ps.FatherZip) end) as FatherZip, 
isnull(es.FatherCountry,case when es.Page_Father is not null then null else isnull(sibling_es.FatherCountry,ps.FatherCountry) end) as FatherCountry, 
isnull(es.FatherOccupation,case when es.Page_Father is not null then null else isnull(sibling_es.FatherOccupation,ps.FatherOccupation) end) as FatherOccupation, 
isnull(es.FatherEmployer,case when es.Page_Father is not null then null else isnull(sibling_es.FatherEmployer,ps.FatherEmployer) end) as FatherEmployer, 
case when isnull(es.FatherEmployer,case when es.Page_Father is not null then null else isnull(sibling_es.FatherEmployer,ps.FatherEmployer) end) is null 
then '' else isnull(es.FatherEmployerAddr,case when es.Page_Father is not null then null else isnull(sibling_es.FatherEmployerAddr,ps.FatherEmployerAddr) end) end FatherEmployerAddr, 
isnull(es.FatherHomePhone,case when es.Page_Father is not null then null else isnull(sibling_es.FatherHomePhone,ps.FatherHomePhone) end) as FatherHomePhone, 
isnull(es.FatherCellPhone,case when es.Page_Father is not null then null else isnull(sibling_es.FatherCellPhone,ps.FatherCellPhone) end) as FatherCellPhone, 
isnull(es.FatherWorkPhone,case when es.Page_Father is not null then null else isnull(sibling_es.FatherWorkPhone,ps.FatherWorkPhone) end) as FatherWorkPhone, 
isnull(es.FatherWorkExtension,case when es.Page_Father is not null then null else isnull(sibling_es.FatherWorkExtension,ps.FatherWorkExtension) end) as FatherWorkExtension, 
isnull(es.FatherEmail,case when es.Page_Father is not null then null else isnull(sibling_es.FatherEmail,ps.FatherEmail) end) as FatherEmail,
isnull(es.FatherEducation,case when es.Page_Father is not null then null else isnull(sibling_es.FatherEducation,ps.FatherEducation) end) as FatherEducation,
isnull(es.FatherRoles,case when es.Page_Father is not null then null else isnull(sibling_es.FatherRoles,ps.FatherRoles) end) as FatherRoles,

isnull(es.FatherSSN,case when es.Page_Father is not null then null else isnull(sibling_es.FatherSSN,ps.FatherSSN) end) as FatherSSN,

------------------------------------------------------------------------------------------------
-- Mother block - identical to FATHER block except for replacement of 'Mother' with 'father'...
------------------------------------------------------------------------------------------------

isnull(es.NoMother, case when es.Page_Mother is not null then null else isnull(sibling_es.NoMother,ps.NoMother) end) as NoMother,

isnull(es.MotherFname,case when es.Page_Mother is not null then null else 
	isnull( isnull(sibling_es.MotherFname,ps.MotherFname) ,
		(CASE WHEN 0 = CHARINDEX(' ', s.Mother) 
			then  s.Mother 
			ELSE SUBSTRING(s.Mother, 1, CHARINDEX(' ', s.Mother)) end)
		) end) as MotherFname, 

isnull(es.MotherMname,case when es.Page_Mother is not null then null 
	else isnull(sibling_es.MotherMname,ps.MotherMName) end) as MotherMname, 

isnull(es.MotherLname,case when es.Page_Mother is not null then null else 
	isnull( isnull(sibling_es.MotherLname,ps.MotherLname),
		ltrim(rtrim((CASE WHEN 0 = CHARINDEX(' ', s.Mother) 
			then  '' 
			ELSE SUBSTRING(s.Mother, CHARINDEX(' ', s.Mother), LEN(s.Mother) ) end)))
		) end) as MotherLname, 
 
isnull(es.MotherSuffix,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherSuffix,ps.MotherSuffix) end) as MotherSuffix, 
isnull(es.MotherAddressDescription,

case when es.Page_Mother is not null then null else sibling_es.MotherAddressDescription end) as MotherAddressDescription, 
isnull(es.MotherAddressName,case when es.Page_Mother is not null then null else sibling_es.MotherAddressName end) as MotherAddressName, 

isnull(es.MotherAddressLine1,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherAddressLine1,ps.MotherAddressLine1) end) as MotherAddressLine1, 
isnull(es.MotherAddressLine2,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherAddressLine2,ps.MotherAddressLine2) end) as MotherAddressLine2, 
isnull(es.MotherCity,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherCity,ps.MotherCity) end) as MotherCity, 
isnull(es.MotherState,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherState,ps.MotherState) end) as MotherState, 
isnull(es.MotherZip,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherZip,ps.MotherZip) end) as MotherZip, 
isnull(es.MotherCountry,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherCountry,ps.MotherCountry) end) as MotherCountry, 
isnull(es.MotherOccupation,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherOccupation,ps.MotherOccupation) end) as MotherOccupation, 
isnull(es.MotherEmployer,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherEmployer,ps.MotherEmployer) end) as MotherEmployer, 
case when isnull(es.MotherEmployer,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherEmployer,ps.MotherEmployer) end) is null 
then '' else isnull(es.MotherEmployerAddr,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherEmployerAddr,ps.MotherEmployerAddr) end) end MotherEmployerAddr, 
isnull(es.MotherHomePhone,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherHomePhone,ps.MotherHomePhone) end) as MotherHomePhone, 
isnull(es.MotherCellPhone,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherCellPhone,ps.MotherCellPhone) end) as MotherCellPhone, 
isnull(es.MotherWorkPhone,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherWorkPhone,ps.MotherWorkPhone) end) as MotherWorkPhone, 
isnull(es.MotherWorkExtension,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherWorkExtension,ps.MotherWorkExtension) end) as MotherWorkExtension, 
isnull(es.MotherEmail,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherEmail,ps.MotherEmail) end) as MotherEmail,
isnull(es.MotherEducation,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherEducation,ps.MotherEducation) end) as MotherEducation,
isnull(es.MotherRoles,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherRoles,ps.MotherRoles) end) as MotherRoles,

isnull(es.MotherSSN,case when es.Page_Mother is not null then null else isnull(sibling_es.MotherSSN,ps.MotherSSN) end) as MotherSSN,


es.GradeLevelOptionID,
es.EnrollmentProgramID,
es.EnteringGradeLevel, 
es.Campus,

-----------------------------------------------------------------------------
-- Family page defauls...
-----------------------------------------------------------------------------

isnull(es.StudentLivesWithFather,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithFather,ps.StudentLivesWithFather) end) as StudentLivesWithFather,
isnull(es.StudentLivesWithMother,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithMother,ps.StudentLivesWithMother) end) as StudentLivesWithMother,
isnull(es.StudentLivesWithStepfather,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithStepfather,ps.StudentLivesWithStepfather) end) as StudentLivesWithStepfather,
isnull(es.StudentLivesWithStepmother,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithStepmother,ps.StudentLivesWithStepmother) end) as StudentLivesWithStepmother,
isnull(es.StudentLivesWithGuardian1,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithGuardian1,ps.StudentLivesWithGuardian1) end) as StudentLivesWithGuardian1,
isnull(es.StudentLivesWithGuardian2,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithGuardian2,ps.StudentLivesWithGuardian2) end) as StudentLivesWithGuardian2,
isnull(es.StudentLivesWithOther,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithOther,ps.StudentLivesWithOther) end) as StudentLivesWithOther,
isnull(es.StudentLivesWithDesc,case when es.Page_Family is not null then null else isnull(sibling_es.StudentLivesWithDesc,ps.StudentLivesWithDesc) end) as StudentLivesWithDesc,
isnull(es.Divorced,case when es.Page_Family is not null then null else isnull(sibling_es.Divorced,ps.Divorced) end) as Divorced,
isnull(es.Custody,case when es.Page_Family is not null then null else isnull(sibling_es.Custody,ps.Custody) end) as Custody,

case when es.Sibling1FName is not null  
	then es.Sibling1FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling1FName,ps.Sibling1FName) end end 
			as Sibling1FName,
case when es.Sibling1LName is not null  
	then es.Sibling1LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling1LName,ps.Sibling1LName) end end 
			as Sibling1LName,
case when es.Sibling1DOB is not null  
	then es.Sibling1DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling1DOB,ps.Sibling1DOB) end end
			as Sibling1DOB,
case when es.Sibling1Grade is not null  
	then es.Sibling1Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling1Grade end end
			as Sibling1Grade,
case when es.Sibling1School is not null  
	then es.Sibling1School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling1School,ps.Sibling1School) end end
			as Sibling1School,

case when es.Sibling2FName is not null  
	then es.Sibling2FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling2FName,ps.Sibling2FName) end end 
			as Sibling2FName,
case when es.Sibling2LName is not null  
	then es.Sibling2LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling2LName,ps.Sibling2LName) end end 
			as Sibling2LName,
case when es.Sibling2DOB is not null  
	then es.Sibling2DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling2DOB,ps.Sibling2DOB) end end
			as Sibling2DOB,
case when es.Sibling2Grade is not null  
	then es.Sibling2Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling2Grade end end
			as Sibling2Grade,
case when es.Sibling2School is not null  
	then es.Sibling2School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling2School,ps.Sibling2School) end end
			as Sibling2School,

case when es.Sibling3FName is not null  
	then es.Sibling3FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling3FName,ps.Sibling3FName) end end 
			as Sibling3FName,
case when es.Sibling3LName is not null  
	then es.Sibling3LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling3LName,ps.Sibling3LName) end end 
			as Sibling3LName,
case when es.Sibling3DOB is not null  
	then es.Sibling3DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling3DOB,ps.Sibling3DOB) end end
			as Sibling3DOB,
case when es.Sibling3Grade is not null  
	then es.Sibling3Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling3Grade end end
			as Sibling3Grade,
case when es.Sibling3School is not null  
	then es.Sibling3School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling3School,ps.Sibling3School) end end
			as Sibling3School,

case when es.Sibling4FName is not null  
	then es.Sibling4FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling4FName,ps.Sibling4FName) end end 
			as Sibling4FName,
case when es.Sibling4LName is not null  
	then es.Sibling4LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling4LName,ps.Sibling4LName) end end 
			as Sibling4LName,
case when es.Sibling4DOB is not null  
	then es.Sibling4DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling4DOB,ps.Sibling4DOB) end end
			as Sibling4DOB,
case when es.Sibling4Grade is not null  
	then es.Sibling4Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling4Grade end end 
			as Sibling4Grade,
case when es.Sibling4School is not null  
	then es.Sibling4School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling4School,ps.Sibling4School) end end
			as Sibling4School,

case when es.Sibling5FName is not null  
	then es.Sibling5FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling5FName,ps.Sibling5FName) end end 
			as Sibling5FName,
case when es.Sibling5LName is not null  
	then es.Sibling5LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling5LName,ps.Sibling5LName) end end 
			as Sibling5LName,
case when es.Sibling5DOB is not null  
	then es.Sibling5DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling5DOB,ps.Sibling5DOB) end end
			as Sibling5DOB,
case when es.Sibling5Grade is not null  
	then es.Sibling5Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling5Grade end end
			as Sibling5Grade,
case when es.Sibling5School is not null  
	then es.Sibling5School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling5School,ps.Sibling5School) end end 
			as Sibling5School,

case when es.Sibling6FName is not null  
	then es.Sibling6FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling6FName,ps.Sibling6FName) end end 
			as Sibling6FName,
case when es.Sibling6LName is not null  
	then es.Sibling6LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling6LName,ps.Sibling6LName) end end 
			as Sibling6LName,
case when es.Sibling6DOB is not null  
	then es.Sibling6DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling6DOB,ps.Sibling6DOB) end end
			as Sibling6DOB,
case when es.Sibling6Grade is not null  
	then es.Sibling6Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling6Grade end end
			as Sibling6Grade,
case when es.Sibling6School is not null  
	then es.Sibling6School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling6School,ps.Sibling6School) end end
			as Sibling6School,

case when es.Sibling7FName is not null  
	then es.Sibling7FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling7FName,ps.Sibling7FName) end end 
			as Sibling7FName,
case when es.Sibling7LName is not null  
	then es.Sibling7LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling7LName,ps.Sibling7LName) end end 
			as Sibling7LName,
case when es.Sibling7DOB is not null  
	then es.Sibling7DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling7DOB,ps.Sibling7DOB) end end
			as Sibling7DOB,
case when es.Sibling7Grade is not null  
	then es.Sibling7Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling7Grade end end
			as Sibling7Grade,
case when es.Sibling7School is not null  
	then es.Sibling7School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling7School,ps.Sibling7School) end end
			as Sibling7School,

case when es.Sibling8FName is not null  
	then es.Sibling8FName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling8FName,ps.Sibling8FName) end end 
			as Sibling8FName,
case when es.Sibling8LName is not null  
	then es.Sibling8LName 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling8LName,ps.Sibling8LName) end end 
			as Sibling8LName,
case when es.Sibling8DOB is not null  
	then es.Sibling8DOB 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling8DOB,ps.Sibling8DOB) end end 
			as Sibling8DOB,
case when es.Sibling8Grade is not null  
	then es.Sibling8Grade 
	else case when es.Page_Family is not null then null 
		else sibling_es.Sibling8Grade end end 
			as Sibling8Grade,
case when es.Sibling8School is not null  
	then es.Sibling8School 
	else case when es.Page_Family is not null then null 
		else isnull(sibling_es.Sibling8School,ps.Sibling8School) end end 
			as Sibling8School,

-----------------------------------------------------------------------------
-- Medical page defauls...
-----------------------------------------------------------------------------

isnull(es.DoctorFname,case when es.Page_Medical is not null then null else ps.DoctorFname end) as DoctorFname,
isnull(es.DoctorLname,case when es.Page_Medical is not null then null else ps.DoctorLname end) as DoctorLname,
isnull(es.DoctorPhone,case when es.Page_Medical is not null then null else ps.DoctorPhone end) as DoctorPhone,
isnull(es.DoctorAddress,case when es.Page_Medical is not null then null else ps.DoctorAddress end) as DoctorAddress,

isnull(es.DentistFname,case when es.Page_Medical is not null then null else ps.DentistFname end) as DentistFname,
isnull(es.DentistLname,case when es.Page_Medical is not null then null else ps.DentistLname end) as DentistLname,
isnull(es.DentistPhone,case when es.Page_Medical is not null then null else ps.DentistPhone end) as DentistPhone,
isnull(es.DentistAddress,case when es.Page_Medical is not null then null else ps.DentistAddress end) as DentistAddress,

isnull(es.TylenolOK,case when es.Page_Medical is not null then null else ps.TylenolOK end) as TylenolOK,
isnull(es.TylenolChildOrJunior,case when es.Page_Medical is not null then null else ps.TylenolChildOrJunior end) as TylenolChildOrJunior,

isnull(es.Allergies,case when es.Page_Medical is not null then null else ps.Allergies end) as Allergies,
isnull(es.ListAllergies,case when es.Page_Medical is not null then null else ps.ListAllergies end) as ListAllergies,

isnull(es.HospitalPreference,case when es.Page_Medical is not null 
	then null else isnull(sibling_es.HospitalPreference,ps.HospitalPreference) end) as HospitalPreference,
isnull(es.InsuranceCompany,case when es.Page_Medical is not null 
	then null else isnull(sibling_es.InsuranceCompany,ps.InsuranceCompany) end) as InsuranceCompany,
isnull(es.InsurancePolicyNumber,case when es.Page_Medical is not null 
	then null else isnull(sibling_es.InsurancePolicyNumber,ps.InsurancePolicyNumber) end) as InsurancePolicyNumber,

-- Nullify all medical fields if the medical form is not configured to avoid overwriting SIS medical history in this case!!!
case when es.isMedicalHistory = 0 then null else 
isnull(es.ADD_ADHD,case when es.Page_Medical is not null then null else ps.ADD_ADHD end) end as ADD_ADHD,
case when es.isMedicalHistory = 0 then null else 
isnull(es.ADD_ADHD_Comments,case when es.Page_Medical is not null then null else ps.ADD_ADHD_Comments end) end as ADD_ADHD_Comments,
case when es.isMedicalHistory = 0 and es.isMedicalAllergies = 0 then null else 
isnull(es.Allergy,case when es.Page_Medical is not null then null else ps.Allergy end) end as Allergy,
case when es.isMedicalHistory = 0 and es.isMedicalAllergies = 0 then null else 
isnull(es.Allergy_Comments,case when es.Page_Medical is not null then null else ps.Allergy_Comments end) end as Allergy_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Allergy_epipen,case when es.Page_Medical is not null then null else ps.Allergy_epipen end) end as Allergy_epipen,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Allergy_food,case when es.Page_Medical is not null then null else ps.Allergy_food end) end as Allergy_food,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Allergy_insects,case when es.Page_Medical is not null then null else ps.Allergy_insects end) end as Allergy_insects,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Allergy_pollens,case when es.Page_Medical is not null then null else ps.Allergy_pollens end) end as Allergy_pollens,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Allergy_animals,case when es.Page_Medical is not null then null else ps.Allergy_animals end) end as Allergy_animals,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Allergy_medications,case when es.Page_Medical is not null then null else ps.Allergy_medications end) end as Allergy_medications,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Asthma_Inhailer,case when es.Page_Medical is not null then null else ps.Asthma_Inhailer end) end as Asthma_Inhailer,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Asthma,case when es.Page_Medical is not null then null else ps.Asthma end) end as Asthma,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Asthma_Comments,case when es.Page_Medical is not null then null else ps.Asthma_Comments end) end as Asthma_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Diabetes_Care,case when es.Page_Medical is not null then null else ps.Diabetes_Care end) end as Diabetes_Care,
case when es.isMedicalHistory = 0 then null else 
isnull(es.HearingLoss_HearingAid,case when es.Page_Medical is not null then null else ps.HearingLoss_HearingAid end) end as HearingLoss_HearingAid,
case when es.isMedicalHistory = 0 then null else 
isnull(es.BoneOrMuscleCond,case when es.Page_Medical is not null then null else ps.BoneOrMuscleCond end) end as BoneOrMuscleCond,
case when es.isMedicalHistory = 0 then null else 
isnull(es.BoneOrMuscleCond_Comments,case when es.Page_Medical is not null then null else ps.BoneOrMuscleCond_Comments end) end as BoneOrMuscleCond_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Diabetes,case when es.Page_Medical is not null then null else ps.Diabetes end) end as Diabetes,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Diabetes_Comments,case when es.Page_Medical is not null then null else ps.Diabetes_Comments end) end as Diabetes_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.EarThroatInf,case when es.Page_Medical is not null then null else ps.EarThroatInf end) end as EarThroatInf,
case when es.isMedicalHistory = 0 then null else 
isnull(es.EarThroatInf_Comments,case when es.Page_Medical is not null then null else ps.EarThroatInf_Comments end) end as EarThroatInf_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.EmotionalProb,case when es.Page_Medical is not null then null else ps.EmotionalProb end) end as EmotionalProb,
case when es.isMedicalHistory = 0 then null else 
isnull(es.EmotionalProb_Comments,case when es.Page_Medical is not null then null else ps.EmotionalProb_Comments end) end as EmotionalProb_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Fainting,case when es.Page_Medical is not null then null else ps.Fainting end) end as Fainting,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Fainting_Comments,case when es.Page_Medical is not null then null else ps.Fainting_Comments end) end as Fainting_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Headaches,case when es.Page_Medical is not null then null else ps.Headaches end) end as Headaches,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Headaches_Comments,case when es.Page_Medical is not null then null else ps.Headaches_Comments end) end as Headaches_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.MajorInjury,case when es.Page_Medical is not null then null else ps.MajorInjury end) end as MajorInjury,
case when es.isMedicalHistory = 0 then null else 
isnull(es.MajorInjury_Comments,case when es.Page_Medical is not null then null else ps.MajorInjury_Comments end) end as MajorInjury_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.HeartBlood,case when es.Page_Medical is not null then null else ps.HeartBlood end) end as HeartBlood,
case when es.isMedicalHistory = 0 then null else 
isnull(es.HeartBlood_Comments,case when es.Page_Medical is not null then null else ps.HeartBlood_Comments end) end as HeartBlood_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.HearingLoss,case when es.Page_Medical is not null then null else ps.HearingLoss end) end as HearingLoss,
case when es.isMedicalHistory = 0 then null else 
isnull(es.HearingLoss_Comments,case when es.Page_Medical is not null then null else ps.HearingLoss_Comments end) end as HearingLoss_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.PhysicalHandicap,case when es.Page_Medical is not null then null else ps.PhysicalHandicap end) end as PhysicalHandicap,
case when es.isMedicalHistory = 0 then null else 
isnull(es.PhysicalHandicap_Comments,case when es.Page_Medical is not null then null else ps.PhysicalHandicap_Comments end) end as PhysicalHandicap_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Seizures,case when es.Page_Medical is not null then null else ps.Seizures end) end as Seizures,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Seizures_Comments,case when es.Page_Medical is not null then null else ps.Seizures_Comments end) end as Seizures_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.SkinProb,case when es.Page_Medical is not null then null else ps.SkinProb end) end as SkinProb,
case when es.isMedicalHistory = 0 then null else 
isnull(es.SkinProb_Comments,case when es.Page_Medical is not null then null else ps.SkinProb_Comments end) end as SkinProb_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.UrinaryBowel,case when es.Page_Medical is not null then null else ps.UrinaryBowel end) end as UrinaryBowel,
case when es.isMedicalHistory = 0 then null else 
isnull(es.UrinaryBowel_Comments,case when es.Page_Medical is not null then null else ps.UrinaryBowel_Comments end) end as UrinaryBowel_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Vision,case when es.Page_Medical is not null then null else ps.Vision end) end as Vision,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Vision_Comments,case when es.Page_Medical is not null then null else ps.Vision_Comments end) end as Vision_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Vision_Glasses,case when es.Page_Medical is not null then null else ps.Vision_Glasses end) end as Vision_Glasses,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Vision_Contacts,case when es.Page_Medical is not null then null else ps.Vision_Contacts end) end as Vision_Contacts,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Vision_Wears_always,case when es.Page_Medical is not null then null else ps.Vision_Wears_always end) end as Vision_Wears_always,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Vision_Wears_sometimes,case when es.Page_Medical is not null then null else ps.Vision_Wears_sometimes end) end as Vision_Wears_sometimes,	
case when es.isMedicalHistory = 0 then null else 
isnull(es.Vision_Surgery,case when es.Page_Medical is not null then null else ps.Vision_Surgery end) end as Vision_Surgery,
case when es.isMedicalHistory = 0 then null else 
isnull(es.HospOper,case when es.Page_Medical is not null then null else ps.HospOper end) end as HospOper,
case when es.isMedicalHistory = 0 then null else 
isnull(es.HospOper_Comments,case when es.Page_Medical is not null then null else ps.HospOper_Comments end) end as HospOper_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Concerns,case when es.Page_Medical is not null then null else ps.Concerns end) end as Concerns,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Concerns_Comments,case when es.Page_Medical is not null then null else ps.Concerns_Comments end) end as Concerns_Comments,
case when es.isMedicalHistory = 0 then null else 
isnull(es.Concerns_SpeakToNurse,case when es.Page_Medical is not null then null else ps.Concerns_SpeakToNurse end) end as Concerns_SpeakToNurse,

es.PhotoRelease, -- TODO: never used???
es.SchoolDirectory, -- TODO: never used???

-----------------------------------------------------------------------------
-- Contacts page defauls...
-----------------------------------------------------------------------------

isnull(es.Contact1Fname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact1Fname,ps.Contact1Fname) end) as Contact1Fname,
isnull(es.Contact1Lname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact1Lname,ps.Contact1Lname) end) as Contact1Lname,
isnull(es.Contact1Relationship,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact1Relationship,ps.Contact1Relationship) end) as Contact1Relationship,
isnull(es.Contact1Phone1,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact1Phone1,ps.Contact1Phone1) end) as Contact1Phone1,
isnull(es.Contact1Phone2,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact1Phone2,ps.Contact1Phone2) end) as Contact1Phone2,
isnull(es.Contact1Addr,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact1Addr,ps.Contact1Addr) end) as Contact1Addr,
isnull(es.Contact1Roles,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact1Roles,ps.Contact1Roles) end) as Contact1Roles,

isnull(es.Contact2Fname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact2Fname,ps.Contact2Fname) end) as Contact2Fname,
isnull(es.Contact2Lname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact2Lname,ps.Contact2Lname) end) as Contact2Lname,
isnull(es.Contact2Relationship,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact2Relationship,ps.Contact2Relationship) end) as Contact2Relationship,
isnull(es.Contact2Phone1,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact2Phone1,ps.Contact2Phone1) end) as Contact2Phone1,
isnull(es.Contact2Phone2,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact2Phone2,ps.Contact2Phone2) end) as Contact2Phone2,
isnull(es.Contact2Addr,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact2Addr,ps.Contact2Addr) end) as Contact2Addr,
isnull(es.Contact2Roles,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact2Roles,ps.Contact2Roles) end) as Contact2Roles,

isnull(es.Contact3Fname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact3Fname,ps.Contact3Fname) end) as Contact3Fname,
isnull(es.Contact3Lname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact3Lname,ps.Contact3Lname) end) as Contact3Lname,
isnull(es.Contact3Relationship,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact3Relationship,ps.Contact3Relationship) end) as Contact3Relationship,
isnull(es.Contact3Phone1,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact3Phone1,ps.Contact3Phone1) end) as Contact3Phone1,
isnull(es.Contact3Phone2,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact3Phone2,ps.Contact3Phone2) end) as Contact3Phone2,
isnull(es.Contact3Addr,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact3Addr,ps.Contact3Addr) end) as Contact3Addr,
isnull(es.Contact3Roles,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact3Roles,ps.Contact3Roles) end) as Contact3Roles,

isnull(es.Contact4Fname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact4Fname,ps.Contact4Fname) end) as Contact4Fname,
isnull(es.Contact4Lname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact4Lname,ps.Contact4Lname) end) as Contact4Lname,
isnull(es.Contact4Relationship,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact4Relationship,ps.Contact4Relationship) end) as Contact4Relationship,
isnull(es.Contact4Phone1,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact4Phone1,ps.Contact4Phone1) end) as Contact4Phone1,
isnull(es.Contact4Phone2,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact4Phone2,ps.Contact4Phone2) end) as Contact4Phone2,
isnull(es.Contact4Addr,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact4Addr,ps.Contact4Addr) end) as Contact4Addr,
isnull(es.Contact4Roles,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact4Roles,ps.Contact4Roles) end) as Contact4Roles,

isnull(es.Contact5Fname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact5Fname,ps.Contact5Fname) end) as Contact5Fname,
isnull(es.Contact5Lname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact5Lname,ps.Contact5Lname) end) as Contact5Lname,
isnull(es.Contact5Relationship,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact5Relationship,ps.Contact5Relationship) end) as Contact5Relationship,
isnull(es.Contact5Phone1,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact5Phone2,ps.Contact5Phone1) end) as Contact5Phone1,
isnull(es.Contact5Phone2,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact5Phone2,ps.Contact5Phone2) end) as Contact5Phone2,
isnull(es.Contact5Addr,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact5Addr,ps.Contact5Addr) end) as Contact5Addr,
isnull(es.Contact5Roles,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact5Roles,ps.Contact5Roles) end) as Contact5Roles,

isnull(es.Contact6Fname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact6Fname,ps.Contact6Fname) end) as Contact6Fname,
isnull(es.Contact6Lname,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact6Lname,ps.Contact6Lname) end) as Contact6Lname,
isnull(es.Contact6Relationship,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact6Relationship,ps.Contact6Relationship) end) as Contact6Relationship,
isnull(es.Contact6Phone1,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact6Phone2,ps.Contact6Phone1) end) as Contact6Phone1,
isnull(es.Contact6Phone2,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact6Phone2,ps.Contact6Phone2) end) as Contact6Phone2,
isnull(es.Contact6Addr,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact6Addr,ps.Contact6Addr) end) as Contact6Addr,
isnull(es.Contact6Roles,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contact6Roles,ps.Contact6Roles) end) as Contact6Roles,

isnull(es.Contacts_Release_To_Any,case when es.Page_Contacts is not null then null else isnull(sibling_es.Contacts_Release_To_Any,ps.Contacts_Release_To_Any) end) as Contacts_Release_To_Any,



isnull(es.FamilyChurchAttended,case when es.Page_Worship is not null 
	then null else isnull(sibling_es.FamilyChurchAttended,ps.FamilyChurchAttended) end) 
	as FamilyChurchAttended,
isnull(es.FamilyChurchPastor,case when es.Page_Worship is not null 
	then null else isnull(sibling_es.FamilyChurchPastor,ps.FamilyChurchPastor) end) 
	as FamilyChurchPastor,
isnull(es.FamilyChurchMember,case when es.Page_Worship is not null 
	then null else isnull(sibling_es.FamilyChurchMember,ps.FamilyChurchMember) end) 
	as FamilyChurchMember,
isnull(es.FamilyChurchAttendFreq,case when es.Page_Worship is not null 
	then null else isnull(sibling_es.FamilyChurchAttendFreq,ps.FamilyChurchAttendFreq) end) 
	as FamilyChurchAttendFreq,
isnull(es.FamilyChurchDenomination,case when es.Page_Worship is not null 
	then null else isnull(sibling_es.FamilyChurchDenomination,ps.FamilyChurchDenomination) end) 
	as FamilyChurchDenomination,
isnull(es.CatholicYN,case when es.Page_Worship is not null 
	then null else isnull(sibling_es.CatholicYN,ps.CatholicYN) end) as CatholicYN,

-- es.BaptismYN,
-- es.BaptismChurch,

/*
case when isnull(es.StudentBaptized,ps.StudentBaptized)='Yes' 
	then isnull(es.BaptismChurch,
			case when es.Page_Worship is not null 
				then null else ps.BaptismChurch end)
	else null end BaptismChurch,
*/
isnull(es.BaptismDate,case when es.Page_Worship is not null 
	then null else isnull(ps.BaptismDate,sm.BaptismDate) end) as BaptismDate,


isnull(es.FirstReconciliationYN,case when es.Page_Worship is not null 
	then null else ps.FirstReconciliationYN end) as FirstReconciliationYN,

-- following fields are needed under two names...
isnull(es.FirstReconciliationDate,case when es.Page_Worship is not null 
	then null else isnull(ps.FirstReconciliationDate,sm.ReconciliationDate) end) as FirstReconciliationDate,
isnull(es.FirstReconciliationDate,case when es.Page_Worship is not null 
	then null else isnull(ps.FirstReconciliationDate,sm.ReconciliationDate) end) as ReconciliationDate,

isnull(es.FirstReconciliationChurch,case when es.Page_Worship is not null 
	then null else ps.FirstReconciliationChurch end) as FirstReconciliationChurch,
isnull(es.HolyEucharistYN,case when es.Page_Worship is not null 
	then null else ps.HolyEucharistYN end) as HolyEucharistYN,

-- following fields are needed under two names...
isnull(es.HolyEucharistDate,case when es.Page_Worship is not null 
	then null else isnull(ps.HolyEucharistDate,sm.CommunionDate) end) as HolyEucharistDate,
isnull(es.HolyEucharistDate,case when es.Page_Worship is not null 
	then null else isnull(ps.HolyEucharistDate,sm.CommunionDate) end) as CommunionDate,

isnull(es.HolyEucharistChurch,case when es.Page_Worship is not null 
	then null else ps.HolyEucharistChurch end) as HolyEucharistChurch,
isnull(es.ConfirmationYN,case when es.Page_Worship is not null 
	then null else ps.ConfirmationYN end) as ConfirmationYN,

isnull(es.ConfirmationDate,case when es.Page_Worship is not null 
	then null else isnull(ps.ConfirmationDate,sm.ConfirmationDate) end) as ConfirmationDate,

isnull(es.ConfirmationChurch,case when es.Page_Worship is not null 
	then null else ps.ConfirmationChurch end) as ConfirmationChurch,


	isnull(es.NoGuardian1,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.NoGuardian1	else sibling_es.NoGuardian1 end end) as NoGuardian1,
	isnull(es.Guardian1Fname,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Fname else sibling_es.Guardian1Fname end end) as Guardian1Fname,
	isnull(es.Guardian1Mname,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Mname	else sibling_es.Guardian1Mname end end) as Guardian1Mname,
	isnull(es.Guardian1Lname,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Lname	else sibling_es.Guardian1Lname end end) as Guardian1Lname,
	isnull(es.Guardian1Suffix,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Suffix	else sibling_es.Guardian1Suffix end end) as Guardian1Suffix,
	isnull(es.Guardian1AddressDescription,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1AddressDescription	else sibling_es.Guardian1AddressDescription end end) as Guardian1AddressDescription,
	isnull(es.Guardian1AddressName,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1AddressName	else sibling_es.Guardian1AddressName end end) as Guardian1AddressName,
	isnull(es.Guardian1AddressLine1,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1AddressLine1	else sibling_es.Guardian1AddressLine1 end end) as Guardian1AddressLine1,
	isnull(es.Guardian1AddressLine2,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1AddressLine2	else sibling_es.Guardian1AddressLine2 end end) as Guardian1AddressLine2,
	isnull(es.Guardian1City,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1City	else sibling_es.Guardian1City end end) as Guardian1City,
	isnull(es.Guardian1State,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1State	else sibling_es.Guardian1State end end) as Guardian1State,
	isnull(es.Guardian1Zip,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Zip	else sibling_es.Guardian1Zip end end) as Guardian1Zip,
	isnull(es.Guardian1Country,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Country is null then ps.Guardian1Country	else sibling_es.Guardian1Country end end) as Guardian1Country,
	isnull(es.Guardian1Occupation,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Occupation	else sibling_es.Guardian1Occupation end end) as Guardian1Occupation,
	isnull(es.Guardian1Employer,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Employer	else sibling_es.Guardian1Employer end end) as Guardian1Employer,
	isnull(es.Guardian1EmployerAddr,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1EmployerAddr	else sibling_es.Guardian1EmployerAddr end end) as Guardian1EmployerAddr,
	isnull(es.Guardian1HomePhone,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1HomePhone	else sibling_es.Guardian1HomePhone end end) as Guardian1HomePhone,
	isnull(es.Guardian1CellPhone,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1CellPhone	else sibling_es.Guardian1CellPhone end end) as Guardian1CellPhone,
	isnull(es.Guardian1WorkPhone,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1WorkPhone	else sibling_es.Guardian1WorkPhone end end) as Guardian1WorkPhone,
	isnull(es.Guardian1WorkExtension,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1WorkExtension	else sibling_es.Guardian1WorkExtension end end) as Guardian1WorkExtension,
	isnull(es.Guardian1Email,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Email	else sibling_es.Guardian1Email end end) as Guardian1Email,
	isnull(es.Guardian1ChurchMember,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1ChurchMember	else sibling_es.Guardian1ChurchMember end end) as Guardian1ChurchMember,
	isnull(es.Guardian1Church,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Church	else sibling_es.Guardian1Church end end) as Guardian1Church,
	isnull(es.Guardian1Roles,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Roles	else sibling_es.Guardian1Roles end end) as Guardian1Roles,
	isnull(es.Guardian1Relationship,case when es.Page_Guardian1 is not null then null else 
		case when sibling_es.Guardian1Fname is null then ps.Guardian1Relationship	else sibling_es.Guardian1Relationship end end) as Guardian1Relationship,

	isnull(es.NoGuardian2,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.NoGuardian2	else sibling_es.NoGuardian2 end end) as NoGuardian2,
	isnull(es.Guardian2Fname,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Fname	else sibling_es.Guardian2Fname end end) as Guardian2Fname,
	isnull(es.Guardian2Mname,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Mname	else sibling_es.Guardian2Mname end end) as Guardian2Mname,
	isnull(es.Guardian2Lname,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Lname	else sibling_es.Guardian2Lname end end) as Guardian2Lname,
	isnull(es.Guardian2Suffix,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Suffix	else sibling_es.Guardian2Suffix end end) as Guardian2Suffix,
	isnull(es.Guardian2AddressDescription,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2AddressDescription	else sibling_es.Guardian2AddressDescription end end) as Guardian2AddressDescription,
	isnull(es.Guardian2AddressName,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2AddressName	else sibling_es.Guardian2AddressName end end) as Guardian2AddressName,
	isnull(es.Guardian2AddressLine1,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2AddressLine1	else sibling_es.Guardian2AddressLine1 end end) as Guardian2AddressLine1,
	isnull(es.Guardian2AddressLine2,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2AddressLine2	else sibling_es.Guardian2AddressLine2 end end) as Guardian2AddressLine2,
	isnull(es.Guardian2City,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2City	else sibling_es.Guardian2City end end) as Guardian2City,
	isnull(es.Guardian2State,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2State	else sibling_es.Guardian2State end end) as Guardian2State,
	isnull(es.Guardian2Zip,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Zip	else sibling_es.Guardian2Zip end end) as Guardian2Zip,
	isnull(es.Guardian2Country,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Country is null then ps.Guardian2Country	else sibling_es.Guardian2Country end end) as Guardian2Country,		
	isnull(es.Guardian2Occupation,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Occupation	else sibling_es.Guardian2Occupation end end) as Guardian2Occupation,
	isnull(es.Guardian2Employer,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Employer	else sibling_es.Guardian2Employer end end) as Guardian2Employer,
	isnull(es.Guardian2EmployerAddr,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2EmployerAddr	else sibling_es.Guardian2EmployerAddr end end) as Guardian2EmployerAddr,
	isnull(es.Guardian2HomePhone,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2HomePhone	else sibling_es.Guardian2HomePhone end end) as Guardian2HomePhone,
	isnull(es.Guardian2CellPhone,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2CellPhone	else sibling_es.Guardian2CellPhone end end) as Guardian2CellPhone,
	isnull(es.Guardian2WorkPhone,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2WorkPhone	else sibling_es.Guardian2WorkPhone end end) as Guardian2WorkPhone,
	isnull(es.Guardian2WorkExtension,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2WorkExtension	else sibling_es.Guardian2WorkExtension end end) as Guardian2WorkExtension,
	isnull(es.Guardian2Email,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Email	else sibling_es.Guardian2Email end end) as Guardian2Email,
	isnull(es.Guardian2ChurchMember,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2ChurchMember	else sibling_es.Guardian2ChurchMember end end) as Guardian2ChurchMember,
	isnull(es.Guardian2Church,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Church	else sibling_es.Guardian2Church end end) as Guardian2Church,
	isnull(es.Guardian2Roles,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Roles	else sibling_es.Guardian2Roles end end) as Guardian2Roles,
	isnull(es.Guardian2Relationship,case when es.Page_Guardian2 is not null then null else 
		case when sibling_es.Guardian2Fname is null then ps.Guardian2Relationship	else sibling_es.Guardian2Relationship end end) as Guardian2Relationship,

isnull(es.SchoolDistrict,case when es.Page_Schools is not null then null else isnull(sibling_es.SchoolDistrict,smf.SchoolDistrict) end) as SchoolDistrict,
es.SchoolName1,
es.SchoolAddr1,
es.SchoolPhone1,
es.SchoolGrades1,
es.SchoolPrincipals1,
es.SchoolTeachers1,
es.SchoolName2,
es.SchoolAddr2,
es.SchoolPhone2,
es.SchoolGrades2,
es.SchoolName3,
es.SchoolAddr3,
es.SchoolPhone3,
es.SchoolGrades3,
es.SchoolSuspensionYN,
es.SchoolSuspensionDesc,
es.SchoolExpulsionYN,
es.SchoolExpulsionDesc,
es.SchoolLawEnforceYN,
es.SchoolLawEnforceDesc,
es.SchoolPsychiatricYN,
es.SchoolPsychiatricDesc,
es.SchoolLearnDisorderYN,
es.SchoolLearnDisorderDesc,
es.SchoolBilingualYN,
es.SchoolBilingualDesc,
es.SchoolIepYN,
es.SchoolIepDesc,
es.SchoolTranscriptYN,
es.SchoolFirstYearYN,

-- Info 1 page defaults...
isnull(es.FatherChurchMember,case when es.Page_Info is not null then null else isnull(sibling_es.FatherChurchMember,ps.FatherChurchMember) end) as FatherChurchMember,
case when isnull(es.FatherChurchMember,case when es.Page_Info is not null then null else isnull(sibling_es.FatherChurchMember,ps.FatherChurchMember) end)='No' 
then isnull(es.FatherChurch,case when es.Page_Info is not null then null else isnull(sibling_es.FatherChurch,ps.FatherChurch) end) else null end FatherChurch,
isnull(es.MotherChurchMember,case when es.Page_Info is not null then null else isnull(sibling_es.MotherChurchMember,ps.MotherChurchMember) end) as MotherChurchMember,
case when isnull(es.MotherChurchMember,case when es.Page_Info is not null then null else isnull(sibling_es.MotherChurchMember,ps.MotherChurchMember) end)='No' 
then isnull(es.MotherChurch,case when es.Page_Info is not null then null else isnull(sibling_es.MotherChurch,ps.MotherChurch) end) else null end MotherChurch,

-- Tuition page defaults...
isnull(es.Tuition_Num_Children,case when es.Page_Tuition is not null then null else sibling_es.Tuition_Num_Children end) as Tuition_Num_Children,
isnull(es.Tuition_Plan,case when es.Page_Tuition is not null then null else sibling_es.Tuition_Plan end) as Tuition_Plan,
isnull(es.Tuition_Pay_Plan,case when es.Page_Tuition is not null then null else sibling_es.Tuition_Pay_Plan end) as Tuition_Pay_Plan,
isnull(es.Morning_Care_Children,case when es.Page_Submit is not null then null else sibling_es.Morning_Care_Children end) as Morning_Care_Children,
isnull(es.Kinder_Care_Children,case when es.Page_Submit is not null then null else sibling_es.Kinder_Care_Children end) as Kinder_Care_Children,
isnull(es.Aftercare_Children,case when es.Page_Submit is not null then null else sibling_es.Aftercare_Children end) as Aftercare_Children,
isnull(es.Aftercare_Days,case when es.Page_Submit is not null then null else sibling_es.Aftercare_Days end) as Aftercare_Days,

-- Submit page defaults...
isnull(es.ExtendedCareYN,case when es.Page_Submit is not null then null else sibling_es.ExtendedCareYN end) as ExtendedCareYN,
isnull(es.ExtendedCareSign,case when es.Page_Submit is not null then null else sibling_es.ExtendedCareSign end) as ExtendedCareSign,
isnull(es.TuitionSign1,case when es.Page_Tuition is not null then null else sibling_es.TuitionSign1 end) as TuitionSign1,
isnull(es.TuitionSign2,case when es.Page_Tuition is not null then null else sibling_es.TuitionSign2 end) as TuitionSign2,

es.MedicationsYN,
es.MedicationsDesc,

	-- when SIS saves pages, the following ensures that the flags indicating a page update get set...
	1 as Page_Intro,
	1 as Page_Student,
	1 as Page_Mother,
	1 as Page_Father,
	1 as Page_Guardian1,
	1 as Page_Guardian2,
	1 as Page_Family,
	1 as Page_Schools,
	1 as Page_Contacts,
	1 as Page_Worship,
	1 as Page_Info,
	1 as Page_Info2,
	1 as Page_Tuition,
	1 as Page_Submit,
	1 as Page_Medical,
/*
	-- the following fields can continue to be used for the current, true value of the page_* fields...
	Page_Intro as _Page_Intro,
	Page_Student as _Page_Student,
	Page_Mother as _Page_Mother,
	Page_Father as _Page_Father,
	Page_Guardian1 as _Page_Guardian1,
	Page_Guardian2 as _Page_Guardian2,
	Page_Family as _Page_Family,
	Page_Schools as _Page_Schools,
	Page_Contacts as _Page_Contacts,
	Page_Worship as _Page_Worship,
	Page_Info as _Page_Info,
	Page_Info2 as _Page_Info2,
	Page_Tuition as _Page_Tuition,
	Page_Submit as _Page_Submit,
	Page_Medical as _Page_Medical,
*/

-- Computed ethnicity field used for reporting and/or importing...
case when isnull(es.DeclineRaceAndEthnicity,0)=1 then 'Decline to respond' else 
	
	dbo.ConcatIfBoth(case when es.HispanicOrLatino=1 
		then 'Hispanic or Latino' else '' end, '<br/>')

	+ dbo.ConcatIfBoth(case when es.Filipino=1 
		then 'Filipino' else '' end, '<br/>')
	+ dbo.ConcatIfBoth(case when es.MiddleEasternSemitic=1 
		then 'Middle Eastern/Semitic' else '' end, '<br/>')

	+ dbo.ConcatIfBoth(case when es.AmericanIndianOrAlaskaNative=1 
		then 'American Indian or Alaska Native' else '' end, '<br/>')
	+ dbo.ConcatIfBoth(case when es.Asian=1 then 'Asian' else '' end, '<br/>')
	+ dbo.ConcatIfBoth(case when es.BlackOrAfricanAmerican=1 
		then 'Black or African American' else '' end, '<br/>')
	+ dbo.ConcatIfBoth(case when es.NativeHawaiianOrPacificIslander=1 
		then 'Native Hawaiian or Other Pacific Islander' else '' end, '<br/>')
	+ dbo.ConcatIfBoth(case when es.White=1 
		then 'White' else '' end, '<br/>') end
	EthnicityAndRace,

-- Fields to help control read/write and read/only and admin access...
es.EnteredByAdmin,
case when es.EnteredByAdmin=1 
		and (es.FormStatus is null or es.FormStatus='Started') 
		and (es.SessionID = (CurrentSession))
	then 1 else 0 end as OpenForAdminEditing,
case when (es.FormStatus is null or es.FormStatus='Started') then 1 else 0 end as StatusIsStarted,
case when es.EnteredByAdmin=0 or es.FormStatus='Approved' then 'Yes' else 'No' end inUseLock,
case when es.StudentID is null then '' else 
   case when es.FormStatus is null then 'Started' else es.FormStatus end end FormStatus,
es.DateStarted,
es.DateSubmitted,
es.DateRestarted,
es.DateInProcess,
es.DateApproved,
case when
	es.fname is not null or es.lname is not null or es.ManualReenrollStudentID is not null
	then 1 else 0 end as ShowOnWorkflow,

es.QuickPayNotes,
es.QuickPayAmount,

es.program, 
es.term_start, 
es.degree, 
es.major, 
es.duration, 
es.other_program, 
es.housing_type, 
es.other_housing, 
es.learn_about, 
es.learn_about_name,

es.isUsAddress,
es.isMedicalHistory,
es.isMedicalAllergies,
es.glName

-- From clause...
from (select * from Students where (Active=1 or Status='New enrollment')) s
left join StudentMiscFields smf
on smf.StudentID = s.StudentID

/* find prior enrollme form for defaulting some fields... */
left join EnrollmentStudent ps 
	on ps.EnrollmentStudentID = 
		(select max(EnrollmentStudentID) from EnrollmentStudent es2
			where 
				(s.StudentID = es2.ImportStudentID
					or (es2.ImportStudentID is null 
						and es2.StudentID = s.StudentID))
				and (es2.SessionID<(Select SessionID from EnrollmentFormSettings)))

--full outer join EnrollmentStudent es
full outer join (
	select es.*,
		efs.SessionID as CurrentSession,
		/*
		** Tried using 'Fields_To_Incl at around line 25 above but failed because we need
		** this information for re-enrollment defualt records that are not yet assigned a session
		** and the isUsAddress and isMedicalHistory fields are only needed/used for current session forms...
		**
		CASE WHEN es.StudentID<=999999999 
			THEN efs.Configurable_Fields_To_Incl 
			ELSE efs.New_Enroll_Fields_To_Incl END as Fields_To_Incl,
		*/
		CASE WHEN CHARINDEX('US-Address',
			CASE WHEN es.StudentID<=999999999 
				THEN efs.Configurable_Fields_To_Incl 
				ELSE efs.New_Enroll_Fields_To_Incl END
			) > 0 THEN 1 ELSE 0 END	AS isUsAddress,
		CASE WHEN CHARINDEX('Medical-History',
			CASE WHEN es.StudentID<=999999999 
				THEN efs.Configurable_Fields_To_Incl 
				ELSE efs.New_Enroll_Fields_To_Incl END
			) > 0 THEN 1 ELSE 0 END AS isMedicalHistory,
		CASE WHEN CHARINDEX('Medical-Allergies',
			CASE WHEN es.StudentID<=999999999 
				THEN efs.Configurable_Fields_To_Incl 
				ELSE efs.New_Enroll_Fields_To_Incl END
			) > 0 THEN 1 ELSE 0 END AS isMedicalAllergies
		from EnrollmentStudent es 
		cross join EnrollmentFormSettings efs
) es on isnull(
		case when es.StudentID>999999999 or es.SessionID 
			= (CurrentSession)		
		then es.StudentID
		else -(cast(es.SessionID as bigint) * 1000000000 + es.StudentID) end,
	es.StudentID) = s.StudentID -- defaults only appear for current session
--    on es.StudentID = s.StudentID
    
    
left outer join StudentMiscFields sm
on es.StudentID = sm.StudentID

left join 
-- default some fields from any prior (first) Enrollment record within this family ID....
-- (prioritize fields from prior SUBMITTED form over a form merely STARTED)
(
select 
  isnull(-s.FamilyID,es.EnrollFamilyID) FamilyID, 
  MIN(case when isnull(es.FormStatus,'Started')<>'Started' then es.EnrollmentStudentID else null end) EnrollmentStudentID1,
  MIN(EnrollmentStudentID) EnrollmentStudentID2
from EnrollmentStudent es
left join Students s
on es.StudentID = s.StudentID
and es.SessionID = (select SessionID from EnrollmentFormSettings)
group by isnull(-s.FamilyID,es.EnrollFamilyID) 
) link
on isnull(-s.FamilyID,es.EnrollFamilyID) = link.FamilyID
left join EnrollmentStudent sibling_es 
on 
	case when link.EnrollmentStudentID1 is not null 
		and link.EnrollmentStudentID1<>es.EnrollmentStudentID -- i.e. don't default from self
		then link.EnrollmentStudentID1 else link.EnrollmentStudentID2 end
	= sibling_es.EnrollmentStudentID

GO
