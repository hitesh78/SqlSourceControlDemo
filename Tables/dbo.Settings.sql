CREATE TABLE [dbo].[Settings]
(
[SettingID] [tinyint] NOT NULL IDENTITY(1, 1),
[MultiLanguageSupport] [bit] NOT NULL CONSTRAINT [DF_Settings_MultiLanguageSupport] DEFAULT ((0)),
[CreditNoCreditPassingGrade] [int] NOT NULL CONSTRAINT [DF_Settings_CreditNoCreditPassingGrade] DEFAULT ((70)),
[TeachersCanPopulateClasses] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanPopulateClasses] DEFAULT ((0)),
[TeachersCanPrintProgressReports] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanPrintProgressReports] DEFAULT ((0)),
[TeachersCanPrintSingleTermReportCards] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanPrintSingleTermReportCards] DEFAULT ((0)),
[TeachersCanPrintMultiTermReportCards] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanPrintMultiTermReportCards] DEFAULT ((0)),
[TeachersCanConcludeClasses] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanConcludeClasses] DEFAULT ((1)),
[TeachersCanViewCurrentGrades] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanViewCurrentGrades] DEFAULT ((1)),
[TeachersCanSeeStudentContactInfo] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanSeeStudentContactInfo] DEFAULT ((1)),
[TeachersCanSeeStudentRoster] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanSeeStudentRoster] DEFAULT ((1)),
[TeachersCanSeeStaffRoster] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanSeeStaffRoster] DEFAULT ((1)),
[HideTermsOlderThanXDays] [smallint] NOT NULL CONSTRAINT [DF_Settings_HideTermsOlderThanXDays] DEFAULT ((400)),
[TermCommentsCharLimit] [smallint] NOT NULL CONSTRAINT [DF_Settings_TermCommentsLimit] DEFAULT ((500)),
[TermCommentsLineLimit] [tinyint] NOT NULL CONSTRAINT [DF_Settings_TermCommentsLineLimit] DEFAULT ((7)),
[ParentsCanViewBellCurveGraph] [bit] NOT NULL CONSTRAINT [DF_Settings_ParentsCanViewBellCurveGraph] DEFAULT ((1)),
[CustomUnits] [bit] NOT NULL CONSTRAINT [DF_Settings_CustomUnits] DEFAULT ((0)),
[TurnOffAttendanceAlerts] [bit] NOT NULL CONSTRAINT [DF_Settings_TurnOffAttendanceAlerts] DEFAULT ((0)),
[GradeAverageBasedonTypeWeight] [bit] NOT NULL CONSTRAINT [DF_Settings_GradeAverageBasedonTypeWeight] DEFAULT ((0)),
[ShowTeacherEmail] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowTeacherEmail] DEFAULT ((0)),
[ShowParentGPA] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowParentGPA] DEFAULT ((1)),
[ShowTranscriptInformation] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowTranscriptInformation] DEFAULT ((1)),
[LockAllStudents] [bit] NOT NULL CONSTRAINT [DF_Settings_LockAllStudents] DEFAULT ((0)),
[LockoutReason] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowPercentageOnTranscript] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowPercentageOnTranscript] DEFAULT ((0)),
[OfficialStateGPA] [bit] NULL CONSTRAINT [DF_Settings_OfficialStateGPA] DEFAULT ((0)),
[ClassRankUseGradDate] [bit] NOT NULL CONSTRAINT [DF_Settings_ClassRankUseGradDate] DEFAULT ((0)),
[DisplayClassRank] [bit] NOT NULL CONSTRAINT [DF_Settings_DisplayClassRank] DEFAULT ((1)),
[LowTranscriptGradeLevel] [int] NOT NULL CONSTRAINT [DF_Settings_LowTranscriptGradeLevel] DEFAULT ((9)),
[HiTranscriptGradeLevel] [int] NOT NULL CONSTRAINT [DF_Settings_HiTranscriptGradeLevel] DEFAULT ((12)),
[TranscriptProfileID] [tinyint] NULL,
[AttendanceSheetProfileID] [tinyint] NULL,
[TranscriptSchoolAuthTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_TranscriptSchoolAuthTitle] DEFAULT ('Principal/Administrator'),
[SchoolID] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowOnlyChurchAttendance] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowOnlyChurchAttendance] DEFAULT ((0)),
[EnablePDFWriter] [bit] NOT NULL CONSTRAINT [DF_Settings_EnablePDFWriter] DEFAULT ((0)),
[MinPasswordLength] [tinyint] NOT NULL CONSTRAINT [DF_Settings_MinPasswordLength] DEFAULT ((6)),
[ChangePasswordEvery] [smallint] NOT NULL CONSTRAINT [DF_Settings_ChangePasswordEvery] DEFAULT ((-1)),
[TimeOutLength] [int] NOT NULL CONSTRAINT [DF_Settings_TimeOutLength] DEFAULT ((3600000)),
[LockAcctAfterXDays] [smallint] NOT NULL CONSTRAINT [DF_Settings_LockAcctAfterXDays] DEFAULT ((-1)),
[AttendanceEntry] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SportEligibilityGPA] [decimal] (3, 2) NOT NULL CONSTRAINT [DF_Settings_SportEligibilityGPA] DEFAULT ((2.00)),
[SpanishReports] [bit] NOT NULL CONSTRAINT [DF_Settings_SpanishReports] DEFAULT ((0)),
[SchoolName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolStreet] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolCity] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolState] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolZip] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPhone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolFax] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPrincipal] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolContact] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolEmailAddress] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolWebSite] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CategoryName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_EffortName] DEFAULT ('Effort'),
[CategoryAbbr] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_EffortAbbr] DEFAULT ('Eff'),
[Category1Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_Effort1Symbol] DEFAULT ('O'),
[Category1Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Effort1Description] DEFAULT ('Outstanding'),
[Category2Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_Effort2Symbol] DEFAULT ('S'),
[Category2Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Effort2Description] DEFAULT ('Satisfactory'),
[Category3Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_Effort3Symbol] DEFAULT ('N'),
[Category3Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Effort3Description] DEFAULT ('Needs Improvement'),
[Category4Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_Effort4Symbol] DEFAULT ('U'),
[Category4Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Effort4Description] DEFAULT ('Unsatisfactory'),
[CommentName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_CommentName] DEFAULT ('Comments'),
[CommentAbbr] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_CommentAbbr] DEFAULT ('Com'),
[Comment1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment5] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment6] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment7] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment8] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment9] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment10] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment11] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment12] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment13] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment14] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment15] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment16] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment17] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment18] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment19] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment20] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment21] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment22] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment23] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment24] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment25] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment26] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment27] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment28] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment29] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment30] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Attendance1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Attendance1] DEFAULT ('Present'),
[Attendance1Legend] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Attendance2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Attendance2] DEFAULT ('Ex. Tardy'),
[Attendance2Legend] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Attendance3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Attendance3] DEFAULT ('Ex. Absent'''),
[Attendance3Legend] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Attendance4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Attendance4] DEFAULT ('Unex. Tardy'),
[Attendance4Legend] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Attendance5] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Attendance5] DEFAULT ('Unex. Absent'),
[Attendance5Legend] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DailyAttendance] [bit] NOT NULL CONSTRAINT [DF_Settings_DailyAttendance] DEFAULT ((1)),
[ClassAttendance] [bit] NOT NULL CONSTRAINT [DF_Settings_ClassAttendance] DEFAULT ((1)),
[TermCommentsFormat] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_TermCommentsFormat] DEFAULT ('PlainText'),
[EnablePercentageGradeOnNewTranscriptRecords] [bit] NOT NULL CONSTRAINT [DF_Settings_EnablePercentageGradeOnNewTranscriptRecords] DEFAULT ((0)),
[EnableStudentLockerInfo] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableStudentLockerInfo] DEFAULT ((0)),
[EnableNewMultiTermReportCard] [bit] NULL CONSTRAINT [DF_Settings_EnableNewMultiTermReportCard] DEFAULT ((0)),
[TeachersCanViewStudentNotes] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanViewStudentNotes] DEFAULT ((0)),
[TeachersCanViewEffortTab] [bit] NOT NULL CONSTRAINT [DF_Settings_AllowEffortTab] DEFAULT ((1)),
[ParentsCanViewAttendanceComments] [bit] NOT NULL CONSTRAINT [DF_Settings_ParentsCanViewAttendanceComments] DEFAULT ((0)),
[AttSunday] [bit] NOT NULL CONSTRAINT [DF_Settings_AttSundat] DEFAULT ((1)),
[AttMonday] [bit] NOT NULL CONSTRAINT [DF_Settings_AttMonday] DEFAULT ((1)),
[AttTuesday] [bit] NOT NULL CONSTRAINT [DF_Settings_AttTuesday] DEFAULT ((1)),
[AttWednesday] [bit] NOT NULL CONSTRAINT [DF_Settings_AttWednesday] DEFAULT ((1)),
[AttThursday] [bit] NOT NULL CONSTRAINT [DF_Settings_AttThursday] DEFAULT ((1)),
[AttFriday] [bit] NOT NULL CONSTRAINT [DF_Settings_AttFriday] DEFAULT ((1)),
[AttSaturday] [bit] NOT NULL CONSTRAINT [DF_Settings_AttSaturday] DEFAULT ((1)),
[TranscriptOrderCreditClassesLast] [bit] NOT NULL CONSTRAINT [DF_Settings_TranscriptOrderCreditClassesLast] DEFAULT ((1)),
[DisableDepopulateSafety] [datetime] NOT NULL CONSTRAINT [DF_Settings_DisableDepopulateSafety] DEFAULT ('2010-11-04 14:34:58.110'),
[RunDeficiencyReportOnAllClasses] [bit] NOT NULL CONSTRAINT [DF_Settings_RunDeficiencyReportOnAllClasses] DEFAULT ((0)),
[AllowParentsToViewPastGrades] [bit] NOT NULL CONSTRAINT [DF_Settings_AllowParentsToViewPastGrades] DEFAULT ((1)),
[EnableDoubleRoundingOnSemesterGrade] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableDoubleRoundingOnSemesterGrade] DEFAULT ((0)),
[AllowBulkEmailAccess] [bit] NOT NULL CONSTRAINT [DF_Settings_AllowBulkEmailAccess] DEFAULT ((0)),
[SchoolStartMonth] [tinyint] NOT NULL CONSTRAINT [DF_Settings_SchoolStartMonth] DEFAULT ((8)),
[SchoolEndMonth] [tinyint] NOT NULL CONSTRAINT [DF_Settings_SchoolEndMonth] DEFAULT ((6)),
[PreSelectTermsOnReportCard] [bit] NOT NULL CONSTRAINT [DF_Settings_PreSelectTermsOnReportCard] DEFAULT ((1)),
[AllowAdminToSchoolEmail] [bit] NOT NULL CONSTRAINT [DF_Settings_AllowAdminToSchoolEmail] DEFAULT ((0)),
[InProgressShowGrades] [bit] NOT NULL CONSTRAINT [DF_Settings_InProgressShowGrades] DEFAULT ((0)),
[ShowNonAcademicClassSetting] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowNonAcademicClassSetting] DEFAULT ((0)),
[BCCemailAddress] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BCCemailACK] [bit] NOT NULL CONSTRAINT [DF_Settings_BCCemailACK] DEFAULT ((0)),
[UseNewStudentInterface] [bit] NOT NULL CONSTRAINT [DF_Settings_UseNewStudentInterface] DEFAULT ((1)),
[LimitConcludedPercentageGrades] [int] NOT NULL CONSTRAINT [DF_Settings_LimitConcludedPercentageGrades] DEFAULT ((100)),
[ShowPercentageGradesOnParentTranscript] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowPercentageGradesOnParentTranscript] DEFAULT ((0)),
[DateFormat] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_DateFormat] DEFAULT ('mm/dd/yy'),
[TimeZone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_TimeZone] DEFAULT ('Pacific Time (-8)'),
[TimeZoneOffset] [int] NOT NULL CONSTRAINT [DF_Settings_TimeZoneOffset] DEFAULT ((-480)),
[EnableDaylightSavingsTime] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableDaylightSavingsTime] DEFAULT ((1)),
[TeachersCanViewGPAScoresReport] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanViewGPAScoresReport] DEFAULT ((1)),
[SportsEligibilityLetterGrade] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HideGPAonTranscript] [bit] NOT NULL CONSTRAINT [DF_Settings_HideGPAonTranscript] DEFAULT ((0)),
[SupportSCUniversalGradeScale] [bit] NOT NULL CONSTRAINT [DF_Settings_SupportSCUniversalGradeScale] DEFAULT ((0)),
[AllowLockerInfoAccess] [bit] NOT NULL CONSTRAINT [DF_Settings_AllowLockerInfoAccess] DEFAULT ((1)),
[AllowLockerCodeAccess] [bit] NOT NULL CONSTRAINT [DF_Settings_AllowLockerCodeAccess] DEFAULT ((0)),
[AllowGoogleMaps] [bit] NOT NULL CONSTRAINT [DF_Settings_AllowGoogleMaps] DEFAULT ((1)),
[DefaultClassUnits] [decimal] (10, 6) NOT NULL CONSTRAINT [DF_Settings_DefaultClassUnits] DEFAULT ((5.0)),
[StudentContactRolesTeachersCanView] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentAccessToOnlineReportCards] [bit] NOT NULL CONSTRAINT [DF_Settings_StudentAccessToOnlineReportCards] DEFAULT ((0)),
[EnableOnlineReportCardOptions] [bit] NOT NULL CONSTRAINT [DF_Settings_EnablePublishOnlineOptionForReportCards] DEFAULT ((0)),
[TeachersCanViewStudentEmergencyContacts] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanViewStudentEmergencyContacts] DEFAULT ((1)),
[TeachersCanViewStudentPickupInfo] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanViewStudentPickupInfo] DEFAULT ((1)),
[CalculateGPAto3Decimals] [bit] NOT NULL CONSTRAINT [DF_Settings_CalculateGPAto3Decimals] DEFAULT ((0)),
[OnlineEnrollment] [bit] NOT NULL CONSTRAINT [DF_Settings_OnlineEnrollment] DEFAULT ((0)),
[HideAcademicTabsForLowGrades] [int] NULL,
[DefaultToEnrollmentTabIfNotCompleted] [bit] NOT NULL CONSTRAINT [DF_Settings_DefaultToEnrollmentTabIfNotComplet] DEFAULT ((0)),
[HideReEnrollTabOnParentInterface] [bit] NOT NULL CONSTRAINT [DF_Settings_HideReEnrollTabOnParentInterface] DEFAULT ((0)),
[AdultSchool] [bit] NOT NULL CONSTRAINT [DF_Settings_AdultSchool] DEFAULT ((0)),
[SchoolAcronym] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiocesanGatewaySchool] [bit] NOT NULL CONSTRAINT [DF_Settings_DiocesanGatewaySchool] DEFAULT ((0)),
[ParentOrgID] [int] NOT NULL CONSTRAINT [DF_Settings_ParentOrgID] DEFAULT ((-1)),
[ShowGraduationRequirementsonTranscript] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowGraduationRequirementsonTranscript] DEFAULT ((0)),
[EnableAllEnrollmeNotifications] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableAllEnrollmeNotifications] DEFAULT ((0)),
[EnableCampusNationality] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableCampusNationality] DEFAULT ((0)),
[PublicAnnouncements] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StaffAnnouncements] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentAnnouncements] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TeachersCanAccessDiscplineInfo] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanAccessDiscplineInfo] DEFAULT ((1)),
[TeachersCanAddEditDisciplineAndActionEntries] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanAddEditDisciplineAndActionEntries] DEFAULT ((1)),
[TeachersCanAccessDisciplinePrivateNotes] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanAccessDisciplinePrivateNotes] DEFAULT ((1)),
[TeachersCanAccessMedicalInfo] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanAccessMedicalInfo] DEFAULT ((0)),
[EnableSingleSignOn] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableSingleSignOn] DEFAULT ((1)),
[Enalable917Notes] [bit] NOT NULL CONSTRAINT [DF_Settings_Enalable917Notes] DEFAULT ((0)),
[EnableClassesOfferedDuring] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableClassesOfferedDuring] DEFAULT ((0)),
[ShowBilling] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowBilling] DEFAULT ((0)),
[ShowFamilyStatements] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowFamilyStatements] DEFAULT ((1)),
[TaxID] [nvarchar] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaxID] DEFAULT (''),
[OnlineStatementsMessage] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnableLunchBilling] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableLunchBilling] DEFAULT ((1)),
[EnableInstallmentBilling] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableInstallmentBilling] DEFAULT ((0)),
[AllowCopyingTermClassesEarly] [datetime] NOT NULL CONSTRAINT [DF_Settings_AllowCopyingTermClassesEarly] DEFAULT (getdate()),
[AllowChangesToClassesAfter1stTerm] [datetime] NOT NULL CONSTRAINT [DF_Settings_AllowChangesToClassesAfter1stTerm] DEFAULT (getdate()),
[ActivateFinancialTab] [bit] NOT NULL CONSTRAINT [DF_Settings_ActivateFinancialTab] DEFAULT ((0)),
[ShowAssignmentTypesAsReportCardSubgradesSetting] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowAssignmentTypesAsReportCardSubgradesSetting] DEFAULT ((0)),
[HideAssignmentTypeSubgradeWeight] [bit] NOT NULL CONSTRAINT [DF_Settings_HideAssignmentTypeSubgradeWeight] DEFAULT ((0)),
[PreventAssignmentTypeChanges] [bit] NOT NULL CONSTRAINT [DF_Settings_PreventAssignmentTypeChanges] DEFAULT ((0)),
[EnableReceivablesEditsToClosedPeriods] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableReceivablesEditsToClosedPeriods] DEFAULT ((0)),
[PaymentProcessingEnabled] [bit] NOT NULL CONSTRAINT [DF_Settings_TakeThisOut] DEFAULT ((0)),
[PaymentProcessingField1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentProcessingField2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentProcessingField3] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentProcessingField4] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HideEditEmailsButton] [bit] NOT NULL CONSTRAINT [DF_Settings_HideEditEmailsButton] DEFAULT ((0)),
[isBillingNotificationEnabled] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableBillingNotification] DEFAULT ((1)),
[BillingNotificationMsg] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingDisplayDate] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FacebookURL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TwitterURL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GooglePlusURL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrincipalEmail] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolSponsorship] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolLocationType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolPastor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolGroupMembership] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultipleClassesPerGrade] [bit] NOT NULL CONSTRAINT [DF_Settings_MultipleClassesPerGrade] DEFAULT ((0)),
[SchoolHasBoard] [bit] NOT NULL CONSTRAINT [DF_Settings_SchoolHasBoard] DEFAULT ((0)),
[SchoolHasEnrollmentWaitingList] [bit] NOT NULL CONSTRAINT [DF_Settings_SchoolHasEnrollmentWaitingList] DEFAULT ((0)),
[SchoolHasExtendedDayProgram] [bit] NOT NULL CONSTRAINT [DF_Settings_SchoolHasExtendedDayProgram] DEFAULT ((0)),
[StudentsUseComputersWithInternet] [int] NOT NULL CONSTRAINT [DF_Settings_StudentsUseComputersWithInternet] DEFAULT ((0)),
[PreviousYearMaleGradsManualEntry] [bit] NOT NULL CONSTRAINT [DF_Settings_PreviousYearMaleGradsManualEntry] DEFAULT ((0)),
[PreviousYearFemaleGradsManualEntry] [bit] NOT NULL CONSTRAINT [DF_Settings_PreviousYearFemaleGradsManualEntry] DEFAULT ((0)),
[CurrentYearMalesEnteringCatholicHSManualEntry] [bit] NOT NULL CONSTRAINT [DF_Settings_CurrentYearMalesEnteringCatholicHSManualEntry] DEFAULT ((0)),
[CurrentYearFemalesEnteringCatholicHSManualEntry] [bit] NOT NULL CONSTRAINT [DF_Settings_CurrentYearFemalesEnteringCatholicHSManualEntry] DEFAULT ((0)),
[SchoolAffiliation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AvgDailyAttendanceManualEntry] [bit] NULL CONSTRAINT [DF_Settings_AvgDailyAttendanceManualEntry] DEFAULT ((0)),
[PreSchoolType] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolEnrollmentManualEntry] [bit] NULL CONSTRAINT [DF_Settings_PreSchoolEnrollmentManualEntry] DEFAULT ((0)),
[PreSchoolName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolSponsoringEntity] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolLicenseNum] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolDirectorName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolDirectorPhone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolDirectorEmail] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolState] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolZip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreSchoolPhone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title1EligibleStudentCountManualEntry] [bit] NULL CONSTRAINT [DF_Settings_Title1EligibleStudentCountManualEntry] DEFAULT ((0)),
[Title1ReceivingStudentCountManualEntry] [bit] NULL CONSTRAINT [DF_Settings_Title1ReceivingStudentCountManualEntry] DEFAULT ((0)),
[PercStudentsWithTitle1FundsManualEntry] [bit] NULL CONSTRAINT [DF_Settings_PercStudentsWithTitle1FundsManualEntry] DEFAULT ((0)),
[Title2ProfessionalDevelopment] [bit] NULL CONSTRAINT [DF_Settings_Title2ProfessionalDevelopment] DEFAULT ((0)),
[Title3LanguageInstruction] [bit] NULL CONSTRAINT [DF_Settings_Title3LanguageInstruction] DEFAULT ((0)),
[Title4AfterSchoolPrograms] [bit] NULL CONSTRAINT [DF_Settings_Title4AfterSchoolPrograms] DEFAULT ((0)),
[AppliedForERate] [bit] NULL CONSTRAINT [DF_Settings_AppliedForERate] DEFAULT ((0)),
[ReceivingERate] [bit] NULL CONSTRAINT [DF_Settings_ReceivingERate] DEFAULT ((0)),
[NSLPParticipation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_NSLPParticipation] DEFAULT ((0)),
[StudentsRecievingNSLPBreakfastManualEntry] [bit] NULL CONSTRAINT [DF_Settings_StudentsRecievingNSLPBreakfastManualEntry] DEFAULT ((0)),
[StudentsRecievingNSLPLunchManualEntry] [bit] NULL CONSTRAINT [DF_Settings_StudentsRecievingNSLPLunchManualEntry] DEFAULT ((0)),
[StudentsRecievingSpecialEdServicesManualEntry] [bit] NULL CONSTRAINT [DF_Settings_StudentsRecievingSpecialEdServicesManualEntry] DEFAULT ((0)),
[PinterestURL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CensusSubmittedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title1EligibleStudentCount] [int] NULL,
[Title1ReceivingStudentCount] [int] NULL,
[PercStudentsWithTitle1Funds] [decimal] (5, 2) NOT NULL,
[StudentsRecievingNSLPBreakfast] [int] NULL,
[StudentsRecievingNSLPLunch] [int] NULL,
[StudentsRecievingSpecialEdServices] [int] NULL,
[PreviousYearMaleGrads] [int] NULL,
[PreviousYearFemaleGrads] [int] NULL,
[CurrentYearMalesEnteringCatholicHS] [int] NULL,
[CurrentYearFemalesEnteringCatholicHS] [int] NULL,
[AvgDailyAttendance] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Settings_AvgDailyAttendance] DEFAULT ((0.00)),
[PreSchoolEnrollment] [int] NULL,
[SchoolType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_SchoolType] DEFAULT ('default'),
[EnableHispanicEthnicityQuestion] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableHispanicEthnicityQuestion] DEFAULT ((0)),
[LockRaceChanges] [bit] NOT NULL CONSTRAINT [DF_Settings_LockdownCensus] DEFAULT ((0)),
[ShowStudentIDOnTranscript] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowStudentIDOnTranscript] DEFAULT ((0)),
[HideReEnrollTabForGradeLevel] [int] NULL,
[ShowConductForClassAttendance] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowConductForClassAttendance] DEFAULT ((1)),
[ShowAttendanceAlertsOnParentInterface] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowAttendancAlertsOnParentInterface] DEFAULT ((1)),
[ShowAcademicAlertsOnParentInterface] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowGradeAlertsOnParentInterface] DEFAULT ((1)),
[ShowAlertsTabOnParentInterface] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowAlertsTab] DEFAULT ((1)),
[EnableTuitionQuickPay] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableTuitionQuickPay] DEFAULT ((0)),
[TeachersCanAccessReportCardOptions] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanAccessReportCardOptions] DEFAULT ((0)),
[AllowSameReportTitlePopulating] [bit] NOT NULL CONSTRAINT [DF_Settings_PreventSameReportTitlePopulating] DEFAULT ((0)),
[AllowSamePeriodPopulating] [bit] NOT NULL CONSTRAINT [DF_Settings_PreventSamePeriodPopulating] DEFAULT ((1)),
[PaymentProcessingField5] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentProcessingField6] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentProcessingField7] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentProcessingField8] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BalanceTransferByAccount] [bit] NOT NULL CONSTRAINT [DF_Settings_BalanceTransferByAccount] DEFAULT ((0)),
[SuppressOnlineStatements] [bit] NOT NULL CONSTRAINT [DF_Settings_SuppressOnlineStatements] DEFAULT ((0)),
[ShowPKasTK] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowPKasTK] DEFAULT ((0)),
[EnableCreditCardPayments] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableCreditCardPayments] DEFAULT ((0)),
[EnableACHPayments] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableACHPayments] DEFAULT ((0)),
[EnableSingleStudentConclude] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableSingleStudentConclude] DEFAULT ((0)),
[EnableSchoolNews] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableSchoolNews] DEFAULT ((0)),
[ClassAtt1AbsentValue] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Settings_ClassAtt1AbsentValue] DEFAULT ((0)),
[ClassAtt2AbsentValue] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Settings_ClassAtt2AbsentValue] DEFAULT ((0)),
[ClassAtt3AbsentValue] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Settings_ClassAtt3AbsentValue] DEFAULT ((0)),
[ClassAtt4AbsentValue] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Settings_ClassAtt4AbsentValue] DEFAULT ((0)),
[ClassAtt5AbsentValue] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Settings_ClassAtt5AbsentValue] DEFAULT ((0)),
[EnablCurrentActivityStatements] [bit] NOT NULL CONSTRAINT [DF_Settings_EnablCurrentActivityStatements] DEFAULT ((0)),
[ShowTeacherPagesForStudents] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowTeacherPagesForStudents] DEFAULT ((0)),
[EnableTeacherPages] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableTeacherPages] DEFAULT ((0)),
[ShowSchoolNewsForStudents] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowSchoolNewsForStudents] DEFAULT ((0)),
[PaySimpleAchLimit] [smallmoney] NOT NULL CONSTRAINT [DF_Settings_PaySimpleAchLimit] DEFAULT ((400)),
[StdMinNumAssignmentsToMeet] [int] NOT NULL CONSTRAINT [DF_Settings_StdMinNumAssignmentsToMeet] DEFAULT ((2)),
[StdMinPercAvgToMeet] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_Settings_StdMinPercAvgToMeet] DEFAULT ((85.0)),
[StdMinNumStudentsMeetingAvg] [int] NOT NULL CONSTRAINT [DF_Settings_StdMinNumStudentsMeetingAvg] DEFAULT ((85)),
[StdAverageAllAssignments] [bit] NOT NULL CONSTRAINT [DF_Settings_StdAverageAllAssignments] DEFAULT ((1)),
[StdRCShowOverallGrade] [bit] NOT NULL CONSTRAINT [DF_Settings_StdRCShowOverallGrade] DEFAULT ((0)),
[StdRCShowCategoryGrade] [bit] NOT NULL CONSTRAINT [DF_Settings_StdRCShowCategoryGrade] DEFAULT ((0)),
[StdRCShowSubCategoryGrade] [bit] NOT NULL CONSTRAINT [DF_Settings_StdRCShowSubCategoryGrade] DEFAULT ((1)),
[StdRCShowStandardGrade] [bit] NOT NULL CONSTRAINT [DF_Settings_StdRCShowStandardGrade] DEFAULT ((0)),
[SyncFamilyFields] [bit] NOT NULL CONSTRAINT [DF_Settings_SyncFamilyFields] DEFAULT ((1)),
[AutoPost] [bit] NOT NULL CONSTRAINT [DF_Settings_AutoPost] DEFAULT ((0)),
[EnableVisaPayments] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableVisaPayments] DEFAULT ((0)),
[EnableMasterCardPayments] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableMasterCardPayments] DEFAULT ((0)),
[EnableAmexPayments] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableAmexPayments] DEFAULT ((0)),
[EnableDiscoverPayments] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableDiscoverPayments] DEFAULT ((0)),
[isBillingNotificationEnabledTeachers] [bit] NOT NULL CONSTRAINT [DF_Settings_isBillingNotificationEnabledTeachers] DEFAULT ((0)),
[ShowStandardsDataOnReportCards] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowStandardsDataOnReportCards] DEFAULT ((0)),
[ShowStandardIDOnReportCards] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowStandardIDOnReportCards] DEFAULT ((0)),
[GeneralizeGuardianLabels] [bit] NOT NULL CONSTRAINT [DF_Settings_GeneralizeGuardianLabels] DEFAULT ((0)),
[showBillingCategoriesBreakdown] [bit] NULL CONSTRAINT [DF_Settings_showBillingCategoriesBreakdown] DEFAULT ((0)),
[StudentAccountsHaveParentAccess] [bit] NOT NULL CONSTRAINT [DF_Settings_StudentAccountsHaveParentAccess] DEFAULT ((1)),
[ShowDisciplineOnParentUI] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowDisciplineOnParentUI] DEFAULT ((0)),
[DisciplineTabTitle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_DisciplineTabTitle] DEFAULT ('Discipline'),
[SpanishDisciplineTabTitle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_SpanishDisciplineTabTitle] DEFAULT ('Disciplina'),
[NumDaysOfDisciplineToShow] [smallint] NOT NULL CONSTRAINT [DF_Settings_NumDaysOfDisciplineToShow] DEFAULT ((300)),
[ShowDisciplineDescription] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowDisciplineDescription] DEFAULT ((1)),
[ShowDisciplineResult] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowDisciplineResult] DEFAULT ((1)),
[ShowDisciplineToStudents] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowDisciplineToStudents] DEFAULT ((1)),
[TeachersCanViewAllGradesOnComments] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanViewAllGradesOnComments] DEFAULT ((1)),
[AutoCopyTransactionTypes] [bit] NULL CONSTRAINT [DF_Settings_AutoCopyTransactionTypes] DEFAULT ((1)),
[PSSyncLastUpdated] [datetime] NULL,
[UseOnlyAdminConfIncidentCodes] [bit] NOT NULL CONSTRAINT [DF_Settings_UseOnlyAdminConfIncidentCodes] DEFAULT ((0)),
[EnablePaySimpleProcFee] [bit] NOT NULL CONSTRAINT [DF_Settings_EnablePaySimpleProcFee] DEFAULT ((0)),
[PaySimpleCCProcFeeAmnt] [smallmoney] NOT NULL CONSTRAINT [DF_Settings_PaySimpleCCProcFeeAmnt] DEFAULT ((0)),
[PaySimpleACHProcFeePcnt] [smallmoney] NOT NULL CONSTRAINT [DF_Settings_PaySimpleACHProcFeePcnt] DEFAULT ((0)),
[StudentsParentsCanViewStudentSchedule] [bit] NOT NULL CONSTRAINT [DF_Settings_StudentsParentsCanViewStudentSchedule] DEFAULT ((1)),
[StudentsParentsCanViewLockerInfo] [bit] NOT NULL CONSTRAINT [DF_Settings_StudentsParentsCanViewLockerInfo] DEFAULT ((1)),
[EnableDegreeAndMajor] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableDegreeAndMajor] DEFAULT ((0)),
[EnableMexicoSpecificFeatures] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableMexicoSpecificFeatures] DEFAULT ((0)),
[isPastDueNotificationEnabled] [bit] NOT NULL CONSTRAINT [DF_Settings_isPastDueNotificationEnabled] DEFAULT ((0)),
[PastDueNotificationMsg] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OnlinePaymentURL] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoicePDFname] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoicePDFbinary] [varbinary] (max) NULL,
[BillingContactPerson] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingContactEmail] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingContactPhone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoicePastDueAmount] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceDateAccountDue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DayCareDefaultTimeLogged] [time] NULL,
[EnableRecurringPayments] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableRecurringPayments] DEFAULT ((0)),
[WISEdataChoiceSchool] [bit] NOT NULL CONSTRAINT [DF_Settings_isWisconsinChoiceSchool] DEFAULT ((0)),
[WISEdataClientKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WISEdataClientSecret] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WISEdataSchoolID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WISEdataLEA] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WISEdataLimitToChoiceStudents] [bit] NOT NULL CONSTRAINT [DF_Settings_WisconsinLimitDPItoChoiceStudents] DEFAULT ((1)),
[WISEdataCurrentSchoolYear] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_WISEdataCurrentSchoolYear] DEFAULT ((2016)),
[WISEdataSnapshotPeriod] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_WISEdataSnapshotPeriod] DEFAULT ('May 19,2016'),
[EnableParentAutoPay] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableParentAutoPay] DEFAULT ((0)),
[AutoPayStartTomorrow] [bit] NOT NULL CONSTRAINT [DF_Settings_AutoPayStartTomorrow] DEFAULT ((1)),
[EnableNewInterface] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableNewInterface] DEFAULT ((0)),
[EnableTeacherPagePublicURL] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableTeacherPagePublicURL] DEFAULT ((0)),
[ShowCourseCodeFieldOnClasses] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowCourseCodeFieldOnClasses] DEFAULT ((0)),
[SwiftReachAPIKey] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comm2] [bit] NOT NULL CONSTRAINT [DF_Settings_Comm2] DEFAULT ((0)),
[DisciplineAllowParentEmailAlerts] [bit] NOT NULL CONSTRAINT [DF_Settings_DisciplineAllowParentEmailAlerts] DEFAULT ((0)),
[ServiceHoursDisplayParentInterface] [bit] NOT NULL CONSTRAINT [DF_Settings_ServiceHoursDisplayParentInterface] DEFAULT ((0)),
[ServiceHoursEnableApproval] [bit] NOT NULL CONSTRAINT [DF_Settings_ServiceHoursEnableApproval] DEFAULT ((1)),
[ServiceHoursReqHours] [smallint] NOT NULL CONSTRAINT [DF_Settings_ServiceHoursReqHours] DEFAULT ((0)),
[ServiceHoursReqFamilyOrStudent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_ServiceHoursRecFamilyOrStudent] DEFAULT (N'Student'),
[Comm2SchedTimeStart] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Comm2SchedTimeStart] DEFAULT ('8:00PM'),
[Comm2SchedTimeEnd] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Settings_Comm2SchedTimeEnd] DEFAULT ('7:00AM'),
[EnableBlastBlackout] [bit] NOT NULL CONSTRAINT [DF_Settings_BlastBlackout] DEFAULT ((1)),
[AutoPayIntroMessage] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AutoPayAllowSuspend] [bit] NOT NULL CONSTRAINT [DF_Settings_AutoPayAllowSuspend] DEFAULT ((1)),
[AutoPayPlanDeadline] [date] NULL,
[SchoolBillingMethod] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_SchoolBillingMethod] DEFAULT ('ACH-CC'),
[Comm2DefaultAreaCode] [smallint] NULL,
[ServiceHoursShowNewEnrollment] [bit] NOT NULL CONSTRAINT [DF_Settings_ServiceHoursShowNewEnrollment] DEFAULT ((0)),
[ServiceHoursReqFamilyHours] [smallint] NULL,
[ServiceHoursReqStudentHours] [smallint] NOT NULL CONSTRAINT [DF_Settings_ServiceHoursReqStudentHours] DEFAULT ((100)),
[ServiceHoursFamily] [bit] NOT NULL CONSTRAINT [DF_Settings_ServiceHoursFamily] DEFAULT ((0)),
[ServiceHoursStudent] [bit] NOT NULL CONSTRAINT [DF_Settings_ServiceHoursStudent] DEFAULT ((1)),
[ServiceHoursDateFrom] [date] NULL,
[ServiceHoursDateTo] [date] NULL,
[UseStudentTableParentPhones] [bit] NULL,
[UseContactsTableParentPhones] [bit] NULL,
[ServiceHoursSplitFamilies] [bit] NOT NULL CONSTRAINT [Settings_ServiceHoursSplitFamilies] DEFAULT ((0)),
[ServiceHoursParentsAddEntries] [bit] NOT NULL CONSTRAINT [Settings_ServiceHoursParentsAddEntries] DEFAULT ((0)),
[ServiceHoursStudentsAddEntries] [bit] NOT NULL CONSTRAINT [Settings_ServiceHoursStudentsAddEntries] DEFAULT ((0)),
[ServiceHoursGradeLevelMin] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Settings_ServiceHoursGradeLevelMin] DEFAULT ((6)),
[ServiceHoursGradeLevelMax] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [Settings_ServiceHoursGradeLevelMax] DEFAULT ((12)),
[ServiceHoursTeacherAccess] [bit] NOT NULL CONSTRAINT [Settings_ServiceHoursTeacherAccess] DEFAULT ((0)),
[ServiceHoursTeacherApproval] [bit] NOT NULL CONSTRAINT [Settings_ServiceHoursTeacherApproval] DEFAULT ((0)),
[InternationalSchool] [bit] NOT NULL CONSTRAINT [DF_Settings_InternationalSchool] DEFAULT ((0)),
[AdminDefaultLanguage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_AdminDefaultLanguage] DEFAULT ('English'),
[TeacherDefaultLanguage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_TeacherDefaultLanguage] DEFAULT ('English'),
[StudentDefaultLanguage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_StudentDefaultLanguage] DEFAULT ('English'),
[EnableAdvSchedulingForGrades] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_EnableAdvSchedulingForGrades] DEFAULT (''),
[SchedShowClassColor] [bit] NOT NULL CONSTRAINT [DF_Settings_SchedShowClassColor] DEFAULT ((1)),
[SchedShowTimeMap] [bit] NOT NULL CONSTRAINT [DF_Settings_SchedShowTimeMap] DEFAULT ((1)),
[SchedTimeScale] [decimal] (3, 1) NOT NULL CONSTRAINT [DF_Settings_SchedTimeScale] DEFAULT ((1.0)),
[ClassDropDownOrderAlphabetically] [bit] NOT NULL CONSTRAINT [DF_Settings_ClassDropDownOrderAlphabetically] DEFAULT ((1)),
[TeachersCanViewPublishedReportCards] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanViewPublishedReportCards] DEFAULT ((1)),
[ShowLanguageDropDown] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowLanguageDropDown] DEFAULT ((1)),
[DatePickerLanguage] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeorgiaStateTranscriptsExportUsePercentageGrade] [bit] NOT NULL CONSTRAINT [DF_Settings_GeorgiaStateTranscriptsExportUsePercentageGrade] DEFAULT ((0)),
[ASMUseStudentEmail] [bit] NOT NULL CONSTRAINT [DF_Settings_ASMUseStudentEmail] DEFAULT ((0)),
[ShowEthnicityRace] [bit] NOT NULL CONSTRAINT [DF_Settings_ShowEthnicityRace] DEFAULT ((1)),
[SchoolCountryRegion] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolStateProvince] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HideAttendanceTabForGradeLevels] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HideAcademicTabForGradeLevels] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HideGradesForGradeLevels] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnableGovIDonStudentRosterReport] [bit] NOT NULL CONSTRAINT [DF_Settings_EnableGovIDonStudentRosterReport] DEFAULT ((0)),
[AllowDateChangesToPastTerms] [datetime] NOT NULL CONSTRAINT [DF_Settings_AllowDateChangesToPastTerms] DEFAULT (getdate()),
[PromotedDate] [datetime] NULL,
[EnableAttendanceNotices] [bit] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Enabl__2D350706] DEFAULT ((0)),
[EnableAdminDailyAttendanceNotices] [bit] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Enabl__2E292B3F] DEFAULT ((0)),
[EnableAdminClassAttendanceNotices] [bit] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Enabl__2F1D4F78] DEFAULT ((0)),
[EnableTeacherDailyAttendanceNotices] [bit] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Enabl__301173B1] DEFAULT ((0)),
[EnableTeacherClassAttendanceNotices] [bit] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Enabl__310597EA] DEFAULT ((0)),
[DailyAttendanceNotificationMode] [int] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Daily__31F9BC23] DEFAULT ((1)),
[DailyAttendanceNotificationTime] [time] (0) NOT NULL CONSTRAINT [DF__tmp_ms_xx__Daily__32EDE05C] DEFAULT ('09:00'),
[DailyAttendanceNotificationMinutes] [int] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Daily__33E20495] DEFAULT ((15)),
[ClassAttendanceNotificationMinutes] [int] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Class__34D628CE] DEFAULT ((15)),
[EnableAdminAttendanceNotices] [bit] NOT NULL CONSTRAINT [DF__tmp_ms_xx__Enabl__35CA4D07] DEFAULT ((0)),
[SchoolCategory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolGender] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosedWithdisabilityCount] [bit] NULL,
[InternetAccess] [bit] NULL,
[SchoolEducationalStage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSTStartDate] AS (CONVERT([date],case datepart(year,getdate()) when (2019) then '2019-03-10' when (2020) then '2020-03-08' when (2021) then '2021-03-14' when (2022) then '2022-03-13' when (2023) then '2023-03-12' when (2024) then '2024-03-10' when (2025) then '2025-03-09' else '2026-03-11' end,(0))),
[DSTEndDate] AS (CONVERT([date],case datepart(year,getdate()) when (2019) then '2019-11-03' when (2020) then '2020-11-01' when (2021) then '2021-11-07' when (2022) then '2022-11-06' when (2023) then '2023-11-05' when (2024) then '2024-11-03' when (2025) then '2025-11-02' else '2026-11-04' end,(0))),
[AllowProgressReportOptionChanges] [bit] NULL CONSTRAINT [ProReportOptionDefault] DEFAULT ((0)),
[LimitConcludedLowPercentageGradesTo] [int] NOT NULL CONSTRAINT [DF_Settings_LimitConcludedLowPercentageGradesTo] DEFAULT ((-1)),
[AllowGradebookSync] [bit] NOT NULL CONSTRAINT [DF__Settings__AllowG__3B83265D] DEFAULT ((0)),
[AssociateFamilyBatchTransactionsTo] [bit] NOT NULL CONSTRAINT [DF__Settings__Associ__3C774A96] DEFAULT ((0)),
[WISEdataSubmitStudentAddresses] [bit] NOT NULL CONSTRAINT [DF_Settings_WISEdataSubmitStudentAddresses] DEFAULT ((0)),
[EdFiSchoolSchedule] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdFiCalendarType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdfiSYCalenderPostDt] [datetime] NULL,
[IndianaChoiceSchool] [bit] NULL CONSTRAINT [DF_Settings_IndianaChoiceSchool] DEFAULT ((0)),
[TeachersCanEditAdvSchedules] [bit] NOT NULL CONSTRAINT [DF_Settings_TeachersCanEditAdvSchedules] DEFAULT ((1)),
[StudentMfa] [bit] NULL,
[StaffMfa] [bit] NULL,
[MfaValidHours] [int] NULL,
[OtpActiveMins] [int] NULL,
[DeleteSchoolDate] [date] NULL,
[SchoolEducationalBoard] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isDualLanguageProgram] [bit] NULL,
[isInternBaccalaureate] [bit] NULL,
[InternStudentsWithVisasCount] [int] NULL,
[HeadsOfSchoolCount] [int] NULL,
[PrincipalsCount] [int] NULL,
[AssistPrincipalsCount] [int] NULL,
[GuideConselorsCount] [int] NULL,
[TeachersCount] [int] NULL,
[TeachersAssistCount] [int] NULL,
[OtherStaffCount] [int] NULL,
[TeachersEmployedCount21_22] [int] NULL,
[TeacherNotReturnedCount22_23] [int] NULL,
[PrincipalsEmployedCount21_22] [int] NULL,
[PrincipalsNotReturnedCount22_23] [int] NULL,
[StudentsDiagnosedWithdisabilityCount] [int] NULL,
[SchoolReceivedTitle1Access] [bit] NULL,
[SchoolReceivedTitle2Access] [bit] NULL,
[SchoolReceivedTitle3Access] [bit] NULL,
[SchoolReceivedTitle4Access] [bit] NULL,
[SchoolLibrariansCount] [int] NULL,
[APTL_BCForOverPayment] [int] NULL,
[APTL_BCForNonPaymentCategory] [int] NULL,
[APTL_Automation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_APTL_Automation] DEFAULT (N'DisableAutomation'),
[RemoveDivisionOnPromote] [bit] NOT NULL CONSTRAINT [DF_Settings_RemoveDivisionOnPromote] DEFAULT ((1)),
[StudentPasswordWarningAcknowledged] [bit] NOT NULL CONSTRAINT [DF_Settings_StudentPasswordWarningAcknowledged] DEFAULT ((0)),
[StudentPasswordWarningAcknowledgedDate] [datetime] NULL,
[StudentPasswordWarningAcknowledgedTeacherID] [int] NULL,
[QboCustomer] [int] NULL,
[APTL_AutoPostingMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Settings_APTL_AutoPostingMethod] DEFAULT (N'ByFamilySimple'),
[APTL_AutoPostingStartDate] [date] NULL,
[APTL_ProcessRegistrationFeesPaymentsSeparately] [bit] NOT NULL CONSTRAINT [DF_Settings_APTL_ProcessRegistrationFeesPaymentsSeparately] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[Settings_Comm2_Conversion]
 ON [dbo].[Settings]
 AFTER Insert, Update
