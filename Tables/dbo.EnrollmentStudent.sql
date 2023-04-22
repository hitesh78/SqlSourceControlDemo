CREATE TABLE [dbo].[EnrollmentStudent]
(
[EnrollmentStudentID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [bigint] NOT NULL CONSTRAINT [df_EnrollmentStudent_StudentID] DEFAULT ([dbo].[EnrollmentStudent_Default_StudentID]()),
[SessionID] [int] NULL,
[FormName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollFamilyID] [int] NULL,
[Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentHomePhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentCellPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentWorkPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthDate] [smalldatetime] NULL,
[Sex] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HispanicLatino] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmericanIndianOrAlaskaNative] [bit] NULL,
[Asian] [bit] NULL,
[BlackOrAfricanAmerican] [bit] NULL,
[NativeHawaiianOrPacificIslander] [bit] NULL,
[White] [bit] NULL,
[BirthCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthState] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthZip] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthCountry] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentBaptized] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BaptismDate] [date] NULL,
[BaptismChurch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoFather] [bit] NULL,
[FatherFname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherMname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherLname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherSuffix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherAddressDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherAddressName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherAddressLine1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherAddressLine2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherState] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherZip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherOccupation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherEmployer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherEmployerAddr] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherHomePhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherCellPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherWorkPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherWorkExtension] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherEmail] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherChurchMember] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherChurch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoMother] [bit] NULL,
[MotherFname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherMname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherLname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherSuffix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherAddressDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherAddressName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherAddressLine1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherAddressLine2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherState] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherZip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherOccupation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherEmployer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherEmployerAddr] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherHomePhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherCellPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherWorkPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherWorkExtension] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherEmail] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherChurchMember] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherChurch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeLevelOptionID] [int] NULL,
[EnteringGradeLevel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentLivesWithFather] [bit] NULL,
[StudentLivesWithMother] [bit] NULL,
[StudentLivesWithStepfather] [bit] NULL,
[StudentLivesWithStepmother] [bit] NULL,
[StudentLivesWithOther] [bit] NULL,
[StudentLivesWithDesc] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Divorced] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Custody] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling1FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling1LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling1DOB] [date] NULL,
[Sibling1Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling2FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling2LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling2DOB] [date] NULL,
[Sibling2Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling3FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling3LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling3DOB] [date] NULL,
[Sibling3Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling4FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling4LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling4DOB] [date] NULL,
[Sibling4Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoctorFname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoctorLname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoctorPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoctorAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TylenolOK] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TylenolChildOrJunior] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergies] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListAllergies] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhotoRelease] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolDirectory] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Relationship] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Phone1] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Phone2] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Relationship] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Phone1] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Phone2] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Relationship] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Phone1] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Phone2] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact4Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact4Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact4Relationship] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact4Phone1] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact4Phone2] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormStatus] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateStarted] [datetime] NULL,
[DateSubmitted] [datetime] NULL,
[DateRestarted] [datetime] NULL,
[DateInProcess] [datetime] NULL,
[DateApproved] [datetime] NULL,
[ProcessingNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeclineRaceAndEthnicity] [bit] NULL,
[StudentSSN] [nchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nickname] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralSource] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherEducation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherEducation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HospitalPreference] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherRoles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherRoles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyChurchAttended] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyChurchPastor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyChurchMember] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyChurchAttendFreq] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyChurchDenomination] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling1School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling2School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling3School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling4School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling5FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling5LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling5DOB] [date] NULL,
[Sibling5Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling5School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling6FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling6LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling6DOB] [date] NULL,
[Sibling6Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling6School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstReconciliationYN] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstReconciliationDate] [date] NULL,
[FirstReconciliationChurch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HolyEucharistYN] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HolyEucharistDate] [date] NULL,
[HolyEucharistChurch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConfirmationYN] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConfirmationDate] [date] NULL,
[ConfirmationChurch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentProgramID] [int] NULL,
[NoGuardian1] [bit] NULL,
[Guardian1Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Mname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Suffix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1AddressDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1AddressName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1AddressLine1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1AddressLine2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1City] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Zip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Occupation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Employer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1EmployerAddr] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1HomePhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1CellPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1WorkPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1WorkExtension] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Email] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1ChurchMember] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Church] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Education] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Relationship] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoGuardian2] [bit] NULL,
[Guardian2Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Mname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Suffix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2AddressDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2AddressName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2AddressLine1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2AddressLine2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2City] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Zip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Occupation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Employer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2EmployerAddr] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2HomePhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2CellPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2WorkPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2WorkExtension] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Email] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2ChurchMember] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Church] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Relationship] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentProgram] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsuranceCompany] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsurancePolicyNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contacts_Release_To_Any] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling7FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling7LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling7DOB] [date] NULL,
[Sibling7Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling7School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling8FName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling8LName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling8DOB] [date] NULL,
[Sibling8Grade] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sibling8School] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DentistFname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DentistLname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DentistPhone] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DentistAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CatholicYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Page_Intro] [bit] NULL,
[Page_Student] [bit] NULL,
[Page_Mother] [bit] NULL,
[Page_Father] [bit] NULL,
[Page_Guardian1] [bit] NULL,
[Page_Guardian2] [bit] NULL,
[Page_Family] [bit] NULL,
[Page_Contacts] [bit] NULL,
[Page_Worship] [bit] NULL,
[Page_Info] [bit] NULL,
[Page_Info2] [bit] NULL,
[Page_Tuition] [bit] NULL,
[Page_Submit] [bit] NULL,
[Page_Schools] [bit] NULL,
[SchoolName1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolAddr1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPhone1] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolGrades1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPrincipals1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolTeachers1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolName2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolAddr2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPhone2] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolGrades2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolName3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolAddr3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPhone3] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolGrades3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolSuspensionYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolSuspensionDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolExpulsionYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolExpulsionDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolLawEnforceYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolLawEnforceDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPsychiatricYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPsychiatricDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolLearnDisorderYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolLearnDisorderDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolBilingualYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolBilingualDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolIepYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolIepDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolTranscriptYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolFirstYearYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tuition_Num_Children] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tuition_Plan] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tuition_Pay_Plan] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Morning_Care_Children] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Kinder_Care_Children] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Aftercare_Children] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Aftercare_Days] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherSSN] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherSSN] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicationsYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicationsDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendedCareYN] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendedCareSign] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TuitionSign1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TuitionSign2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Page_Medical] [bit] NULL,
[EnteredByAdmin] [bit] NOT NULL CONSTRAINT [DF_EnrollmentStudent_EnteredByAdmin] DEFAULT ((0)),
[Contact5Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact5Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact5Relationship] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact5Phone1] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact5Phone2] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact6Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact6Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact6Relationship] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact6Phone1] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact6Phone2] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact4Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact5Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact6Roles] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Addr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Addr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Addr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact4Addr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact5Addr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact6Addr] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ManualReenrollStudentID] [int] NULL,
[ManualNewStudentLname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ManualNewStudentFname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HispanicOrLatino] [bit] NULL,
[Filipino] [bit] NULL,
[MiddleEasternSemitic] [bit] NULL,
[ImportStudentID] [int] NULL,
[ImportFamilyID] [int] NULL,
[StudentEmail] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentLivesWithGuardian1] [bit] NULL,
[StudentLivesWithGuardian2] [bit] NULL,
[SchoolDistrict] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuickPayNotes] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuickPayAmount] [money] NULL,
[program] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[term_start] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[degree] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[major] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[duration] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[other_program] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[housing_type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[other_housing] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[learn_about] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[learn_about_name] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergy] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergy_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergy_epipen] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergy_food] [bit] NULL,
[Allergy_insects] [bit] NULL,
[Allergy_pollens] [bit] NULL,
[Allergy_animals] [bit] NULL,
[Allergy_medications] [bit] NULL,
[Asthma_Inhailer] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diabetes_Care] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HearingLoss_HearingAid] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concerns_SpeakToNurse] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADD_ADHD] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADD_ADHD_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asthma] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asthma_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoneOrMuscleCond] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoneOrMuscleCond_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diabetes] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diabetes_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EarThroatInf] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EarThroatInf_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmotionalProb] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmotionalProb_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fainting] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fainting_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Headaches] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Headaches_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MajorInjury] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MajorInjury_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HeartBlood] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HeartBlood_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HearingLoss] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HearingLoss_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalHandicap] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalHandicap_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seizures] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seizures_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkinProb] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkinProb_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UrinaryBowel] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UrinaryBowel_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vision] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vision_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HospOper] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HospOper_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concerns] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concerns_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vision_Glasses] [bit] NULL,
[Vision_Contacts] [bit] NULL,
[Vision_Wears_always] [bit] NULL,
[Vision_Wears_sometimes] [bit] NULL,
[Vision_Surgery] [bit] NULL,
[Allergy_attribs] AS (replace(rtrim(((((case  when isnull([Allergy_epipen],'')='Yes' then 'Epi-Pen at school  ' else '' end+case  when [Allergy_food]=(1) then 'Food  ' else '' end)+case  when [Allergy_insects]=(1) then 'Insect bites and stings  ' else '' end)+case  when [Allergy_pollens]=(1) then 'Pollens  ' else '' end)+case  when [Allergy_animals]=(1) then 'Animals  ' else '' end)+case  when [Allergy_medications]=(1) then 'Medications  ' else '' end),'  ','; ')),
[Asthma_attribs] AS (case  when isnull([Asthma_Inhailer],'')='Yes' then 'Inhailer at school  ' else '' end),
[Diabetes_attribs] AS (case  when isnull([Diabetes_Care],'')='Yes' then 'Insulin and glucometer at school' else '' end),
[HearingLoss_attribs] AS (case  when isnull([HearingLoss_HearingAid],'')='Yes' then 'Wears hearing aid' else '' end),
[Concerns_attribs] AS (case  when isnull([Concerns_SpeakToNurse],'')='Yes' then 'Requests Nurse call' else '' end),
[Vision_attribs] AS (replace(rtrim((((case  when [Vision_Glasses]=(1) then 'Wears glasses  ' else '' end+case  when [Vision_Contacts]=(1) then 'Wears contacts  ' else '' end)+case  when [Vision_Wears_always]=(1) then 'Wears all the time  ' else '' end)+case  when [Vision_Wears_sometimes]=(1) then 'Wears some of the time  ' else '' end)+case  when [Vision_Surgery]=(1) then 'Eye surgery history  ' else '' end),'  ','; ')),
[Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherCountry] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MotherCountry] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian1Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Guardian2Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glName] AS (case isnull(session_context(N'AdminLanguage'),'English') when 'Chinese' then (isnull([Lname],'')+isnull([Fname],''))+case  when len(ltrim(rtrim([NickName])))>(0) then (' ('+[NickName])+')' else '' end else ((isnull([Lname]+', ','')+isnull([Fname],''))+case  when len(ltrim(rtrim([Mname])))>(0) then (' '+left([Mname],(1)))+'.' else '' end)+case  when len(ltrim(rtrim([NickName])))>(0) then (' ('+[NickName])+')' else '' end end),
[Campus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[DEL_CleanupVenrollmentstudentXmlRecords]
 on [dbo].[EnrollmentStudent]
 After Delete
As

 Delete xml_records
	from xml_records x
	inner join Deleted d
	on x.table_pk_id = d.StudentID 
		and x.table_name = 'vEnrollmentStudent'

 Delete from BinFiles 
	Where FileID in 
		( select FileID
			from EnrollmentStudentBinFiles esbf
			inner join Deleted d
			on esbf.StudentID = d.StudentID and esbf.EnrollSessionID = d.SessionID )

 delete EnrollmentStudentBinFiles
   from EnrollmentStudentBinFiles esbf
   inner join Deleted d
   on esbf.StudentID = d.StudentID and esbf.EnrollSessionID = d.SessionID

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[EnrollmentStudent_Block_Submit]
   ON  [dbo].[EnrollmentStudent]
   AFTER UPDATE, INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	IF (select distinct 1
		from inserted i
		where (isnull(lname,'') = '' or isnull(fname,'') = '' or SessionID is null)
			and isnull(i.FormStatus,'Started') not in ('Started','Cancelled')) = 1
	begin
		ROLLBACK TRANSACTION;
		RAISERROR ('There was a problem saving the student''s name or grade level. Please verify that name and grade level are filled-in on the first ''Student'' tab before submitting this form.',15,1);
		return;
	end

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[EnrollmentStudent_Set_SessionID]
   ON  [dbo].[EnrollmentStudent]
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	--
	-- TODO: 
	-- One more use case could be covered.  If a prior session is re-opened (normally there is NO
	-- reason to do this) then custom fields for that session are archived for submitted forms.
	-- Later, if the more recent/current session is opened and the submitted form is re-started
	-- and hanged, then the archive data previously stored for that form and session should be 
	-- cleared/deleted...  This is a very rare scenario that we probably don't need to address but
	-- since I thought of it, it does represent a potential, future upgrade to this trigger....
	--

  -- handle audit trail log updates...
	insert into EnrollStudentStatusDates 
			(EnrollmentStudentID,FormStatus,SessionID)
		select i.EnrollmentStudentID,
				isnull(i.FormStatus,'Started'),
				(select SessionID from EnrollmentFormSettings)
			from EnrollmentStudent es
			inner join inserted i 
				on i.EnrollmentStudentID = es.EnrollmentStudentID
			left join deleted d 
				on d.EnrollmentStudentID = i.EnrollmentStudentID
			where (isnull(i.FormStatus,'Started')
				<>isnull(d.FormStatus,'Started')
				-- only create started record once a name is entered on student page...
				or d.page_student is null
				or d.lname is null)
				-- and i.page_student=1 -- 5/28/14, COMMENT OUT, NOT ALWAYS SET - Duke
				and isnull(i.lname,'')>''

    -- handle audit trail updates for session changes
	insert into EnrollStudentStatusDates 
			(EnrollmentStudentID,FormStatus,SessionID)
		select i.EnrollmentStudentID,'Session changed',i.SessionID
			from EnrollmentStudent es
			inner join inserted i 
				on i.EnrollmentStudentID = es.EnrollmentStudentID
			inner join deleted d 
				on d.EnrollmentStudentID = i.EnrollmentStudentID
			where i.SessionID<>d.SessionID

	-- If we detect that a prior ImportStudentID is orphaned (that new student imported record was deleted)
	-- then add an import deleted status record if the user is selecting another ImportStudentID...
	-- Fresh Desk #102303, Jira I18N-232...
	insert into EnrollStudentStatusDates 
			(EnrollmentStudentID,FormStatus,SessionID)
		select d.EnrollmentStudentID,'Import deleted',
				(select SessionID from EnrollmentFormSettings)
			from EnrollmentStudent es -- maybe no needed but doesn't hurt
			inner join inserted i
				on i.EnrollmentStudentID = es.EnrollmentStudentID
			inner join deleted d 
				on d.EnrollmentStudentID = i.EnrollmentStudentID
			where d.ImportStudentID is not NULL
				and isnull(i.ImportStudentID,'')<>d.ImportStudentID
				and (select 1 from Students where StudentID = d.ImportStudentID) is NULL
					-- orphaned test, we can assume record is New Enroll that was previously imported
					-- because d.ImportStudentID is null.
					-- We could also add this row even if user is not changing ImportStudentID,
					-- but we just don't need to except to block incorrectly categorizing
					-- record as Imported merely as a result of relinking to a new student....
					-- (this rule is easier to code than others that query prior status, etc...)

	-- If i.EnrollmentProgram set, then use that to update IDs (we allow entry of either)...
	if update(EnrollmentProgram) 
		update EnrollmentStudent
			set EnrollmentProgramID = ep.EnrollmentProgramID
			from EnrollmentStudent es
			inner join inserted i on i.EnrollmentStudentID = es.EnrollmentStudentID
			inner join EnrollmentPrograms ep on ep.EnrollmentProgram = i.EnrollmentProgram
			where  ep.EnrollmentProgramID is not null

    -- For the insert cases only, set defaulted StudentID form ManualReenrollStudentID if present
	update es
		set 
			StudentID = es.ManualReenrollStudentID, 
			EnteredByAdmin = 1
		from EnrollmentStudent es
		inner join inserted i on i.EnrollmentStudentID = es.EnrollmentStudentID
		inner join students s on es.ManualReenrollStudentID = s.StudentID
		where -- i.ManualReenrollStudentID is not null and -- inner join handles
		i.StudentID>999999999 -- (correct default student ID>=1B)
		and i.EnrollmentStudentID not in (select EnrollmentStudentID from deleted)

    -- For the insert cases only, set First and Last names for a new enrollment (from admin interface)
	update es
		set EnteredByAdmin = 1,
			Lname = es.ManualNewStudentLname,
			Fname = es.ManualNewStudentFname
		from EnrollmentStudent es
		inner join inserted i on i.EnrollmentStudentID = es.EnrollmentStudentID
		where i.ManualReenrollStudentID is null and i.ManualNewStudentLname is not null
		and i.StudentID>999999999 -- (correct default student ID>=1B)
		and i.EnrollmentStudentID not in (select EnrollmentStudentID from deleted)

	--
	-- NOTE:
	-- The next code in this trigger will not break or throw an error
	-- on multiple row updates, but it uses @@ROWCOUNT to 
	-- run cases that will be only mutually exclusive assuming an
	-- update to a single row.  That is OK because Enrollment
	-- forms can ony be moved to new sessions or added
	-- one-by-one...
	-- This logic just speeds up the trigger...
	--
	
	declare @currSessionID int = (select SessionID from EnrollmentFormSettings);

	--------------------------------------
	-- Initialize sessions for new rows...
	--------------------------------------
	update es 
		set SessionID = @currSessionID
		from EnrollmentStudent es
			inner join inserted i 
				on i.EnrollmentStudentID = es.EnrollmentStudentID
			left join deleted d
				on d.EnrollmentStudentID = es.EnrollmentStudentID
			where d.EnrollmentStudentID is null
			and es.SessionID is null

	-----------------------------------------------
	-- Also, handle custom field replication or 
	-- orphan cleanup when SessionID is changed...
	-----------------------------------------------

	-- delete orphaned custom field data that was replicated 
	-- when the form was changed from current to archival for 
	-- re-enroll forms being brought back to current session
	-- so that moving these forms back to archive status will
	-- capture any updated custom fields if edits were made
	-- under the current status...
	delete x 
	from xml_records x
	where 
	-- only registration custom fields for re-enrollments...
	entityName like 'Reg%' -- important!
	and x.table_pk_id<0 -- important!
	-- for updated student rows being moved to the current session...
	and (-x.table_pk_id%1000000000) in (
			Select i.StudentID 
				from inserted i
				inner join deleted d
				on i.EnrollmentStudentID = d.EnrollmentStudentID
					and d.SessionID is not null
					and i.SessionID <> d.SessionID 
					and i.SessionID = @currSessionID)
	-- that are xml custom field rows are becoming orphaned 
	-- based on a student and session id search...
	and (
		Select distinct 1 
		from EnrollmentStudent
		where StudentID = (-x.table_pk_id%1000000000)
			and SessionID = (-x.table_pk_id/1000000000)
			-- previously archived fields in the now current session are subject to clean up too....
			and SessionID <> @currSessionID
	) is null
	-- Safeguard - make sure the custom fields are still in "current" session
	and (
		Select distinct 1 
		from xml_records
		where table_pk_id 
			-- (current session custom fields are stored under student id
			--  without any mangled (negative) session prefix)
			= (-x.table_pk_id%1000000000)
	) is not null

	--
	-- Or, see if we are going the other way, and changing
	-- a current session re-enroll form to a prior session,
	-- in which case we need to replicate the current-session
	-- custom fields to the prior session target...
	--
	IF @@ROWCOUNT = 0
	BEGIN
		--
		-- Replicate reenrolling students XML data to any non-current sessions that do not already contain it.
		-- This will preserve the xml data for historical reenrollment forms.
		-- Only copy for submitted forms so that we avoid copying incomplete data
		--
		insert into xml_records
			select table_name,entityName,
			-(cast(SessionID as bigint)*1000000000 + StudentID) as table_pk_id,
			xml_fields,records_version,deprecated
			from xml_records
			inner join (
				select StudentID, -- always positive, so will match "current session" custom fields in join...
					SessionID from inserted
				where studentID<1000000000 -- reenroll only
				and SessionID <> @currSessionID -- not current session
				and -(cast(SessionID as bigint)*1000000000 + StudentID) 
					not in (select table_pk_id from xml_records) -- don't overwrite previously replicated xml data
				and (isnull(FormStatus,'Started')<>'Started') -- make sure form was submitted before replicating
			) x
			on xml_records.table_pk_id = x.StudentID 
				and xml_records.entityName like 'Reg%'
	END

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[EnrollmentStudent_Sync_Allergy_Fields]
   ON  [dbo].[EnrollmentStudent]
   AFTER INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	
	--
	-- NOTE:
	-- The code in this trigger will not break or throw an error
	-- on multiple row updates, but it uses @@ROWCOUNT to 
	-- run cases that will be only mutually exclusive assuming an
	-- update to a single row.  That is OK because 	allergy data is entered
	-- one student at a time and we assume that it isn't being mass
	-- edited or imported.  Any import case can handle proper syncing
	-- of these fields anyway...
	-- This logic just speeds up the trigger...
	--

	if update(Allergies) or update(ListAllergies) 
		or update(Allergy) or update(Allergy_Comments)
	begin
		-- 
		-- Replicate MedicalHistory allergies to stand-alone field if history form
		-- is turned on and fields have changed
		--
		update es 
			set Allergies = rtrim(i.Allergy), ListAllergies = rtrim(i.Allergy_Comments)
		from EnrollmentStudent es
		inner join inserted i 
			on es.EnrollmentStudentID = i.EnrollmentStudentID
		left join deleted d
			on es.EnrollmentStudentID = d.EnrollmentStudentID
		where 
			(	isnull(i.Allergy,'')<>isnull(d.Allergy,'')
			 or isnull(i.Allergy_Comments,'')<>isnull(d.Allergy_Comments,'') )
			AND (case when i.StudentID > 999999999
				then (Select New_Enroll_Fields_To_Incl from EnrollmentFormSettings)
				else (Select Configurable_Fields_To_Incl from EnrollmentFormSettings)
				end) LIKE '%Medical-History%'
						
		if @@ROWCOUNT = 0
		begin
			-- 
			-- Replicate stand-alone allergies to health history form allergy fields
			-- if stand-alone fields have changed and those fields are turned on
			--
			update es 
				set Allergy = rtrim(i.Allergies), Allergy_Comments = rtrim(i.ListAllergies)
			from EnrollmentStudent es
			inner join inserted i 
				on es.EnrollmentStudentID = i.EnrollmentStudentID
			left join deleted d
				on es.EnrollmentStudentID = d.EnrollmentStudentID
			where
				(	isnull(i.Allergies,'')<>isnull(d.Allergies,'')
					or isnull(i.ListAllergies,'')<>isnull(d.ListAllergies,'') )
				AND (case when i.StudentID > 999999999
					then (Select New_Enroll_Fields_To_Incl from EnrollmentFormSettings)
					else (Select Configurable_Fields_To_Incl from EnrollmentFormSettings)
					end) LIKE '%Medical-Allergies%'

			if @@ROWCOUNT = 0
			begin
				--
				-- If medical history form is not on rollback and don't allow
				-- nulling replicate allergy field values
				-- (SIS framework can nullify fields not displayed on forms)
				--
				update es 
					set Allergy = d.Allergy, Allergy_Comments = d.Allergy_Comments
				from EnrollmentStudent es
				inner join inserted i 
					on es.EnrollmentStudentID = i.EnrollmentStudentID
				left join deleted d
					on es.EnrollmentStudentID = d.EnrollmentStudentID
				where ((i.allergy is null and d.allergy is not null)
					or (i.allergy_comments is null and d.allergy_comments is not null))
					AND (case when i.StudentID > 999999999
						then (Select New_Enroll_Fields_To_Incl from EnrollmentFormSettings)
						else (Select Configurable_Fields_To_Incl from EnrollmentFormSettings)
						end) NOT LIKE '%Medical-History%'

				if @@ROWCOUNT = 0
				begin
					--
					-- If stand alone allergy fields are not turned on
					-- rollback and don't allow these fields to be nullified
					-- (SIS framework can nullify fields not displayed on forms)
					--
					update es 
						set Allergies = rtrim(d.Allergies), ListAllergies = rtrim(d.ListAllergies)
					from EnrollmentStudent es
					inner join inserted i 
						on es.EnrollmentStudentID = i.EnrollmentStudentID
					left join deleted d
						on es.EnrollmentStudentID = d.EnrollmentStudentID
					where ( (i.Allergies is null and d.Allergies is not null)
						or (i.ListAllergies is null and d.ListAllergies is not null) )
						AND (case when i.StudentID > 999999999
							then (Select New_Enroll_Fields_To_Incl from EnrollmentFormSettings)
							else (Select Configurable_Fields_To_Incl from EnrollmentFormSettings)
							end) NOT LIKE '%Medical-Allergies%'
				end		

			end

		end
			
	end

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create   Trigger [dbo].[UpdatePSPaymentsGLXrefID]
   ON  [dbo].[EnrollmentStudent]
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

-- Update GLXrefID from EnrollmentStudent if possible
Update PSPayments
Set GLXrefID = x.ImportStudentID
From
PSPayments P
	inner join
(
	Select
	P.PSPaymentID,
	i.ImportStudentID
	From 
	PSPayments P
		inner join
	inserted i
		on P.GLXrefID = i.StudentID
	Where
	P.GLXrefID > 1000000
	and
	i.ImportStudentID is not null
) x
	on x.PSPaymentID = P.PSPaymentID;

END

GO
ALTER TABLE [dbo].[EnrollmentStudent] ADD CONSTRAINT [PK_EnrollmentStudent] PRIMARY KEY CLUSTERED ([EnrollmentStudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentStudent_EnrollFamilyID] ON [dbo].[EnrollmentStudent] ([EnrollFamilyID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentStudent_StudentID] ON [dbo].[EnrollmentStudent] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_EnrollmentStudent_StudentID_SessionID_FormName] ON [dbo].[EnrollmentStudent] ([StudentID], [SessionID], [FormName]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
