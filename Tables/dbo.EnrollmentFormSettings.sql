CREATE TABLE [dbo].[EnrollmentFormSettings]
(
[ID] [int] NOT NULL,
[SessionID] [int] NOT NULL,
[RelegiousFields] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_RelegiousFields] DEFAULT ((0)),
[EnrollFormCSS] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollSiteBannerHTML] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollSiteBannerOption] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EnrollmentFormSettings_EnrollSiteBannerOption] DEFAULT ('schoolname'),
[HomeChurch] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Configurable_Fields_To_Incl] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New_Enroll_Fields_To_Incl] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollMeDemo] [bit] NULL,
[StartedStatusMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmittedStatusMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InProcessStatusMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PendingStatusMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CancelledStatusMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApprovedStatusMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotApprovedStatusMsg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnableStartedStatusEmail] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableStartedStatusEmail] DEFAULT ((1)),
[EnableSubmittedStatusEmail] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableSubmittedStatusEmail] DEFAULT ((1)),
[EnableInProcessStatusEmail] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableInProcessStatusEmail] DEFAULT ((1)),
[EnablePendingStatusEmail] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnablePendingStatusEmail] DEFAULT ((1)),
[EnableCancelledStatusEmail] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableCancelledStatusEmail] DEFAULT ((1)),
[EnableApprovedStatusEmail] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableApprovedStatusEmail] DEFAULT ((1)),
[EnableNotApprovedStatusEmail] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableNotApprovedStatusEmail] DEFAULT ((1)),
[SubscriptionRenewal] [date] NULL,
[UDF_Title_1] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_1] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_Title_2] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_2] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_Title_3] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_3] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_Title_4] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_4] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_Title_5] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_5] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_Title_6] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_6] [date] NULL,
[UDF_Title_7] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_7] [date] NULL,
[UDF_Title_8] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_8] [date] NULL,
[UDF_Title_9] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF_value_9] [date] NULL,
[EnableUserAccessToPageHTML] [bit] NULL,
[Profiles_SchoolID] [int] NULL,
[Profiles_Import_Settings] [bit] NULL,
[Profiles_Import_HTML] [bit] NULL,
[Profiles_Clear_HTML] [bit] NULL,
[Profiles_Add_Grade_Options] [bit] NULL,
[Profiles_Import_Programs] [bit] NULL,
[Profiles_Clear_Programs] [bit] NULL,
[PromoteReenrollsToActive] [bit] NULL,
[EnableSpanishEnrollme] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableSpanishEnrollme] DEFAULT ((0)),
[RemovePhoneAndZipMasks] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_RemovePhoneAndZipMasks] DEFAULT ((0)),
[EnableEnrollMeContract] [bit] NOT NULL CONSTRAINT [DF_EnrollmentFormSettings_EnableEnrollMeContract] DEFAULT ((1)),
[CustomFieldDefaultExcludes] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollFormCSS_use] AS (isnull([EnrollFormCSS],'')+replace(replace(('.Re-Enroll; '+[Configurable_Fields_To_Incl])+'; ','; ',' { display: inline-block !important; visibility: visible; } .')+';','.;','')),
[EnrollFormCSS_new_enroll_use] AS (isnull([EnrollFormCSS],'')+replace(replace(('.New-Enroll; '+[New_Enroll_Fields_To_Incl])+'; ','; ',' { display: inline-block !important; visibility: visible; } .')+';','.;',''))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[OnlineFormSettings_Default_GradeLevelOptions] 
   ON  [dbo].[EnrollmentFormSettings]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	if (select COUNT(*) from GradeLevelOptions) = 0
	begin
		insert into GradeLevelOptions (GradeLevel, GradeLevelOption)
		select distinct g.GradeLevel, g.GradeLevelOption from Students s
		inner join (
		select 'PS' as GradeLevel,'   Preschool' as GradeLevelOption
		union all
		select 'PK' as GradeLevel,'  Junior Kindergarten' as GradeLevelOption
		union all
		select 'K' as GradeLevel,'  Kindergarten' as GradeLevelOption
		union all
		select '1' as GradeLevel,' 1st Grade' as GradeLevelOption
		union all
		select '2' as GradeLevel,' 2nd Grade' as GradeLevelOption
		union all
		select '3' as GradeLevel,' 3rd Grade' as GradeLevelOption
		union all
		select '4' as GradeLevel,' 4th Grade' as GradeLevelOption
		union all
		select '5' as GradeLevel,' 5th Grade' as GradeLevelOption
		union all
		select '6' as GradeLevel,' 6th Grade' as GradeLevelOption
		union all
		select '7' as GradeLevel,' 7th Grade' as GradeLevelOption
		union all
		select '8' as GradeLevel,' 8th Grade' as GradeLevelOption
		union all
		select '9' as GradeLevel,' 9th Grade' as GradeLevelOption
		union all
		select '10' as GradeLevel,'10th Grade' as GradeLevelOption
		union all
		select '11' as GradeLevel,'11th Grade' as GradeLevelOption
		union all
		select '12' as GradeLevel,'12th Grade' as GradeLevelOption
		) g 
		on s.GradeLevel = g.GradeLevel
		where Active=1
	end
	
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[OnlineFormSettings_Replicate_To_LKG] 
   ON  [dbo].[EnrollmentFormSettings]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	delete from LKG.dbo.[OnlineFormSettings] 
		where SchoolID = DB_NAME()

	insert into LKG.dbo.[OnlineFormSettings]
		(SchoolID,SessionID,[EnrollFormCSS],[EnrollSiteBannerHTML],
		[EnrollSiteBannerOption],[HomeChurch],[Configurable_Fields_To_Incl],
		[New_Enroll_Fields_To_Incl],[EnrollMeDemo])
	select 
		DB_NAME(),SessionID,[EnrollFormCSS],[EnrollSiteBannerHTML],
		[EnrollSiteBannerOption],[HomeChurch],[Configurable_Fields_To_Incl],
		[New_Enroll_Fields_To_Incl],[EnrollMeDemo]
	from inserted
	
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[OnlineFormSettings_Update_Session_trigger] 
   ON  [dbo].[EnrollmentFormSettings]
   AFTER UPDATE