AS
BEGIN

	-- If no SIS phone settings specified, then default to using parent phones from main SIS tab
	IF ( SELECT 1 FROM settings 
			WHERE isnull(UseStudentTableParentPhones,0)=0 
				AND isnull(UseContactsTableParentPhones,0)=0 ) = 1
	BEGIN
		UPDATE Settings SET UseStudentTableParentPhones = 1;
	END

	DECLARE 
		@AdultSchool bit, 
		@Comm2 bit, 
		@UseStudentTableParentPhones bit,
		@UseContactsTableParentPhones bit

	SELECT 
		@AdultSchool=AdultSchool, 
		@Comm2=ISNULL(Comm2,0),
		@UseStudentTableParentPhones = isnull(UseStudentTableParentPhones,0),
		@UseContactsTableParentPhones = isnull(UseContactsTableParentPhones,0)
		FROM inserted

	-- Only run rest of this trigger if there's a change to the Comm2 setting...
	IF UPDATE(Comm2) AND @Comm2<>ISNULL((SELECT Comm2 FROM DELETED),0)
		-- SYNC LKG Comm2 Setting... - Wrike #149055627
		UPDATE LKG.dbo.Schools
			SET Comm2 = @Comm2
			WHERE SchoolID = DB_NAME()
	ELSE
		RETURN

	/*
	** Deprecated, as we want to avoid Twilio re-validation costs
	** in case conversion script is re-run.  We could also do a post-check for orphaned
	** phone entries in the if @Comm2 = 1 block below but it isn't really needed
	** since Comm2 should rely on the vPhoneNumbers view which will not contain
	** any orphaned phones.  I don't expect orphans to occur anyway, but not messing
	** with any delete passes is conservative from the standpoint of not accidentially
	** removing useful data...
	**
	-- Clear any prior data if turning off Comm2 (or if data was left behind and turning on...)
	-- NOTE: We could do something more sophisticated here to try to avoid losing 
	--       any prior phone validation work if we think this is just a temporary deactivation.
	delete from StudentContacts 
		where RolesAndPermissions = '(SIS Parent Contact)'
	-- ...
	delete from PhoneNumbers where StudentID is not null
	*/

	IF @Comm2 = 1
	BEGIN
		-- Convert/refresh SIS parent phones (or first two adult school student phones)...
