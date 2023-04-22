SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[glSaveEnrollMeDefaults]
as
begin

	declare @SessionID int = null;
	declare @InvoicePeriodID int = null;
	declare @FromDate date = null;
	declare @ThruDate date = null;
	declare @Status nchar(7) = null;
	declare @FromDateStr nvarchar(20) = '';
	declare @ThruDateStr nvarchar(20) = '';

	DECLARE @lastRunTime datetime;

	SET @lastRunTime = isnull(
		(select max(runTime) from joblog where title = 'Save EnrollMe defaults'), 
		cast('2000-01-01' as datetime));
	
	declare @pkids nvarchar(4000);
	declare @pk_id int;
	declare @pos int

	DECLARE @errmsg nvarchar(4000)  = null
	DECLARE @errsev int
	DECLARE @errsta int
	DECLARE @errnum int
	DECLARE @errpro nvarchar(4000)
	DECLARE @errlin int

	BEGIN TRANSACTION
	BEGIN TRY

		--
		-- Permanently record default values shown in view back into base enrollment form table.
		-- Only do this for records that are not in the current session and that have been submitted...
		--
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

		/* not used yet?
		PhotoRelease 
		SchoolDirectory 
		*/

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
		
		-- only update records with status updates since last batch process run
		INNER JOIN (
			select EnrollmentStudentID,MAX(UpdateDate) lastUpdated
			from EnrollStudentStatusDates
			where FormStatus<>'Started'
			and SessionID = (Select SessionID from EnrollmentFormSettings)
			group by EnrollmentStudentID
		) x on x.EnrollmentStudentID = es.EnrollmentStudentID
			and x.lastUpdated > @lastRunTime
		
		INNER JOIN VENROLLMENTSTUDENT v
		ON es.EnrollmentStudentID = v.EnrollmentStudentID
		
		where es.SessionID = (select SessionID from EnrollmentFormSettings) -- current session
			and isnull(es.FormStatus,'Started')<>'Started' -- make sure form was submitted before replicating

		DECLARE @okmsg nvarchar(4000) = cast(@@ROWCOUNT as nvarchar(10))+ ' rows updated'

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		SELECT @errmsg = ERROR_MESSAGE(), 
			@errsev = ERROR_SEVERITY(), 
			@errsta = ERROR_STATE(),
			@errnum = ERROR_NUMBER(),
			@errpro = ERROR_PROCEDURE(),
			@errlin = ERROR_LINE()
		IF @errsev <> 18
			SET @errmsg = @errmsg + '<br/>Error #:   ' + CAST(@errnum as nvarchar(20))
								  + '<br/>Procedure: ' + @errpro
								  + '<br/>Line #:    ' + CAST(@errlin as nvarchar(20))
								  
	END CATCH

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION

	IF @errmsg is not null or @okmsg <> '0 rows updated'
	BEGIN
		insert into JobLog (title, runTime, success, resultText)
		values (
			'Save EnrollMe defaults', 
			getdate(), 
			case when @errmsg is null then 1 else 0 end,
			isnull(@errmsg,@okmsg)
		)
	END
		
end


GO