AS 
BEGIN

	IF UPDATE(SessionID) AND
		(SELECT DISTINCT 1 FROM Inserted i INNER JOIN Deleted d ON i.ID=d.ID AND i.SessionID<>d.SessionID) 
			IS NOT NULL
	BEGIN

		-- MAINTENANCE TASK #1 ------
		--
		-- Replicate reenrolling students XML data to any non-current sessions that do not already contain it.
		-- This will preserve the xml data for historical reenrollment forms.
		-- Only copy for submitted forms so that we avoid copying incomplete data unless clear/purge flag set above
		--
		insert into xml_records
			select table_name,entityName,
			-(cast(SessionID as bigint)*1000000000 + StudentID) as table_pk_id,
			xml_fields,records_version,deprecated
			from xml_records
			inner join (
				select StudentID,SessionID from EnrollmentStudent
				where studentID<1000000000 -- reenroll only
				and SessionID <> (select SessionID from EnrollmentFormSettings) -- not current session
				and -(cast(SessionID as bigint)*1000000000 + StudentID) 
					not in (select table_pk_id from xml_records) -- don't overwrite previously replicated xml data
				and (isnull(FormStatus,'Started')<>'Started') -- make sure form was submitted before replicating
			) x
			on xml_records.table_pk_id = x.StudentID and xml_records.entityName like 'Reg%'

		-- MAINTENANCE TASK #2 ------
		--
		-- Permanently record default values shown in view back into base enrollment form table.
		-- Only do this for records that are not in the current session and that have been submitted...