--			if @UseStudentTableParentPhones = 1 and @Comm2 = 1
--			begin
			-- Make sure phone number up-to-date based on latest trigger logic...
--				update students -- trigger handles actual conversion...
--					set Phone1 = Phone1, Phone2 = Phone2
--			end

		-- Convert/refresh student phones...
--			update students -- trigger handles actual conversion...
--				set Phone3 = Phone3

			UPDATE students -- trigger handles actual conversion...
				SET Phone1 = Phone1, Phone2 = Phone2, Phone3 = Phone3, Family2Phone1 = Family2Phone1, Family2Phone2 = Family2Phone2

		-- Default opt. in for students table based on settings...
		IF (@UseStudentTableParentPhones=1 AND @AdultSchool=0)
			UPDATE Students
				SET Phone1OptIn = case when isnull(Phone1,'')>'' then 1 else null end,
					Phone2OptIn = case when isnull(Phone2,'')>'' then 1 else null end,
					Phone3OptIn = case when isnull(Phone3,'')>'' then 1 else null end,
					Family2Phone1OptIn = case when isnull(Family2Phone1,'')>'' then 1 else null end,
					Family2Phone2OptIn = case when isnull(Family2Phone2,'')>'' then 1 else null end
		ELSE IF (@AdultSchool=1)
			UPDATE Students
				SET Phone1OptIn = case when isnull(Phone1,'')>'' then 1 else null end,
					Phone2OptIn = case when isnull(Phone2,'')>'' then 1 else null end,
					Phone3OptIn = case when isnull(Phone3,'')>'' then 1 else null end

		IF (@UseContactsTableParentPhones=1)
			UPDATE StudentContacts
				SET Phone1OptIn = case when isnull(Phone1Num,'')>'' then 1 else null end,
					Phone2OptIn = case when isnull(Phone2Num,'')>'' then 1 else null end,
					Phone3OptIn = case when isnull(Phone3Num,'')>'' then 1 else null end
			WHERE
				-- 
				-- following is the same rule (and should remain the same) 
				-- as around line 75 in vStudentContacts.sql
				-- (TODO: could turn this into a function at some point)
				--
				(Relationship like '%Parent%' 
					and Relationship not like '%Grandparent%'
					and Relationship not like '%Godparent%')

				or (Relationship like '%Father%' 
					and Relationship not like '%Grandfather%'
					and Relationship not like '%Godfather%')

				or (Relationship like '%Mother%' 
					and Relationship not like '%Grandmother%'
					and Relationship not like '%Godmother%')

				or (Relationship like '%Guardian%')
	END
	ELSE
	BEGIN
		--
		-- Turning off Comm2, Nullify and Opt Ins that are not different from the default settings
		-- Not 100% necessary but useful if the school wants to change their default settings....
		--
			IF (@UseStudentTableParentPhones=1 AND @AdultSchool=0)
				UPDATE Students
					SET 
						Phone1OptIn = case when isnull(Phone1OptIn,999) = 1 then null else Phone1OptIn end,
						Phone2OptIn = case when isnull(Phone2OptIn,999) = 1 then null else Phone2OptIn end,
						Phone3OptIn = case when isnull(Phone3OptIn,999) = 1 then null else Phone3OptIn end,
						Family2Phone1OptIn = case when isnull(Family2Phone1OptIn,999) = 1 then null else Family2Phone1OptIn end,
						Family2Phone2OptIn = case when isnull(Family2Phone2OptIn,999) = 1 then null else Family2Phone2OptIn end

			ELSE IF (@AdultSchool=1)
				UPDATE Students
					SET 
						Phone1OptIn = case when isnull(Phone1OptIn,999) = 1 then null else Phone1OptIn end,
						Phone2OptIn = case when isnull(Phone2OptIn,999) = 1 then null else Phone2OptIn end,
						Phone3OptIn = case when isnull(Phone3OptIn,999) = 1 then null else Phone3OptIn end

			IF (@UseContactsTableParentPhones=1)
				UPDATE StudentContacts
					SET 
						Phone1OptIn = case when isnull(Phone1OptIn,999) = 1 then null else Phone1OptIn end,
						Phone2OptIn = case when isnull(Phone2OptIn,999) = 1 then null else Phone2OptIn end,
						Phone3OptIn = case when isnull(Phone3OptIn,999) = 1 then null else Phone3OptIn end
				WHERE
					-- 
					-- following is the same rule (and should remain the same) 
					-- as around line 75 in vStudentContacts.sql
					-- (TODO: could turn this into a function at some point)
					--
					(Relationship like '%Parent%' 
						and Relationship not like '%Grandparent%'
						and Relationship not like '%Godparent%')

					or (Relationship like '%Father%' 
						and Relationship not like '%Grandfather%'
						and Relationship not like '%Godfather%')

					or (Relationship like '%Mother%' 
						and Relationship not like '%Grandmother%'
						and Relationship not like '%Godmother%')

					or (Relationship like '%Guardian%')		
	END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[SettingsValidation]
