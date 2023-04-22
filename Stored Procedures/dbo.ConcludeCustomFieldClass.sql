SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[ConcludeCustomFieldClass]
@ClassID int,
@ReConclude int,
@TheStudentID int
as

BEGIN TRAN

Declare @ParentClassID int
Declare @NonAcademic bit

Set @ParentClassID = (Select ParentClassID from Classes where ClassID = @ClassID)

If @ParentClassID = 0
Begin
	Set @NonAcademic = (select NonAcademic From Classes Where ClassID = @ClassID)
End
Else
Begin
	Set @NonAcademic = (select NonAcademic From Classes Where ClassID = @ParentClassID)
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


	If @ReConclude = 1
	Begin
		Delete From Transcript
		Where ClassID = @ClassID
		and
		StudentID in (Select StudentID From ClassesStudents Where ClassID = @ClassID and StudentConcludeDate is null)		
	End

	Declare @SubCommentClassTypeID int
	Declare @TermID int
	Declare @ParentTermID int
	Declare @TermTitle nvarchar(30)
	Declare @TermReportTitle nvarchar(30)
	Declare @TermStart datetime
	Declare @TermEnd datetime
	Declare @ExamTerm bit
	Declare @Fname nvarchar(30)
	Declare @Mname nvarchar(30)
	Declare @StudentID int
	Declare @Lname nvarchar(30)
	Declare @Suffix nvarchar(100)
	Declare @Nickname nvarchar(30)
	Declare @StaffTitle nvarchar(30)
	Declare @TFname nvarchar(30)
	Declare @TLname nvarchar(30)
	Declare @GradeLevel nvarchar(20)
	Declare @ClassTitle nvarchar(60) -- expanded from 40 to match width in transcript table and allow subgrades to associate with classes up to 60 characters wide in reportcard1 sproc (temp table there supports 150 char width but includes concatenated zzz stuff. 1/30/14 - Duke
	Declare @ReportOrder int
	Declare @ClassTypeID smallint
	Declare @Period int
	Declare @CustomFieldGrade nvarchar(10)
	Declare @CustomFieldOrder int
	Declare @FieldBolded bit
	Declare @FieldNotGraded bit
	Declare @Indent tinyint
	Declare @Bullet nvarchar(20)
	Declare @CustomFieldName nvarchar(500)
	Declare @CustomFieldSpanishName nvarchar(500)
	Declare @ReportSectionTitle nvarchar(100)
	Declare @ClassComments nvarchar(100)

	Declare @TeacherID int
	Declare @CSID int

	Declare @Comment1 as  nvarchar(50)
	Declare @Comment2 as  nvarchar(50)
	Declare @Comment3 as  nvarchar(50)
	Declare @Comment4 as  nvarchar(50)
	Declare @Comment5 as  nvarchar(50)
	Declare @Comment6 as  nvarchar(50)
	Declare @Comment7 as  nvarchar(50)
	Declare @Comment8 as  nvarchar(50)
	Declare @Comment9 as  nvarchar(50)
	Declare @Comment10 as  nvarchar(50)
	Declare @Comment11 as  nvarchar(50)
	Declare @Comment12 as  nvarchar(50)
	Declare @Comment13 as  nvarchar(50)
	Declare @Comment14 as  nvarchar(50)
	Declare @Comment15 as  nvarchar(50)
	Declare @Comment16 as  nvarchar(50)
	Declare @Comment17 as  nvarchar(50)
	Declare @Comment18 as  nvarchar(50)
	Declare @Comment19 as  nvarchar(50)
	Declare @Comment20 as  nvarchar(50)
	Declare @Comment21 as  nvarchar(50)
	Declare @Comment22 as  nvarchar(50)
	Declare @Comment23 as  nvarchar(50)
	Declare @Comment24 as  nvarchar(50)
	Declare @Comment25 as  nvarchar(50)
	Declare @Comment26 as  nvarchar(50)
	Declare @Comment27 as  nvarchar(50)
	Declare @Comment28 as  nvarchar(50)
	Declare @Comment29 as  nvarchar(50)
	Declare @Comment30 as  nvarchar(50)
	Declare @CommentID int

	Set @ClassTypeID = (Select ClassTypeID from Classes where ClassID = @ClassID)
	Declare @FetchCommentNumber int
	Declare @FetchComment nvarchar(50)
	Declare CommentCursor Cursor For
	Select 	CommentNumber, 
			convert(nvarchar(2), CommentNumber) + '. ' + CommentDescription
	from CustomTypeComments
	Where ClassTypeID = @ClassTypeID

	Open  CommentCursor

	FETCH NEXT FROM CommentCursor INTO @FetchCommentNumber, @FetchComment
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN

	If @FetchCommentNumber = 1
	Set @Comment1 = @FetchComment
	If @FetchCommentNumber = 2
	Set @Comment2 = @FetchComment
	If @FetchCommentNumber = 3
	Set @Comment3 = @FetchComment
	If @FetchCommentNumber = 4
	Set @Comment4 = @FetchComment
	If @FetchCommentNumber = 5
	Set @Comment5 = @FetchComment
	If @FetchCommentNumber = 6
	Set @Comment6 = @FetchComment
	If @FetchCommentNumber = 7
	Set @Comment7 = @FetchComment
	If @FetchCommentNumber = 8
	Set @Comment8 = @FetchComment
	If @FetchCommentNumber = 9
	Set @Comment9 = @FetchComment
	If @FetchCommentNumber = 10
	Set @Comment10 = @FetchComment
	If @FetchCommentNumber = 11
	Set @Comment11 = @FetchComment
	If @FetchCommentNumber = 12
	Set @Comment12 = @FetchComment
	If @FetchCommentNumber = 13
	Set @Comment13 = @FetchComment
	If @FetchCommentNumber = 14
	Set @Comment14 = @FetchComment
	If @FetchCommentNumber = 15
	Set @Comment15 = @FetchComment
	If @FetchCommentNumber = 16
	Set @Comment16 = @FetchComment
	If @FetchCommentNumber = 17
	Set @Comment17 = @FetchComment
	If @FetchCommentNumber = 18
	Set @Comment18 = @FetchComment
	If @FetchCommentNumber = 19
	Set @Comment19 = @FetchComment
	If @FetchCommentNumber = 20
	Set @Comment20 = @FetchComment
	If @FetchCommentNumber = 21
	Set @Comment21 = @FetchComment
	If @FetchCommentNumber = 22
	Set @Comment22 = @FetchComment
	If @FetchCommentNumber = 23
	Set @Comment23 = @FetchComment
	If @FetchCommentNumber = 24
	Set @Comment24 = @FetchComment
	If @FetchCommentNumber = 25
	Set @Comment25 = @FetchComment
	If @FetchCommentNumber = 26
	Set @Comment26 = @FetchComment



	If @FetchCommentNumber =27 
	Set @Comment27 = @FetchComment
	If @FetchCommentNumber = 28
	Set @Comment28 = @FetchComment
	If @FetchCommentNumber = 29
	Set @Comment29 = @FetchComment
	If @FetchCommentNumber = 30
	Set @Comment30 = @FetchComment


	FETCH NEXT FROM CommentCursor INTO @FetchCommentNumber, @FetchComment

	End
	Close CommentCursor
	Deallocate CommentCursor


	 Set @TermID = (Select TermID from Classes where ClassID = @ClassID)
	 Set @ParentTermID = (Select ParentTermID from Terms where TermID = @TermID)
	 Set @TermTitle = (Select TermTitle from Terms where TermID = @TermID)
	 Set @TermReportTitle = (Select ReportTitle from Terms where TermID = @TermID)
	 Set @TermStart = (Select StartDate from Terms where TermID = @TermID)
	 Set @TermEnd = (Select EndDate from Terms where TermID = @TermID)
	 Set @ExamTerm = (Select ExamTerm from Terms where TermID = @TermID)
	 Set @TeacherID = (Select TeacherID from Classes where ClassID = @ClassID)
	 Set @StaffTitle = (Select StaffTitle from Teachers where TeacherID = @TeacherID)
	 Set @TFname = (Select Fname from Teachers where TeacherID = @TeacherID)
	 Set @TLname = (Select Lname from Teachers where TeacherID = @TeacherID)
	 Set @ClassTitle = (Select ReportTitle from Classes where ClassID = @ClassID)
	 Set @ReportOrder = (Select ReportOrder  from Classes where ClassID = @ClassID) 
	 Set @Period = (Select Period from Classes where ClassID = @ClassID)
	 Set @ReportSectionTitle = (Select ReportSectionTitle From ClassType Where ClassTypeID = @ClassTypeID)
	 Set @SubCommentClassTypeID = (Select SubCommentClassTypeID from Classes where ClassID = @ClassID)

	-- Create GradeScaleLegend string
	Declare @GradeScaleLegend nvarchar(500)
	Set @GradeScaleLegend = ' '
	Declare @FetchGradeScaleItem nvarchar(10)
	Declare @FetchGradeScaleItemDescription nvarchar(200) -- zoho 18906, grade scale legends were being truncated; match SQL table size

	Declare GradeScaleCursor Cursor For
	Select GradeScaleItem, GradeScaleItemDescription
	from GradeScale
	Where ClassTypeID = @ClassTypeID
	Order By GradeScaleOrder

	Open  GradeScaleCursor

	FETCH NEXT FROM GradeScaleCursor INTO @FetchGradeScaleItem, @FetchGradeScaleItemDescription
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN

	Set @GradeScaleLegend = @GradeScaleLegend + '(' + @FetchGradeScaleItem + ')' + '=' + @FetchGradeScaleItemDescription + '  '

	FETCH NEXT FROM GradeScaleCursor INTO @FetchGradeScaleItem, @FetchGradeScaleItemDescription

	End
	Close GradeScaleCursor
	Deallocate GradeScaleCursor
																					

																					
	Declare @FetchStudentID int
																		
	Declare StudentCursor Cursor For
	Select StudentID
	from ClassesStudents
	Where 
	case 
		when @TheStudentID is not null and @StudentCSID = CSID then 1
		when @TheStudentID is null and ClassID = @ClassID then 1
		else 0
	end = 1
	and
	ClassGradeOnConclude is null

	Open  StudentCursor
																																					
	FETCH NEXT FROM StudentCursor INTO @FetchStudentID
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN

	 Set @StudentID = @FetchStudentID
 	 Select 
	 	@Fname=Fname, @Mname=Mname, @Lname=Lname, @Suffix=Suffix, @Nickname=Nickname 
	 from Students 
	 where StudentID = @StudentID

	 Set @CSID = (Select CSID from ClassesStudents where ClassID = @ClassID and StudentID = @FetchStudentID)



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


		Declare @FetchCSCFID int
		
		Declare CSCFCursor Cursor For
		Select CSCFID
		from 	ClassesStudentsCF CSCF
					inner join CustomFields CF
					on CSCF.CustomFieldID = CF.CustomFieldID
		Where CSCF.CSID = @CSID and CF.ClassTypeID = @ClassTypeID
		
		Open  CSCFCursor
		
		FETCH NEXT FROM CSCFCursor INTO @FetchCSCFID
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
		
		Select 	@CustomFieldGrade = CFGrade,
				@ClassComments = CFComments,
				@CustomFieldOrder = CF.CustomFieldOrder,
				@FieldBolded = CF.FieldBolded,
				@FieldNotGraded = CF.FieldNotGraded,
				@Indent = CF.Indent,
				@Bullet = CF.Bullet,
				@CustomFieldName = CF.CustomFieldName,
				@CustomFieldSpanishName = CF.CustomFieldSpanishName
		From	CustomFields CF
					inner join
				ClassesStudentsCF CSCF
					on CF.CustomFieldID = CSCF.CustomFieldID
		Where CSCF.CSCFID = @FetchCSCFID
		
		BEGIN TRY

		 Insert Into Transcript
		(
			TermID,
			ParentTermID,
			TermTitle,
			TermReportTitle,
			TermStart,
			TermEnd,
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
			ReportOrder,
			ClassTypeID,
			ParentClassID,
			SubCommentClassTypeID,
			Period,
			CustomFieldName,
			CustomFieldSpanishName,
			CustomFieldGrade,
			CustomFieldOrder,
			FieldBolded,
			FieldNotGraded,
			Indent,
			Bullet,
			GradeScaleLegend,
			ReportSectionTitle,
			ClassComments,
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
			ConcludeDate,
			GPABoost
		)
		
		 Values(
			@TermID,
			@ParentTermID,
			@TermTitle,
			@TermReportTitle,
			@TermStart,
			@TermEnd,
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
			@ClassID,
			@ClassTitle,
			@ReportOrder,
			@ClassTypeID,
			@ParentClassID,
			@SubCommentClassTypeID,
			@Period,
			@CustomFieldName,
			@CustomFieldSpanishName,
			@CustomFieldGrade,
			@CustomFieldOrder,
			@FieldBolded,
			@FieldNotGraded,
			@Indent,
			@Bullet,
			@GradeScaleLegend,
			@ReportSectionTitle,
			@ClassComments,
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
			convert(char(30), dbo.GLgetdatetime()),
			0
		)
		
		END TRY
		BEGIN CATCH
			-- Error handling code goes here
		END CATCH
		
		
		 FETCH NEXT FROM CSCFCursor INTO @FetchCSCFID
		
		End
		
		Close CSCFCursor
		Deallocate CSCFCursor


	 FETCH NEXT FROM StudentCursor INTO @FetchStudentID

	End

	Close StudentCursor
	Deallocate StudentCursor


	-- Old code to delete class when concluding
	--**********************************************************
	-- Delete from Classes
	-- where ClassID = @ClassID
	--**********************************************************

If @TheStudentID is not null 
Begin
	Update ClassesStudents
	Set 
	ClassGradeOnConclude = dbo.TrimZeros(StudentGrade),
	StudentConcludeDate = dbo.GLgetdatetime()
	Where
	CSID = @StudentCSID
End	


End -- If Non-Academic Class


	Update Classes
	Set Concluded = 1
	Where ClassID = @ClassID

COMMIT


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON


GO