/*
This Update Statement has to be broken into to parts as it was hitting an 8k limitation by SQL Server

Msg 511, Level 16, State 1, Procedure OnlineFormSettings_Update_Session_trigger, Line 38 [Batch Start Line 0]
Cannot create a row of size 8074 which is greater than the allowable maximum row size of 8060.
The statement has been terminated.

*/
-- ********************************************************************************************
-- ********************************************************************************************
-- ********************************** Part One of Update **************************************
-- ********************************************************************************************
-- ********************************************************************************************


		UPDATE es
		SET

		/* key fields and student pages should be set properly already...
		EnrollmentStudentID 
		StudentID 
		SessionID 
		FormName 
		EnrollFamilyID 
		Fname 
		Mname 
		Lname 
		Suffix 
		AddressDescription 
		AddressName 
		AddressLine1 
		AddressLine2 
		City 
		State 
		Zip 
		StudentHomePhone 
		StudentCellPhone 
		StudentWorkPhone 
		BirthDate 
		Sex 
		HispanicLatino 
		AmericanIndianOrAlaskaNative 
		Asian 
		BlackOrAfricanAmerican 
		NativeHawaiianOrPacificIslander 
		White 
		BirthCity 
		BirthState 
		BirthZip 
		BirthCountry 
		GradeLevelOptionID 
		EnteringGradeLevel 
		*/

		StudentBaptized = v.StudentBaptized,
		BaptismDate = v.BaptismDate,
		BaptismChurch = v.BaptismChurch,

		NoFather = v.NoFather ,
		FatherFname = v.FatherFname,
		FatherMname = v.FatherMname ,
		FatherLname = v.FatherLname ,
		FatherSuffix = v.FatherSuffix ,
		FatherAddressDescription = v.FatherAddressDescription,
		FatherAddressName = v.FatherAddressName ,
		FatherAddressLine1 = v.FatherAddressLine1 ,
		FatherAddressLine2 = v.FatherAddressLine2 ,
		FatherCity = v.FatherCity ,
		FatherState = v.FatherState ,
		FatherZip = v.FatherZip ,
		FatherOccupation = v.FatherOccupation,
		FatherEmployer = v.FatherEmployer ,
		FatherEmployerAddr = v.FatherEmployerAddr ,
		FatherHomePhone = v.FatherHomePhone ,
		FatherCellPhone = v.FatherCellPhone ,
		FatherWorkPhone = v.FatherWorkPhone ,
		FatherWorkExtension = v.FatherWorkExtension ,
		FatherEmail = v.FatherEmail ,
		FatherChurchMember = v.FatherChurchMember ,
		FatherChurch = v.FatherChurch ,

		FatherSSN = v.FatherSSN,
		MotherSSN = v.MotherSSN,

		NoMother = v.NoMother ,
		MotherFname = v.MotherFname ,
		MotherMname = v.MotherMname ,
		MotherLname = v.MotherLname ,
		MotherSuffix = v.MotherSuffix,
		MotherAddressDescription = v.MotherAddressDescription,
		MotherAddressName = v.MotherAddressName,
		MotherAddressLine1 = v.MotherAddressLine1,
		MotherAddressLine2 = v.MotherAddressLine2,
		MotherCity = v.MotherCity,
		MotherState = v.MotherState,
		MotherZip = v.MotherZip,
		MotherOccupation = v.MotherOccupation,
		MotherEmployer = v.MotherEmployer,
		MotherEmployerAddr = v.MotherEmployerAddr,
		MotherHomePhone = v.MotherHomePhone,
		MotherCellPhone = v.MotherCellPhone ,
		MotherWorkPhone = v.MotherWorkPhone ,
		MotherWorkExtension = v.MotherWorkExtension ,
		MotherEmail = v.MotherEmail ,
		MotherChurchMember = v.MotherChurchMember ,
		MotherChurch = v.MotherChurch ,

		StudentLivesWithFather = v.StudentLivesWithFather,
		StudentLivesWithMother = v.StudentLivesWithMother,
		StudentLivesWithStepfather = v.StudentLivesWithStepfather,
		StudentLivesWithStepmother = v.StudentLivesWithStepmother,
		StudentLivesWithOther = v.StudentLivesWithOther,
		StudentLivesWithDesc = v.StudentLivesWithDesc,
		-- StudentLivesWithGuardian1 = StudentLivesWithGuardian1,
		-- StudentLivesWithGuardian2 = StudentLivesWithGuardian2,
		Divorced = v.Divorced,
		Custody = v.Custody,

		Sibling1FName = v.Sibling1FName,
		Sibling1LName = v.Sibling1LName,
		Sibling1DOB = v.Sibling1DOB,
		Sibling1Grade = v. Sibling1Grade,
		Sibling2FName = v.Sibling2FName,
		Sibling2LName = v.Sibling2LName,
		Sibling2DOB = v.Sibling2DOB,
		Sibling2Grade = v.Sibling2Grade,
		Sibling3FName = v.Sibling3FName,
		Sibling3LName = v.Sibling3LName,
		Sibling3DOB = v.Sibling3DOB,
		Sibling3Grade = v.Sibling3Grade,
		Sibling4FName = v.Sibling4FName,
		Sibling4LName = v.Sibling4LName,
		Sibling4DOB = v.Sibling4DOB,
		Sibling4Grade = v.Sibling4Grade,
		Sibling1School = v.Sibling1School,
		Sibling2School = v.Sibling2School,
		Sibling3School = v.Sibling3School,
		Sibling4School = v.Sibling4School,
		Sibling5FName = v.Sibling5FName,
		Sibling5LName = v.Sibling5LName,
		Sibling5DOB = v.Sibling5DOB,
		Sibling5Grade = v.Sibling5Grade,
		Sibling5School = v.Sibling5School,
		Sibling6FName = v.Sibling6FName,
		Sibling6LName = v.Sibling6LName,
		Sibling6DOB = v.Sibling6DOB,
		Sibling6Grade = v.Sibling6Grade,
		Sibling6School = v.Sibling6School,
		Sibling7FName = v.Sibling7FName,
		Sibling7LName = v.Sibling7LName,
		Sibling7DOB = v.Sibling7DOB,
		Sibling7Grade = v.Sibling7Grade,
		Sibling7School = v.Sibling7School,
		Sibling8FName = v.Sibling8FName,
		Sibling8LName = v.Sibling8LName,
		Sibling8DOB = v.Sibling8DOB,
		Sibling8Grade = v.Sibling8Grade,
		Sibling8School = v.Sibling8School,

		DoctorFname = v. DoctorFname,
		DoctorLname = v. DoctorLname,
		DoctorPhone = v.DoctorPhone,
		DoctorAddress = v.DoctorAddress,
		TylenolOK = v.TylenolOK,
		TylenolChildOrJunior = v.TylenolChildOrJunior,
		Allergies = v.Allergies,
		ListAllergies = v.ListAllergies,

		es.ADD_ADHD = v.ADD_ADHD,
		es.ADD_ADHD_Comments = v.ADD_ADHD_Comments,
		es.Allergy = v.Allergy,
		es.Allergy_Comments = v.Allergy_Comments,
		es.Allergy_epipen = v.Allergy_epipen,
		es.Allergy_food = v.Allergy_food,
		es.Allergy_insects = v.Allergy_insects,
		es.Allergy_pollens = v.Allergy_pollens,
		es.Allergy_animals = v.Allergy_animals,
		es.Allergy_medications = v.Allergy_medications,
		es.Asthma_Inhailer = v.Asthma_Inhailer,
		es.Asthma = v.Asthma,
		es.Asthma_Comments = v.Asthma_Comments,
		es.Diabetes_Care = v.Diabetes_Care,
		es.HearingLoss_HearingAid = v.HearingLoss_HearingAid,
		es.BoneOrMuscleCond = v.BoneOrMuscleCond,
		es.BoneOrMuscleCond_Comments = v.BoneOrMuscleCond_Comments,
		es.Diabetes = v.Diabetes,
		es.Diabetes_Comments = v.Diabetes_Comments,
		es.EarThroatInf = v.EarThroatInf,
		es.EarThroatInf_Comments = v.EarThroatInf_Comments,
		es.EmotionalProb = v.EmotionalProb,
		es.EmotionalProb_Comments = v.EmotionalProb_Comments,
		es.Fainting = v.Fainting,
		es.Fainting_Comments = v.Fainting_Comments,
		es.Headaches = v.Headaches,
		es.Headaches_Comments = v.Headaches_Comments,
		es.MajorInjury = v.MajorInjury,
		es.MajorInjury_Comments = v.MajorInjury_Comments,
		es.HeartBlood = v.HeartBlood,
		es.HeartBlood_Comments = v.HeartBlood_Comments,
		es.HearingLoss = v.HearingLoss,
		es.HearingLoss_Comments = v.HearingLoss_Comments,
		es.PhysicalHandicap = v.PhysicalHandicap,
		es.PhysicalHandicap_Comments = v.PhysicalHandicap_Comments,
		es.Seizures = v.Seizures,
		es.Seizures_Comments = v.Seizures_Comments,
		es.SkinProb = v.SkinProb,
		es.SkinProb_Comments = v.SkinProb_Comments,
		es.UrinaryBowel = v.UrinaryBowel,
		es.UrinaryBowel_Comments = v.UrinaryBowel_Comments,
		es.Vision = v.Vision,
		es.Vision_Comments = v.Vision_Comments,
		es.Vision_Glasses = v.Vision_Glasses,
		es.Vision_Contacts = v.Vision_Contacts,
		es.Vision_Wears_always = v.Vision_Wears_always,
		es.Vision_Wears_sometimes = v.Vision_Wears_sometimes	,
		es.Vision_Surgery = v.Vision_Surgery,
		es.HospOper = v.HospOper,
		es.HospOper_Comments = v.HospOper_Comments,
		es.Concerns = v.Concerns,
		es.Concerns_Comments = v.Concerns_Comments,
		es.Concerns_SpeakToNurse = v.Concerns_SpeakToNurse

		/* not used yet?
		PhotoRelease 
		SchoolDirectory 
		*/


		FROM ENROLLMENTSTUDENT es
		INNER JOIN VENROLLMENTSTUDENT v
		ON es.EnrollmentStudentID = v.EnrollmentStudentID
		where es.SessionID <> (select SessionID from EnrollmentFormSettings) -- not current session
			and isnull(es.FormStatus,'Started')<>'Started' -- make sure form was submitted before replicating
		--
		-- THE FOLLOWING SECTION IS OPTIONAL, but it simply represents whether or not any of the
		-- replaces above are needed and avoids updating rows if there are no changes.  It also helps me 
		-- monitor the need to keep running these queries by giving feedback on whether any schools still
		-- have default values that need to be memorialized...
		--
		and (
		es.StudentBaptized <> v.StudentBaptized or
		es.BaptismDate <> v.BaptismDate or
		es.BaptismChurch <> v.BaptismChurch or

		es.NoFather <> v.NoFather  or
		es.FatherFname <> v.FatherFname or
		es.FatherMname <> v.FatherMname  or
		es.FatherLname <> v.FatherLname  or
		es.FatherSuffix <> v.FatherSuffix  or
		es.FatherAddressDescription <> v.FatherAddressDescription or
		es.FatherAddressName <> v.FatherAddressName  or
		es.FatherAddressLine1 <> v.FatherAddressLine1  or
		es.FatherAddressLine2 <> v.FatherAddressLine2  or
		es.FatherCity <> v.FatherCity  or
		es.FatherState <> v.FatherState  or
		es.FatherZip <> v.FatherZip  or
		es.FatherOccupation <> v.FatherOccupation or
		es.FatherEmployer <> v.FatherEmployer  or
		es.FatherEmployerAddr <> v.FatherEmployerAddr  or
		es.FatherHomePhone <> v.FatherHomePhone  or
		es.FatherCellPhone <> v.FatherCellPhone  or
		es.FatherWorkPhone <> v.FatherWorkPhone  or
		es.FatherWorkExtension <> v.FatherWorkExtension  or
		es.FatherEmail <> v.FatherEmail  or
		es.FatherChurchMember <> v.FatherChurchMember  or
		es.FatherChurch <> v.FatherChurch  or

		es.FatherSSN <> v.FatherSSN or
		es.MotherSSN <> v.MotherSSN or

		es.NoMother <> v.NoMother  or
		es.MotherFname <> v.MotherFname  or
		es.MotherMname <> v.MotherMname  or
		es.MotherLname <> v.MotherLname  or
		es.MotherSuffix <> v.MotherSuffix or
		es.MotherAddressDescription <> v.MotherAddressDescription or
		es.MotherAddressName <> v.MotherAddressName or
		es.MotherAddressLine1 <> v.MotherAddressLine1 or
		es.MotherAddressLine2 <> v.MotherAddressLine2 or
		es.MotherCity <> v.MotherCity or
		es.MotherState <> v.MotherState or
		es.MotherZip <> v.MotherZip or
		es.MotherOccupation <> v.MotherOccupation or
		es.MotherEmployer <> v.MotherEmployer or
		es.MotherEmployerAddr <> v.MotherEmployerAddr or
		es.MotherHomePhone <> v.MotherHomePhone or
		es.MotherCellPhone <> v.MotherCellPhone  or
		es.MotherWorkPhone <> v.MotherWorkPhone  or
		es.MotherWorkExtension <> v.MotherWorkExtension  or
		es.MotherEmail <> v.MotherEmail  or
		es.MotherChurchMember <> v.MotherChurchMember  or
		es.MotherChurch <> v.MotherChurch  or

		es.StudentLivesWithFather <> v.StudentLivesWithFather or
		es.StudentLivesWithMother <> v.StudentLivesWithMother or
		es.StudentLivesWithStepfather <> v.StudentLivesWithStepfather or
		es.StudentLivesWithStepmother <> v.StudentLivesWithStepmother or
		es.StudentLivesWithOther <> v.StudentLivesWithOther or
		es.StudentLivesWithDesc <> v.StudentLivesWithDesc or

		es.Divorced <> v.Divorced or
		es.Custody <> v.Custody or

		es.Sibling1FName <> v.Sibling1FName or
		es.Sibling1LName <> v.Sibling1LName or
		es.Sibling1DOB <> v.Sibling1DOB or
		es.Sibling1Grade <> v. Sibling1Grade or
		es.Sibling2FName <> v.Sibling2FName or
		es.Sibling2LName <> v.Sibling2LName or
		es.Sibling2DOB <> v.Sibling2DOB or
		es.Sibling2Grade <> v.Sibling2Grade or
		es.Sibling3FName <> v.Sibling3FName or
		es.Sibling3LName <> v.Sibling3LName or
		es.Sibling3DOB <> v.Sibling3DOB or
		es.Sibling3Grade <> v.Sibling3Grade or
		es.Sibling4FName <> v.Sibling4FName or
		es.Sibling4LName <> v.Sibling4LName or
		es.Sibling4DOB <> v.Sibling4DOB or
		es.Sibling4Grade <> v.Sibling4Grade or
		es.Sibling1School <> v.Sibling1School or
		es.Sibling2School <> v.Sibling2School or
		es.Sibling3School <> v.Sibling3School or
		es.Sibling4School <> v.Sibling4School or
		es.Sibling5FName <> v.Sibling5FName or
		es.Sibling5LName <> v.Sibling5LName or
		es.Sibling5DOB <> v.Sibling5DOB or
		es.Sibling5Grade <> v.Sibling5Grade or
		es.Sibling5School <> v.Sibling5School or
		es.Sibling6FName <> v.Sibling6FName or
		es.Sibling6LName <> v.Sibling6LName or
		es.Sibling6DOB <> v.Sibling6DOB or
		es.Sibling6Grade <> v.Sibling6Grade or
		es.Sibling6School <> v.Sibling6School or
		es.Sibling7FName <> v.Sibling7FName or
		es.Sibling7LName <> v.Sibling7LName or
		es.Sibling7DOB <> v.Sibling7DOB or
		es.Sibling7Grade <> v.Sibling7Grade or
		es.Sibling7School <> v.Sibling7School or
		es.Sibling8FName <> v.Sibling8FName or
		es.Sibling8LName <> v.Sibling8LName or
		es.Sibling8DOB <> v.Sibling8DOB or
		es.Sibling8Grade <> v.Sibling8Grade or
		es.Sibling8School <> v.Sibling8School or

		es.DoctorFname <> v. DoctorFname or
		es.DoctorLname <> v. DoctorLname or
		es.DoctorPhone <> v.DoctorPhone or
		es.DoctorAddress <> v.DoctorAddress or
		es.TylenolOK <> v.TylenolOK or
		es.TylenolChildOrJunior <> v.TylenolChildOrJunior or
		es.Allergies <> v.Allergies or
		es.ListAllergies <> v.ListAllergies or

		es.ADD_ADHD <> v.ADD_ADHD or
		es.ADD_ADHD_Comments <> v.ADD_ADHD_Comments or
		es.Allergy <> v.Allergy or
		es.Allergy_Comments <> v.Allergy_Comments or
		es.Allergy_epipen <> v.Allergy_epipen or
		es.Allergy_food <> v.Allergy_food or
		es.Allergy_insects <> v.Allergy_insects or
		es.Allergy_pollens <> v.Allergy_pollens or
		es.Allergy_animals <> v.Allergy_animals or
		es.Allergy_medications <> v.Allergy_medications or
		es.Asthma_Inhailer <> v.Asthma_Inhailer or
		es.Asthma <> v.Asthma or
		es.Asthma_Comments <> v.Asthma_Comments or
		es.Diabetes_Care <> v.Diabetes_Care or
		es.HearingLoss_HearingAid <> v.HearingLoss_HearingAid or
		es.BoneOrMuscleCond <> v.BoneOrMuscleCond or
		es.BoneOrMuscleCond_Comments <> v.BoneOrMuscleCond_Comments or
		es.Diabetes <> v.Diabetes or
		es.Diabetes_Comments <> v.Diabetes_Comments or
		es.EarThroatInf <> v.EarThroatInf or
		es.EarThroatInf_Comments <> v.EarThroatInf_Comments or
		es.EmotionalProb <> v.EmotionalProb or
		es.EmotionalProb_Comments <> v.EmotionalProb_Comments or
		es.Fainting <> v.Fainting or
		es.Fainting_Comments <> v.Fainting_Comments or
		es.Headaches <> v.Headaches or
		es.Headaches_Comments <> v.Headaches_Comments or
		es.MajorInjury <> v.MajorInjury or
		es.MajorInjury_Comments <> v.MajorInjury_Comments or
		es.HeartBlood <> v.HeartBlood or
		es.HeartBlood_Comments <> v.HeartBlood_Comments or
		es.HearingLoss <> v.HearingLoss or
		es.HearingLoss_Comments <> v.HearingLoss_Comments or
		es.PhysicalHandicap <> v.PhysicalHandicap or
		es.PhysicalHandicap_Comments <> v.PhysicalHandicap_Comments or
		es.Seizures <> v.Seizures or
		es.Seizures_Comments <> v.Seizures_Comments or
		es.SkinProb <> v.SkinProb or
		es.SkinProb_Comments <> v.SkinProb_Comments or
		es.UrinaryBowel <> v.UrinaryBowel or
		es.UrinaryBowel_Comments <> v.UrinaryBowel_Comments or
		es.Vision <> v.Vision or
		es.Vision_Comments <> v.Vision_Comments or
		es.Vision_Glasses <> v.Vision_Glasses or
		es.Vision_Contacts <> v.Vision_Contacts or
		es.Vision_Wears_always <> v.Vision_Wears_always or
		es.Vision_Wears_sometimes <> v.Vision_Wears_sometimes	 or
		es.Vision_Surgery <> v.Vision_Surgery or
		es.HospOper <> v.HospOper or
		es.HospOper_Comments <> v.HospOper_Comments or
		es.Concerns <> v.Concerns or
		es.Concerns_Comments <> v.Concerns_Comments or
		es.Concerns_SpeakToNurse <> v.Concerns_SpeakToNurse
		)