on [dbo].[Settings]
after insert, update
as
Begin

	-- Copy Banner Info
	Update lkg.dbo.Schools
	Set
	isBillingNotificationEnabled = (Select isBillingNotificationEnabled from inserted),
	BillingNotificationMsg = (Select BillingNotificationMsg from inserted)
	Where
	SchoolID = DB_NAME ()



    IF (UPDATE(AdminDefaultLanguage) OR UPDATE(TeacherDefaultLanguage) OR UPDATE(StudentDefaultLanguage))
    BEGIN
        IF (Select distinct 1 
            from Inserted
            where AdminDefaultLanguage='' or TeacherDefaultLanguage='' or StudentDefaultLanguage='') = 1
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR ('Blank is not allowed for the admin/teacher/student default language fields.',15,1);
            RETURN;
        END
    END

    IF (UPDATE(PaySimpleCCProcFeeAmnt) OR UPDATE(PaySimpleACHProcFeePcnt) OR UPDATE(EnablePaySimpleProcFee))
    BEGIN

        if (select distinct 1 from Settings 
                where PaySimpleCCProcFeeAmnt<>0 and PaySimpleCCProcFeeAmnt<.5) 
            is not null
        begin
            ROLLBACK TRANSACTION;
            RAISERROR ('Credit card convenience fee needs to be expressed as a percentage between 0.50 and 4.00 percent.',15,1);
            return;
        end

        if (select distinct 1 
                from Settings s 
                cross join deleted d
                where s.PaySimpleCCProcFeeAmnt=0 and s.PaySimpleACHProcFeePcnt=0
                and (s.EnablePaySimpleProcFee=d.EnablePaySimpleProcFee)
                and s.EnablePaySimpleProcFee=1) 
            is not null
        begin
            update Settings
            set EnablePaySimpleProcFee = 0;
        end

    END
End
GO
