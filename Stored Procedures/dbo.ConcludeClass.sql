SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         Procedure [dbo].[ConcludeClass]
@ClassID int,
@ReConclude int,
@TheStudentID int
as

BEGIN TRAN



Declare @NonAcademic bit
Set @NonAcademic = (select NonAcademic From Classes Where ClassID = @ClassID)

Declare 
@theClassTypeID int,
@DefaultPresentValue decimal(5,2)


select 
@theClassTypeID = ClassTypeID,
@DefaultPresentValue = DefaultPresentValue
From Classes 
Where 
ClassID = @ClassID

If	@theClassTypeID = 9		-- Don't add transcript records for Preschool classes
	or
	@DefaultPresentValue = 0	-- Don't add transcript records for DayCare / Extended Care classes
Begin
	Set @NonAcademic = 1
End

Declare @StudentCSID int
If @TheStudentID is not null 
Begin
	Set @StudentCSID = 
	(
	Select CSID 
	From ClassesStudents
	Where
	StudentID = @TheStudentID
	and
	ClassID = @ClassID
	)
End

if @NonAcademic = 0
Begin

	Declare
	@StdRCShowOverallGrade bit,
	@StdRCShowCategoryGrade bit,
	@StdRCShowSubCategoryGrade bit,
	@StdRCShowStandardGrade bit,
	@StandardsGroupID int,
	@ShowStandardsDataOnReportCards bit,
	@ShowStandardIDOnReportCards bit,
	@StdRCShowMarzanoTopicGrade bit

	Select
	@StdRCShowOverallGrade = StdRCShowOverallGrade,
	@StdRCShowCategoryGrade = StdRCShowCategoryGrade,
	@StdRCShowSubCategoryGrade = StdRCShowSubCategoryGrade,
	@StdRCShowStandardGrade = StdRCShowStandardGrade,
	@StandardsGroupID = StandardsGroupID,
	@ShowStandardsDataOnReportCards = ShowStandardsDataOnReportCards,
	@ShowStandardIDOnReportCards = ShowStandardIDOnReportCards,
	@StdRCShowMarzanoTopicGrade = ShowMarzanoTopicsOnReportCard
	From 
	Classes 
	Where
	ClassID = @ClassID


	If @ReConclude = 1
	Begin
		Delete From Transcript
		Where ClassID = @ClassID
		and
		StudentID in (Select StudentID From ClassesStudents Where ClassID = @ClassID and StudentConcludeDate is null)		
	End

	Declare @SubCommentClassTypeID int
	Declare @ParentClassID int
	Declare @TermID int
	Declare @TermTitle nvarchar(50)
	Declare @TermReportTitle nvarchar(20)
	Declare @TermStart datetime
	Declare @TermEnd datetime
	Declare @TermComment nvarchar(max)
	Declare @StudentID int
	Declare @Fname nvarchar(30)
	Declare @Mname nvarchar(30)
	Declare @Lname nvarchar(30)
	Declare @Suffix nvarchar(100)
	Declare @Nickname nvarchar(30)
	Declare @StaffTitle nvarchar(30)
	Declare @TFname nvarchar(30)
	Declare @TLname nvarchar(30)
	Declare @GradeLevel nvarchar(20)
	Declare @ClassTitle nvarchar(140)
	Declare @SpanishTitle nvarchar(50)
	Declare @ReportOrder int
	Declare @ClassTypeID smallint
	Declare @CustomGradeScaleID smallint
	Declare @StandardsGradeScaleID tinyint
	Declare @LetterGrade nvarchar(6)
	Declare @AlternativeGrade nvarchar(6)
	Declare @ClassLevel nvarchar(20)
	Declare @UnitGPA decimal(7,4)
	Declare @Effort tinyint
	Declare @Att1 Decimal(5,2)
	Declare @Att2 Decimal(5,2)
	Declare @Att3 Decimal(5,2)
	Declare @Att4 Decimal(5,2)
	Declare @Att5 Decimal(5,2)
	Declare @PercAtt1  decimal(5,2)
	Declare @PercAtt2 decimal(5,2)
	Declare @PercAtt3 decimal(5,2)
	Declare @PercAtt4 decimal(5,2)
	Declare @PercAtt5 decimal(5,2)
	Declare @Exceptional Decimal(5,2)
	Declare @Good Decimal(5,2)
	Declare @Poor Decimal(5,2)
	Declare @Unacceptable Decimal(5,2)
	Declare @PercExceptional decimal(5,2)
	Declare @PercGood decimal(5,2)
	Declare @PercPoor decimal(5,2)
	Declare @PercUnacceptable decimal(5,2)
	Declare @TotalAttendance Decimal(5,2)
	Declare @TotalConduct Decimal(5,2)
	Declare @AbsentEntries smallint
	Declare @ClassComments nvarchar(20)
	Declare @Comment1 as  nvarchar(60)
	Declare @Comment2 as  nvarchar(60)
	Declare @Comment3 as  nvarchar(60)
	Declare @Comment4 as  nvarchar(60)
	Declare @Comment5 as  nvarchar(60)
	Declare @Comment6 as  nvarchar(60)
	Declare @Comment7 as  nvarchar(60)
	Declare @Comment8 as  nvarchar(60)
	Declare @Comment9 as  nvarchar(60)
	Declare @Comment10 as  nvarchar(60)
	Declare @Comment11 as  nvarchar(60)
	Declare @Comment12 as  nvarchar(60)
	Declare @Comment13 as  nvarchar(60)
	Declare @Comment14 as  nvarchar(60)
	Declare @Comment15 as  nvarchar(60)
	Declare @Comment16 as  nvarchar(60)
	Declare @Comment17 as  nvarchar(60)
	Declare @Comment18 as  nvarchar(60)
	Declare @Comment19 as  nvarchar(60)
	Declare @Comment20 as  nvarchar(60)
	Declare @Comment21 as  nvarchar(60)
	Declare @Comment22 as  nvarchar(60)
	Declare @Comment23 as  nvarchar(60)
	Declare @Comment24 as  nvarchar(60)
	Declare @Comment25 as  nvarchar(60)
	Declare @Comment26 as  nvarchar(60)
	Declare @Comment27 as  nvarchar(60)
	Declare @Comment28 as  nvarchar(60)
	Declare @Comment29 as  nvarchar(60)
	Declare @Comment30 as  nvarchar(60)
	Declare @CategoryName as nvarchar(50)
	Declare @CategoryAbbr as nvarchar(20)
	Declare @Category1Symbol as nvarchar(3)
	Declare @Category1Desc as nvarchar(20)
	Declare @Category2Symbol as nvarchar(3)
	Declare @Category2Desc as nvarchar(20)
	Declare @Category3Symbol as nvarchar(3)
	Declare @Category3Desc as nvarchar(20)
	Declare @Category4Symbol as nvarchar(3)
	Declare @Category4Desc as nvarchar(20)
	Declare @CommentName as nvarchar(50)
	Declare @CommentAbbr as  nvarchar(3)
	Declare @ExamTerm bit
	Declare @TermWeight Decimal(5,2)
	Declare @ParentTermID int
	Declare @ParentTermTitle nvarchar(100)
	Declare @ParentTermReportTitle nvarchar(100)
	Declare @ParentTermStart smalldatetime
	Declare @ParentTermEnd smalldatetime
	Declare @PercentageGrade Decimal(5,2)
	Declare @ParentTermCount int
	Declare @CalculateGPA bit
	Declare @LowestGradeSymbol nvarchar(3)
	Declare @GPABoost decimal(5,2)
	Declare @GradeScaleLegend nvarchar(2000)
	Declare @IgnoreTranscriptGradeLevelFilter bit
	Declare @HideAssignmentTypeSubgradeWeight bit
	Declare @CourseCode nvarchar(30)
	Declare @PostSecondaryInstitution nvarchar(10)
	Declare @CreditType nvarchar(50)
	Declare @Rigor bit
	Declare @DualEnrollment bit
	Declare @HighSchoolLevel bit


	Set @TermID = (Select TermID from Classes where ClassID = @ClassID)
	Set @CustomGradeScaleID = (Select CustomGradeScaleID from Classes where ClassID = @ClassID)
	Set @StandardsGradeScaleID = (Select StandardsGradeScaleID from Classes where ClassID = @ClassID)
	Set @LowestGradeSymbol = (Select top 1 GradeSymbol From CustomGradeScaleGrades Where CustomGradeScaleID = @CustomGradeScaleID Order by GradeOrder desc);


	Set @GPABoost = (Select GPABoost From CustomGradeScale Where CustomGradeScaleID = @CustomGradeScaleID)
	Set @CalculateGPA = (Select CalculateGPA From CustomGradeScale where CustomGradeScaleID = @CustomGradeScaleID)
	Set @ClassTypeID = (Select ClassTypeID from Classes where ClassID = @ClassID)
	Set @IgnoreTranscriptGradeLevelFilter = (Select IgnoreTranscriptGradeLevelFilter from Classes where ClassID = @ClassID)
	Set @CourseCode = (Select CourseCode from Classes where ClassID = @ClassID)
	Set @PostSecondaryInstitution = (Select PostSecondaryInstitution from Classes where ClassID = @ClassID)
	Set @Rigor = (Select isnull(Rigor,0) from Classes where ClassID = @ClassID)
	Set @DualEnrollment = (Select DualEnrollment from Classes where ClassID = @ClassID)
	
	Set @HighSchoolLevel = (Select HighSchoolLevel from LKG.dbo.edfiCourses e
							inner join  Classes c on e.CourseCode = c.CourseCode
							where c.ClassID = @ClassID)

	Set @CreditType = (
	Case 
	When ((Select DualEnrollment from Classes where ClassID = @ClassID) = 1 
	and (Select PostSecondaryInstitution from Classes where ClassID = @ClassID) != '00'
	and (Select PostSecondaryInstitution from Classes where ClassID = @ClassID) != '') 
	then 'Dual Credit' else 'Regular Credit' end)
	Set @GradeScaleLegend = ''

	If @ClassTypeID in (1, 2)
	Begin
		Set @GradeScaleLegend = dbo.getGradeScaleLegend2(@CustomGradeScaleID)
	End

	If @ClassTypeID = 8
	Begin
		Set @GradeScaleLegend = 'CR=(Credit) NC=(No Credit)'
	End




	Select 
	@ParentTermID = ParentTermID,
	@TermWeight = TermWeight,
	@ExamTerm = ExamTerm
	From Terms
	Where TermID = @TermID

	Select
	@ParentTermTitle = TermTitle,
	@ParentTermReportTitle = ReportTitle,
	@ParentTermStart = StartDate,
	@ParentTermEnd = EndDate
	From Terms
	Where TermID = @ParentTermID

	Select
	@HideAssignmentTypeSubgradeWeight = HideAssignmentTypeSubgradeWeight,
	@CategoryName = CategoryName,
	@CategoryAbbr = CategoryAbbr,
	@Category1Symbol = Category1Symbol,
	@Category1Desc = Category1Description,
	@Category2Symbol = Category2Symbol,
	@Category2Desc = Category2Description,
	@Category3Symbol = Category3Symbol,
	@Category3Desc = Category3Description,
	@Category4Symbol = Category4Symbol,
	@Category4Desc = Category4Description,
	@CommentName = CommentName,
	@CommentAbbr = CommentAbbr,

	@Comment1 =
		case
			When Comment1 = '' then null
			else '1. ' + Comment1
		end,
	@Comment2 =
		case
			When Comment2 = '' then null
			else '2. ' + Comment2
		end,
	@Comment3 =
		case
			When Comment3 = '' then null
			else '3. ' + Comment3
		end,
	@Comment4 =
		case
			When Comment4 = '' then null
			else '4. ' + Comment4
		end,
	@Comment5 =
		case
			When Comment5 = '' then null
			else '5. ' + Comment5
		end,
	@Comment6 =
		case
			When Comment6 = '' then null
			else '6. ' + Comment6
		end,
	@Comment7 =
		case
			When Comment7 = '' then null
			else '7. ' + Comment7
		end,
	@Comment8 =
		case
			When Comment8 = '' then null
			else '8. ' + Comment8
		end,
	@Comment9 =
		case
			When Comment9 = '' then null
			else '9. ' + Comment9
		end,

	@Comment10 =
		case
			When Comment10 = '' then null
			else '10. ' + Comment10
		end,
	@Comment11 =
		case
			When Comment11 = '' then null
			else '11. ' + Comment11
		end,
	@Comment12 =
		case
			When Comment12 = '' then null
			else '12. ' + Comment12
		end,
	@Comment13 =
		case
			When Comment13 = '' then null
			else '13. ' + Comment13
		end,
	@Comment14 =
		case
			When Comment14 = '' then null
			else '14. ' + Comment14
		end,
	@Comment15 =
		case
			When Comment15 = '' then null
			else '15. ' + Comment15
		end,
	@Comment16 =
		case
			When Comment16 = '' then null
			else '16. ' + Comment16
		end,
	@Comment17 =
		case
			When Comment17 = '' then null
			else '17. ' + Comment17
		end,
	@Comment18 =
		case
			When Comment18 = '' then null
			else '18. ' + Comment18
		end,
	@Comment19 =
		case
			When Comment19 = '' then null
			else '19. ' + Comment19
		end,
	@Comment20 =
		case
			When Comment20 = '' then null
			else '20. ' + Comment20
		end,
	@Comment21 =
		case
			When Comment21 = '' then null
			else '21. ' + Comment21
		end,
	@Comment22 =
		case
			When Comment22 = '' then null
			else '22. ' + Comment22
		end,
	@Comment23 =
		case
			When Comment23 = '' then null
			else '23. ' + Comment23
		end,
	@Comment24 =
		case
			When Comment24 = '' then null
			else '24. ' + Comment24
		end,
	@Comment25 =
		case
			When Comment25 = '' then null
			else '25. ' + Comment25
		end,
	@Comment26 =
		case
			When Comment26 = '' then null
			else '26. ' + Comment26
		end,


	@Comment27 =
		case
			When Comment27 = '' then null
			else '27. ' + Comment27
		end,
	@Comment28 =
		case
			When Comment28 = '' then null
			else '28. ' + Comment28
		end,
	@Comment29 =
		case
			When Comment29 = '' then null
			else '29. ' + Comment29
		end,
	@Comment30 =
		case
			When Comment30 = '' then null
			else '30. ' + Comment30
		end

	From Settings Where SettingID = 1


	Declare @TeacherID int
	Declare @CSID int
	Declare @EExceptional tinyint
	Declare @EGood tinyint
	Declare @EPoor tinyint
	Declare @EUnacceptable tinyint
	Declare @Period int
	Declare @ClassUnits decimal(10,6)
	Declare @UnitsEarned decimal(10,6)


	 Set @TermTitle = (Select TermTitle from Terms where TermID = @TermID)
	 set @TermReportTitle = (Select ReportTitle from Terms where TermID = @TermID) 
	 Set @TermStart = (Select StartDate from Terms where TermID = @TermID)
	 Set @TermEnd = (Select EndDate from Terms where TermID = @TermID)
	 Set @TeacherID = (Select TeacherID from Classes where ClassID = @ClassID)
	 Set @StaffTitle = (Select StaffTitle from Teachers where TeacherID = @TeacherID)
	 Set @TFname = (Select Fname from Teachers where TeacherID = @TeacherID)
	 Set @TLname = (Select Lname from Teachers where TeacherID = @TeacherID)
	 
	 
	If @ClassTypeID = 3
	Begin
		Set @ClassTitle = (Select ReportTitle from Classes where ClassID = @ClassID) +
						' (' 
						+  
						case
							when @StaffTitle is null then @TFname + ' ' + @TLname
							when rtrim(@StaffTitle) = '' then @TFname + ' ' + @TLname
							else @StaffTitle + ' ' + @TLname
						end
						+ ')'
	End
	Else
	Begin
		Set @ClassTitle = (Select ReportTitle from Classes where ClassID = @ClassID)
	End 
	 
	 

	 Set @SpanishTitle = (Select SpanishTitle from Classes where ClassID = @ClassID)
	 Set @ReportOrder = (Select ReportOrder from Classes where ClassID = @ClassID)
	 Set @Period = (Select Period from Classes where ClassID = @ClassID)
	 Set @ParentClassID = (Select ParentClassID from Classes where ClassID = @ClassID)
	 Set @SubCommentClassTypeID = (Select SubCommentClassTypeID from Classes where ClassID = @ClassID)


	Declare @ChurchPresent Decimal(5,2)
	Declare @PercChurchPresent Decimal(5,2)
	Declare @ChurchAbsent Decimal(5,2)
	Declare @PercChurchAbsent Decimal(5,2)
	Declare @SSchoolPresent Decimal(5,2)
	Declare @PercSSchoolPresent Decimal(5,2)
	Declare @SSchoolAbsent Decimal(5,2)
	Declare @PercSSchoolAbsent Decimal(5,2)

	Declare @SchoolAtt1 Decimal(5,2)
	Declare @PercSchoolAtt1 Decimal(5,2)
	Declare @SchoolAtt2 Decimal(5,2)
	Declare @PercSchoolAtt2 Decimal(5,2)
	Declare @SchoolAtt3 Decimal(5,2)
	Declare @PercSchoolAtt3 Decimal(5,2)
	Declare @SchoolAtt4 Decimal(5,2)
	Declare @PercSchoolAtt4 Decimal(5,2)
	Declare @SchoolAtt5 Decimal(5,2)
	Declare @PercSchoolAtt5 Decimal(5,2)
	Declare @SchoolAtt6 Decimal(5,2)
	Declare @PercSchoolAtt6 Decimal(5,2)
	Declare @SchoolAtt7 Decimal(5,2)
	Declare @PercSchoolAtt7 Decimal(5,2)
	Declare @SchoolAtt8 Decimal(5,2)
	Declare @PercSchoolAtt8 Decimal(5,2)
	Declare @SchoolAtt9 Decimal(5,2)
	Declare @PercSchoolAtt9 Decimal(5,2)
	Declare @SchoolAtt10 Decimal(5,2)
	Declare @PercSchoolAtt10 Decimal(5,2)
	Declare @SchoolAtt11 Decimal(5,2)
	Declare @PercSchoolAtt11 Decimal(5,2)
	Declare @SchoolAtt12 Decimal(5,2)
	Declare @PercSchoolAtt12 Decimal(5,2)
	Declare @SchoolAtt13 Decimal(5,2)
	Declare @PercSchoolAtt13 Decimal(5,2)
	Declare @SchoolAtt14 Decimal(5,2)
	Declare @PercSchoolAtt14 Decimal(5,2)
	Declare @SchoolAtt15 Decimal(5,2)
	Declare @PercSchoolAtt15 Decimal(5,2)



	Select 
	CS.StudentID, A.*
	into #tmpAttendance
	From 
		Attendance A
			inner join 
		ClassesStudents CS
			on A.CSID = CS.CSID
			inner join
		Classes C
			on CS.ClassID = C.ClassID			
	Where
	CS.ClassID = @ClassID
	and
	case
		when Att1 = 1 then 1
		when Att2 = 1 then 1
		when Att3 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att3' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att4 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att4' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att5 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att5' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att6 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att6' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att7 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att7' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att8 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att8' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att9 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att9' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att10 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att10' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att11 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att11' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att12 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att12' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att13 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att13' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att14 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att14' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		when Att15 = 1 and not exists(Select * From AttendanceSettings Where ID = 'Att15' and C.ClassTypeID = 5 and (ExcludedAttendance = 1 or MultiSelect = 1)) then 1
		else 0
	end = 1 
	and
	case 
		when @TheStudentID is not null and @StudentCSID = CS.CSID then 1
		when @TheStudentID is null and C.ClassID = @ClassID then 1
		else 0
	end = 1
	and
	CS.StudentConcludeDate is null


	Select StudentID
	into #tmpStudents
	From ClassesStudents
	Where
	case 
		when @TheStudentID is not null and @StudentCSID = CSID then 1
		when @TheStudentID is null and ClassID = @ClassID then 1
		else 0
	end = 1
	and
	ClassGradeOnConclude is null
	

	While (Select count(*) from #tmpStudents) > 0
	Begin

	 Set @StudentID = (Select top 1 StudentID From #tmpStudents)

	 Select 
	 	@Fname=Fname, @Mname=Mname, @Lname=Lname, @Suffix=Suffix, @Nickname=Nickname 
	 from Students 
	 where StudentID = @StudentID

	 Set @GradeLevel = null; -- reset the gradelevel back to null to start
	 
	 Set @GradeLevel = 
		(
		Select top 1
		GradeLevel
		From Transcript
		Where
		StudentID = @StudentID
		and
		TermID = @TermID
		Group By GradeLevel
		Order By COUNT(*) desc, GradeLevel
		) 
	 
	If @GradeLevel is null
	Begin
	 Set @GradeLevel = (Select GradeLevel from Students where StudentID = @StudentID)
	End

	 Set @CSID = (Select CSID from ClassesStudents where ClassID = @ClassID and StudentID = @StudentID)
	 Set @ClassComments = (Select ClassComments From ClassesStudents where CSID = @CSID)

	If @ClassTypeID = 3
	Begin
		Set @TermComment = (	Select TermComment
								From ClassesStudents
								Where 	CSID = @CSID
							)	
	End
				


	If @ClassTypeID in (3, 5, 6, 7)			
	Begin
		 Set @LetterGrade = null
		 Set @UnitGPA = null
		 Set @ClassUnits = null
		 Set @UnitsEarned = null
		 Set @GPABoost = 0
	End
	Else
	Begin
		 Set @PercentageGrade = (Select StudentGrade from ClassesStudents where CSID = @CSID)
		 Set @LetterGrade = dbo.GetLetterGrade(@ClassID, @PercentageGrade)
		 Set @AlternativeGrade = (Select AlternativeGrade from ClassesStudents where CSID = @CSID)
		 Set @ClassLevel = (Select ClassLevel from ClassesStudents where CSID = @CSID)
		 Set @ClassUnits = (Select Units from Classes where ClassID = @ClassID)
		 Set @UnitGPA = (Select isnull(dbo.getUnitGPA(@ClassID, @PercentageGrade),0))


		Declare @LimitConcludedPercentageGrades int
		Set @LimitConcludedPercentageGrades = (Select LimitConcludedPercentageGrades From Settings Where SettingID = 1)
		
		If @LimitConcludedPercentageGrades > -1 and @PercentageGrade > @LimitConcludedPercentageGrades
		Begin
			Set @PercentageGrade = @LimitConcludedPercentageGrades
		End

		Declare @LimitConcludedLowPercentageGradesTo int
		Set @LimitConcludedLowPercentageGradesTo = (Select LimitConcludedLowPercentageGradesTo From Settings Where SettingID = 1)
		
		If @LimitConcludedLowPercentageGradesTo > -1 and @PercentageGrade < @LimitConcludedLowPercentageGradesTo
		Begin
			Set @PercentageGrade = @LimitConcludedLowPercentageGradesTo
		End

		if @UnitGPA < 0
		 Begin
		  Set @UnitGPA = 0
		 END
		 
		-- Commented out "or @UnitGPA = 0" below as we recieved the following issue SF:153222  - dp 1/6/2023
		-- If we do run into issues we probably should handle it on the report card sproc or transcript report side
		if @LetterGrade = 'F' or @LetterGrade = @LowestGradeSymbol -- or @UnitGPA = 0
		Begin
		  Set @UnitsEarned = 0
		End
		else
		Begin
		 Set @UnitsEarned = (Select Units from Classes where ClassID = @ClassID)
		End

		if @LetterGrade is null and @AlternativeGrade is null
		Begin
			Set @AlternativeGrade = 'nm'
		End
		
	End


	if @ClassTypeID = 8
	Begin

		Declare @CreditNoCreditPassingGrade int

		Set @CreditNoCreditPassingGrade = (Select CreditNoCreditPassingGrade From Settings Where SettingID = 1)

		if @PercentageGrade < @CreditNoCreditPassingGrade
		Begin
			Set @UnitsEarned = 0
			Set @LetterGrade = 'NC'
		End
		Else
		Begin
			Set @UnitsEarned = @ClassUnits
			Set @LetterGrade = 'CR'
		End

	End
	 
	 Set @EExceptional = (Select Exceptional from ClassesStudents where CSID = @CSID)
	 Set @EGood = (Select Good  from ClassesStudents where CSID = @CSID)
	 Set @EPoor = (Select Poor from ClassesStudents where CSID = @CSID)
	 Set @EUnacceptable = (Select Unacceptable from ClassesStudents where CSID = @CSID)

	 If @EExceptional = 1
	  Begin
		Set @Effort = 1
	  End
	 Else if @EPoor = 1
	  Begin
		Set @Effort = 3

	  End
	 Else if @EUnacceptable = 1
	  Begin
		Set @Effort = 4
	  End
	 Else

	  Begin
		Set @Effort = 2
	  End



	 Set @Att1 = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Att1 = 1)
	 Set @Att2 = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Att2 = 1)
	 Set @Att3 = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Att3 = 1)
	 Set @Att4 = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Att4 = 1)
	 Set @Att5 = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Att5 = 1)

	 Set @TotalAttendance = (Select count(CSID) from #tmpAttendance where CSID = @CSID)

	 if (@TotalAttendance = 0)
	 Begin
		 Set @PercAtt1 = 0
		 Set @PercAtt2 = 0
		 Set @PercAtt3 = 0
		 Set @PercAtt4 = 0
		 Set @PercAtt5 = 0
	 End
	 else
	 Begin
		 Set @PercAtt1 = (@Att1 / @TotalAttendance ) * 100
		 Set @PercAtt2 = (@Att2 / @TotalAttendance) * 100
		 Set @PercAtt3 = (@Att3 / @TotalAttendance)* 100
		 Set @PercAtt4 = (@Att4 / @TotalAttendance) * 100
		 Set @PercAtt5 = (@Att5 / @TotalAttendance)* 100
	 End

	-- Set @AbsentEntries = @Absent + @UAbsent

	 Set @Exceptional = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Exceptional = 1 and Att3 = 0 and Att5 = 0)
	 Set @Good = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Good = 1 and Att3 = 0 and Att5 = 0)
	 Set @Poor = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Poor = 1 and Att3 = 0 and Att5 = 0)
	 Set @Unacceptable = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Unacceptable = 1 and Att3 = 0 and Att5 = 0)

	 Set @TotalConduct = (Select count(CSID) from #tmpAttendance where CSID = @CSID and Att3 = 0 and Att5 = 0)

	 if (@TotalConduct = 0)
	 Begin
		 Set @PercExceptional = 0
		 Set @PercGood = 0
		 Set @PercPoor = 0
		 Set @PercUnacceptable = 0
	 End
	 else
	 Begin
		 Set @PercExceptional = (@Exceptional / @TotalConduct) * 100
		 Set @PercGood = (@Good / @TotalConduct) * 100
		 Set @PercPoor = (@Poor / @TotalConduct) * 100

  -- Set @PercUnacceptable = (@TotalConduct) * 100 - Fresh Desk #48356, corrected to:
		 Set @PercUnacceptable = (@Unacceptable / @TotalConduct) * 100
	 End


	If @ClassTypeID = 5
	Begin		-- Set School Attendance Variables

		Select
			@SchoolAtt1 = sum(Att1),
			@PercSchoolAtt1 = convert(decimal(5,2),(sum(Att1)/@TotalAttendance)*100),
			@SchoolAtt2 = sum(Att2),
			@PercSchoolAtt2 = convert(decimal(5,2),(sum(Att2)/@TotalAttendance)*100),
			@SchoolAtt3 = sum(Att3),
			@PercSchoolAtt3 = convert(decimal(5,2),(sum(Att3)/@TotalAttendance)*100),
			@SchoolAtt4 = sum(Att4),
			@PercSchoolAtt4 = convert(decimal(5,2),(sum(Att4)/@TotalAttendance)*100),
			@SchoolAtt5 = sum(Att5),
			@PercSchoolAtt5 = convert(decimal(5,2),(sum(Att5)/@TotalAttendance)*100),
			@SchoolAtt6 = sum(Att6),
			@PercSchoolAtt6 = convert(decimal(5,2),(sum(Att6)/@TotalAttendance)*100),
			@SchoolAtt7 = sum(Att7),
			@PercSchoolAtt7 = convert(decimal(5,2),(sum(Att7)/@TotalAttendance)*100),
			@SchoolAtt8 = sum(Att8),
			@PercSchoolAtt8 = convert(decimal(5,2),(sum(Att8)/@TotalAttendance)*100),
			@SchoolAtt9 = sum(Att9),
			@PercSchoolAtt9 = convert(decimal(5,2),(sum(Att9)/@TotalAttendance)*100),
			@SchoolAtt10 = sum(Att10),
			@PercSchoolAtt10 = convert(decimal(5,2),(sum(Att10)/@TotalAttendance)*100),
			@SchoolAtt11 = sum(Att11),
			@PercSchoolAtt11 = convert(decimal(5,2),(sum(Att11)/@TotalAttendance)*100),
			@SchoolAtt12 = sum(Att12),
			@PercSchoolAtt12 = convert(decimal(5,2),(sum(Att12)/@TotalAttendance)*100),
			@SchoolAtt13 = sum(Att13),
			@PercSchoolAtt13 = convert(decimal(5,2),(sum(Att13)/@TotalAttendance)*100),
			@SchoolAtt14 = sum(Att14),
			@PercSchoolAtt14 = convert(decimal(5,2),(sum(Att14)/@TotalAttendance)*100),
			@SchoolAtt15 = sum(Att15),
			@PercSchoolAtt15 = convert(decimal(5,2),(sum(Att15)/@TotalAttendance)*100)
		From #tmpAttendance
		Where StudentID = @StudentID



		-- Get Total Present Value
		Declare @TotalPresentValue decimal(5,2)
		Set @TotalPresentValue = 
		(
		@SchoolAtt1 * (Select PresentValue From AttendanceSettings Where ID = 'Att1')
		+
		@SchoolAtt2 * (Select PresentValue From AttendanceSettings Where ID = 'Att2')
		+
		@SchoolAtt3 * (Select PresentValue From AttendanceSettings Where ID = 'Att3')
		+
		@SchoolAtt4 * (Select PresentValue From AttendanceSettings Where ID = 'Att4')
		+
		@SchoolAtt5 * (Select PresentValue From AttendanceSettings Where ID = 'Att5')
		+
		@SchoolAtt6 * (Select PresentValue From AttendanceSettings Where ID = 'Att6')
		+
		@SchoolAtt7 * (Select PresentValue From AttendanceSettings Where ID = 'Att7')
		+
		@SchoolAtt8 * (Select PresentValue From AttendanceSettings Where ID = 'Att8')
		+
		@SchoolAtt9 * (Select PresentValue From AttendanceSettings Where ID = 'Att9')
		+
		@SchoolAtt10 * (Select PresentValue From AttendanceSettings Where ID = 'Att10')
		+
		@SchoolAtt11 * (Select PresentValue From AttendanceSettings Where ID = 'Att11')
		+
		@SchoolAtt12 * (Select PresentValue From AttendanceSettings Where ID = 'Att12')
		+
		@SchoolAtt13 * (Select PresentValue From AttendanceSettings Where ID = 'Att13')
		+
		@SchoolAtt14 * (Select PresentValue From AttendanceSettings Where ID = 'Att14')
		+
		@SchoolAtt15 * (Select PresentValue From AttendanceSettings Where ID = 'Att15')
		)

		-- Get Total Absent Value
		Declare @TotalAbsentValue decimal(5,2)
		Set @TotalAbsentValue = 
		(
		@SchoolAtt1 * (Select AbsentValue From AttendanceSettings Where ID = 'Att1')
		+
		@SchoolAtt2 * (Select AbsentValue From AttendanceSettings Where ID = 'Att2')
		+
		@SchoolAtt3 * (Select AbsentValue From AttendanceSettings Where ID = 'Att3')
		+
		@SchoolAtt4 * (Select AbsentValue From AttendanceSettings Where ID = 'Att4')
		+
		@SchoolAtt5 * (Select AbsentValue From AttendanceSettings Where ID = 'Att5')
		+
		@SchoolAtt6 * (Select AbsentValue From AttendanceSettings Where ID = 'Att6')
		+
		@SchoolAtt7 * (Select AbsentValue From AttendanceSettings Where ID = 'Att7')
		+
		@SchoolAtt8 * (Select AbsentValue From AttendanceSettings Where ID = 'Att8')
		+
		@SchoolAtt9 * (Select AbsentValue From AttendanceSettings Where ID = 'Att9')
		+
		@SchoolAtt10 * (Select AbsentValue From AttendanceSettings Where ID = 'Att10')
		+
		@SchoolAtt11 * (Select AbsentValue From AttendanceSettings Where ID = 'Att11')
		+
		@SchoolAtt12 * (Select AbsentValue From AttendanceSettings Where ID = 'Att12')
		+
		@SchoolAtt13 * (Select AbsentValue From AttendanceSettings Where ID = 'Att13')
		+
		@SchoolAtt14 * (Select AbsentValue From AttendanceSettings Where ID = 'Att14')
		+
		@SchoolAtt15 * (Select AbsentValue From AttendanceSettings Where ID = 'Att15')
		)


		Set @SchoolAtt1 = @TotalPresentValue
		Set @SchoolAtt2 = @TotalAbsentValue
		--
		-- DS-277 / FD 115652 - Percentages for School Attendance present/absent stats
		-- 		need to be updated too if numerator changes.  Yikes, this error has been
		--		in here for a long time; I'm surprised no other schools have reported.
		--	10/27/2018 - Duke
		--
		Set	@PercSchoolAtt1 = convert(decimal(5,2),(sum(@SchoolAtt1)/@TotalAttendance)*100)
		Set @PercSchoolAtt2 = convert(decimal(5,2),(sum(@SchoolAtt2)/@TotalAttendance)*100)

	End



	If @ClassTypeID = 6
	Begin		-- Set Worship Attendance Variables

		Select
			@ChurchPresent = sum(A.ChurchPresent),
			@PercChurchPresent = convert(decimal(5,2),(sum(A.ChurchPresent)/@TotalAttendance)*100),
			@ChurchAbsent = sum(A.ChurchAbsent),
			@PercChurchAbsent = convert(decimal(5,2),(sum(A.ChurchAbsent)/@TotalAttendance)*100),
			@SSchoolPresent = sum(A.SSchoolPresent),
			@PercSSchoolPresent = convert(decimal(5,2),(sum(A.SSchoolPresent)/@TotalAttendance)*100),
			@SSchoolAbsent = sum(A.SSchoolAbsent),
			@PercSSchoolAbsent = convert(decimal(5,2),(sum(A.SSchoolAbsent)/@TotalAttendance)*100)
		From 
			Attendance A
				inner join 
			ClassesStudents CS
				on A.CSID = CS.CSID
				inner join
			Classes C
				on CS.ClassID = C.ClassID
		Where
			C.ClassTypeID = 6
			and
			CS.StudentID = @StudentID
			and
			C.TermID = @TermID

	End


	If @GPABoost is null
	Begin
		Set @GPABoost = 0
	End
	If @CalculateGPA is null
	Begin
		Set @CalculateGPA = 0
	End

	
--	BEGIN TRY

	Declare 
	@GradReqCategoryHistoryID int,
	@GradReqCategoryID int

	If @ClassTypeID in (1, 8)
	Begin
		Declare @CXML nvarchar(4000) =
		(
		Select
		CategoryID,
		CategoryName,
		RequiredUnits
		From GradReqCategories
		FOR XML RAW
		)

		if (not exists (Select * From dbo.GradReqCategoryHistory where CXML = @CXML))
		Begin
			insert into dbo.GradReqCategoryHistory (CDate, CXML)
			values(GETDATE(), @CXML)
		End
		
		Set @GradReqCategoryHistoryID = (SELECT Max(CHistoryID) From GradReqCategoryHistory)
		Set @GradReqCategoryID = (Select CategoryID from Classes where ClassID = @ClassID)


		-- Remove any potential Duplicate Records if they exist - Otherwise the SQL KEY CONSTRAINT [IX_Transcript] will prevent adding this record
		-- Just doing this for ClassTypes 1 and 8 for now but we can add it to other Custom ClassTypes if needed
		-- FD #358674 - dp  12/20/2021
		-- ****************************************************************************
		Delete from Transcript
		Where
		TermID = @TermID
		and
		TermTitle = @TermTitle
		and
		StudentID = @StudentID
		and
		ClassTypeID = @ClassTypeID
		and
		ClassTitle = @ClassTitle;
		-- ****************************************************************************


	End



	 Insert Into Transcript
	(
		TermID,
		TermTitle,
		TermReportTitle,
		TermStart,
		TermEnd,
		ParentTermID,
		TermWeight,
		ExamTerm,
		StudentID,
		GradeLevel,
		Fname,
		Mname,
		Lname,
		Suffix,
		Nickname,
		StaffTitle,
		TFname,
		TLname,
		TermComment,
		ClassID,
		ClassTitle,
		SpanishTitle,
		ReportOrder,
		ClassTypeID,
		ParentClassID,
		SubCommentClassTypeID,
		CustomGradeScaleID,
		ClassUnits,
		UnitsEarned,
		Period,
		LetterGrade,
		AlternativeGrade,
		ClassLevel,
		PercentageGrade,
		UnitGPA,
		FieldNotGraded,
		GradeScaleLegend,
		Effort,
		ClassComments,
		Att1,
		PercAtt1,
		Att2,
		PercAtt2,
		Att3,
		PercAtt3,
		Att4,
		PercAtt4,
		Att5,
		PercAtt5,
		SchoolAtt1,
		PercSchoolAtt1,
		SchoolAtt2,
		PercSchoolAtt2,
		SchoolAtt3,
		PercSchoolAtt3,
		SchoolAtt4,
		PercSchoolAtt4,
		SchoolAtt5,
		PercSchoolAtt5,
		SchoolAtt6,
		PercSchoolAtt6,
		SchoolAtt7,
		PercSchoolAtt7,
		SchoolAtt8,
		PercSchoolAtt8,
		SchoolAtt9,
		PercSchoolAtt9,
		SchoolAtt10,
		PercSchoolAtt10,
		SchoolAtt11,
		PercSchoolAtt11,
		SchoolAtt12,
		PercSchoolAtt12,
		SchoolAtt13,
		PercSchoolAtt13,
		SchoolAtt14,
		PercSchoolAtt14,
		SchoolAtt15,
		PercSchoolAtt15,
		ChurchPresent,
		PercChurchPresent,
		ChurchAbsent,
		PercChurchAbsent,
		SSchoolPresent,
		PercSSchoolPresent,
		SSchoolAbsent,
		PercSSchoolAbsent,
		Exceptional,
		PercExceptional,
		Good,
		PercGood,
		Poor,
		PercPoor,
		Unacceptable,
		PercUnacceptable,
		CommentName,
		CommentAbbr,
		Comment1,
		Comment2,
		Comment3,
		Comment4,
		Comment5,
		Comment6,
		Comment7,
		Comment8,
		Comment9,
		Comment10,
		Comment11,
		Comment12,
		Comment13,
		Comment14,
		Comment15,
		Comment16,
		Comment17,
		Comment18,
		Comment19,
		Comment20,
		Comment21,
		Comment22,
		Comment23,
		Comment24,
		Comment25,
		Comment26,
		Comment27,
		Comment28,
		Comment29,
		Comment30,
		CategoryName,
		CategoryAbbr,
		Category1Symbol,
		Category1Desc,
		Category2Symbol,
		Category2Desc,
		Category3Symbol,
		Category3Desc,
		Category4Symbol,
		Category4Desc,
		ConcludeDate,
		GPABoost,
		CalculateGPA,
		IgnoreTranscriptGradeLevelFilter,
		GradReqCategoryID,
		GradReqCategoryHistoryID,
		CourseCode,
		PostSecondaryInstitution,
		CreditType,
		Rigor,
		DualEnrollment,
		HighSchoolLevel,
		StandardsGradeScaleID
	)

	 Values(
		@TermID,
		@TermTitle,
		@TermReportTitle,
		@TermStart,
		@TermEnd,
		@ParentTermID,
		@TermWeight,
		@ExamTerm,
		@StudentID,
		@GradeLevel,
		@Fname,
		@Mname,
		@Lname,
		@Suffix,
		@Nickname,
		@StaffTitle,
		@TFname,
		@TLname,
		@TermComment,
		@ClassID,
		@ClassTitle,
		@SpanishTitle,
		@ReportOrder,
		@ClassTypeID,
		@ParentClassID,
		@SubCommentClassTypeID,
		@CustomGradeScaleID,
		@ClassUnits,
		@UnitsEarned,
		@Period,
		@LetterGrade,
		@AlternativeGrade,
		@ClassLevel,
		@PercentageGrade,
		@UnitGPA,
		case 
			when	@StandardsGroupID is not null 
					and 
					@StdRCShowOverallGrade = 0
					and
					@ShowStandardsDataOnReportCards = 1 then 1
			else 0
		end,
		@GradeScaleLegend,
		@Effort,
		@ClassComments,
		@Att1,
		@PercAtt1,
		@Att2,
		@PercAtt2,
		@Att3,
		@PercAtt3,
		@Att4,
		@PercAtt4,
		@Att5,
		@PercAtt5,
		@SchoolAtt1,
		@PercSchoolAtt1,
		@SchoolAtt2,
		@PercSchoolAtt2,
		@SchoolAtt3,
		@PercSchoolAtt3,
		@SchoolAtt4,
		@PercSchoolAtt4,
		@SchoolAtt5,
		@PercSchoolAtt5,
		@SchoolAtt6,
		@PercSchoolAtt6,
		@SchoolAtt7,
		@PercSchoolAtt7,
		@SchoolAtt8,
		@PercSchoolAtt8,
		@SchoolAtt9,
		@PercSchoolAtt9,
		@SchoolAtt10,
		@PercSchoolAtt10,
		@SchoolAtt11,
		@PercSchoolAtt11,
		@SchoolAtt12,
		@PercSchoolAtt12,
		@SchoolAtt13,
		@PercSchoolAtt13,
		@SchoolAtt14,
		@PercSchoolAtt14,
		@SchoolAtt15,
		@PercSchoolAtt15,
		@ChurchPresent,
		@PercChurchPresent,
		@ChurchAbsent,
		@PercChurchAbsent,
		@SSchoolPresent,
		@PercSSchoolPresent,
		@SSchoolAbsent,
		@PercSSchoolAbsent,
		@Exceptional,
		@PercExceptional,
		@Good,
		@PercGood,
		@Poor,
		@PercPoor,
		@Unacceptable,
		@PercUnacceptable,
		@CommentName,
		@CommentAbbr,
		@Comment1,
		@Comment2,
		@Comment3,
		@Comment4,
		@Comment5,
		@Comment6,
		@Comment7,
		@Comment8,
		@Comment9,
		@Comment10,
		@Comment11,
		@Comment12,
		@Comment13,
		@Comment14,
		@Comment15,
		@Comment16,
		@Comment17,
		@Comment18,
		@Comment19,
		@Comment20,
		@Comment21,
		@Comment22,
		@Comment23,
		@Comment24,
		@Comment25,
		@Comment26,
		@Comment27,
		@Comment28,
		@Comment29,
		@Comment30,
		@CategoryName,
		@CategoryAbbr,
		@Category1Symbol,
		@Category1Desc,
		@Category2Symbol,
		@Category2Desc,
		@Category3Symbol,
		@Category3Desc,
		@Category4Symbol,
		@Category4Desc,
		convert(char(30), dbo.GLgetdatetime()),
		isnull(@GPABoost, 0),
		@CalculateGPA,
		@IgnoreTranscriptGradeLevelFilter,
		@GradReqCategoryID,
		@GradReqCategoryHistoryID,
		@CourseCode,
		@PostSecondaryInstitution,
		@CreditType,
		isnull(@Rigor,0),
		isnull(@DualEnrollment,0),
		isnull(@HighSchoolLevel,0),
		@StandardsGradeScaleID	
		)
		
		
		-- ************************************************************
		-- Check to see if we need to add AssignmentTypes as Subgrades
		-- ************************************************************
		if ((Select AddAssignmentTypesAsReportCardSubgrades From Classes Where ClassID = @ClassID) = 1)
		Begin
					
			Insert Into Transcript
			(
				TermID,
				ParentTermID,
				TermTitle,
				TermReportTitle,
				TermStart,
				TermEnd,
				StudentID,
				GradeLevel,
				Fname,
				Mname,
				Lname,
				Suffix,
				Nickname,
				StaffTitle,
				TFname,
				TLname,
				ClassID,
				ClassTitle,
				ReportOrder,
				ClassTypeID,
				ParentClassID,
				CustomGradeScaleID,
				Period,
				CustomFieldName,
				CustomFieldGrade,
				CustomFieldOrder,
				GradeScaleLegend,
				ConcludeDate
			)
			Select
			T.TermID,
			T.ParentTermID,
			T.TermTitle,
			T.ReportTitle,
			T.StartDate,
			T.EndDate,
			S.StudentID,
			S.GradeLevel,
			S.Fname,
			S.Mname,
			S.Lname,
			S.Suffix,
			S.Nickname,
			Tch.StaffTitle,
			Tch.Fname,
			Tch.Lname,
			C.ClassID,
			C.ReportTitle,
			C.ReportOrder,
			-100,
			@ClassID,
			C.CustomGradeScaleID,
			C.Period,
			case
				when @HideAssignmentTypeSubgradeWeight = 1 then LTRIM(RTRIM(TA.TypeTitle))
				else LTRIM(RTRIM(TA.TypeTitle)) + ' (' + TA.TypeWeight + '%)' 
			end as FieldName,
			TA.TypeAvg as FieldGrade,
			ROW_NUMBER() OVER
			(
			Order By 
			CASE WHEN @HideAssignmentTypeSubgradeWeight = 0 THEN TA.TypeWeightNumber End desc,
			TA.TypeTitle
			)
			*-1 AS FieldOrder,
			dbo.getGradeScaleLegend2(C.CustomGradeScaleID) as GradeScaleLegend,
			convert(char(30), dbo.GLgetdatetime()) as ConcludeDate
			From 
			Terms T
				inner join
			Classes C
				on C.TermID = T.TermID
				inner join
			Teachers Tch
				on C.TeacherID = Tch.TeacherID
				inner join
			ClassesStudents CS
				on C.ClassID = CS.ClassID
				inner join
			Students S
				on CS.StudentID = S.StudentID
				inner join
			(
				Select 
				CS2.CSID as CSID,
				AT2.TypeTitle as TypeTitle,
				AT2.TypeWeight as TypeWeightNumber,
				dbo.trimzeros(AT2.TypeWeight) as TypeWeight,
				isnull(
				(
					Select
					case
						when Sum(A.Weight) = 0 then dbo.trimzeros(avg(G.Grade))
						else dbo.trimzeros(Sum((G.Grade*A.Weight)) / Sum(A.Weight)) 
					end as TypeAvg
					From 
					AssignmentType AT
						inner join
					Assignments A
						on AT.TypeID = A.TypeID
						inner join
					Grades G
						on G.AssignmentID = A.AssignmentID
					Where
					CSID = CS2.CSID
					and
					G.Grade is not null
					and
					AT.TypeID = AT2.TypeID
					Group By AT.TypeTitle, AT.TypeWeight
				), '') as TypeAvg
				From 
				AssignmentType AT2
					inner join
				Classes C
					on AT2.ClassID = C.ClassID
					inner join
				ClassesStudents CS2
					on C.ClassID = CS2.ClassID
			) TA
				on TA.CSID = CS.CSID
			Where
			S.StudentID = @StudentID 
			and
			C.ClassID = @ClassID
			Order By 
			CASE WHEN @HideAssignmentTypeSubgradeWeight = 0 THEN TA.TypeWeightNumber End desc,
			TA.TypeTitle
			
		End	-- Check to see if we need to add AssignmentTypes as Subgrades
		-- ************************************************************
		-- ************************************************************




	--END TRY
	--BEGIN CATCH
	---- Error handling code goes here
	

	--END CATCH


	-- Check If semester Grades need to be added or updated.


	Set @ParentTermCount = (Select count(*) From Transcript where TermID = @ParentTermID and ClassTitle = @ClassTitle and StudentID = @StudentID)						


	If @ParentTermID > 0 and @ClassTypeID in (1,8)
	Begin

		If @ParentTermCount = 0
		Begin

			 Insert Into Transcript
			(
				TermID,
				TermTitle,
				TermReportTitle,
				TermStart,
				TermEnd,
				ParentTermID,
				TermWeight,
				ExamTerm,
				StudentID,
				GradeLevel,
				Fname,
				Mname,
				Lname,
				Suffix,
				Nickname,
				StaffTitle,
				TFname,
				TLname,
				ClassID,
				ClassTitle,
				SpanishTitle,
				ReportOrder,
				ClassTypeID,
				CustomGradeScaleID,
				ClassUnits,
				UnitsEarned,
				LetterGrade,
				AlternativeGrade,
				ClassLevel,
				PercentageGrade,
				UnitGPA,
				GradeScaleLegend,
				ConcludeDate,
				GPABoost,
				CalculateGPA,
				IgnoreTranscriptGradeLevelFilter,
				GradReqCategoryID,
				GradReqCategoryHistoryID,
				CourseCode,
				PostSecondaryInstitution,
				CreditType,
				Rigor,
				DualEnrollment,
				HighSchoolLevel
			)
			 Values(
				@ParentTermID,
				@ParentTermTitle,
				@ParentTermReportTitle,
				@ParentTermStart,
				@ParentTermEnd,
				0,
				null,
				0,
				@StudentID,
				@GradeLevel,
				@Fname,
				@Mname,
				@Lname,
				@Suffix,
				@Nickname,
				@StaffTitle,
				@TFname,
				@TLname,
				@ClassID,
				@ClassTitle,
				@SpanishTitle,
				@ReportOrder,
				@ClassTypeID,
				@CustomGradeScaleID,
				@ClassUnits,
				@UnitsEarned,
				@LetterGrade,
				case 
					when @AlternativeGrade = 'nm' then null
					else @AlternativeGrade
				end,
				@ClassLevel,
				@PercentageGrade,
				@UnitGPA,
				@GradeScaleLegend,
				convert(char(30), dbo.GLgetdatetime()),
				isnull(@GPABoost, 0),
				@CalculateGPA,
				@IgnoreTranscriptGradeLevelFilter,
				@GradReqCategoryID,
				@GradReqCategoryHistoryID,
				@CourseCode,
				@PostSecondaryInstitution,
				@CreditType,
				isnull(@Rigor,0),
				isnull(@DualEnrollment,0),
				isnull(@HighSchoolLevel,0)
				)
				
			Execute UpdateParentTermGrade @ParentTermID, @StudentID, @ClassTitle
		End
		Else
		Begin
			Execute UpdateParentTermGrade @ParentTermID, @StudentID, @ClassTitle
		End

	End		


	Delete From #tmpStudents Where StudentID = @StudentID

	End -- While for Students



		
	-- ************************************************************
	-- Check to see if we need to add Standards as Subgrades
	-- ************************************************************
	if 
	@StandardsGroupID is not null 
	and 
	(@StdRCShowMarzanoTopicGrade = 1 or  @StdRCShowCategoryGrade = 1 or @StdRCShowSubCategoryGrade = 1 or @StdRCShowStandardGrade = 1)
	and
	@ShowStandardsDataOnReportCards = 1
	Begin

		If @StandardsGradeScaleID = 0
		Begin
			Set @StandardsGradeScaleID = (Select CustomGradeScaleID From Classes Where ClassID = @ClassID)
		End

		Declare @StdMinNumAssignmentsToMeet int
		Declare @StdMinPercAvgToMeet decimal(7,2)
		Declare @StdMinNumStudentsMeetingAvg int
		Declare @StdAverageAllAssignments bit

		Select 
		@StdMinNumAssignmentsToMeet = StdMinNumAssignmentsToMeet,
		@StdMinPercAvgToMeet = StdMinPercAvgToMeet,
		@StdMinNumStudentsMeetingAvg = StdMinNumStudentsMeetingAvg,
		@StdAverageAllAssignments = StdAverageAllAssignments
		From Classes
		Where ClassID = @ClassID


		Declare @StdAvgs table
		(
		StudentID int,
		StandardID int,
		StdAssignmentsCount int,
		StdAvg decimal(7,2)
		)

		Insert into @StdAvgs
		Select 
		CS.StudentID,
		Ast.StandardID,
		COUNT(A.AssignmentID) as AssignmentCount, 
		case
			when @StdAverageAllAssignments = 1 then	
				dbo.TrimZeros(
				sum(A.Weight*G.Grade)/nullif(sum(A.Weight), 0)
				) 
			else
				(
					Select 
					dbo.TrimZeros(
					sum(A2.Weight*G2.Grade)/nullif(sum(A2.Weight), 0)
					) as StdAvg
					From 
					Assignments A2
						inner join
					Grades G2
						on A2.AssignmentID = G2.AssignmentID
						inner join
					AssignmentStandards Ast2
						on A2.AssignmentID = Ast2.AssignmentID
						inner join
					ClassesStudents CS2
						on G2.CSID = CS2.CSID
					Where
					CS2.StudentID = CS.StudentID
					and
					Ast2.StandardID = Ast.StandardID
					and
					G2.Grade is not null
					and
					A2.AssignmentID in
					(
						Select top(@StdMinNumAssignmentsToMeet)
						A3.AssignmentID
						From
						Assignments A3
							inner join
						AssignmentStandards Ast3
							on A3.AssignmentID = Ast3.AssignmentID
							inner join
						Grades G3
							on A3.AssignmentID = G3.AssignmentID
							inner join
						ClassesStudents CS3
							on G3.CSID = CS3.CSID
						Where
						A3.ClassID = @ClassID
						and
						StandardID = Ast2.StandardID
						and
						G3.Grade is not null
						and
						CS3.StudentID = CS2.StudentID
						Group By A3.AssignmentID, A3.DueDate
						Order By A3.DueDate desc
					)
					Group By CS2.StudentID, Ast2.StandardID
				)
		end as StdAvg
		From 
		Assignments A
			inner join
		Grades G
			on A.AssignmentID = G.AssignmentID
			inner join
		AssignmentStandards Ast
			on A.AssignmentID = Ast.AssignmentID
			inner join
		ClassesStudents CS
			on G.CSID = CS.CSID
		Where
		A.ClassID = @ClassID
		and
		G.Grade is not null
		Group By CS.StudentID, Ast.StandardID



		--Select * From @StdAvgs


		Declare @StudentStandardsAverages table 
		(
		--StdOrder int identity(1,1),
		StudentID int,
		Fname nvarchar(30),
		Mname nvarchar(30),
		Lname nvarchar(30),
		Suffix nvarchar(100),
		Nickname nvarchar(30),
		GradeLevel nvarchar(10),
		StdOrder int,
		StandardID int,
		Category nvarchar(90),
		SubCategory nvarchar(400),
		CCSSID nvarchar(50),
		StandardText nvarchar(2000),
		StandardAverage decimal(7,2)
		)

		insert into @StudentStandardsAverages
		Select 
		St.StudentID,
		St.Fname,
		St.Mname,
		St.Lname,
		St.Suffix,
		St.Nickname,
		isnull(
					(
					Select top 1
					GradeLevel
					From Transcript
					Where
					StudentID = St.StudentID
					and
					TermID = T.TermID
					Group By GradeLevel
					Order By COUNT(*) desc, GradeLevel
					)
					,
					(Select GradeLevel from Students where StudentID = St.StudentID)	
				) as GradeLevel,	
		ROW_NUMBER() OVER(PARTITION BY St.StudentID 
		ORDER BY 
		St.StudentID,
		case 
			when S.ID < 99999 then S.ID	-- Use this for the Built-in Standards as the order is preset and we can just use the StandardID.
			else 1
		end,
		S.Category,
		S.SubCategory,
		case
			when charIndex('.', CCSSID) = 0 then 1000 
			when LEFT(left(CCSSID, charIndex('.', CCSSID)-1),2) = 'k' then -1
			when isnumeric(LEFT(left(CCSSID, charIndex('.', CCSSID)-1),2)) = 0 then 100 
			else LEFT(left(CCSSID, charIndex('.', CCSSID)-1),2)
		end,
		case  -- Changed Left statement from above from 2 to 1.. it likely should be 1 .. it works above because .# is still valid -dp 3/19/2020
			when charIndex('-', CCSSID) = 0 then 1000 
			when LEFT(left(CCSSID, charIndex('-', CCSSID)-1),1) = 'k' then -1
			when isnumeric(LEFT(left(CCSSID, charIndex('-', CCSSID)-1),1)) = 0 then 100 
			else LEFT(left(CCSSID, charIndex('-', CCSSID)-1),1)
		end,
		case when isnumeric(right(CCSSID, 1)) = 0 then dbo.RemoveChars(CCSSID)end,
		case when isnumeric(right(CCSSID, 1)) = 0 then dbo.RemoveNumbers(CCSSID)end,
		case when isnumeric(right(CCSSID, 1)) = 1 then dbo.RemoveNumbers(CCSSID)end,
		case when isnumeric(right(CCSSID, 1)) = 1 then dbo.RemoveChars(CCSSID)end		
		),
		S.ID as StandardID,
		S.Category,
		S.SubCategory,
		S.CCSSID as CCSSID,
		S.StandardText as StandardText,
		Sd.StdAvg as StandardAverage
		From 
		vStandards S
			inner join
		SGStandards SGS
			on S.ID = SGS.StandardID
			inner join
		StandardsGroups SG
			on SG.SGID = SGS.SGID
			inner join
		Classes C
			on C.StandardsGroupID = SG.SGID
			inner join
		ClassesStudents CS
			on C.ClassID = CS.ClassID
			inner join
		Students St
			on St.StudentID = CS.StudentID
			inner join
		Terms T
			on T.TermID = C.TermID
			inner join
		Teachers Tch
			on Tch.TeacherID = C.TeacherID
			left join
		@StdAvgs Sd
			on S.ID = Sd.StandardID and Sd.StudentID = St.StudentID
			
		Where
		C.ClassID = @ClassID
		Order By
		St.StudentID,
		case 
			when S.ID < 99999 then S.ID	-- Use this for the Built-in Standards as the order is preset and we can just use the StandardID.
			else 1
		end,
		S.Category,
		S.SubCategory,		
		case
			when charIndex('.', CCSSID) = 0 then 1000 
			when LEFT(left(CCSSID, charIndex('.', CCSSID)-1),2) = 'k' then -1
			when isnumeric(LEFT(left(CCSSID, charIndex('.', CCSSID)-1),2)) = 0 then 100 
			else LEFT(left(CCSSID, charIndex('.', CCSSID)-1),2)
		end,
		case -- Changed Left statement from above from 2 to 1.. it likely should be 1 .. it works above because .# is still valid -dp 3/19/2020
			when charIndex('-', CCSSID) = 0 then 1000 
			when LEFT(left(CCSSID, charIndex('-', CCSSID)-1),1) = 'k' then -1
			when isnumeric(LEFT(left(CCSSID, charIndex('-', CCSSID)-1),1)) = 0 then 100 
			else LEFT(left(CCSSID, charIndex('-', CCSSID)-1),1)
		end,
		case when isnumeric(right(CCSSID, 1)) = 0 then dbo.RemoveChars(CCSSID)end,
		case when isnumeric(right(CCSSID, 1)) = 0 then dbo.RemoveNumbers(CCSSID)end,
		case when isnumeric(right(CCSSID, 1)) = 1 then dbo.RemoveNumbers(CCSSID)end,
		case when isnumeric(right(CCSSID, 1)) = 1 then dbo.RemoveChars(CCSSID)end		


		--Select * From @StudentStandardsAverages

		Declare @tmpStandardsRecords table
		(
		--FieldOrder int identity(1,1),
		StudentID int,
		Fname nvarchar(30),
		Mname nvarchar(30),
		Lname nvarchar(30),
		Suffix nvarchar(100),
		Nickname nvarchar(30),
		GradeLevel nvarchar(10),
		GroupOrder int,
		FieldOrder int,
		StdItem nvarchar(2000),
		ItemAvg decimal(7,2)
		)

		Insert into @tmpStandardsRecords
		Select				-- Category
		StudentID,
		Fname,
		Mname,
		Lname,
		Suffix,
		Nickname,
		GradeLevel,
		1 as GroupOrder,
		MIN(StdOrder) as StdOrder,
		Category,
		AVG(StandardAverage) as theAvg
		From @StudentStandardsAverages
		Group By StudentID, Fname, Mname, Lname, Suffix, Nickname, GradeLevel, Category

		Union All

		Select 			-- Sub-Category
		StudentID,
		Fname,
		Mname,
		Lname,
		Suffix,
		Nickname,
		GradeLevel,
		2 as GroupOrder,
		MIN(StdOrder) as StdOrder,
		SubCategory,
		AVG(StandardAverage) as theAvg
		From @StudentStandardsAverages
		Group By StudentID, Fname, Mname, Lname, Suffix, Nickname, GradeLevel, Category, SubCategory

		Union All

		Select			-- Standards
		StudentID,
		Fname,
		Mname,
		Lname,
		Suffix,
		Nickname,
		GradeLevel,
		3 as GroupOrder,
		StdOrder,
		case 
			when @ShowStandardIDOnReportCards = 1 then CCSSID + ': ' + StandardText
			else StandardText
		end,
		StandardAverage as theAvg
		From @StudentStandardsAverages

		Union All

		Select			-- Marzano Topics
		StudentID,
		Fname,
		Mname,
		Lname,
		Suffix,
		Nickname,
		GradeLevel,
		4 as GroupOrder,
		MIN(StdOrder) as StdOrder,
		MT.Topic,
		AVG(StandardAverage) as theAvg
		From 
		@StudentStandardsAverages S
		left join
		lkg.dbo.StandardsMarzanoTopics SM
			on SM.StandardID = S.StandardID
			left join
		lkg.dbo.MarzanoTopics MT
			on SM.MTID = MT.MTID
		Where MT.Topic is not null
		Group By StudentID, Fname, Mname, Lname, Suffix, Nickname, GradeLevel, MT.Topic
		Order By StudentID, Fname, Mname, Lname, Suffix, Nickname, GradeLevel, MIN(StdOrder), GroupOrder


		Declare @tmpStandardsRecordsOrdered table 
		(
		StudentID int,
		Fname nvarchar(30),
		Mname nvarchar(30),
		Lname nvarchar(30),
		Suffix nvarchar(100),
		Nickname nvarchar(30),
		GradeLevel nvarchar(10),
		GroupOrder int,
		FieldOrder int,
		StdItem nvarchar(2000),
		ItemAvg decimal(7,2)
		)

		Insert into @tmpStandardsRecordsOrdered
		Select
		StudentID,
		Fname,
		Mname,
		Lname,
		Suffix,
		Nickname,
		GradeLevel,
		GroupOrder,
		ROW_NUMBER() OVER(PARTITION BY StudentID Order By StudentID, FieldOrder, GroupOrder) as FieldOrder,
		StdItem,
		ItemAvg 
		From @tmpStandardsRecords
		Where
		case 
			when @StdRCShowCategoryGrade = 1 and GroupOrder = 1 then 1
			when @StdRCShowSubCategoryGrade = 1 and GroupOrder = 2 then 1
			when @StdRCShowStandardGrade = 1 and GroupOrder = 3 then 1
			when @StdRCShowMarzanoTopicGrade = 1 and GroupOrder = 4 then 1
			else 0
		end = 1


		/*
		select *
		from @tmpStandardsRecordsOrdered tso
		left join transcript t
		on tso.StudentID = t.StudentID
		and tso.StdItem = t.ClassTitle
		and tso.FieldOrder = t.CustomFieldOrder
		and t.ClassTypeID = -100
		and t.TermID = @TermID
--		where t.StudentID is null
		*/		

		Insert Into Transcript
		(
			TermID,
			ParentTermID,
			TermTitle,
			TermReportTitle,
			TermStart,
			TermEnd,
			StudentID,
			GradeLevel,
			Fname,
			Mname,
			Lname,
			Suffix,
			Nickname,
			StaffTitle,
			TFname,
			TLname,
			ClassID,
			ClassTitle,
			ReportOrder,
			ClassTypeID,
			ParentClassID,
			CustomGradeScaleID,
			Period,
			CustomFieldName,
			CustomFieldGrade,
			CustomFieldOrder,
			GradeScaleLegend,
			ConcludeDate,
			StandardsItemType,
			StandardsGradeScaleID
		)
		Select
		@TermID as TermID,
		@ParentTermID as ParentTermID,
		@TermTitle as TermTitle,
		@TermReportTitle as TermReportTitle,
		@TermStart as StartDate,
		@TermEnd as EndDate,
		tso.StudentID as StudentID,
		tso.GradeLevel,
		tso.Fname as Fname,
		tso.Mname as Mname,
		tso.Lname as Lname,
		tso.Suffix as Suffix,
		tso.Nickname as Nickname,
		@StaffTitle as StaffTitle,
		@TFname as TFname,
		@TLname as TLname,
		@ClassID as ClassID,
		@ClassTitle as ReportTitle,
		@ReportOrder as ReportOrder,
		-100 as ClassTypeID,
		@ClassID as ParentClassID,
		@CustomGradeScaleID as CustomGradeScaleID,
		@Period as Period,
		tso.StdItem as CustomFieldName,
		dbo.getLetterGrade2(@StandardsGradeScaleID, tso.ItemAvg) as CustomFieldGrade,
		tso.FieldOrder as CustomFieldOrder,
		@GradeScaleLegend as GradeScaleLegend,
		convert(char(30), dbo.GLgetdatetime()),
		tso.GroupOrder,
		@StandardsGradeScaleID
		from @tmpStandardsRecordsOrdered tso
			left join transcript t
			on tso.StudentID = t.StudentID
			and tso.StdItem = t.ClassTitle
			and tso.FieldOrder = t.CustomFieldOrder
			and t.ClassTypeID = -100
			and t.TermID = @TermID
			where t.StudentID is null

			
	End	-- Check to see if we need to add Standards as Subgrades
	-- ************************************************************
	-- ************************************************************





	Update Classes
	Set Concluded = 1
	Where 
	ClassID = @ClassID
	and
	@TheStudentID is null


	If @ReConclude != 1
	Begin
		----------Check to see if we should make next term active-------------------------------------------
		Declare @NonConcludedCount int
		Declare @NextTermID int
		Declare @CurrentTermStartDate smalldatetime
		Declare @CurrentTermEndDate smalldatetime
		
		Set @NonConcludedCount = (Select count(*) From Classes where Concluded = 0 and TermID = @TermID)
		
		IF @NonConcludedCount = 0
		Begin
		
		Set @CurrentTermStartDate = (Select StartDate From Terms where TermID = @TermID)
		Set @CurrentTermEndDate = (Select EndDate From Terms where TermID = @TermID)
		
		
		
		Set @NextTermID = 
		(
		Select top 1 TermID
		From Terms
		Where 
			StartDate > @CurrentTermStartDate
			and
			TermID not in (Select ParentTermID From Terms)
			and
			DATEDIFF(day, @CurrentTermEndDate, StartDate) <= 30
		Order by StartDate
		)
		
		Declare @NumActiveTermsInFuture int
		
		Set @NumActiveTermsInFuture = 
		(
			Select COUNT(*)
			From 
			Terms 
			Where 
			StartDate > @CurrentTermStartDate
			and
			TermID not in (Select ParentTermID From Terms)
			and
			Status = 1
		)
		
		
		If @NextTermID is not null and @NumActiveTermsInFuture = 0
		begin
		  Update Terms Set Status = 0 Where TermID = @TermID
		  Update Terms Set Status = 1 Where TermID = @NextTermID
		End
		----------------------------------------------------------------------------------------------------

	End


	drop table #tmpStudents
	drop table #tmpAttendance

	End

End
Else
Begin

	Update Classes
	Set Concluded = 1
	Where 
	ClassID = @ClassID
	and
	@TheStudentID is null


End


If @TheStudentID is not null 
Begin
	Update ClassesStudents
	Set 
	ClassGradeOnConclude = dbo.TrimZeros(StudentGrade),
	StudentConcludeDate = dbo.GLgetdatetime()
	Where
	CSID = @StudentCSID
End	


COMMIT

--If @ClassTypeID = 1
--Begin	-- Update UnitGPA to prevent any null values
--	Update Transcript
--	Set UnitGPA = 
--	(
--	case 
--		when C.GPAValue = 0 then 0
--		else C.GPAValue + CS.GPABoost
--	end
--	) * T.UnitsEarned
--	From 
--	Transcript T
--		inner join
--	CustomGradeScaleGrades C
--		on T.CustomGradeScaleID = C.CustomGradeScaleID and T.LetterGrade = C.GradeSymbol
--		inner join
--	CustomGradeScale CS
--		on C.CustomGradeScaleID = CS.CustomGradeScaleID
--	Where
--	T.ClassID = @ClassID
--End
GO