-- ********************************************************************************************
-- ********************************************************************************************
-- ********************************** Part Two of Update **************************************
-- ********************************************************************************************
-- ********************************************************************************************

		UPDATE es
		SET
		Contact1Fname = v.Contact1Fname,
		Contact1Lname = v.Contact1Lname,
		Contact1Relationship = v.Contact1Relationship,
		Contact1Phone1 = v.Contact1Phone1,
		Contact1Phone2 = v.Contact1Phone2,
		Contact2Fname = v.Contact2Fname,
		Contact2Lname = v.Contact2Lname,
		Contact2Relationship = v.Contact2Relationship,
		Contact2Phone1 = v.Contact2Phone1,
		Contact2Phone2 = v.Contact2Phone2,
		Contact3Fname = v.Contact3Fname,
		Contact3Lname = v.Contact3Lname,
		Contact3Relationship = v.Contact3Relationship,
		Contact3Phone1 = v.Contact3Phone1,
		Contact3Phone2 = v.Contact3Phone2,
		Contact4Fname = v.Contact4Fname,
		Contact4Lname = v.Contact4Lname,
		Contact4Relationship = v.Contact4Relationship,
		Contact4Phone1 = v.Contact4Phone1,
		Contact4Phone2 = v.Contact4Phone2,
		Contact5Fname = v.Contact5Fname,
		Contact5Lname = v.Contact5Lname,
		Contact5Relationship = v.Contact5Relationship,
		Contact5Phone1 = v.Contact5Phone1,
		Contact5Phone2 = v.Contact5Phone2,
		Contact6Fname = v.Contact6Fname,
		Contact6Lname = v.Contact6Lname,
		Contact6Relationship = v.Contact6Relationship,
		Contact6Phone1 = v.Contact6Phone1,
		Contact6Phone2 = v.Contact6Phone2,
		Contact1Roles = v.Contact1Roles,
		Contact2Roles = v.Contact2Roles,
		Contact3Roles = v.Contact3Roles,
		Contact4Roles = v.Contact4Roles,
		Contact5Roles = v.Contact5Roles,
		Contact6Roles = v.Contact6Roles,
		Contact1Addr = v.Contact1Addr,
		Contact2Addr = v.Contact2Addr,
		Contact3Addr = v.Contact3Addr,
		Contact4Addr = v.Contact4Addr,
		Contact5Addr = v.Contact5Addr,
		Contact6Addr = v.Contact6Addr,

		/*
		FormStatus 
		DateStarted 
		DateSubmitted 
		DateRestarted 
		DateInProcess 
		DateApproved 
		ProcessingNotes 
		DeclineRaceAndEthnicity 
		StudentSSN 
		Nickname 
		ReferralSource 
		*/

		FatherEducation = v.FatherEducation,
		MotherEducation = v.MotherEducation,
		HospitalPreference = v.HospitalPreference,

		FatherRoles = v.FatherRoles,
		MotherRoles = v.MotherRoles,

		FamilyChurchAttended = v.FamilyChurchAttended,
		FamilyChurchPastor = v.FamilyChurchPastor,
		FamilyChurchMember = v.FamilyChurchMember,
		FamilyChurchAttendFreq = v.FamilyChurchAttendFreq,
		FamilyChurchDenomination = v. FamilyChurchDenomination,

		FirstReconciliationYN = v.FirstReconciliationYN,
		FirstReconciliationDate = v.FirstReconciliationDate,
		FirstReconciliationChurch = v.FirstReconciliationChurch,
		HolyEucharistYN = v.HolyEucharistYN,
		HolyEucharistDate = v. HolyEucharistDate,
		HolyEucharistChurch = v.HolyEucharistChurch,
		ConfirmationYN = v.ConfirmationYN,
		ConfirmationDate = v.ConfirmationDate,
		ConfirmationChurch = v.ConfirmationChurch,

		/* Maybe good default candidate in future
		EnrollmentProgramID
		EnrollmentProgram 
		*/

		NoGuardian1 = v.NoGuardian1,
		Guardian1Fname = v.Guardian1Fname,
		Guardian1Mname = v.Guardian1Mname,
		Guardian1Lname = v.Guardian1Lname,
		Guardian1Suffix = v.Guardian1Suffix,
		Guardian1AddressDescription = v.Guardian1AddressDescription,
		Guardian1AddressName = v.Guardian1AddressName,
		Guardian1AddressLine1 = v.Guardian1AddressLine1,
		Guardian1AddressLine2 = v.Guardian1AddressLine2,
		Guardian1City = v.Guardian1City,
		Guardian1State = v.Guardian1State,
		Guardian1Zip = v.Guardian1Zip,
		Guardian1Occupation = v.Guardian1Occupation,
		Guardian1Employer = v.Guardian1Employer,
		Guardian1EmployerAddr = v.Guardian1EmployerAddr,
		Guardian1HomePhone = v.Guardian1HomePhone,
		Guardian1CellPhone = v.Guardian1CellPhone,
		Guardian1WorkPhone = v.Guardian1WorkPhone,
		Guardian1WorkExtension = v.Guardian1WorkExtension,
		Guardian1Email = v.Guardian1Email,
		Guardian1ChurchMember = v.Guardian1ChurchMember,
		Guardian1Church = v.Guardian1Church,
		Guardian1Roles = v.Guardian1Roles,
		--Guardian1Education = v.Guardian1Education, -- possible error
		Guardian1Relationship = v.Guardian1Relationship,
		NoGuardian2 = v.NoGuardian2,
		Guardian2Fname = v.Guardian2Fname,
		Guardian2Mname = v.Guardian2Mname,
		Guardian2Lname = v.Guardian2Lname,
		Guardian2Suffix = v.Guardian2Suffix,
		Guardian2AddressDescription = v.Guardian2AddressDescription,
		Guardian2AddressName = v.Guardian2AddressName,
		Guardian2AddressLine1 = v.Guardian2AddressLine1,
		Guardian2AddressLine2 = v.Guardian2AddressLine2,
		Guardian2City = v.Guardian2City,
		Guardian2State = v.Guardian2State,
		Guardian2Zip = v.Guardian2Zip,
		Guardian2Occupation = v.Guardian2Occupation,
		Guardian2Employer = v.Guardian2Employer,
		Guardian2EmployerAddr = v.Guardian2EmployerAddr,
		Guardian2HomePhone = v.Guardian2HomePhone,
		Guardian2CellPhone = v.Guardian2CellPhone,
		Guardian2WorkPhone = v.Guardian2WorkPhone,
		Guardian2WorkExtension = v.Guardian2WorkExtension,
		Guardian2Email = v.Guardian2Email,
		Guardian2ChurchMember = v.Guardian2ChurchMember,
		Guardian2Church = v.Guardian2Church,
		Guardian2Roles = v.Guardian2Roles,
		Guardian2Relationship = v.Guardian2Relationship,

		InsuranceCompany = v.InsuranceCompany,
		InsurancePolicyNumber = v.InsurancePolicyNumber,
		Contacts_Release_To_Any = v.Contacts_Release_To_Any,

		DentistFname = v.DentistFname,
		DentistLname = v.DentistLname,
		DentistPhone = v.DentistPhone,
		DentistAddress = v.DentistAddress,
		CatholicYN = v.CatholicYN,

		/* These will still be set ONLY if user actually edited page...
		Page_Intro 
		Page_Student 
		Page_Mother 
		Page_Father 
		Page_Guardian1 
		Page_Guardian2 
		Page_Family 
		Page_Contacts 
		Page_Worship 
		Page_Info 
		Page_Info2 
		Page_Tuition 
		Page_Submit 
		Page_Schools 
		Page_Medical 
		*/

		/* No defaults for school fields at present
		SchoolName1 
		SchoolAddr1 
		SchoolPhone1 
		SchoolGrades1 
		SchoolPrincipals1 
		SchoolTeachers1 
		SchoolName2 
		SchoolAddr2 
		SchoolPhone2 
		SchoolGrades2 
		SchoolName3 
		SchoolAddr3 
		SchoolPhone3 
		SchoolGrades3 
		SchoolSuspensionYN 
		SchoolSuspensionDesc 
		SchoolExpulsionYN 
		SchoolExpulsionDesc 
		SchoolLawEnforceYN 
		SchoolLawEnforceDesc 
		SchoolPsychiatricYN 
		SchoolPsychiatricDesc 
		SchoolLearnDisorderYN 
		SchoolLearnDisorderDesc 
		SchoolBilingualYN 
		SchoolBilingualDesc 
		SchoolIepYN 
		SchoolIepDesc 
		SchoolTranscriptYN 
		SchoolFirstYearYN 
		*/

		Tuition_Num_Children = v.Tuition_Num_Children,
		Tuition_Plan = v.Tuition_Plan,
		Tuition_Pay_Plan = v.Tuition_Pay_Plan,
		Morning_Care_Children = v.Morning_Care_Children,
		Kinder_Care_Children = v.Kinder_Care_Children,
		Aftercare_Children = v.Aftercare_Children,
		Aftercare_Days = v.Aftercare_Days,
		ExtendedCareYN = v.ExtendedCareYN,
		ExtendedCareSign = v.ExtendedCareSign,
		TuitionSign1 = v.TuitionSign1,
		TuitionSign2 = v.TuitionSign2,

		/*
		MedicationsYN 
		MedicationsDesc 
		*/

		/*
		EnteredByAdmin 
		ManualReenrollStudentID 
		ManualNewStudentLname 
		ManualNewStudentFname 
		HispanicOrLatino 
		Filipino 
		MiddleEasternSemitic 
		ImportStudentID 
		ImportFamilyID 
		StudentEmail 
		*/

		SchoolDistrict = v.SchoolDistrict

		/*
		QuickPayNotes 
		QuickPayAmount
		*/

		FROM ENROLLMENTSTUDENT es
		INNER JOIN VENROLLMENTSTUDENT v
		ON es.EnrollmentStudentID = v.EnrollmentStudentID
		where es.SessionID <> (select SessionID from EnrollmentFormSettings) -- not current session
			and isnull(es.FormStatus,'Started')<>'Started' -- make sure form was submitted before replicating
		--
		-- THE FOLLOWING SECTION IS OPTIONAL, but it simply represents whether or not any of the
		-- replaces above are needed and avoids updating rows if there are no changes.  It also helps me 
		-- monitor the need to keep running these queries by giving feedback on whether any schools still
		-- have default values that need to be memorialized...
		--

		and (
		es.Contact1Fname <> v.Contact1Fname or
		es.Contact1Lname <> v.Contact1Lname or
		es.Contact1Relationship <> v.Contact1Relationship or
		es.Contact1Phone1 <> v.Contact1Phone1 or
		es.Contact1Phone2 <> v.Contact1Phone2 or
		es.Contact2Fname <> v.Contact2Fname or
		es.Contact2Lname <> v.Contact2Lname or
		es.Contact2Relationship <> v.Contact2Relationship or
		es.Contact2Phone1 <> v.Contact2Phone1 or
		es.Contact2Phone2 <> v.Contact2Phone2 or
		es.Contact3Fname <> v.Contact3Fname or
		es.Contact3Lname <> v.Contact3Lname or
		es.Contact3Relationship <> v.Contact3Relationship or
		es.Contact3Phone1 <> v.Contact3Phone1 or
		es.Contact3Phone2 <> v.Contact3Phone2 or
		es.Contact4Fname <> v.Contact4Fname or
		es.Contact4Lname <> v.Contact4Lname or
		es.Contact4Relationship <> v.Contact4Relationship or
		es.Contact4Phone1 <> v.Contact4Phone1 or
		es.Contact4Phone2 <> v.Contact4Phone2 or
		es.Contact5Fname <> v.Contact5Fname or
		es.Contact5Lname <> v.Contact5Lname or
		es.Contact5Relationship <> v.Contact5Relationship or
		es.Contact5Phone1 <> v.Contact5Phone1 or
		es.Contact5Phone2 <> v.Contact5Phone2 or
		es.Contact6Fname <> v.Contact6Fname or
		es.Contact6Lname <> v.Contact6Lname or
		es.Contact6Relationship <> v.Contact6Relationship or
		es.Contact6Phone1 <> v.Contact6Phone1 or
		es.Contact6Phone2 <> v.Contact6Phone2 or
		es.Contact1Roles <> v.Contact1Roles or
		es.Contact2Roles <> v.Contact2Roles or
		es.Contact3Roles <> v.Contact3Roles or
		es.Contact4Roles <> v.Contact4Roles or
		es.Contact5Roles <> v.Contact5Roles or
		es.Contact6Roles <> v.Contact6Roles or
		es.Contact1Addr <> v.Contact1Addr or
		es.Contact2Addr <> v.Contact2Addr or
		es.Contact3Addr <> v.Contact3Addr or
		es.Contact4Addr <> v.Contact4Addr or
		es.Contact5Addr <> v.Contact5Addr or
		es.Contact6Addr <> v.Contact6Addr or

		es.FatherEducation <> v.FatherEducation or
		es.MotherEducation <> v.MotherEducation or
		es.HospitalPreference <> v.HospitalPreference or

		es.FatherRoles <> v.FatherRoles or
		es.MotherRoles <> v.MotherRoles or

		es.FamilyChurchAttended <> v.FamilyChurchAttended or
		es.FamilyChurchPastor <> v.FamilyChurchPastor or
		es.FamilyChurchMember <> v.FamilyChurchMember or
		es.FamilyChurchAttendFreq <> v.FamilyChurchAttendFreq or
		es.FamilyChurchDenomination <> v. FamilyChurchDenomination or

		es.FirstReconciliationYN <> v.FirstReconciliationYN or
		es.FirstReconciliationDate <> v.FirstReconciliationDate or
		es.FirstReconciliationChurch <> v.FirstReconciliationChurch or
		es.HolyEucharistYN <> v.HolyEucharistYN or
		es.HolyEucharistDate <> v. HolyEucharistDate or
		es.HolyEucharistChurch <> v.HolyEucharistChurch or
		es.ConfirmationYN <> v.ConfirmationYN or
		es.ConfirmationDate <> v.ConfirmationDate or
		es.ConfirmationChurch <> v.ConfirmationChurch or

		es.NoGuardian1 <> v.NoGuardian1 or
		es.Guardian1Fname <> v.Guardian1Fname or
		es.Guardian1Mname <> v.Guardian1Mname or
		es.Guardian1Lname <> v.Guardian1Lname or
		es.Guardian1Suffix <> v.Guardian1Suffix or
		es.Guardian1AddressDescription <> v.Guardian1AddressDescription or
		es.Guardian1AddressName <> v.Guardian1AddressName or
		es.Guardian1AddressLine1 <> v.Guardian1AddressLine1 or
		es.Guardian1AddressLine2 <> v.Guardian1AddressLine2 or
		es.Guardian1City <> v.Guardian1City or
		es.Guardian1State <> v.Guardian1State or
		es.Guardian1Zip <> v.Guardian1Zip or
		es.Guardian1Occupation <> v.Guardian1Occupation or
		es.Guardian1Employer <> v.Guardian1Employer or
		es.Guardian1EmployerAddr <> v.Guardian1EmployerAddr or
		es.Guardian1HomePhone <> v.Guardian1HomePhone or
		es.Guardian1CellPhone <> v.Guardian1CellPhone or
		es.Guardian1WorkPhone <> v.Guardian1WorkPhone or
		es.Guardian1WorkExtension <> v.Guardian1WorkExtension or
		es.Guardian1Email <> v.Guardian1Email or
		es.Guardian1ChurchMember <> v.Guardian1ChurchMember or
		es.Guardian1Church <> v.Guardian1Church or
		es.Guardian1Roles <> v.Guardian1Roles or

		es.Guardian1Relationship <> v.Guardian1Relationship or
		es.NoGuardian2 <> v.NoGuardian2 or
		es.Guardian2Fname <> v.Guardian2Fname or
		es.Guardian2Mname <> v.Guardian2Mname or
		es.Guardian2Lname <> v.Guardian2Lname or
		es.Guardian2Suffix <> v.Guardian2Suffix or
		es.Guardian2AddressDescription <> v.Guardian2AddressDescription or
		es.Guardian2AddressName <> v.Guardian2AddressName or
		es.Guardian2AddressLine1 <> v.Guardian2AddressLine1 or
		es.Guardian2AddressLine2 <> v.Guardian2AddressLine2 or
		es.Guardian2City <> v.Guardian2City or
		es.Guardian2State <> v.Guardian2State or
		es.Guardian2Zip <> v.Guardian2Zip or
		es.Guardian2Occupation <> v.Guardian2Occupation or
		es.Guardian2Employer <> v.Guardian2Employer or
		es.Guardian2EmployerAddr <> v.Guardian2EmployerAddr or
		es.Guardian2HomePhone <> v.Guardian2HomePhone or
		es.Guardian2CellPhone <> v.Guardian2CellPhone or
		es.Guardian2WorkPhone <> v.Guardian2WorkPhone or
		es.Guardian2WorkExtension <> v.Guardian2WorkExtension or
		es.Guardian2Email <> v.Guardian2Email or
		es.Guardian2ChurchMember <> v.Guardian2ChurchMember or
		es.Guardian2Church <> v.Guardian2Church or
		es.Guardian2Roles <> v.Guardian2Roles or
		es.Guardian2Relationship <> v.Guardian2Relationship or

		es.InsuranceCompany <> v.InsuranceCompany or
		es.InsurancePolicyNumber <> v.InsurancePolicyNumber or
		es.Contacts_Release_To_Any <> v.Contacts_Release_To_Any or

		es.DentistFname <> v.DentistFname or
		es.DentistLname <> v.DentistLname or
		es.DentistPhone <> v.DentistPhone or
		es.DentistAddress <> v.DentistAddress or
		es.CatholicYN <> v.CatholicYN or

		es.Tuition_Num_Children <> v.Tuition_Num_Children or
		es.Tuition_Plan <> v.Tuition_Plan or
		es.Tuition_Pay_Plan <> v.Tuition_Pay_Plan or
		es.Morning_Care_Children <> v.Morning_Care_Children or
		es.Kinder_Care_Children <> v.Kinder_Care_Children or
		es.Aftercare_Children <> v.Aftercare_Children or
		es.Aftercare_Days <> v.Aftercare_Days or
		es.ExtendedCareYN <> v.ExtendedCareYN or
		es.ExtendedCareSign <> v.ExtendedCareSign or
		es.TuitionSign1 <> v.TuitionSign1 or
		es.TuitionSign2 <> v.TuitionSign2 or

		es.SchoolDistrict <> v.SchoolDistrict
		)

	END
END
GO
