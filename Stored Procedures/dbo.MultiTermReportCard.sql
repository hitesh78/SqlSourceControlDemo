SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MultiTermReportCard]
@AvgGrade nvarchar(3),
@ShowLegend nvarchar(3),
@Browser nvarchar(50),
@ClassID int,
@EK Decimal(15,15),
@PB nvarchar(50),
@ForceSemesterGrade nvarchar(3),   
@TeacherName nvarchar(3),
@SchoolInfo nvarchar(3),
@ReportTitle nvarchar(100),
@PromotedLine nvarchar(3), 
@SignatureText nvarchar(1000),
@Gradelevel nvarchar(3),
@ReportType nvarchar(10),
@StudentIDs nvarchar(1000),
@Terms nvarchar(100),
@ReportOrder nvarchar(1000),
@StandardClasses nvarchar(3),
@ClassCredits nvarchar(3),
@ClassEffort nvarchar(3),
@ClassAttendance nvarchar(3),
@StandardClassesComments nvarchar(3),
@GPA nvarchar(3),
@TermComments nvarchar(3),
@SchoolAttendance nvarchar(3),
@WorshipAttendance nvarchar(3),
@ClassTypeIDs nvarchar(500),
@CommentCustomClassTypeIDs nvarchar(500),
@RunByClassSetting nvarchar(5),
@TheClassID int,
@GradeStyle nvarchar(12),
@ProfileID int

as

-- Create and Define temp table of all data within date range.
CREATE TABLE #ReportCardData (
	[TranscriptID] [int] NULL ,
	[TermID] [int] NOT NULL ,
	[TermTitle] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[TermReportTitle] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TermStart] [datetime] NOT NULL ,
	[TermEnd] [datetime] NOT NULL ,
	[ParentTermID] [int] NULL ,
	[TermWeight] [decimal](5,2) NULL ,
	[ExamTerm] [bit] NULL ,
	[StudentID] [int] NOT NULL ,
	[GradeLevel]  [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Mname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[StaffTitle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TFname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TLname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[TermComment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ClassID] [int] NULL ,
	[ClassTitle] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ReportOrder] [int] NULL ,
	[ClassTypeID] [int] NOT NULL ,
	[ParentClassID] [int] NULL ,
	[SubCommentClassTypeID] [int] NULL ,
	[CustomGradeScaleID] [int] NULL ,
	[ClassUnits] [decimal](7,4) NULL ,
	[UnitsEarned] [decimal](7,4) NULL ,
	[Period] [tinyint] NULL ,
	[LetterGrade] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[AlternativeGrade] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[PercentageGrade] [decimal](5,2) NULL ,
	[UnitGPA] [decimal](7,4) NULL ,
	[CustomFieldName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CustomFieldGrade] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CustomFieldOrder] [int] NULL ,
	[FieldBolded] [int] Null,
	[FieldNotGraded] [int] Null,
	[GradeScaleLegend]  [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ReportSectionTitle] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Effort] [tinyint] NULL ,
	[ClassComments] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Att1] [smallint] NULL ,
	[PercAtt1] [decimal](5, 2) NULL ,
	[Att2] [smallint] NULL ,
	[PercAtt2] [decimal](5, 2) NULL ,
	[Att3] [smallint] NULL ,
	[PercAtt3] [decimal](5, 2) NULL ,
	[Att4] [smallint] NULL ,
	[PercAtt4] [decimal](5, 2) NULL ,
	[Att5] [smallint] NULL ,
	[PercAtt5] [decimal](5, 2) NULL ,
	[SchoolAtt1] [decimal](5, 1) NULL ,
	[PercSchoolAtt1] [decimal](5, 2) NULL ,
	[SchoolAtt2] [decimal](5, 1) NULL ,
	[PercSchoolAtt2] [decimal](5, 2) NULL ,
	[SchoolAtt3] [smallint] NULL ,
	[PercSchoolAtt3] [decimal](5, 2) NULL ,
	[SchoolAtt4] [smallint] NULL ,
	[PercSchoolAtt4] [decimal](5, 2) NULL ,
	[SchoolAtt5] [smallint] NULL ,
	[PercSchoolAtt5] [decimal](5, 2) NULL ,
	[SchoolAtt6] [smallint] NULL ,
	[PercSchoolAtt6] [decimal](5, 2) NULL ,
	[SchoolAtt7] [smallint] NULL ,
	[PercSchoolAtt7] [decimal](5, 2) NULL ,
	[SchoolAtt8] [smallint] NULL ,
	[PercSchoolAtt8] [decimal](5, 2) NULL ,
	[SchoolAtt9] [smallint] NULL ,
	[PercSchoolAtt9] [decimal](5, 2) NULL ,
	[SchoolAtt10] [smallint] NULL ,
	[PercSchoolAtt10] [decimal](5, 2) NULL ,
	[SchoolAtt11] [smallint] NULL ,
	[PercSchoolAtt11] [decimal](5, 2) NULL ,
	[SchoolAtt12] [smallint] NULL ,
	[PercSchoolAtt12] [decimal](5, 2) NULL ,
	[SchoolAtt13] [smallint] NULL ,
	[PercSchoolAtt13] [decimal](5, 2) NULL ,
	[SchoolAtt14] [smallint] NULL ,
	[PercSchoolAtt14] [decimal](5, 2) NULL ,
	[SchoolAtt15] [smallint] NULL ,
	[PercSchoolAtt15] [decimal](5, 2) NULL ,
	[ChurchPresent] [smallint] NULL ,
	[PercChurchPresent] [decimal](5, 2) NULL ,
	[ChurchAbsent] [smallint] NULL ,
	[PercChurchAbsent] [decimal](5, 2) NULL ,
	[SSchoolPresent] [smallint] NULL ,
	[PercSSchoolPresent] [decimal](5, 2) NULL ,
	[SSchoolAbsent] [smallint] NULL ,
	[PercSSchoolAbsent] [decimal](5, 2) NULL ,
	[Exceptional] [smallint] NULL ,
	[PercExceptional] [decimal](5, 2) NULL ,
	[Good] [smallint] NULL ,
	[PercGood] [decimal](5, 2) NULL ,
	[Poor] [smallint] NULL ,
	[PercPoor] [decimal](5, 2) NULL ,
	[Unacceptable] [smallint] NULL ,
	[PercUnacceptable] [decimal](5, 2) NULL ,
	[CommentName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CommentAbbr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment6] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment7] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment8] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment9] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment10] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment11] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment12] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment13] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment14] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment15] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment16] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment17] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment18] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment19] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment20] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment21] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment22] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment23] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment24] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment25] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment26] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment27] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment28] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment29] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Comment30] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CategoryName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CategoryAbbr] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category1Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category1Desc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category2Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category2Desc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category3Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category3Desc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category4Symbol] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Category4Desc] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ConcludeDate] [nvarchar](40) NULL
)

Create Index ReportCardData_Index on #ReportCardData (StudentID, ClassTypeID, TermID)

Declare @NumMissingClassTypes int
Declare @AreStudentsMissingClassTypes nvarchar(5)
Declare @TermCount int
Set @TermCount = (Select count(*) From SplitCSVIntegers(@Terms))

-- Update ClassTypeIDs Add built-in any types
if @StandardClasses = 'yes'
Set @ClassTypeIDs = @ClassTypeIDs + '1,2,8,'
if @TermComments = 'yes'
Set @ClassTypeIDs = @ClassTypeIDs + '3,'
if @SchoolAttendance = 'yes'
Set @ClassTypeIDs = @ClassTypeIDs + '5,'
if @WorshipAttendance = 'yes'

Set @ClassTypeIDs = @ClassTypeIDs + '6,'

Declare @ReportGroupType nvarchar(12)
Declare @ReportGroupIdentifier nvarchar(1000)




Declare @ActiveStudents int
Declare @InActiveStudents int 

Set @ActiveStudents = 
(
	Select count(*) 
	From
	Transcript T
		inner join
	Students S
		on T.StudentID = S.StudentID
	Where 	
	T.TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
	and
	S.Active = 1
)


Set @InActiveStudents = 
(
	Select count(*) 
	From
	Transcript T
		inner join
	Students S
		on T.StudentID = S.StudentID
	Where 	
	T.TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
	and
	S.Active = 0
)







If @ReportType = 'Individual'
Begin

	-- Get list of SubComments ClassTypeIDs
	Select Distinct ClassTypeID
	into #SubCommentClassTypeIDs1
	From Transcript
	Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
			and
			StudentID in (Select IntegerID From SplitCSVIntegers(@StudentIDs))
			and
			ParentClassID > 0



	Set @ReportGroupType = 'ByStudent'
	Set @ReportGroupIdentifier = convert(nvarchar(1000), @StudentIDs)
	-- Populate Temp Table for a single Student

	Insert into #ReportCardData
	(
	[TranscriptID],
	[TermID],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[ParentTermID],
	[TermWeight],
	[ExamTerm],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[StaffTitle],
	[TFname],
	[TLname],
	[TermComment],
	[ClassID],
	[ClassTitle],
	[ReportOrder],
	[ClassTypeID],
	[ParentClassID],
	[SubCommentClassTypeID],
	[CustomGradeScaleID],
	[ClassUnits],
	[UnitsEarned],
	[Period],
	[LetterGrade],
	[AlternativeGrade],
	[PercentageGrade],
	[UnitGPA],
	[CustomFieldName],
	[CustomFieldGrade],
	[CustomFieldOrder],
	[GradeScaleLegend],
	[ReportSectionTitle],
	[Effort],
	[ClassComments],
	[Att1],
	[PercAtt1],
	[Att2],
	[PercAtt2],
	[Att3],
	[PercAtt3],
	[Att4],
	[PercAtt4],
	[Att5],
	[PercAtt5],
	[SchoolAtt1],
	[PercSchoolAtt1],
	[SchoolAtt2],
	[PercSchoolAtt2],
	[SchoolAtt3],
	[PercSchoolAtt3],
	[SchoolAtt4],
	[PercSchoolAtt4],
	[SchoolAtt5],
	[PercSchoolAtt5],
	[SchoolAtt6],
	[PercSchoolAtt6],
	[SchoolAtt7],
	[PercSchoolAtt7],
	[SchoolAtt8],
	[PercSchoolAtt8],
	[SchoolAtt9],
	[PercSchoolAtt9],
	[SchoolAtt10],
	[PercSchoolAtt10],
	[SchoolAtt11],
	[PercSchoolAtt11],
	[SchoolAtt12],
	[PercSchoolAtt12],
	[SchoolAtt13],
	[PercSchoolAtt13],
	[SchoolAtt14],
	[PercSchoolAtt14],
	[SchoolAtt15],
	[PercSchoolAtt15],
	[ChurchPresent],
	[PercChurchPresent],
	[ChurchAbsent],
	[PercChurchAbsent],
	[SSchoolPresent],
	[PercSSchoolPresent],
	[SSchoolAbsent],
	[PercSSchoolAbsent],
	[Exceptional],
	[PercExceptional],
	[Good],
	[PercGood],
	[Poor],
	[PercPoor],
	[Unacceptable],
	[PercUnacceptable],
	[CommentName],
	[CommentAbbr],
	[Comment1],
	[Comment2],
	[Comment3],
	[Comment4],
	[Comment5],
	[Comment6],
	[Comment7],
	[Comment8],
	[Comment9],
	[Comment10],
	[Comment11],
	[Comment12],
	[Comment13],
	[Comment14],
	[Comment15],
	[Comment16],
	[Comment17],
	[Comment18],
	[Comment19],
	[Comment20],
	[Comment21],
	[Comment22],
	[Comment23],
	[Comment24],
	[Comment25],
	[Comment26],
	[Comment27],
	[Comment28],
	[Comment29],
	[Comment30],
	[CategoryName],
	[CategoryAbbr],
	[Category1Symbol],
	[Category1Desc],
	[Category2Symbol],
	[Category2Desc],
	[Category3Symbol],
	[Category3Desc],
	[Category4Symbol],
	[Category4Desc],
	[ConcludeDate]
	)
	Select
	[TranscriptID],
	[TermID],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[ParentTermID],
	[TermWeight],
	[ExamTerm],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[StaffTitle],
	[TFname],
	[TLname],
	[TermComment],
	[ClassID],
	[ClassTitle],
	[ReportOrder],
	[ClassTypeID],
	[ParentClassID],
	[SubCommentClassTypeID],
	[CustomGradeScaleID],
	[ClassUnits],
	[UnitsEarned],
	[Period],
	[LetterGrade],
	[AlternativeGrade],
	[PercentageGrade],
	[UnitGPA],
	[CustomFieldName],
	[CustomFieldGrade],
	[CustomFieldOrder],
	[GradeScaleLegend],
	[ReportSectionTitle],
	[Effort],
	[ClassComments],
	[Att1],
	[PercAtt1],
	[Att2],
	[PercAtt2],
	[Att3],
	[PercAtt3],
	[Att4],
	[PercAtt4],
	[Att5],
	[PercAtt5],
	[SchoolAtt1],
	[PercSchoolAtt1],
	[SchoolAtt2],
	[PercSchoolAtt2],
	[SchoolAtt3],
	[PercSchoolAtt3],
	[SchoolAtt4],
	[PercSchoolAtt4],
	[SchoolAtt5],
	[PercSchoolAtt5],
	[SchoolAtt6],
	[PercSchoolAtt6],
	[SchoolAtt7],
	[PercSchoolAtt7],
	[SchoolAtt8],
	[PercSchoolAtt8],
	[SchoolAtt9],
	[PercSchoolAtt9],
	[SchoolAtt10],
	[PercSchoolAtt10],
	[SchoolAtt11],
	[PercSchoolAtt11],
	[SchoolAtt12],
	[PercSchoolAtt12],
	[SchoolAtt13],
	[PercSchoolAtt13],
	[SchoolAtt14],
	[PercSchoolAtt14],
	[SchoolAtt15],
	[PercSchoolAtt15],
	[ChurchPresent],
	[PercChurchPresent],
	[ChurchAbsent],
	[PercChurchAbsent],
	[SSchoolPresent],
	[PercSSchoolPresent],
	[SSchoolAbsent],
	[PercSSchoolAbsent],
	[Exceptional],
	[PercExceptional],
	[Good],
	[PercGood],
	[Poor],
	[PercPoor],
	[Unacceptable],
	[PercUnacceptable],
	[CommentName],
	[CommentAbbr],
	[Comment1],
	[Comment2],
	[Comment3],
	[Comment4],
	[Comment5],
	[Comment6],
	[Comment7],
	[Comment8],
	[Comment9],
	[Comment10],
	[Comment11],
	[Comment12],
	[Comment13],
	[Comment14],
	[Comment15],
	[Comment16],
	[Comment17],
	[Comment18],
	[Comment19],
	[Comment20],
	[Comment21],
	[Comment22],
	[Comment23],
	[Comment24],
	[Comment25],
	[Comment26],
	[Comment27],
	[Comment28],
	[Comment29],
	[Comment30],
	[CategoryName],
	[CategoryAbbr],
	[Category1Symbol],
	[Category1Desc],
	[Category2Symbol],
	[Category2Desc],
	[Category3Symbol],
	[Category3Desc],
	[Category4Symbol],
	[Category4Desc],
	[ConcludeDate]
	From Transcript
	Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
			and
			StudentID in (Select IntegerID From SplitCSVIntegers(@StudentIDs))
			and
			(
			ClassTypeID in (Select IntegerID From SplitCSVIntegers(@ClassTypeIDs)) -- Custom Class Types
			or
			ClassTypeID in (Select ClassTypeID From #SubCommentClassTypeIDs1) -- SubComments Class Types
			)




End
Else
Begin
	If @RunByClassSetting = 'yes'
	Begin

		Select distinct StudentID
		into #Students
		From Transcript
		Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
				and
				ClassID = @TheClassID
				and
				StudentID in (Select StudentID From Students Where Active = 1)
	
	
		-- Get list of SubComments ClassTypeIDs
		Select Distinct ClassTypeID
		into #SubCommentClassTypeIDs2
		From Transcript
		Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
				and
				StudentID in (Select StudentID From #Students)
				and
				ParentClassID > 0
				and
				(case
					when @ActiveStudents < @InActiveStudents then 1 
					when StudentID in (Select StudentID From Students Where Active = 1) then 1
					else 0
				end) = 1
	
	
	
		Set @ReportGroupType = 'ByClass'
		Set @ReportGroupIdentifier = convert(nvarchar(1000), @TheClassID)
		-- Populate Temp Table for a single Class
		Insert into #ReportCardData
	(
	[TranscriptID],
	[TermID],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[ParentTermID],
	[TermWeight],
	[ExamTerm],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[StaffTitle],
	[TFname],
	[TLname],
	[TermComment],
	[ClassID],
	[ClassTitle],
	[ReportOrder],
	[ClassTypeID],
	[ParentClassID],
	[SubCommentClassTypeID],
	[CustomGradeScaleID],
	[ClassUnits],
	[UnitsEarned],
	[Period],
	[LetterGrade],
	[AlternativeGrade],
	[PercentageGrade],
	[UnitGPA],
	[CustomFieldName],
	[CustomFieldGrade],
	[CustomFieldOrder],
	[GradeScaleLegend],
	[ReportSectionTitle],
	[Effort],
	[ClassComments],
	[Att1],
	[PercAtt1],
	[Att2],
	[PercAtt2],
	[Att3],
	[PercAtt3],
	[Att4],
	[PercAtt4],
	[Att5],
	[PercAtt5],
	[SchoolAtt1],
	[PercSchoolAtt1],
	[SchoolAtt2],
	[PercSchoolAtt2],
	[SchoolAtt3],
	[PercSchoolAtt3],
	[SchoolAtt4],
	[PercSchoolAtt4],
	[SchoolAtt5],
	[PercSchoolAtt5],
	[SchoolAtt6],
	[PercSchoolAtt6],
	[SchoolAtt7],
	[PercSchoolAtt7],
	[SchoolAtt8],
	[PercSchoolAtt8],
	[SchoolAtt9],
	[PercSchoolAtt9],
	[SchoolAtt10],
	[PercSchoolAtt10],
	[SchoolAtt11],
	[PercSchoolAtt11],
	[SchoolAtt12],
	[PercSchoolAtt12],
	[SchoolAtt13],
	[PercSchoolAtt13],
	[SchoolAtt14],
	[PercSchoolAtt14],
	[SchoolAtt15],
	[PercSchoolAtt15],
	[ChurchPresent],
	[PercChurchPresent],
	[ChurchAbsent],
	[PercChurchAbsent],
	[SSchoolPresent],
	[PercSSchoolPresent],
	[SSchoolAbsent],
	[PercSSchoolAbsent],
	[Exceptional],
	[PercExceptional],
	[Good],
	[PercGood],
	[Poor],
	[PercPoor],
	[Unacceptable],
	[PercUnacceptable],
	[CommentName],
	[CommentAbbr],
	[Comment1],
	[Comment2],
	[Comment3],
	[Comment4],
	[Comment5],
	[Comment6],
	[Comment7],
	[Comment8],
	[Comment9],
	[Comment10],
	[Comment11],
	[Comment12],
	[Comment13],
	[Comment14],
	[Comment15],
	[Comment16],
	[Comment17],
	[Comment18],
	[Comment19],
	[Comment20],
	[Comment21],
	[Comment22],
	[Comment23],
	[Comment24],
	[Comment25],
	[Comment26],
	[Comment27],
	[Comment28],
	[Comment29],
	[Comment30],
	[CategoryName],
	[CategoryAbbr],
	[Category1Symbol],
	[Category1Desc],
	[Category2Symbol],
	[Category2Desc],
	[Category3Symbol],
	[Category3Desc],
	[Category4Symbol],
	[Category4Desc],
	[ConcludeDate]
	)
	Select
	[TranscriptID],
	[TermID],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[ParentTermID],
	[TermWeight],
	[ExamTerm],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[StaffTitle],
	[TFname],
	[TLname],
	[TermComment],
	[ClassID],
	[ClassTitle],
	[ReportOrder],
	[ClassTypeID],
	[ParentClassID],
	[SubCommentClassTypeID],
	[CustomGradeScaleID],
	[ClassUnits],
	[UnitsEarned],
	[Period],
	[LetterGrade],
	[AlternativeGrade],
	[PercentageGrade],
	[UnitGPA],
	[CustomFieldName],
	[CustomFieldGrade],
	[CustomFieldOrder],
	[GradeScaleLegend],
	[ReportSectionTitle],
	[Effort],
	[ClassComments],
	[Att1],
	[PercAtt1],
	[Att2],
	[PercAtt2],
	[Att3],
	[PercAtt3],
	[Att4],
	[PercAtt4],
	[Att5],
	[PercAtt5],
	[SchoolAtt1],
	[PercSchoolAtt1],
	[SchoolAtt2],
	[PercSchoolAtt2],
	[SchoolAtt3],
	[PercSchoolAtt3],
	[SchoolAtt4],
	[PercSchoolAtt4],
	[SchoolAtt5],
	[PercSchoolAtt5],
	[SchoolAtt6],
	[PercSchoolAtt6],
	[SchoolAtt7],
	[PercSchoolAtt7],
	[SchoolAtt8],
	[PercSchoolAtt8],
	[SchoolAtt9],
	[PercSchoolAtt9],
	[SchoolAtt10],
	[PercSchoolAtt10],
	[SchoolAtt11],
	[PercSchoolAtt11],
	[SchoolAtt12],
	[PercSchoolAtt12],
	[SchoolAtt13],
	[PercSchoolAtt13],
	[SchoolAtt14],
	[PercSchoolAtt14],
	[SchoolAtt15],
	[PercSchoolAtt15],
	[ChurchPresent],
	[PercChurchPresent],
	[ChurchAbsent],
	[PercChurchAbsent],
	[SSchoolPresent],
	[PercSSchoolPresent],
	[SSchoolAbsent],
	[PercSSchoolAbsent],
	[Exceptional],
	[PercExceptional],
	[Good],
	[PercGood],
	[Poor],
	[PercPoor],
	[Unacceptable],
	[PercUnacceptable],
	[CommentName],
	[CommentAbbr],
	[Comment1],
	[Comment2],
	[Comment3],
	[Comment4],
	[Comment5],
	[Comment6],
	[Comment7],
	[Comment8],
	[Comment9],
	[Comment10],
	[Comment11],
	[Comment12],
	[Comment13],
	[Comment14],
	[Comment15],
	[Comment16],
	[Comment17],
	[Comment18],
	[Comment19],
	[Comment20],
	[Comment21],
	[Comment22],
	[Comment23],
	[Comment24],
	[Comment25],
	[Comment26],
	[Comment27],
	[Comment28],
	[Comment29],
	[Comment30],
	[CategoryName],
	[CategoryAbbr],
	[Category1Symbol],
	[Category1Desc],
	[Category2Symbol],
	[Category2Desc],
	[Category3Symbol],
	[Category3Desc],
	[Category4Symbol],
	[Category4Desc],
	[ConcludeDate]
		From Transcript
		Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
				and
				StudentID in (Select StudentID From #Students)
				and
				(
				ClassTypeID in (Select IntegerID From SplitCSVIntegers(@ClassTypeIDs)) -- Custom Class Types
				or
				ClassTypeID in (Select ClassTypeID From #SubCommentClassTypeIDs2) -- SubComments Class Types
				)
				and
				(case
					when @ActiveStudents < @InActiveStudents then 1 
					when StudentID in (Select StudentID From Students Where Active = 1) then 1
					else 0
				end) = 1	


	End
	Else
	Begin
		-- Get list of SubComments ClassTypeIDs
		Select Distinct ClassTypeID
		into #SubCommentClassTypeIDs3
		From Transcript
		Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
				and
				GradeLevel = @Gradelevel
				and
				ParentClassID > 0
				and
				(case
					when @ActiveStudents < @InActiveStudents then 1 
					when StudentID in (Select StudentID From Students Where Active = 1) then 1
					else 0
				end) = 1	
		
			Set @ReportGroupType = 'ByGradeLevel'
			Set @ReportGroupIdentifier = @Gradelevel
	
				-- Populate Temp Table for all Students for a specific Gradelevel

				Insert into #ReportCardData
	(
	[TranscriptID],
	[TermID],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[ParentTermID],
	[TermWeight],
	[ExamTerm],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[StaffTitle],
	[TFname],
	[TLname],
	[TermComment],
	[ClassID],
	[ClassTitle],
	[ReportOrder],
	[ClassTypeID],
	[ParentClassID],
	[SubCommentClassTypeID],
	[CustomGradeScaleID],
	[ClassUnits],
	[UnitsEarned],
	[Period],
	[LetterGrade],
	[AlternativeGrade],
	[PercentageGrade],
	[UnitGPA],
	[CustomFieldName],
	[CustomFieldGrade],
	[CustomFieldOrder],
	[GradeScaleLegend],
	[ReportSectionTitle],
	[Effort],
	[ClassComments],
	[Att1],
	[PercAtt1],
	[Att2],
	[PercAtt2],
	[Att3],
	[PercAtt3],
	[Att4],
	[PercAtt4],
	[Att5],
	[PercAtt5],
	[SchoolAtt1],
	[PercSchoolAtt1],
	[SchoolAtt2],
	[PercSchoolAtt2],
	[SchoolAtt3],
	[PercSchoolAtt3],
	[SchoolAtt4],
	[PercSchoolAtt4],
	[SchoolAtt5],
	[PercSchoolAtt5],
	[SchoolAtt6],
	[PercSchoolAtt6],
	[SchoolAtt7],
	[PercSchoolAtt7],
	[SchoolAtt8],
	[PercSchoolAtt8],
	[SchoolAtt9],
	[PercSchoolAtt9],
	[SchoolAtt10],
	[PercSchoolAtt10],
	[SchoolAtt11],
	[PercSchoolAtt11],
	[SchoolAtt12],
	[PercSchoolAtt12],
	[SchoolAtt13],
	[PercSchoolAtt13],
	[SchoolAtt14],
	[PercSchoolAtt14],
	[SchoolAtt15],
	[PercSchoolAtt15],
	[ChurchPresent],
	[PercChurchPresent],
	[ChurchAbsent],
	[PercChurchAbsent],
	[SSchoolPresent],
	[PercSSchoolPresent],
	[SSchoolAbsent],
	[PercSSchoolAbsent],
	[Exceptional],
	[PercExceptional],
	[Good],
	[PercGood],
	[Poor],
	[PercPoor],
	[Unacceptable],
	[PercUnacceptable],
	[CommentName],
	[CommentAbbr],
	[Comment1],
	[Comment2],
	[Comment3],
	[Comment4],
	[Comment5],
	[Comment6],
	[Comment7],
	[Comment8],
	[Comment9],
	[Comment10],
	[Comment11],
	[Comment12],
	[Comment13],
	[Comment14],
	[Comment15],
	[Comment16],
	[Comment17],
	[Comment18],
	[Comment19],
	[Comment20],
	[Comment21],
	[Comment22],
	[Comment23],
	[Comment24],
	[Comment25],
	[Comment26],
	[Comment27],
	[Comment28],
	[Comment29],
	[Comment30],
	[CategoryName],
	[CategoryAbbr],
	[Category1Symbol],
	[Category1Desc],
	[Category2Symbol],
	[Category2Desc],
	[Category3Symbol],
	[Category3Desc],
	[Category4Symbol],
	[Category4Desc],
	[ConcludeDate]
	)
	Select
	[TranscriptID],
	[TermID],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[ParentTermID],
	[TermWeight],
	[ExamTerm],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[StaffTitle],
	[TFname],
	[TLname],
	[TermComment],
	[ClassID],
	[ClassTitle],
	[ReportOrder],
	[ClassTypeID],
	[ParentClassID],
	[SubCommentClassTypeID],
	[CustomGradeScaleID],
	[ClassUnits],
	[UnitsEarned],
	[Period],
	[LetterGrade],
	[AlternativeGrade],
	[PercentageGrade],
	[UnitGPA],
	[CustomFieldName],
	[CustomFieldGrade],
	[CustomFieldOrder],
	[GradeScaleLegend],
	[ReportSectionTitle],
	[Effort],
	[ClassComments],
	[Att1],
	[PercAtt1],
	[Att2],
	[PercAtt2],
	[Att3],
	[PercAtt3],
	[Att4],
	[PercAtt4],
	[Att5],
	[PercAtt5],
	[SchoolAtt1],
	[PercSchoolAtt1],
	[SchoolAtt2],
	[PercSchoolAtt2],
	[SchoolAtt3],
	[PercSchoolAtt3],
	[SchoolAtt4],
	[PercSchoolAtt4],
	[SchoolAtt5],
	[PercSchoolAtt5],
	[SchoolAtt6],
	[PercSchoolAtt6],
	[SchoolAtt7],
	[PercSchoolAtt7],
	[SchoolAtt8],
	[PercSchoolAtt8],
	[SchoolAtt9],
	[PercSchoolAtt9],
	[SchoolAtt10],
	[PercSchoolAtt10],
	[SchoolAtt11],
	[PercSchoolAtt11],
	[SchoolAtt12],
	[PercSchoolAtt12],
	[SchoolAtt13],
	[PercSchoolAtt13],
	[SchoolAtt14],
	[PercSchoolAtt14],
	[SchoolAtt15],
	[PercSchoolAtt15],
	[ChurchPresent],
	[PercChurchPresent],
	[ChurchAbsent],
	[PercChurchAbsent],
	[SSchoolPresent],
	[PercSSchoolPresent],
	[SSchoolAbsent],
	[PercSSchoolAbsent],
	[Exceptional],
	[PercExceptional],
	[Good],
	[PercGood],
	[Poor],
	[PercPoor],
	[Unacceptable],
	[PercUnacceptable],
	[CommentName],
	[CommentAbbr],
	[Comment1],
	[Comment2],
	[Comment3],
	[Comment4],
	[Comment5],
	[Comment6],
	[Comment7],
	[Comment8],
	[Comment9],
	[Comment10],
	[Comment11],
	[Comment12],
	[Comment13],
	[Comment14],
	[Comment15],
	[Comment16],
	[Comment17],
	[Comment18],
	[Comment19],
	[Comment20],
	[Comment21],
	[Comment22],
	[Comment23],
	[Comment24],
	[Comment25],
	[Comment26],
	[Comment27],
	[Comment28],
	[Comment29],
	[Comment30],
	[CategoryName],
	[CategoryAbbr],
	[Category1Symbol],
	[Category1Desc],
	[Category2Symbol],
	[Category2Desc],
	[Category3Symbol],
	[Category3Desc],
	[Category4Symbol],
	[Category4Desc],
	[ConcludeDate]
				From Transcript
				Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
						and
						GradeLevel = @Gradelevel
						and
						(
						ClassTypeID in (Select IntegerID From SplitCSVIntegers(@ClassTypeIDs)) -- Custom Class Types
						or
						ClassTypeID in (Select ClassTypeID From #SubCommentClassTypeIDs3) -- SubComments Class Types
						)
						and
						(case
							when @ActiveStudents < @InActiveStudents then 1 
							when StudentID in (Select StudentID From Students Where Active = 1) then 1
							else 0
						end) = 1
	End

End

-- Set the Class Title to be the same for all attendance classes
Update #ReportCardData 
Set ClassTitle = 'School Attendance'
Where
ClassTypeID = 5


--- Reset ClassTitle to be the same for all term comments classes
Update #ReportCardData
Set ClassTitle = 'Term Comments'
Where ClassTypeID = 3


-------------------------------------------------------------------------------
-----------------Only Show Semister Grade if last term has grade---------------
-------------------------------------------------------------------------------


Create table #ClassesWithLastSubTermGrades
(
TranscriptID int,
ParentTermID int,
StudentID int,
ClassTitle nvarchar(50)
)


Declare @LastSubTermWithGrades int

Select distinct TermID
into #SemTerms
From #ReportCardData
Where 
ParentTermID = 0
and
TermID < 10000
and
ClassTypeID in (1,2,8)
and
TermID in (Select ParentTermID From #ReportCardData)


Declare @FetchSemTermID int
Declare TheCursor Cursor For
Select TermID
From #SemTerms




Open  TheCursor
FETCH NEXT FROM TheCursor INTO @FetchSemTermID
WHILE (@@FETCH_STATUS != -1)
BEGIN

Set @LastSubTermWithGrades =
(
Select top 1 TermID
From #ReportCardData
Where 
ParentTermID = @FetchSemTermID
and
ExamTerm = 0
and
ClassTypeID in (1,2)
Order By TermEnd desc, TermStart desc
)


Insert into #ClassesWithLastSubTermGrades
Select
TranscriptID,
@FetchSemTermID as ParentTermID,
StudentID,
ClassTitle
From #ReportCardData
Where
TermID = @LastSubTermWithGrades
and
ClassTypeID in (1,2)



FETCH NEXT FROM TheCursor INTO @FetchSemTermID
End

Close TheCursor
Deallocate TheCursor





-- Add Non-Transcript or other Terms that were selected but are not in 
--#ReportCardData because the terms weren't in the selected ClassTypeIDs

Select Distinct 
	TermID, 
	TermTitle, 
	ReportTitle,
	StartDate as TermStart, 
	EndDate as TermEnd,
	ParentTermID as ParentTermID,
	ExamTerm as ExamTerm,
	null as SchoolAtt1,
	null as PercSchoolAtt1,
	null as SchoolAtt2,
	null as PercSchoolAtt2,
	null as SchoolAtt3,
	null as PercSchoolAtt3,
	null as SchoolAtt4,
	null as PercSchoolAtt4,
	null as SchoolAtt5,
	null as PercSchoolAtt5,
	null as SchoolAtt6,
	null as PercSchoolAtt6,
	null as SchoolAtt7,
	null as PercSchoolAtt7,
	null as SchoolAtt8,
	null as PercSchoolAtt8,
	null as SchoolAtt9,
	null as PercSchoolAtt9,
	null as SchoolAtt10,
	null as PercSchoolAtt10,
	null as SchoolAtt11,
	null as PercSchoolAtt11,
	null as SchoolAtt12,
	null as PercSchoolAtt12,
	null as SchoolAtt13,
	null as PercSchoolAtt13,
	null as SchoolAtt14,
	null as PercSchoolAtt14,
	null as SchoolAtt15,
	null as PercSchoolAtt15,
	null as ChurchPresent,
	null as PercChurchPresent,
	null as ChurchAbsent,
	null as PercChurchAbsent,
	null as SSchoolPresent,
	null as PercSSchoolPresent,
	null as SSchoolAbsent,
	null as PercSSchoolAbsent
Into #tmpTerms
From Terms
where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
		and
		TermID not in (Select TermID From #ReportCardData)


--******* Determine if any Exam Terms are selected and SubTerm Count ***************************

Create Table #AllSelectedTerms
(TermID int, ParentTermID int, ExamTerm bit)

Insert into #AllSelectedTerms (TermID, ParentTermID, ExamTerm)
Select Distinct
	TermID,
	ParentTermID,
	ExamTerm
From #ReportCardData
Union
Select
	TermID,
	ParentTermID,
	ExamTerm
From #tmpTerms


Declare @ExamTermsPresent nvarchar(3)
Declare @SubTermCount int

If (Select count(*) From #AllSelectedTerms Where ExamTerm = 1) > 0
Begin
Set @ExamTermsPresent = 'yes'
End
Else
Begin
Set @ExamTermsPresent = 'no'
End

Set @SubTermCount = (Select count(*) From #AllSelectedTerms Where ParentTermID > 0)

if (Select count(*) From #AllSelectedTerms Where ParentTermID = 0) = 0
Begin
	Set @SubTermCount = 0
End



--*****Get a list of all TermIDs for Exam or Parent terms**
Create Table #ExamOrParentTerms (TermID int)
Insert Into #ExamOrParentTerms
Select Distinct TermID
From #AllSelectedTerms
Where 
	ExamTerm = 1
	or
	TermID in (Select ParentTermID From #AllSelectedTerms)


--*********************************************************

Drop table #AllSelectedTerms

-- ****************************************************************************************


-- Create ReportOrder table
Create Table #ReportOrderTable
(ClassTypeID int, ClassTypeOrder int)
Declare @DashPosition int
Declare @TheClassTypeID int
Declare @TheClassTypeOrder int
Declare @OrderItemLength int
Declare @FetchOrderItem nvarchar(10)
Declare ReportOrderCursor Cursor For
Select *
From SplitCSVStrings(@ReportOrder)

Open  ReportOrderCursor
FETCH NEXT FROM ReportOrderCursor INTO @FetchOrderItem
WHILE (@@FETCH_STATUS != -1)
BEGIN

Set @OrderItemLength = LEN(@FetchOrderItem) 
Set @DashPosition = CHARINDEX('-', @FetchOrderItem)
Set @TheClassTypeID = SUBSTRING ( @FetchOrderItem , 1 , (@DashPosition - 1) )
Set @TheClassTypeOrder =  SUBSTRING ( @FetchOrderItem , (@DashPosition + 1) , @OrderItemLength )

Insert into #ReportOrderTable (ClassTypeID, ClassTypeOrder)
Values(@TheClassTypeID, @TheClassTypeOrder)


FETCH NEXT FROM ReportOrderCursor INTO @FetchOrderItem
END
Close ReportOrderCursor
Deallocate ReportOrderCursor

-- Add 1000 to the ClassTypeOrder so each ClassType has big enough range that they won't overlap
-- Use the mod 1000 to translate back to ClassTypeID on the xslt side
Update #ReportOrderTable
Set ClassTypeOrder = (ClassTypeOrder * 1000) + ClassTypeID

Create table #tmpTeachers (StudentID int,Teacher nvarchar(50))  -- Holds Student Teachers

-- Set Grades For Credit / No Credit Classes
Declare @CreditNoCreditPassingGrade int
Set @CreditNoCreditPassingGrade = (Select CreditNoCreditPassingGrade From Settings Where SettingID = 1)

Update #ReportCardData
Set LetterGrade = 'NC'
Where 
ClassTypeID = 8 and PercentageGrade < @CreditNoCreditPassingGrade

Update #ReportCardData
Set LetterGrade = 'CR'
Where 
ClassTypeID = 8 and PercentageGrade >= @CreditNoCreditPassingGrade

Select TranscriptID
into #tmpCreditNoCredit
From #ReportCardData
Where ClassTypeID = 8

-- Make Honors, Credit/NoCredit, and Standard Classes all ClassTypeID 1
Update #ReportCardData
Set ClassTypeID = 1
Where ClassTypeID in (2, 8)

-- Get a List of all the distinct StudentIDs in the Data into StudentCusor
Declare @FetchStudentID int
Declare @FetchFname nvarchar(100)
Declare @FetchMname nvarchar(100)
Declare @FetchLname nvarchar(100)
Declare StudentCursor Cursor For
Select Distinct StudentID, Fname, Mname, Lname
From #ReportCardData

-- Get a List of all distinct Terms into TermsCursor

Declare @FetchTermID int
Declare @FetchTermTitle nvarchar(40)
Declare @FetchTermReportTitle nvarchar(20)
Declare @FetchTermStart smalldatetime
Declare @FetchTermEnd smalldatetime
Declare @FetchParentTermID int
Declare @FetchExamTerm bit
Declare @FetchSchoolAtt1 int
Declare @FetchPercSchoolAtt1 decimal(5,2)
Declare @FetchSchoolAtt2 int
Declare @FetchPercSchoolAtt2 decimal(5,2)
Declare @FetchSchoolAtt3 int
Declare @FetchPercSchoolAtt3 decimal(5,2)
Declare @FetchSchoolAtt4 int
Declare @FetchPercSchoolAtt4 decimal(5,2)
Declare @FetchSchoolAtt5 int
Declare @FetchPercSchoolAtt5 decimal(5,2)
Declare @FetchSchoolAtt6 int
Declare @FetchPercSchoolAtt6 decimal(5,2)
Declare @FetchSchoolAtt7 int
Declare @FetchPercSchoolAtt7 decimal(5,2)
Declare @FetchSchoolAtt8 int
Declare @FetchPercSchoolAtt8 decimal(5,2)
Declare @FetchSchoolAtt9 int
Declare @FetchPercSchoolAtt9 decimal(5,2)
Declare @FetchSchoolAtt10 int
Declare @FetchPercSchoolAtt10 decimal(5,2)
Declare @FetchSchoolAtt11 int
Declare @FetchPercSchoolAtt11 decimal(5,2)
Declare @FetchSchoolAtt12 int
Declare @FetchPercSchoolAtt12 decimal(5,2)
Declare @FetchSchoolAtt13 int
Declare @FetchPercSchoolAtt13 decimal(5,2)
Declare @FetchSchoolAtt14 int
Declare @FetchPercSchoolAtt14 decimal(5,2)
Declare @FetchSchoolAtt15 int
Declare @FetchPercSchoolAtt15 decimal(5,2)
Declare @FetchChurchPresent int
Declare @FetchPercChurchPresent decimal(5,2)
Declare @FetchChurchAbsent int
Declare @FetchPercChurchAbsent decimal(5,2)
Declare @FetchSSchoolPresent int
Declare @FetchPercSSchoolPresent decimal(5,2)
Declare @FetchSSchoolAbsent int
Declare @FetchPercSSchoolAbsent decimal(5,2)

Declare TermCursor Cursor For
Select Distinct 
	TermID, 
	TermTitle, 
	TermReportTitle,
	TermStart, 
	TermEnd,
	ParentTermID,
	ExamTerm,
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
	PercSSchoolAbsent
From #ReportCardData

Union

Select * From #tmpTerms

-- Get a List of all the distinct ClassTypes
Create Table #ClassTypeIDs (ClassTypeID int)
Insert Into #ClassTypeIDs
Select Distinct ClassTypeID
From #ReportCardData

Declare @FetchClassTypeID int
Declare ClassTypeCursor Cursor For
Select * From #ClassTypeIDs



Print '****************************************Mark 1****************************************'

-- Traverse all the Students
Open  StudentCursor
FETCH NEXT FROM StudentCursor INTO @FetchStudentID, @FetchFname, @FetchMname, @FetchLname
WHILE (@@FETCH_STATUS != -1)
BEGIN

--*********If student is missing any ClassTypes then Set AreStudentsMissing variable*************************

Set @NumMissingClassTypes = 0


Select
	@NumMissingClassTypes = count(*)
From #ClassTypeIDs
Where ClassTypeID not in (Select Distinct ClassTypeID From #ReportCardData Where StudentID = @FetchStudentID)

If @NumMissingClassTypes > 0
Begin
  Set @AreStudentsMissingClassTypes = 'yes'
End

--***********************************************************************************************************

	-- Populate #tmpTeachers with the teacher that teaches the most classes for this student
	Insert Into #tmpTeachers
	Select top 1
		StudentID,
		case
			when StaffTitle is null then TFname + ' ' + TLname
			when rtrim(StaffTitle) = '' then TFname + ' ' + TLname
			else StaffTitle + ' ' + TLname
		end as Teacher
	From #ReportCardData
	Where 
	StudentID = @FetchStudentID
	and
	TFname is not null
	and
	ParentClassID = 0	
	Group by TFname, TLname, StudentID, TermEnd, StaffTitle
	Order By TermEnd desc, Count(*) desc

	-- Traverse all the ClassTypes and add any missing terms
	Open  ClassTypeCursor
	FETCH NEXT FROM ClassTypeCursor INTO @FetchClassTypeID
	WHILE (@@FETCH_STATUS != -1)
	BEGIN


		-- Traverse all the TermsCusor to see which terms are missing from this ClassType
		Open  TermCursor
		FETCH NEXT FROM TermCursor INTO 
		@FetchTermID, 
		@FetchTermTitle, 
		@FetchTermReportTitle,
		@FetchTermStart, 
		@FetchTermEnd,
		@FetchParentTermID,
		@FetchExamTerm,
		@FetchSchoolAtt1,
		@FetchPercSchoolAtt1,
		@FetchSchoolAtt2,
		@FetchPercSchoolAtt2,
		@FetchSchoolAtt3,
		@FetchPercSchoolAtt3,
		@FetchSchoolAtt4,
		@FetchPercSchoolAtt4,
		@FetchSchoolAtt5,
		@FetchPercSchoolAtt5,
		@FetchSchoolAtt6,
		@FetchPercSchoolAtt6,
		@FetchSchoolAtt7,
		@FetchPercSchoolAtt7,
		@FetchSchoolAtt8,
		@FetchPercSchoolAtt8,
		@FetchSchoolAtt9,
		@FetchPercSchoolAtt9,
		@FetchSchoolAtt10,
		@FetchPercSchoolAtt10,
		@FetchSchoolAtt11,
		@FetchPercSchoolAtt11,
		@FetchSchoolAtt12,
		@FetchPercSchoolAtt12,
		@FetchSchoolAtt13,
		@FetchPercSchoolAtt13,
		@FetchSchoolAtt14,
		@FetchPercSchoolAtt14,
		@FetchSchoolAtt15,
		@FetchPercSchoolAtt15,
		@FetchChurchPresent,
		@FetchPercChurchPresent,
		@FetchChurchAbsent,
		@FetchPercChurchAbsent,
		@FetchSSchoolPresent,
		@FetchPercSSchoolPresent,
		@FetchSSchoolAbsent,
		@FetchPercSSchoolAbsent

		WHILE (@@FETCH_STATUS != -1)
		BEGIN
		
			If @FetchTermID not in (Select TermID 
									From #ReportCardData
									Where	StudentID = @FetchStudentID
											and
											ClassTypeID = @FetchClassTypeID	
									)
									and
									(@FetchClassTypeID in (Select distinct ClassTypeID From #ReportCardData Where StudentID = @FetchStudentID))

			Begin

-- Select distinct ClassTypeID From #ReportCardData Where StudentID = @FetchStudentID
-- Select @FetchStudentID as StudentID, @FetchClassTypeID as ClassTypeId

			Insert Into #ReportCardData
			(	TermID,
				TermTitle,
				TermReportTitle,
				TermStart,
				TermEnd,
				ParentTermID,
				ExamTerm,
				StudentID,
				Fname,
				Mname,
				Lname,
				ClassTypeID
			)
			Values(	@FetchTermID,
					@FetchTermTitle,
					@FetchTermReportTitle,
					@FetchTermStart,
					@FetchTermEnd,
					@FetchParentTermID,
					@FetchExamTerm,
					@FetchStudentID,
					@FetchFname,
					@FetchMname,
					@FetchLname,
					@FetchClassTypeID
					)

			End

		FETCH NEXT FROM TermCursor INTO
		@FetchTermID, 
		@FetchTermTitle, 
		@FetchTermReportTitle,
		@FetchTermStart, 
		@FetchTermEnd,
		@FetchParentTermID,
		@FetchExamTerm,
		@FetchSchoolAtt1,
		@FetchPercSchoolAtt1,
		@FetchSchoolAtt2,
		@FetchPercSchoolAtt2,
		@FetchSchoolAtt3,
		@FetchPercSchoolAtt3,
		@FetchSchoolAtt4,
		@FetchPercSchoolAtt4,
		@FetchSchoolAtt5,
		@FetchPercSchoolAtt5,
		@FetchSchoolAtt6,
		@FetchPercSchoolAtt6,
		@FetchSchoolAtt7,
		@FetchPercSchoolAtt7,
		@FetchSchoolAtt8,
		@FetchPercSchoolAtt8,
		@FetchSchoolAtt9,
		@FetchPercSchoolAtt9,
		@FetchSchoolAtt10,
		@FetchPercSchoolAtt10,
		@FetchSchoolAtt11,
		@FetchPercSchoolAtt11,
		@FetchSchoolAtt12,
		@FetchPercSchoolAtt12,
		@FetchSchoolAtt13,
		@FetchPercSchoolAtt13,
		@FetchSchoolAtt14,
		@FetchPercSchoolAtt14,
		@FetchSchoolAtt15,
		@FetchPercSchoolAtt15,
		@FetchChurchPresent,
		@FetchPercChurchPresent,
		@FetchChurchAbsent,
		@FetchPercChurchAbsent,
		@FetchSSchoolPresent,
		@FetchPercSSchoolPresent,
		@FetchSSchoolAbsent,
		@FetchPercSSchoolAbsent

		End
		Close TermCursor

	FETCH NEXT FROM ClassTypeCursor INTO @FetchClassTypeID
	End
	Close ClassTypeCursor

FETCH NEXT FROM StudentCursor INTO @FetchStudentID, @FetchFname, @FetchMname, @FetchLname
End
Close StudentCursor

Deallocate ClassTypeCursor

Print '****************************************Mark 2****************************************'

-- Get a List of ClassTypeIDs for ClassTypes 1 and all Custom ClassTypeIDs
-- that were selected into a cursor
Declare @FetchClassTypeID2 int
Declare ClassTypeCursor2 Cursor For
Select * From #ClassTypeIDs

-- Traverse all the Students
Open  StudentCursor
FETCH NEXT FROM StudentCursor INTO @FetchStudentID, @FetchFname, @FetchMname, @FetchLname
WHILE (@@FETCH_STATUS != -1)
BEGIN


	-- Traverse the ClassTypeCursor2 Cursor
	Open  ClassTypeCursor2
	FETCH NEXT FROM ClassTypeCursor2 INTO @FetchClassTypeID2
	WHILE (@@FETCH_STATUS != -1)
	BEGIN
	
		-- Traverse the TermsCusor
		Open  TermCursor
		FETCH NEXT FROM TermCursor INTO 
		@FetchTermID, 
		@FetchTermTitle, 
		@FetchTermReportTitle,
		@FetchTermStart, 
		@FetchTermEnd,
		@FetchParentTermID,
		@FetchExamTerm,
		@FetchSchoolAtt1,
		@FetchPercSchoolAtt1,
		@FetchSchoolAtt2,
		@FetchPercSchoolAtt2,
		@FetchSchoolAtt3,
		@FetchPercSchoolAtt3,
		@FetchSchoolAtt4,
		@FetchPercSchoolAtt4,
		@FetchSchoolAtt5,
		@FetchPercSchoolAtt5,
		@FetchSchoolAtt6,
		@FetchPercSchoolAtt6,
		@FetchSchoolAtt7,
		@FetchPercSchoolAtt7,
		@FetchSchoolAtt8,
		@FetchPercSchoolAtt8,
		@FetchSchoolAtt9,
		@FetchPercSchoolAtt9,
		@FetchSchoolAtt10,
		@FetchPercSchoolAtt10,
		@FetchSchoolAtt11,
		@FetchPercSchoolAtt11,
		@FetchSchoolAtt12,
		@FetchPercSchoolAtt12,
		@FetchSchoolAtt13,
		@FetchPercSchoolAtt13,
		@FetchSchoolAtt14,
		@FetchPercSchoolAtt14,
		@FetchSchoolAtt15,
		@FetchPercSchoolAtt15,
		@FetchChurchPresent,
		@FetchPercChurchPresent,
		@FetchChurchAbsent,
		@FetchPercChurchAbsent,
		@FetchSSchoolPresent,
		@FetchPercSSchoolPresent,
		@FetchSSchoolAbsent,
		@FetchPercSSchoolAbsent
		WHILE (@@FETCH_STATUS != -1)
		BEGIN

			If @FetchClassTypeID2 in (1, 8)
			Begin	-- For Builtin Grades ClassType

				-- Get a List of all distinct ClassTitles from ClassTypeID 1 into TermsCursor
				Declare @FetchClassTitle nvarchar(100)
				Declare @FetchReportOrder int
				Declare @FetchPeriod int
				Declare @FetchCustomGradeScaleID int
				Declare @FetchClassUnits decimal(7,4)
				Declare ClassCusor Cursor For
				Select Distinct ClassTitle, ReportOrder, Period, ClassUnits, CustomGradeScaleID
				From #ReportCardData
				Where 	StudentID = @FetchStudentID
						and
						ClassTypeID = @FetchClassTypeID2
						and
						ClassTitle is not null
						and
						Period is not null

				-- Traverse the ClassFieldCusor
				Open  ClassCusor
				FETCH NEXT FROM ClassCusor INTO @FetchClassTitle, @FetchReportOrder, @FetchPeriod, @FetchClassUnits, @FetchCustomGradeScaleID
				WHILE (@@FETCH_STATUS != -1)
				BEGIN

					If @FetchClassTitle not in (Select ClassTitle 
									From #ReportCardData
									Where	StudentID = @FetchStudentID
											and
											ClassTypeID = @FetchClassTypeID2
											and
											TermID = @FetchTermID
											and
											ClassTitle is not null
									)
					Begin

						Insert Into #ReportCardData
						(	
							TermID,
							TermTitle,
							TermReportTitle,
							TermStart,
							TermEnd,
							ParentTermID,
							ExamTerm,
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
							StudentID,
							Fname,
							Mname,
							Lname,
							ClassTitle,
							ReportOrder,
							Period,
							ClassTypeID,
							CustomGradeScaleID,
							ClassUnits
						)
						Values(	@FetchTermID,
								@FetchTermTitle,
								@FetchTermReportTitle,
								@FetchTermStart,
								@FetchTermEnd,
								@FetchParentTermID,
								@FetchExamTerm,
								@FetchSchoolAtt1,
								@FetchPercSchoolAtt1,
								@FetchSchoolAtt2,
								@FetchPercSchoolAtt2,
								@FetchSchoolAtt3,
								@FetchPercSchoolAtt3,
								@FetchSchoolAtt4,
								@FetchPercSchoolAtt4,
								@FetchSchoolAtt5,
								@FetchPercSchoolAtt5,
								@FetchSchoolAtt6,
								@FetchPercSchoolAtt6,
								@FetchSchoolAtt7,
								@FetchPercSchoolAtt7,
								@FetchSchoolAtt8,
								@FetchPercSchoolAtt8,
								@FetchSchoolAtt9,
								@FetchPercSchoolAtt9,
								@FetchSchoolAtt10,
								@FetchPercSchoolAtt10,
								@FetchSchoolAtt11,
								@FetchPercSchoolAtt11,
								@FetchSchoolAtt12,
								@FetchPercSchoolAtt12,
								@FetchSchoolAtt13,
								@FetchPercSchoolAtt13,
								@FetchSchoolAtt14,
								@FetchPercSchoolAtt14,
								@FetchSchoolAtt15,
								@FetchPercSchoolAtt15,
								@FetchChurchPresent,
								@FetchPercChurchPresent,
								@FetchChurchAbsent,
								@FetchPercChurchAbsent,
								@FetchSSchoolPresent,
								@FetchPercSSchoolPresent,
								@FetchSSchoolAbsent,
								@FetchPercSSchoolAbsent,
								@FetchStudentID,
								@FetchFname,
								@FetchMname,
								@FetchLname,
								@FetchClassTitle,
								@FetchReportOrder,
								@FetchPeriod,
								@FetchClassTypeID2,
								@FetchCustomGradeScaleID,
								@FetchClassUnits
								)
		
					End
		
		
				FETCH NEXT FROM ClassCusor INTO @FetchClassTitle, @FetchReportOrder, @FetchPeriod, @FetchClassUnits, @FetchCustomGradeScaleID
				End
				Close ClassCusor
				Deallocate ClassCusor

			End
			Else
			Begin -- For Custom ClassTypes

				-- Get a List of all distinct ClassTitles from ClassTypeID into TermsCursor
				Declare @FetchClassTitle2 nvarchar(100)
				Declare @FetchCustomFieldName nvarchar(100)
				Declare @FetchCustomFieldOrder int
				Declare FieldCusor Cursor For
				Select Distinct ClassTitle, CustomFieldName, CustomFieldOrder
				From #ReportCardData
				Where 	StudentID = @FetchStudentID
						and
						ClassTypeID = @FetchClassTypeID2
						and
						ClassTitle is not null

				-- Traverse the FieldCusor
				Open  FieldCusor
				FETCH NEXT FROM FieldCusor INTO @FetchClassTitle2, @FetchCustomFieldName, @FetchCustomFieldOrder
				WHILE (@@FETCH_STATUS != -1)
				BEGIN

					If @FetchCustomFieldName not in (Select IsNull(CustomFieldName, '')
													From #ReportCardData
													Where	StudentID = @FetchStudentID
													and
													ClassTypeID = @FetchClassTypeID2
													and
													TermID = @FetchTermID
													)
					Begin

						Insert Into #ReportCardData
						(	TermID,
							TermTitle,
							TermReportTitle,
							TermStart,
							TermEnd,
							ParentTermID,
							ExamTerm,
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
							StudentID,
							Fname,
							Mname,
							Lname,
							ClassTitle,
							ClassTypeID,
							CustomFieldName,
							CustomFieldOrder
						)
						Values(	@FetchTermID,
								@FetchTermTitle,
								@FetchTermReportTitle,
								@FetchTermStart,
								@FetchTermEnd,
								@FetchParentTermID,
								@FetchExamTerm,
								@FetchSchoolAtt1,
								@FetchPercSchoolAtt1,
								@FetchSchoolAtt2,
								@FetchPercSchoolAtt2,
								@FetchSchoolAtt3,
								@FetchPercSchoolAtt3,
								@FetchSchoolAtt4,
								@FetchPercSchoolAtt4,
								@FetchSchoolAtt5,
								@FetchPercSchoolAtt5,
								@FetchSchoolAtt6,
								@FetchPercSchoolAtt6,
								@FetchSchoolAtt7,
								@FetchPercSchoolAtt7,
								@FetchSchoolAtt8,
								@FetchPercSchoolAtt8,
								@FetchSchoolAtt9,
								@FetchPercSchoolAtt9,
								@FetchSchoolAtt10,
								@FetchPercSchoolAtt10,
								@FetchSchoolAtt11,
								@FetchPercSchoolAtt11,
								@FetchSchoolAtt12,
								@FetchPercSchoolAtt12,
								@FetchSchoolAtt13,
								@FetchPercSchoolAtt13,
								@FetchSchoolAtt14,
								@FetchPercSchoolAtt14,
								@FetchSchoolAtt15,
								@FetchPercSchoolAtt15,
								@FetchChurchPresent,
								@FetchPercChurchPresent,
								@FetchChurchAbsent,
								@FetchPercChurchAbsent,
								@FetchSSchoolPresent,
								@FetchPercSSchoolPresent,
								@FetchSSchoolAbsent,
								@FetchPercSSchoolAbsent,
								@FetchStudentID,
								@FetchFname,
								@FetchMname,
								@FetchLname,
								@FetchClassTitle2,
								@FetchClassTypeID2,
								@FetchCustomFieldName,
								@FetchCustomFieldOrder
								)
		
					End
		
		
				FETCH NEXT FROM FieldCusor INTO @FetchClassTitle2, @FetchCustomFieldName, @FetchCustomFieldOrder
				End
				Close FieldCusor
				Deallocate FieldCusor

			End


		FETCH NEXT FROM TermCursor INTO
		@FetchTermID, 
		@FetchTermTitle, 
		@FetchTermReportTitle,
		@FetchTermStart, 
		@FetchTermEnd,
		@FetchParentTermID,
		@FetchExamTerm,
		@FetchSchoolAtt1,
		@FetchPercSchoolAtt1,
		@FetchSchoolAtt2,
		@FetchPercSchoolAtt2,
		@FetchSchoolAtt3,
		@FetchPercSchoolAtt3,
		@FetchSchoolAtt4,
		@FetchPercSchoolAtt4,
		@FetchSchoolAtt5,
		@FetchPercSchoolAtt5,
		@FetchSchoolAtt6,
		@FetchPercSchoolAtt6,
		@FetchSchoolAtt7,
		@FetchPercSchoolAtt7,
		@FetchSchoolAtt8,
		@FetchPercSchoolAtt8,
		@FetchSchoolAtt9,
		@FetchPercSchoolAtt9,
		@FetchSchoolAtt10,
		@FetchPercSchoolAtt10,
		@FetchSchoolAtt11,
		@FetchPercSchoolAtt11,
		@FetchSchoolAtt12,
		@FetchPercSchoolAtt12,
		@FetchSchoolAtt13,
		@FetchPercSchoolAtt13,
		@FetchSchoolAtt14,
		@FetchPercSchoolAtt14,
		@FetchSchoolAtt15,
		@FetchPercSchoolAtt15,
		@FetchChurchPresent,
		@FetchPercChurchPresent,
		@FetchChurchAbsent,
		@FetchPercChurchAbsent,
		@FetchSSchoolPresent,
		@FetchPercSSchoolPresent,
		@FetchSSchoolAbsent,
		@FetchPercSSchoolAbsent
		End
		Close TermCursor

	FETCH NEXT FROM ClassTypeCursor2 INTO @FetchClassTypeID2
	End
	Close ClassTypeCursor2

FETCH NEXT FROM StudentCursor INTO @FetchStudentID, @FetchFname, @FetchMname, @FetchLname
End
Close StudentCursor


Print '****************************************Mark 3****************************************'

-- Select *
-- From #ReportCardData
-- Where StudentID = 1022 and ClassTypeID in (1) and TermID = 57



Deallocate TermCursor
Deallocate StudentCursor
Deallocate ClassTypeCursor2

Declare @SchoolName nvarchar(100)
Declare @SchoolAddress nvarchar(200)
Declare @SchoolPhone nvarchar(30)
Declare @SchoolFax nvarchar(30)
Declare @CategoryName as nvarchar(50)
Declare @CategoryAbbr as nvarchar(3)
Declare @Category1Symbol as nchar(1)
Declare @Category1Desc as nvarchar(20)
Declare @Category2Symbol as nchar(1)
Declare @Category2Desc as nvarchar(20)
Declare @Category3Symbol as nchar(1)
Declare @Category3Desc as nvarchar(20)
Declare @Category4Symbol as nchar(1)
Declare @Category4Desc as nvarchar(20)
Declare @CommentName as nvarchar(50)
Declare @CommentAbbr as  nvarchar(3)
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
Declare @CommentRows as int

Select @CommentRows =
	case
		When Comment1 = '' then 0
		When Comment4 = '' then 1
		When Comment7 = '' then 2
		When Comment10 = '' then 3
		When Comment13 = '' then 4
		When Comment16 = '' then 5
		When Comment19 = '' then 6
		When Comment22 = '' then 7
		When Comment25 = '' then 8
		When Comment28 = '' then 9
		else 10
	end
From Settings where SettingID = 1



Set @SchoolName = (Select SchoolName From Settings Where SettingID = 1)
Set @SchoolAddress = 	(Select SchoolStreet From Settings Where SettingID = 1) + ', ' +
						(Select SchoolCity From Settings Where SettingID = 1) + ', ' +
						(Select SchoolState From Settings Where SettingID = 1) + ' ' +
						(Select SchoolZip From Settings Where SettingID = 1)
Set @SchoolPhone = (Select SchoolPhone From Settings Where SettingID = 1)
Set @SchoolFax = (Select SchoolFax From Settings Where SettingID = 1)


	Declare @Attendance1 nvarchar(50)
	Declare @Attendance2 nvarchar(50)
	Declare @Attendance3 nvarchar(50)
	Declare @Attendance4 nvarchar(50)
	Declare @Attendance5 nvarchar(50)
	Declare @Attendance6 nvarchar(50)
	Declare @Attendance7 nvarchar(50)
	Declare @Attendance8 nvarchar(50)
	Declare @Attendance9 nvarchar(50)
	Declare @Attendance10 nvarchar(50)
	Declare @Attendance11 nvarchar(50)
	Declare @Attendance12 nvarchar(50)
	Declare @Attendance13 nvarchar(50)
	Declare @Attendance14 nvarchar(50)
	Declare @Attendance15 nvarchar(50)
	Declare @CAttendance1 nvarchar(50)
	Declare @CAttendance2 nvarchar(50)
	Declare @CAttendance3 nvarchar(50)
	Declare @CAttendance4 nvarchar(50)
	Declare @CAttendance5 nvarchar(50)	
	Declare @CAttendanceAbbr1 nvarchar(10)
	Declare @CAttendanceAbbr2 nvarchar(10)
	Declare @CAttendanceAbbr3 nvarchar(10)
	Declare @CAttendanceAbbr4 nvarchar(10)
	Declare @CAttendanceAbbr5 nvarchar(10)
	Declare @DailyAttendance nvarchar(10)
	Declare @Att1SOR bit
	Declare @Att2SOR bit
	Declare @Att3SOR bit
	Declare @Att4SOR bit
	Declare @Att5SOR bit
	Declare @Att6SOR bit
	Declare @Att7SOR bit
	Declare @Att8SOR bit
	Declare @Att9SOR bit
	Declare @Att10SOR bit
	Declare @Att11SOR bit
	Declare @Att12SOR bit
	Declare @Att13SOR bit
	Declare @Att14SOR bit
	Declare @Att15SOR bit
	
	Set @Attendance1 = (Select ReportTitle From AttendanceSettings Where ID = 'Att1')
	Set @Attendance2 = (Select ReportTitle From AttendanceSettings Where ID = 'Att2')
	Set @Attendance3 = (Select ReportTitle From AttendanceSettings Where ID = 'Att3')
	Set @Attendance4 = (Select ReportTitle From AttendanceSettings Where ID = 'Att4')
	Set @Attendance5 = (Select ReportTitle From AttendanceSettings Where ID = 'Att5')
	Set @Attendance6 = (Select ReportTitle From AttendanceSettings Where ID = 'Att6')
	Set @Attendance7 = (Select ReportTitle From AttendanceSettings Where ID = 'Att7')
	Set @Attendance8 = (Select ReportTitle From AttendanceSettings Where ID = 'Att8')
	Set @Attendance9 = (Select ReportTitle From AttendanceSettings Where ID = 'Att9')
	Set @Attendance10 = (Select ReportTitle From AttendanceSettings Where ID = 'Att10')
	Set @Attendance11 = (Select ReportTitle From AttendanceSettings Where ID = 'Att11')
	Set @Attendance12 = (Select ReportTitle From AttendanceSettings Where ID = 'Att12')
	Set @Attendance13 = (Select ReportTitle From AttendanceSettings Where ID = 'Att13')
	Set @Attendance14 = (Select ReportTitle From AttendanceSettings Where ID = 'Att14')
	Set @Attendance15 = (Select ReportTitle From AttendanceSettings Where ID = 'Att15')	
	Set @Att1SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att1')	
	Set @Att2SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att2')	
	Set @Att3SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att3')	
	Set @Att4SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att4')	
	Set @Att5SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att5')	
	Set @Att6SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att6')	
	Set @Att7SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att7')	
	Set @Att8SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att8')	
	Set @Att9SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att9')	
	Set @Att10SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att10')	
	Set @Att11SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att11')	
	Set @Att12SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att12')	
	Set @Att13SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att13')	
	Set @Att14SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att14')	
	Set @Att15SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att15')	

	Select 
	@DailyAttendance = DailyAttendance,
	@CAttendance1 = Attendance1,
	@CAttendanceAbbr1 = Attendance1Legend,
	@CAttendance2 = Attendance2,
	@CAttendanceAbbr2 = Attendance2Legend,
	@CAttendance3 = Attendance3,
	@CAttendanceAbbr3 = Attendance3Legend,
	@CAttendance4 = Attendance4,
	@CAttendanceAbbr4 = Attendance4Legend,
	@CAttendance5 = Attendance5,
	@CAttendanceAbbr5 = Attendance5Legend
	From Settings 
	Where SettingID = 1




Delete From #ReportCardData
Where 
	ClassTypeID > 1
	and
	TermID in (Select TermID From #ExamOrParentTerms)
	

-- Get first GradeScaleLegend from records of ClassTypeID 1
Declare @StandardGradeScaleLegend nvarchar(1300)
Declare @StandardGradeScaleLegend2 nvarchar(300)
Declare @StandardGradeScaleLegend3 nvarchar(300)

Set @StandardGradeScaleLegend = (Select top 1 GradeScaleLegend From #ReportCardData Where ClassTypeID = 1 and GradeScaleLegend is not null Order By GradeScaleLegend) + ' ' 
Set @StandardGradeScaleLegend2 = (Select top 1 GradeScaleLegend From #ReportCardData Where ClassTypeID = 1 and GradeScaleLegend is not null and GradeScaleLegend != @StandardGradeScaleLegend) + ' ' 
Set @StandardGradeScaleLegend3 = (Select top 1 GradeScaleLegend From #ReportCardData Where ClassTypeID = 1 and GradeScaleLegend is not null and GradeScaleLegend != @StandardGradeScaleLegend and GradeScaleLegend != @StandardGradeScaleLegend2) + ' ' 

Set @StandardGradeScaleLegend = @StandardGradeScaleLegend + Isnull(@StandardGradeScaleLegend2, '') + Isnull(@StandardGradeScaleLegend3, '') 


-- Remove GradeScaleLegend for records with a classtypeID of 1
Update #ReportCardData
Set GradeScaleLegend = null
Where ClassTypeID = 1



Declare @ClassTitleFontSize nvarchar(30)
Declare @ClassSubgradeCellHeight nvarchar(30)


Declare @GraphicHTML nvarchar(4000)
Declare @ProfileTopMargin nvarchar(10)
Declare @ProfileTeacherName nvarchar(100)
Declare @ShowAttendancePercentages nvarchar(5)
Declare @SchoolAttendanceTitle nvarchar(100)
Declare @WorshipAttendanceChurchTitle nvarchar(100)
Declare @WorshipAttendanceBibleClassTitle nvarchar(100)
Declare @ShowGradeScaleForCustomClasses nvarchar(5)
Declare @ShowPrincipalSignature nvarchar(5)
Declare @ShowTeacherSignature nvarchar(5)
Declare @ShowParentSignature nvarchar(5)
Declare @PrincipalSignatureHTML nvarchar(2000)
Declare @ShowTeacherNameOnTermComments nvarchar(5)

Set @GraphicHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page Graphic HTML')
Set @PrincipalSignatureHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Principal Signature HTML')
Set @ProfileTopMargin = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Top Margin')
Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
Set @ShowAttendancePercentages = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Attendance Percentages')
Set @SchoolAttendanceTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'School Attendance Title')
Set @WorshipAttendanceChurchTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Church Title')
Set @WorshipAttendanceBibleClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Bible Class Title')
Set @ShowGradeScaleForCustomClasses = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Grade Scale for Custom Classes')
Set @ShowPrincipalSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show principal signature')
Set @ShowTeacherSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show teacher signature')
Set @ShowParentSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show parent signature')
Set @ShowTeacherNameOnTermComments = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name on Term Comments')

Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')


-- Remove line feed carriage returns 
Set @GraphicHTML = REPLACE(@GraphicHTML , CHAR(13) , '' )
Set @GraphicHTML = REPLACE(@GraphicHTML , CHAR(10) , '' )
Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(13) , '' )
Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(10) , '' )

-- Replace single quotes with /' for javasript
Set @GraphicHTML = REPLACE(@GraphicHTML , '''' , '\''' )
Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , '''' , '\''' )










----------------------------------------------------------------------------------------
------------------------------ Get Class Yearly Average --------------------------------
----------------------------------------------------------------------------------------

Create table #AvgGrades
(
StudentID int,
ClassTitle nvarchar(100),
AvgGrade decimal(5,1)
)

Create Index AvgGrade_Index on #AvgGrades (StudentID, ClassTitle)

Insert into #AvgGrades
Select
StudentID,
ClassTitle,
convert(decimal(5,1), avg(PercentageGrade)) as AvgGrade
From 
#ReportCardData
Where 
ClassTypeID in (1,2)
and
ParentClassID = 0
and
ParentTermID = 0
Group By StudentID, ClassTitle


----------------------------------------------------------------------------------------
------------------------------     Get Last TermID      --------------------------------
----------------------------------------------------------------------------------------

Declare @LastTermID int

Select top 1 
@LastTermID = TermID
From #ReportCardData
Where ParentTermID = 0
Order By TermEnd desc



---------- Find out how many attendance fields whill be shown so ------------
-----------we know how much to expand worship attendance table to ----------
Declare @AttendanceFieldCount int

Set @AttendanceFieldCount = (Select count(*) From AttendanceSettings Where ShowOnReportCard = 1)

Declare @ShowOnlyChurchAttendance bit
Set @ShowOnlyChurchAttendance = (Select ShowOnlyChurchAttendance From Settings Where SettingID = 1)
		


Print '****************************************Mark 4****************************************'




--Select * From #ReportCardData

Select Distinct
	1 as tag,
	null as parent,
	@ClassTitleFontSize as[Report!1!ClassTitleFontSize],
	@ClassSubgradeCellHeight as[Report!1!ClassSubgradeCellHeight],	
	@ProfileTeacherName as [Report!1!ProfileTeacherName],	
	@ShowGradeScaleForCustomClasses as [Report!1!ShowGradeScaleForCustomClasses],
	@ShowPrincipalSignature as [Report!1!ShowPrincipalSignature],
	@ShowTeacherSignature as [Report!1!ShowTeacherSignature],
	@ShowParentSignature as [Report!1!ShowParentSignature],			
	@ShowAttendancePercentages as [Report!1!ShowAttendancePercentages],
	@SchoolAttendanceTitle as [Report!1!SchoolAttendanceTitle],
	@WorshipAttendanceChurchTitle as [Report!1!WorshipAttendanceChurchTitle],
	@WorshipAttendanceBibleClassTitle as [Report!1!WorshipAttendanceBibleClassTitle],
	@AttendanceFieldCount as [Report!1!AttendanceFieldCount],
	@AvgGrade as [Report!1!AvgGrade],
	@LastTermID as [Report!1!LastTermID],
	@GraphicHTML as [Report!1!GraphicHTML],
	@PrincipalSignatureHTML as [Report!1!PrincipalSignatureHTML],
	@ProfileTopMargin as [Report!1!ProfileTopMargin],
	@StandardGradeScaleLegend as [Report!1!StandardGradeScaleLegend],
	@ShowLegend as [Report!1!ShowLegend],
	@Browser as [Report!1!Browser],
	@ForceSemesterGrade as [Report!1!ForceSemesterGrade],
	@ShowOnlyChurchAttendance as [Report!1!ShowOnlyChurchAttendance],
	@TermCount as [Report!1!TermCount],
	@AreStudentsMissingClassTypes as [Report!1!AreStudentsMissingClassTypes],
	@ClassTypeIDs as [Report!1!ClassTypeIDs],
	@ReportGroupType as [Report!1!ReportGroupType],
	@ReportGroupIdentifier as [Report!1!ReportGroupIdentifier],
	@Terms as [Report!1!Terms],
	@Att1SOR as [Report!1!Att1SOR],
	@Att2SOR as [Report!1!Att2SOR],
	@Att3SOR as [Report!1!Att3SOR],
	@Att4SOR as [Report!1!Att4SOR],
	@Att5SOR as [Report!1!Att5SOR],
	@Att6SOR as [Report!1!Att6SOR],
	@Att7SOR as [Report!1!Att7SOR],
	@Att8SOR as [Report!1!Att8SOR],
	@Att9SOR as [Report!1!Att9SOR],
	@Att10SOR as [Report!1!Att10SOR],
	@Att11SOR as [Report!1!Att11SOR],
	@Att12SOR as [Report!1!Att12SOR],
	@Att13SOR as [Report!1!Att13SOR],
	@Att14SOR as [Report!1!Att14SOR],
	@Att15SOR as [Report!1!Att15SOR],
	@Attendance1 as [Report!1!Attendance1],
	@Attendance2 as [Report!1!Attendance2],
	@Attendance3 as [Report!1!Attendance3],
	@Attendance4 as [Report!1!Attendance4],
	@Attendance5 as [Report!1!Attendance5],
	@Attendance6 as [Report!1!Attendance6],
	@Attendance7 as [Report!1!Attendance7],
	@Attendance8 as [Report!1!Attendance8],
	@Attendance9 as [Report!1!Attendance9],
	@Attendance10 as [Report!1!Attendance10],
	@Attendance11 as [Report!1!Attendance11],
	@Attendance12 as [Report!1!Attendance12],
	@Attendance13 as [Report!1!Attendance13],
	@Attendance14 as [Report!1!Attendance14],
	@Attendance15 as [Report!1!Attendance15],
	@CAttendance1 as [Report!1!CAttendance1],
	@CAttendanceAbbr1 as [Report!1!CAttendanceAbbr1],
	@CAttendanceAbbr2 as [Report!1!CAttendanceAbbr2],
	@CAttendanceAbbr3 as [Report!1!CAttendanceAbbr3],
	@CAttendanceAbbr4 as [Report!1!CAttendanceAbbr4],
	@CAttendanceAbbr5 as [Report!1!CAttendanceAbbr5],
	@CAttendance2 as [Report!1!CAttendance2],
	@CAttendance3 as [Report!1!CAttendance3],
	@CAttendance4 as [Report!1!CAttendance4],
	@CAttendance5 as [Report!1!CAttendance5],
	@DailyAttendance AS [Report!1!DailyAttendance],
	@SubTermCount as [Report!1!SubTermCount],
	@ExamTermsPresent as [Report!1!ExamTermsPresent],
	@ClassID as [Report!1!ClassID],	
	@EK as [Report!1!EK],
	@PB as [Report!1!PB],
	@TeacherName as [Report!1!TeacherName],
	@SchoolInfo as [Report!1!SchoolInfo],
	@ReportTitle as [Report!1!ReportTitle],
	@PromotedLine as [Report!1!PromotedLine],
	@SignatureText as [Report!1!SignatureText],
	@StandardClasses as [Report!1!StandardClasses],
	@ClassCredits as [Report!1!ClassCredits],
	@ClassEffort as [Report!1!ClassEffort],
	@ClassAttendance as [Report!1!ClassAttendance],
	@StandardClassesComments as [Report!1!StandardClassesComments],
	@TermComments as [Report!1!TermComments],
	@GPA as [Report!1!GPA],
	@SchoolAttendance as [Report!1!SchoolAttendance],
	@WorshipAttendance as [Report!1!WorshipAttendance],
	@CommentCustomClassTypeIDs as [Report!1!CommentCustomClassTypeIDs],
	@SchoolName as [Report!1!SchoolName],
	@SchoolAddress as [Report!1!SchoolAddress],
	@SchoolPhone as [Report!1!SchoolPhone],
	@SchoolFax as [Report!1!SchoolFax],
	null as [Student!2!StudentID],
	null as [Student!2!SFname],
	null as [Student!2!SMname],
	null as [Student!2!SLname],
	null as [Student!2!GradeLevel],
	null as [Student!2!Teacher],
	null as [ClassType!3!ClassTypeID],
	null as [ClassType!3!ClassTypeOrder],
	null as [ClassType!3!ReportSectionTitle],
	null as [ClassType!3!GradeScaleLegend],
	null as [ClassType!3!CommentName],
	null as  [ClassType!3!CommentAbbr],
	null as [ClassType!3!CommentRows],
	null as  [ClassType!3!Comment1],
	null as  [ClassType!3!Comment2],
	null as  [ClassType!3!Comment3],
	null as  [ClassType!3!Comment4],
	null as  [ClassType!3!Comment5],
	null as  [ClassType!3!Comment6],
	null as  [ClassType!3!Comment7],
	null as  [ClassType!3!Comment8],
	null as  [ClassType!3!Comment9],
	null as  [ClassType!3!Comment10],
	null as  [ClassType!3!Comment11],
	null as  [ClassType!3!Comment12],
	null as  [ClassType!3!Comment13],
	null as  [ClassType!3!Comment14],
	null as  [ClassType!3!Comment15],
	null as  [ClassType!3!Comment16],
	null as  [ClassType!3!Comment17],
	null as  [ClassType!3!Comment18],
	null as  [ClassType!3!Comment19],
	null as  [ClassType!3!Comment20],
	null as  [ClassType!3!Comment21],
	null as  [ClassType!3!Comment22],
	null as  [ClassType!3!Comment23],
	null as  [ClassType!3!Comment24],
	null as  [ClassType!3!Comment25],
	null as  [ClassType!3!Comment26],
	null as  [ClassType!3!Comment27],
	null as  [ClassType!3!Comment28],
	null as  [ClassType!3!Comment29],
	null as  [ClassType!3!Comment30],
	null as [ClassType!3!CategoryName],
	null as [ClassType!3!CategoryAbbr],
	null as [ClassType!3!Category1Symbol],
	null as [ClassType!3!Category1Desc],
	null as [ClassType!3!Category2Symbol],
	null as [ClassType!3!Category2Desc],
	null as [ClassType!3!Category3Symbol],
	null as [ClassType!3!Category3Desc],
	null as [ClassType!3!Category4Symbol],
	null as [ClassType!3!Category4Desc],
	null as [Term!4!TermID],
	null as [Term!4!TermType],
	null as [Term!4!TermTitle],
	null as [Term!4!TermReportTitle],
	null as [Term!4!TermEnd],
	null as [Term!4!TermGPA],
	null as [Term!4!TermComment],
	null as [Term!4!SAtt1],
	null as [Term!4!SPercAtt1],
	null as [Term!4!SAtt2],
	null as [Term!4!SPercAtt2],
	null as [Term!4!SAtt3],
	null as [Term!4!SPercAtt3],
	null as [Term!4!SAtt4],
	null as [Term!4!SPercAtt4],
	null as [Term!4!SAtt5],
	null as [Term!4!SPercAtt5],
	null as [Term!4!SAtt6],
	null as [Term!4!SPercAtt6],
	null as [Term!4!SAtt7],
	null as [Term!4!SPercAtt7],
	null as [Term!4!SAtt8],
	null as [Term!4!SPercAtt8],
	null as [Term!4!SAtt9],
	null as [Term!4!SPercAtt9],
	null as [Term!4!SAtt10],
	null as [Term!4!SPercAtt10],
	null as [Term!4!SAtt11],
	null as [Term!4!SPercAtt11],
	null as [Term!4!SAtt12],
	null as [Term!4!SPercAtt12],
	null as [Term!4!SAtt13],
	null as [Term!4!SPercAtt13],
	null as [Term!4!SAtt14],
	null as [Term!4!SPercAtt14],
	null as [Term!4!SAtt15],
	null as [Term!4!SPercAtt15],
	null as [Term!4!ChurchPresent],
	null as [Term!4!PercChurchPresent],
	null as [Term!4!ChurchAbsent],
	null as [Term!4!PercChurchAbsent],
	null as [Term!4!SSchoolPresent],
	null as [Term!4!PercSSchoolPresent],
	null as [Term!4!SSchoolAbsent],
	null as [Term!4!PercSSchoolAbsent],
	null as [ClassField!5!ClassTitle],
	null as [ClassField!5!Period],
	null as [ClassField!5!ClassGrade],
	null as [ClassField!5!AvgGrade],
	null as [ClassField!5!ClassEffort],
	null as [ClassField!5!ClassComments],
	null as [ClassField!5!ClassCredits],
	null as [ClassField!5!FieldName],
	null as [ClassField!5!FieldGrade],
	null as [ClassField!5!FieldOrder],
	null as [ClassField!5!Att1],
	null as [ClassField!5!Att2],
	null as [ClassField!5!Att3],
	null as [ClassField!5!Att4],
	null as [ClassField!5!Att5]

Union All

Select Distinct
	2 as tag,
	1 as parent,
	null as[Report!1!ClassTitleFontSize],
	null as[Report!1!ClassSubgradeCellHeight],		
	null as [Report!1!ProfileTeacherName],
	null as [Report!1!ShowGradeScaleForCustomClasses],
	null as [Report!1!ShowPrincipalSignature],
	null as [Report!1!ShowTeacherSignature],
	null as [Report!1!ShowParentSignature],		
	null as [Report!1!ShowAttendancePercentages],
	null as [Report!1!SchoolAttendanceTitle],
	null as [Report!1!WorshipAttendanceChurchTitle],
	null as [Report!1!WorshipAttendanceBibleClassTitle],	
	null as [Report!1!AttendanceFieldCount],
	null as [Report!1!AvgGrade],
	null as [Report!1!LastTermID],
	null as [Report!1!ProfileTopMargin],
	null as [Report!1!GraphicHTML],
	null as [Report!1!PrincipalSignatureHTML],	
	null as [Report!1!StandardGradeScaleLegend],
	null as [Report!1!ShowLegend],
	null as [Report!1!Browser],
	null as [Report!1!ForceSemesterGrade],
	null as [Report!1!ShowOnlyChurchAttendance],
	null as [Report!1!TermCount],
	null as [Report!1!AreStudentsMissingClassTypes],
	null as [Report!1!ClassTypeIDs],
	null as [Report!1!ReportGroupType],
	null as [Report!1!ReportGroupIdentifier],
	null as [Report!1!Terms],
	null as [Report!1!Att1SOR],
	null as [Report!1!Att2SOR],
	null as [Report!1!Att3SOR],
	null as [Report!1!Att4SOR],
	null as [Report!1!Att5SOR],
	null as [Report!1!Att6SOR],
	null as [Report!1!Att7SOR],
	null as [Report!1!Att8SOR],
	null as [Report!1!Att9SOR],
	null as [Report!1!Att10SOR],
	null as [Report!1!Att11SOR],
	null as [Report!1!Att12SOR],
	null as [Report!1!Att13SOR],
	null as [Report!1!Att14SOR],
	null as [Report!1!Att15SOR],
	null as [Report!1!Attendance1],
	null as [Report!1!Attendance2],
	null as [Report!1!Attendance3],
	null as [Report!1!Attendance4],
	null as [Report!1!Attendance5],
	null as [Report!1!Attendance6],
	null as [Report!1!Attendance7],
	null as [Report!1!Attendance8],
	null as [Report!1!Attendance9],
	null as [Report!1!Attendance10],
	null as [Report!1!Attendance11],
	null as [Report!1!Attendance12],
	null as [Report!1!Attendance13],
	null as [Report!1!Attendance14],
	null as [Report!1!Attendance15],
	null as [Report!1!CAttendance1],
	null as [Report!1!CAttendance2],
	null as [Report!1!CAttendance3],
	null as [Report!1!CAttendance4],
	null as [Report!1!CAttendance5],
	null as [Report!1!CAttendanceAbbr1],
	null as [Report!1!CAttendanceAbbr2],
	null as [Report!1!CAttendanceAbbr3],
	null as [Report!1!CAttendanceAbbr4],
	null as [Report!1!CAttendanceAbbr5],
	null AS [Report!1!DailyAttendance],
	null as [Report!1!SubTermCount],
	null as [Report!1!ExamTermsPresent],
	null as [Report!1!ClassID],	
	null as [Report!1!EK],
	null as [Report!1!PB],
	null as [Report!1!TeacherName],
	null as [Report!1!SchoolInfo],
	null as [Report!1!ReportTitle],
	null as [Report!1!PromotedLine],
	null as [Report!1!SignatureText],
	null as [Report!1!StandardClasses],
	null as [Report!1!ClassCredits],
	null as [Report!1!ClassEffort],
	null as [Report!1!ClassAttendance],
	null as [Report!1!StandardClassesComments],
	null as [Report!1!TermComments],
	null as [Report!1!GPA],
	null as [Report!1!SchoolAttendance],
	null as [Report!1!WorshipAttendance],
	null as [Report!1!CommentCustomClassTypeIDs],
	null as [Report!1!SchoolName],
	null as [Report!1!SchoolAddress],
	null as [Report!1!SchoolPhone],
	null as [Report!1!SchoolFax],
	StudentID as [Student!2!StudentID],
	Fname as [Student!2!SFname],
	Mname as [Student!2!SMname],
	Lname as [Student!2!SLname],
	GradeLevel as [Student!2!GradeLevel],
	(	
		Select	top 1 Teacher
		From #tmpTeachers T
		Where T.StudentID = RD.StudentID
	) as [Student!2!Teacher],
	null as [ClassType!3!ClassTypeID],
	null as [ClassType!3!ClassTypeOrder],
	null as [ClassType!3!ReportSectionTitle],
	null as [ClassType!3!GradeScaleLegend],
	null as [ClassType!3!CommentName],
	null as  [ClassType!3!CommentAbbr],
	null as [ClassType!3!CommentRows],
	null as  [ClassType!3!Comment1],
	null as  [ClassType!3!Comment2],
	null as  [ClassType!3!Comment3],
	null as  [ClassType!3!Comment4],
	null as  [ClassType!3!Comment5],
	null as  [ClassType!3!Comment6],
	null as  [ClassType!3!Comment7],
	null as  [ClassType!3!Comment8],
	null as  [ClassType!3!Comment9],
	null as  [ClassType!3!Comment10],
	null as  [ClassType!3!Comment11],
	null as  [ClassType!3!Comment12],
	null as  [ClassType!3!Comment13],
	null as  [ClassType!3!Comment14],
	null as  [ClassType!3!Comment15],
	null as  [ClassType!3!Comment16],
	null as  [ClassType!3!Comment17],
	null as  [ClassType!3!Comment18],
	null as  [ClassType!3!Comment19],
	null as  [ClassType!3!Comment20],
	null as  [ClassType!3!Comment21],
	null as  [ClassType!3!Comment22],
	null as  [ClassType!3!Comment23],
	null as  [ClassType!3!Comment24],
	null as  [ClassType!3!Comment25],
	null as  [ClassType!3!Comment26],
	null as  [ClassType!3!Comment27],
	null as  [ClassType!3!Comment28],
	null as  [ClassType!3!Comment29],
	null as  [ClassType!3!Comment30],
	null as [ClassType!3!CategoryName],
	null as [ClassType!3!CategoryAbbr],
	null as [ClassType!3!Category1Symbol],
	null as [ClassType!3!Category1Desc],
	null as [ClassType!3!Category2Symbol],
	null as [ClassType!3!Category2Desc],
	null as [ClassType!3!Category3Symbol],
	null as [ClassType!3!Category3Desc],
	null as [ClassType!3!Category4Symbol],
	null as [ClassType!3!Category4Desc],
	null as [Term!4!TermID],
	null as [Term!4!TermType],
	null as [Term!4!TermTitle],
	null as [Term!4!TermReportTitle],
	null as [Term!4!TermEnd],
	null as [Term!4!TermGPA],
	null as [Term!4!TermComment],
	null as [Term!4!SAtt1],
	null as [Term!4!SPercAtt1],
	null as [Term!4!SAtt2],
	null as [Term!4!SPercAtt2],
	null as [Term!4!SAtt3],
	null as [Term!4!SPercAtt3],
	null as [Term!4!SAtt4],
	null as [Term!4!SPercAtt4],
	null as [Term!4!SAtt5],
	null as [Term!4!SPercAtt5],
	null as [Term!4!SAtt6],
	null as [Term!4!SPercAtt6],
	null as [Term!4!SAtt7],
	null as [Term!4!SPercAtt7],
	null as [Term!4!SAtt8],
	null as [Term!4!SPercAtt8],
	null as [Term!4!SAtt9],
	null as [Term!4!SPercAtt9],
	null as [Term!4!SAtt10],
	null as [Term!4!SPercAtt10],
	null as [Term!4!SAtt11],
	null as [Term!4!SPercAtt11],
	null as [Term!4!SAtt12],
	null as [Term!4!SPercAtt12],
	null as [Term!4!SAtt13],
	null as [Term!4!SPercAtt13],
	null as [Term!4!SAtt14],
	null as [Term!4!SPercAtt14],
	null as [Term!4!SAtt15],
	null as [Term!4!SPercAtt15],
	null as [Term!4!ChurchPresent],
	null as [Term!4!PercChurchPresent],
	null as [Term!4!ChurchAbsent],
	null as [Term!4!PercChurchAbsent],
	null as [Term!4!SSchoolPresent],
	null as [Term!4!PercSSchoolPresent],
	null as [Term!4!SSchoolAbsent],
	null as [Term!4!PercSSchoolAbsent],
	null as [ClassField!5!ClassTitle],
	null as [ClassField!5!Period],
	null as [ClassField!5!ClassGrade],
	null as [ClassField!5!AvgGrade],
	null as [ClassField!5!ClassEffort],
	null as [ClassField!5!ClassComments],
	null as [ClassField!5!ClassCredits],
	null as [ClassField!5!FieldName],
	null as [ClassField!5!FieldGrade],
	null as [ClassField!5!FieldOrder],
	null as [ClassField!5!Att1],
	null as [ClassField!5!Att2],
	null as [ClassField!5!Att3],
	null as [ClassField!5!Att4],
	null as [ClassField!5!Att5]

From #ReportCardData RD
Where GradeLevel is not null

Union All

Select Distinct
	3 as tag,
	2 as parent,
	null as[Report!1!ClassTitleFontSize],
	null as[Report!1!ClassSubgradeCellHeight],	
	null as [Report!1!ProfileTeacherName],
	null as [Report!1!ShowGradeScaleForCustomClasses],
	null as [Report!1!ShowPrincipalSignature],
	null as [Report!1!ShowTeacherSignature],
	null as [Report!1!ShowParentSignature],	
	null as [Report!1!ShowAttendancePercentages],
	null as [Report!1!SchoolAttendanceTitle],
	null as [Report!1!WorshipAttendanceChurchTitle],
	null as [Report!1!WorshipAttendanceBibleClassTitle],	
	null as [Report!1!AttendanceFieldCount],
	null as [Report!1!AvgGrade],
	null as [Report!1!LastTermID],
	null as [Report!1!ProfileTopMargin],
	null as [Report!1!GraphicHTML],
	null as [Report!1!PrincipalSignatureHTML],	
	null as [Report!1!StandardGradeScaleLegend],
	null as [Report!1!ShowLegend],
	null as [Report!1!Browser],
	null as [Report!1!ForceSemesterGrade],
	null as [Report!1!ShowOnlyChurchAttendance],
	null as [Report!1!TermCount],
	null as [Report!1!AreStudentsMissingClassTypes],
	null as [Report!1!ClassTypeIDs],
	null as [Report!1!ReportGroupType],
	null as [Report!1!ReportGroupIdentifier],
	null as [Report!1!Terms],
	null as [Report!1!Att1SOR],
	null as [Report!1!Att2SOR],
	null as [Report!1!Att3SOR],
	null as [Report!1!Att4SOR],
	null as [Report!1!Att5SOR],
	null as [Report!1!Att6SOR],
	null as [Report!1!Att7SOR],
	null as [Report!1!Att8SOR],
	null as [Report!1!Att9SOR],
	null as [Report!1!Att10SOR],
	null as [Report!1!Att11SOR],
	null as [Report!1!Att12SOR],
	null as [Report!1!Att13SOR],
	null as [Report!1!Att14SOR],
	null as [Report!1!Att15SOR],
	null as [Report!1!Attendance1],
	null as [Report!1!Attendance2],
	null as [Report!1!Attendance3],
	null as [Report!1!Attendance4],
	null as [Report!1!Attendance5],
	null as [Report!1!Attendance6],
	null as [Report!1!Attendance7],
	null as [Report!1!Attendance8],
	null as [Report!1!Attendance9],
	null as [Report!1!Attendance10],
	null as [Report!1!Attendance11],
	null as [Report!1!Attendance12],
	null as [Report!1!Attendance13],
	null as [Report!1!Attendance14],
	null as [Report!1!Attendance15],
	null as [Report!1!CAttendance1],
	null as [Report!1!CAttendance2],
	null as [Report!1!CAttendance3],
	null as [Report!1!CAttendance4],
	null as [Report!1!CAttendance5],
	null as [Report!1!CAttendanceAbbr1],
	null as [Report!1!CAttendanceAbbr2],
	null as [Report!1!CAttendanceAbbr3],
	null as [Report!1!CAttendanceAbbr4],
	null as [Report!1!CAttendanceAbbr5],
	null AS [Report!1!DailyAttendance],
	null as [Report!1!SubTermCount],
	null as [Report!1!ExamTermsPresent],
	null as [Report!1!ClassID],	
	null as [Report!1!EK],
	null as [Report!1!PB],
	null as [Report!1!TeacherName],
	null as [Report!1!SchoolInfo],
	null as [Report!1!ReportTitle],
	null as [Report!1!PromotedLine],
	null as [Report!1!SignatureText],
	null as [Report!1!StandardClasses],
	null as [Report!1!ClassCredits],
	null as [Report!1!ClassEffort],
	null as [Report!1!ClassAttendance],
	null as [Report!1!StandardClassesComments],
	null as [Report!1!TermComments],
	null as [Report!1!GPA],
	null as [Report!1!SchoolAttendance],
	null as [Report!1!WorshipAttendance],
	null as [Report!1!CommentCustomClassTypeIDs],
	null as [Report!1!SchoolName],
	null as [Report!1!SchoolAddress],
	null as [Report!1!SchoolPhone],
	null as [Report!1!SchoolFax],
	StudentID as [Student!2!StudentID],
	Fname as [Student!2!SFname],
	Mname as [Student!2!SMname],
	Lname as [Student!2!SLname],
	null as [Student!2!GradeLevel],
	null as [Student!2!Teacher],
	ClassTypeID as [ClassType!3!ClassTypeID],
	(
	Select ClassTypeOrder 
	From #ReportOrderTable
	Where ClassTypeID = RD.ClassTypeID
	)as [ClassType!3!ClassTypeOrder],
	ReportSectionTitle as [ClassType!3!ReportSectionTitle],
	GradeScaleLegend as [ClassType!3!GradeScaleLegend],
	(Select Top 1 CommentName From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as [ClassType!3!CommentName],
	(Select Top 1 CommentAbbr From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!CommentAbbr],
	case
		when (Select Top 1 Comment4 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 1
		when (Select Top 1 Comment7 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 2
		when (Select Top 1 Comment10 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 3
		when (Select Top 1 Comment13 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 4
		when (Select Top 1 Comment16 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 5
		when (Select Top 1 Comment19 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 6
		when (Select Top 1 Comment22 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 7
		when (Select Top 1 Comment25 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 8
		when (Select Top 1 Comment28 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 9
		else 10
	end as [ClassType!3!CommentRows],
	(Select Top 1 Comment1 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment1],
	(Select Top 1 Comment2 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment2],
	(Select Top 1 Comment3 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment3],
	(Select Top 1 Comment4 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment4],
	(Select Top 1 Comment5 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment5],
	(Select Top 1 Comment6 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment6],
	(Select Top 1 Comment7 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment7],
	(Select Top 1 Comment8 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment8],
	(Select Top 1 Comment9 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment9],
	(Select Top 1 Comment10 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment10],
	(Select Top 1 Comment11 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment11],
	(Select Top 1 Comment12 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment12],
	(Select Top 1 Comment13 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment13],
	(Select Top 1 Comment14 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment14],
	(Select Top 1 Comment15 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment15],
	(Select Top 1 Comment16 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment16],
	(Select Top 1 Comment17 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment17],
	(Select Top 1 Comment18 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment18],
	(Select Top 1 Comment19 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment19],
	(Select Top 1 Comment20 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment20],
	(Select Top 1 Comment21 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment21],
	(Select Top 1 Comment22 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment22],
	(Select Top 1 Comment23 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment23],
	(Select Top 1 Comment24 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment24],
	(Select Top 1 Comment25 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment25],
	(Select Top 1 Comment26 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment26],
	(Select Top 1 Comment27 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment27],
	(Select Top 1 Comment28 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment28],
	(Select Top 1 Comment29 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment29],
	(Select Top 1 Comment30 From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment30],
	(Select Top 1 CategoryName From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as [ClassType!3!CategoryName],
	(Select Top 1 CategoryAbbr From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as [ClassType!3!CategoryAbbr],
	(Select Top 1 Category1Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category1Symbol],
	(Select Top 1 Category1Desc From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category1Desc],
	(Select Top 1 Category2Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category2Symbol],
	(Select Top 1 Category2Desc From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category2Desc],
	(Select Top 1 Category3Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category3Symbol],
	(Select Top 1 Category3Desc From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category3Desc],
	(Select Top 1 Category4Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category4Symbol],
	(Select Top 1 Category4Desc From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)as [ClassType!3!Category4Desc],
	null as [Term!4!TermID],
	null as [Term!4!TermType],
	null as [Term!4!TermTitle],
	null as [Term!4!TermReportTitle],
	null as [Term!4!TermEnd],
	null as [Term!4!TermGPA],
	null as [Term!4!TermComment],
	null as [Term!4!SAtt1],
	null as [Term!4!SPercAtt1],
	null as [Term!4!SAtt2],
	null as [Term!4!SPercAtt2],
	null as [Term!4!SAtt3],
	null as [Term!4!SPercAtt3],
	null as [Term!4!SAtt4],
	null as [Term!4!SPercAtt4],
	null as [Term!4!SAtt5],
	null as [Term!4!SPercAtt5],
	null as [Term!4!SAtt6],
	null as [Term!4!SPercAtt6],
	null as [Term!4!SAtt7],
	null as [Term!4!SPercAtt7],
	null as [Term!4!SAtt8],
	null as [Term!4!SPercAtt8],
	null as [Term!4!SAtt9],
	null as [Term!4!SPercAtt9],
	null as [Term!4!SAtt10],
	null as [Term!4!SPercAtt10],
	null as [Term!4!SAtt11],
	null as [Term!4!SPercAtt11],
	null as [Term!4!SAtt12],
	null as [Term!4!SPercAtt12],
	null as [Term!4!SAtt13],
	null as [Term!4!SPercAtt13],
	null as [Term!4!SAtt14],
	null as [Term!4!SPercAtt14],
	null as [Term!4!SAtt15],
	null as [Term!4!SPercAtt15],
	null as [Term!4!ChurchPresent],
	null as [Term!4!PercChurchPresent],
	null as [Term!4!ChurchAbsent],
	null as [Term!4!PercChurchAbsent],
	null as [Term!4!SSchoolPresent],
	null as [Term!4!PercSSchoolPresent],
	null as [Term!4!SSchoolAbsent],
	null as [Term!4!PercSSchoolAbsent],
	null as [ClassField!5!ClassTitle],
	null as [ClassField!5!Period],
	null as [ClassField!5!ClassGrade],
	null as [ClassField!5!AvgGrade],
	null as [ClassField!5!ClassEffort],
	null as [ClassField!5!ClassComments],
	null as [ClassField!5!ClassCredits],
	null as [ClassField!5!FieldName],
	null as [ClassField!5!FieldGrade],
	null as [ClassField!5!FieldOrder],
	null as [ClassField!5!Att1],
	null as [ClassField!5!Att2],
	null as [ClassField!5!Att3],
	null as [ClassField!5!Att4],
	null as [ClassField!5!Att5]

From #ReportCardData RD
Where 
TranscriptID is not Null

Union All

Select Distinct
	4 as tag,
	3 as parent,
	null as[Report!1!ClassTitleFontSize],
	null as[Report!1!ClassSubgradeCellHeight],	
	null as [Report!1!ProfileTeacherName],
	null as [Report!1!ShowGradeScaleForCustomClasses],
	null as [Report!1!ShowPrincipalSignature],
	null as [Report!1!ShowTeacherSignature],
	null as [Report!1!ShowParentSignature],	
	null as [Report!1!ShowAttendancePercentages],
	null as [Report!1!SchoolAttendanceTitle],
	null as [Report!1!WorshipAttendanceChurchTitle],
	null as [Report!1!WorshipAttendanceBibleClassTitle],	
	null as [Report!1!AttendanceFieldCount],
	null as [Report!1!AvgGrade],
	null as [Report!1!LastTermID],
	null as [Report!1!ProfileTopMargin],
	null as [Report!1!GraphicHTML],
	null as [Report!1!PrincipalSignatureHTML],	
	null as [Report!1!StandardGradeScaleLegend],
	null as [Report!1!ShowLegend],
	null as [Report!1!Browser],
	null as [Report!1!ForceSemesterGrade],
	null as [Report!1!ShowOnlyChurchAttendance],
	null as [Report!1!TermCount],
	null as [Report!1!AreStudentsMissingClassTypes],
	null as [Report!1!ClassTypeIDs],
	null as [Report!1!ReportGroupType],
	null as [Report!1!ReportGroupIdentifier],
	null as [Report!1!Terms],
	null as [Report!1!Att1SOR],
	null as [Report!1!Att2SOR],
	null as [Report!1!Att3SOR],
	null as [Report!1!Att4SOR],
	null as [Report!1!Att5SOR],
	null as [Report!1!Att6SOR],
	null as [Report!1!Att7SOR],
	null as [Report!1!Att8SOR],
	null as [Report!1!Att9SOR],
	null as [Report!1!Att10SOR],
	null as [Report!1!Att11SOR],
	null as [Report!1!Att12SOR],
	null as [Report!1!Att13SOR],
	null as [Report!1!Att14SOR],
	null as [Report!1!Att15SOR],
	null as [Report!1!Attendance1],
	null as [Report!1!Attendance2],
	null as [Report!1!Attendance3],
	null as [Report!1!Attendance4],
	null as [Report!1!Attendance5],
	null as [Report!1!Attendance6],
	null as [Report!1!Attendance7],
	null as [Report!1!Attendance8],
	null as [Report!1!Attendance9],
	null as [Report!1!Attendance10],
	null as [Report!1!Attendance11],
	null as [Report!1!Attendance12],
	null as [Report!1!Attendance13],
	null as [Report!1!Attendance14],
	null as [Report!1!Attendance15],
	null as [Report!1!CAttendance1],
	null as [Report!1!CAttendance2],
	null as [Report!1!CAttendance3],
	null as [Report!1!CAttendance4],
	null as [Report!1!CAttendance5],
	null as [Report!1!CAttendanceAbbr1],
	null as [Report!1!CAttendanceAbbr2],
	null as [Report!1!CAttendanceAbbr3],
	null as [Report!1!CAttendanceAbbr4],
	null as [Report!1!CAttendanceAbbr5],
	null AS [Report!1!DailyAttendance],
	null as [Report!1!SubTermCount],
	null as [Report!1!ExamTermsPresent],
	null as [Report!1!ClassID],	
	null as [Report!1!EK],
	null as [Report!1!PB],
	null as [Report!1!TeacherName],
	null as [Report!1!SchoolInfo],
	null as [Report!1!ReportTitle],
	null as [Report!1!PromotedLine],
	null as [Report!1!SignatureText],
	null as [Report!1!StandardClasses], 
	null as [Report!1!ClassCredits],
	null as [Report!1!ClassEffort],
	null as [Report!1!ClassAttendance],
	null as [Report!1!StandardClassesComments],
	null as [Report!1!TermComments],
	null as [Report!1!GPA],
	null as [Report!1!SchoolAttendance],
	null as [Report!1!WorshipAttendance],
	null as [Report!1!CommentCustomClassTypeIDs],
	null as [Report!1!SchoolName],
	null as [Report!1!SchoolAddress],
	null as [Report!1!SchoolPhone],
	null as [Report!1!SchoolFax],
	StudentID as [Student!2!StudentID],
	Fname as [Student!2!SFname],
	Mname as [Student!2!SMname],
	Lname as [Student!2!SLname],
	null as [Student!2!GradeLevel],
	null as [Student!2!Teacher],
	ClassTypeID as [ClassType!3!ClassTypeID],
	(
	Select ClassTypeOrder 
	From #ReportOrderTable
	Where ClassTypeID = RD.ClassTypeID
	)as [ClassType!3!ClassTypeOrder],
	null as [ClassType!3!ReportSectionTitle],
	null as [ClassType!3!GradeScaleLegend],
	null as [ClassType!3!CommentName],
	null as  [ClassType!3!CommentAbbr],
	null as [ClassType!3!CommentRows],
	null as  [ClassType!3!Comment1],
	null as  [ClassType!3!Comment2],
	null as  [ClassType!3!Comment3],
	null as  [ClassType!3!Comment4],
	null as  [ClassType!3!Comment5],
	null as  [ClassType!3!Comment6],
	null as  [ClassType!3!Comment7],
	null as  [ClassType!3!Comment8],
	null as  [ClassType!3!Comment9],
	null as  [ClassType!3!Comment10],
	null as  [ClassType!3!Comment11],
	null as  [ClassType!3!Comment12],
	null as  [ClassType!3!Comment13],
	null as  [ClassType!3!Comment14],
	null as  [ClassType!3!Comment15],
	null as  [ClassType!3!Comment16],
	null as  [ClassType!3!Comment17],
	null as  [ClassType!3!Comment18],
	null as  [ClassType!3!Comment19],
	null as  [ClassType!3!Comment20],
	null as  [ClassType!3!Comment21],
	null as  [ClassType!3!Comment22],
	null as  [ClassType!3!Comment23],
	null as  [ClassType!3!Comment24],
	null as  [ClassType!3!Comment25],
	null as  [ClassType!3!Comment26],
	null as  [ClassType!3!Comment27],
	null as  [ClassType!3!Comment28],
	null as  [ClassType!3!Comment29],
	null as  [ClassType!3!Comment30],
	null as [ClassType!3!CategoryName],
	null as [ClassType!3!CategoryAbbr],
	null as [ClassType!3!Category1Symbol],
	null as [ClassType!3!Category1Desc],
	null as [ClassType!3!Category2Symbol],
	null as [ClassType!3!Category2Desc],
	null as [ClassType!3!Category3Symbol],
	null as [ClassType!3!Category3Desc],
	null as [ClassType!3!Category4Symbol],
	null as [ClassType!3!Category4Desc],
	TermID as [Term!4!TermID],
	case
	  when  @SubTermCount = 0 then 'xRegularTerm'	
	  when	RD.ExamTerm = 1 then 'xExamTerm'
	  when  RD.ParentTermID > 0 then 'SubTerm'
	  when	(
			Select count(*)
			From #ReportCardData
			Where 
				ParentTermID = RD.TermID
			) > 0 then 'xParentTerm'
	  else	'xRegularTerm'
	end as [Term!4!TermType],
	TermTitle as [Term!4!TermTitle],
	TermReportTitle as [Term!4!TermReportTitle],
	TermEnd as [Term!4!TermEnd],
	case
		when 	(	
			Select sum(ClassUnits) 
			From #ReportCardData RD2
			Where 	
				RD2.TermID = RD.TermID 
				and 
				RD2.StudentID = RD.StudentID 
				and
				RD2.GradeLevel is not null
				and
				RD2.CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1) 
				and 
				RD2.ClassTypeID = 1
				and
				RD2.AlternativeGrade is null
				and
				RD2.LetterGrade is not null
				and
				(case
					when TermID not in (Select TermID From #SemTerms) then 1
					when TermID in (Select TermID From #SemTerms)
						 and 
						 ((Select TranscriptID From #ClassesWithLastSubTermGrades Where StudentID = RD2.StudentID and ClassTitle = RD2.ClassTitle and ParentTermID = RD2.TermID) is not null) then 1
					else 0
				end) = 1
				and
				RD2.TranscriptID not in (Select * From #tmpCreditNoCredit)
			) = 0 Then 0
		else 	(
			Select Sum(convert(dec(7,4), RD2.UnitGPA)) / Sum(convert(dec(7,4), RD2.ClassUnits))
			From #ReportCardData RD2
			Where 	
				RD2.TermID = RD.TermID 
				and 
				RD2.StudentID = RD.StudentID 
				and
				RD2.GradeLevel is not null
				and
				RD2.CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1) 
				and 
				RD2.ClassTypeID = 1
				and
				RD2.AlternativeGrade is null
				and
				RD2.LetterGrade is not null
				and
				(case
					when TermID not in (Select TermID From #SemTerms) then 1
					when TermID in (Select TermID From #SemTerms)
						 and 
						 ((Select TranscriptID From #ClassesWithLastSubTermGrades Where StudentID = RD2.StudentID and ClassTitle = RD2.ClassTitle and ParentTermID = RD2.TermID) is not null) then 1
					else 0
				end) = 1
				and
				RD2.TranscriptID not in (Select * From #tmpCreditNoCredit)
			)
	end [Term!4!TermGPA],
	case 
		when ClassTypeID = 3 and @ShowTeacherNameOnTermComments = 'yes' then
			(
				Select top 1
				REPLACE(REPLACE(REPLACE(dbo.ConcatComments(RD.TermID, RD.StudentID) , '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )  -- Remove line feed carriage returns 
				From #ReportCardData 
				Where 	TermID = RD.TermID 
						and 
						StudentID = RD.StudentID 
						and
						ClassTypeID = 3
						and
						TermComment is not null
			)	
		when ClassTypeID = 3 then
			(
				Select top 1
				REPLACE(REPLACE(REPLACE(dbo.ConcatComments(RD.TermID, RD.StudentID) , '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )  -- Remove line feed carriage returns 
				From #ReportCardData 
				Where 	TermID = RD.TermID 
						and 
						StudentID = RD.StudentID 
						and
						ClassTypeID = 3
						and
						TermComment is not null
			) 
		else ''
	end	as [Term!4!TermComment],
	SchoolAtt1 as [Term!4!SAtt1],
	PercSchoolAtt1 as [Term!4!SPercAtt1],
	SchoolAtt2 as [Term!4!SAtt2],
	PercSchoolAtt2 as [Term!4!SPercAtt2],
	SchoolAtt3 as [Term!4!SAtt3],
	PercSchoolAtt3 as [Term!4!SPercAtt3],
	SchoolAtt4 as [Term!4!SAtt4],
	PercSchoolAtt4 as [Term!4!SPercAtt4],
	SchoolAtt5 as [Term!4!SAtt5],
	PercSchoolAtt5 as [Term!4!SPercAtt5],
	SchoolAtt6 as [Term!4!SAtt6],
	PercSchoolAtt6 as [Term!4!SPercAtt6],
	SchoolAtt7 as [Term!4!SAtt7],
	PercSchoolAtt7 as [Term!4!SPercAtt7],
	SchoolAtt8 as [Term!4!SAtt8],
	PercSchoolAtt8 as [Term!4!SPercAtt8],
	SchoolAtt9 as [Term!4!SAtt9],
	PercSchoolAtt9 as [Term!4!SPercAtt9],
	SchoolAtt10 as [Term!4!SAtt10],
	PercSchoolAtt10 as [Term!4!SPercAtt10],
	SchoolAtt11 as [Term!4!SAtt11],
	PercSchoolAtt11 as [Term!4!SPercAtt11],
	SchoolAtt12 as [Term!4!SAtt12],
	PercSchoolAtt12 as [Term!4!SPercAtt12],
	SchoolAtt13 as [Term!4!SAtt13],
	PercSchoolAtt13 as [Term!4!SPercAtt13],
	SchoolAtt14 as [Term!4!SAtt14],
	PercSchoolAtt14 as [Term!4!SPercAtt14],
	SchoolAtt15 as [Term!4!SAtt15],
	PercSchoolAtt15 as [Term!4!SPercAtt15],
	ChurchPresent as [Term!4!ChurchPresent],
	PercChurchPresent as [Term!4!PercChurchPresent],
	ChurchAbsent as [Term!4!ChurchAbsent],
	PercChurchAbsent as [Term!4!PercChurchAbsent],
	SSchoolPresent as [Term!4!SSchoolPresent],
	PercSSchoolPresent as [Term!4!PercSSchoolPresent],
	SSchoolAbsent as [Term!4!SSchoolAbsent],
	PercSSchoolAbsent as [Term!4!PercSSchoolAbsent],
	null as [ClassField!5!ClassTitle],
	null as [ClassField!5!Period],
	null as [ClassField!5!ClassGrade],
	null as [ClassField!5!AvgGrade],
	null as [ClassField!5!ClassEffort],
	null as [ClassField!5!ClassComments],
	null as [ClassField!5!ClassCredits],
	null as [ClassField!5!FieldName],
	null as [ClassField!5!FieldGrade],
	null as [ClassField!5!FieldOrder],
	null as [ClassField!5!Att1],
	null as [ClassField!5!Att2],
	null as [ClassField!5!Att3],
	null as [ClassField!5!Att4],
	null as [ClassField!5!Att5]

From #ReportCardData RD
Group By
StudentID,
Fname,
Mname,
Lname,
ClassTypeID,
TermID,
ClassTitle,
ParentTermID,
ExamTerm,
TermTitle,
TermReportTitle,
TermEnd,
TermComment,
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
PercSSchoolAbsent

Union All

Select Distinct
	5 as tag,
	4 as parent,
	null as[Report!1!ClassTitleFontSize],
	null as[Report!1!ClassSubgradeCellHeight],	
	null as [Report!1!ProfileTeacherName],
	null as [Report!1!ShowGradeScaleForCustomClasses],
	null as [Report!1!ShowPrincipalSignature],
	null as [Report!1!ShowTeacherSignature],
	null as [Report!1!ShowParentSignature],		
	null as [Report!1!ShowAttendancePercentages],
	null as [Report!1!SchoolAttendanceTitle],
	null as [Report!1!WorshipAttendanceChurchTitle],
	null as [Report!1!WorshipAttendanceBibleClassTitle],	
	null as [Report!1!AttendanceFieldCount],
	null as [Report!1!AvgGrade],
	null as [Report!1!LastTermID],
	null as [Report!1!ProfileTopMargin],
	null as [Report!1!GraphicHTML],
	null as [Report!1!PrincipalSignatureHTML],	
	null as [Report!1!StandardGradeScaleLegend],
	null as [Report!1!ShowLegend],
	null as [Report!1!Browser],
	null as [Report!1!ForceSemesterGrade],
	null as [Report!1!ShowOnlyChurchAttendance],
	null as [Report!1!TermCount],
	null as [Report!1!AreStudentsMissingClassTypes],
	null as [Report!1!ClassTypeIDs],
	null as [Report!1!ReportGroupType],
	null as [Report!1!ReportGroupIdentifier],
	null as [Report!1!Terms],
	null as [Report!1!Att1SOR],
	null as [Report!1!Att2SOR],
	null as [Report!1!Att3SOR],
	null as [Report!1!Att4SOR],
	null as [Report!1!Att5SOR],
	null as [Report!1!Att6SOR],
	null as [Report!1!Att7SOR],
	null as [Report!1!Att8SOR],
	null as [Report!1!Att9SOR],
	null as [Report!1!Att10SOR],
	null as [Report!1!Att11SOR],
	null as [Report!1!Att12SOR],
	null as [Report!1!Att13SOR],
	null as [Report!1!Att14SOR],
	null as [Report!1!Att15SOR],
	null as [Report!1!Attendance1],
	null as [Report!1!Attendance2],
	null as [Report!1!Attendance3],
	null as [Report!1!Attendance4],
	null as [Report!1!Attendance5],
	null as [Report!1!Attendance6],
	null as [Report!1!Attendance7],
	null as [Report!1!Attendance8],
	null as [Report!1!Attendance9],
	null as [Report!1!Attendance10],
	null as [Report!1!Attendance11],
	null as [Report!1!Attendance12],
	null as [Report!1!Attendance13],
	null as [Report!1!Attendance14],
	null as [Report!1!Attendance15],
	null as [Report!1!CAttendance1],
	null as [Report!1!CAttendance2],
	null as [Report!1!CAttendance3],
	null as [Report!1!CAttendance4],
	null as [Report!1!CAttendance5],
	null as [Report!1!CAttendanceAbbr1],
	null as [Report!1!CAttendanceAbbr2],
	null as [Report!1!CAttendanceAbbr3],
	null as [Report!1!CAttendanceAbbr4],
	null as [Report!1!CAttendanceAbbr5],
	null AS [Report!1!DailyAttendance],
	null as [Report!1!SubTermCount],
	null as [Report!1!ExamTermsPresent],
	null as [Report!1!ClassID],	
	null as [Report!1!EK],
	null as [Report!1!PB],
	null as [Report!1!TeacherName],
	null as [Report!1!SchoolInfo],
	null as [Report!1!ReportTitle],
	null as [Report!1!PromotedLine],
	null as [Report!1!SignatureText],
	null as [Report!1!StandardClasses],
	null as [Report!1!ClassCredits],
	null as [Report!1!ClassEffort],
	null as [Report!1!ClassAttendance],
	null as [Report!1!StandardClassesComments],
	null as [Report!1!TermComments],
	null as [Report!1!GPA],
	null as [Report!1!SchoolAttendance],
	null as [Report!1!WorshipAttendance],
	null as [Report!1!CommentCustomClassTypeIDs],
	null as [Report!1!SchoolName],
	null as [Report!1!SchoolAddress],
	null as [Report!1!SchoolPhone],
	null as [Report!1!SchoolFax],
	StudentID as [Student!2!StudentID],
	Fname as [Student!2!SFname],
	Mname as [Student!2!SMname],
	Lname as [Student!2!SLname],
	null as [Student!2!GradeLevel],
	null as [Student!2!Teacher],
	ClassTypeID as [ClassType!3!ClassTypeID],
	(
	Select ClassTypeOrder 
	From #ReportOrderTable
	Where ClassTypeID = RD.ClassTypeID
	)as [ClassType!3!ClassTypeOrder],
	null as [ClassType!3!ReportSectionTitle],
	null as [ClassType!3!GradeScaleLegend],
	null as [ClassType!3!CommentName],
	null as  [ClassType!3!CommentAbbr],
	null as [ClassType!3!CommentRows],
	null as  [ClassType!3!Comment1],
	null as  [ClassType!3!Comment2],
	null as  [ClassType!3!Comment3],
	null as  [ClassType!3!Comment4],
	null as  [ClassType!3!Comment5],
	null as  [ClassType!3!Comment6],
	null as  [ClassType!3!Comment7],
	null as  [ClassType!3!Comment8],
	null as  [ClassType!3!Comment9],
	null as  [ClassType!3!Comment10],
	null as  [ClassType!3!Comment11],
	null as  [ClassType!3!Comment12],
	null as  [ClassType!3!Comment13],
	null as  [ClassType!3!Comment14],
	null as  [ClassType!3!Comment15],
	null as  [ClassType!3!Comment16],
	null as  [ClassType!3!Comment17],
	null as  [ClassType!3!Comment18],
	null as  [ClassType!3!Comment19],
	null as  [ClassType!3!Comment20],
	null as  [ClassType!3!Comment21],
	null as  [ClassType!3!Comment22],
	null as  [ClassType!3!Comment23],
	null as  [ClassType!3!Comment24],
	null as  [ClassType!3!Comment25],
	null as  [ClassType!3!Comment26],
	null as  [ClassType!3!Comment27],
	null as  [ClassType!3!Comment28],
	null as  [ClassType!3!Comment29],
	null as  [ClassType!3!Comment30],
	null as [ClassType!3!CategoryName],
	null as [ClassType!3!CategoryAbbr],
	null as [ClassType!3!Category1Symbol],
	null as [ClassType!3!Category1Desc],
	null as [ClassType!3!Category2Symbol],
	null as [ClassType!3!Category2Desc],
	null as [ClassType!3!Category3Symbol],
	null as [ClassType!3!Category3Desc],
	null as [ClassType!3!Category4Symbol],
	null as [ClassType!3!Category4Desc],
	TermID as [Term!4!TermID],
	case
	  when  @SubTermCount = 0 then 'xRegularTerm'	
	  when	RD.ExamTerm = 1 then 'xExamTerm'
	  when  RD.ParentTermID > 0 then 'SubTerm'
	  when	(
			Select count(*)
			From #ReportCardData
			Where 
				ParentTermID = RD.TermID
			) > 0 then 'xParentTerm'
	  else	'xRegularTerm'
	end as [Term!4!TermType],
	null as [Term!4!TermTitle],
	null as [Term!4!TermReportTitle],
	TermEnd as [Term!4!TermEnd],
	null as [Term!4!TermGPA],
	null as [Term!4!TermComment],
	null as [Term!4!SAtt1],
	null as [Term!4!SPercAtt1],
	null as [Term!4!SAtt2],
	null as [Term!4!SPercAtt2],
	null as [Term!4!SAtt3],
	null as [Term!4!SPercAtt3],
	null as [Term!4!SAtt4],
	null as [Term!4!SPercAtt4],
	null as [Term!4!SAtt5],
	null as [Term!4!SPercAtt5],
	null as [Term!4!SAtt6],
	null as [Term!4!SPercAtt6],
	null as [Term!4!SAtt7],
	null as [Term!4!SPercAtt7],
	null as [Term!4!SAtt8],
	null as [Term!4!SPercAtt8],
	null as [Term!4!SAtt9],
	null as [Term!4!SPercAtt9],
	null as [Term!4!SAtt10],
	null as [Term!4!SPercAtt10],
	null as [Term!4!SAtt11],
	null as [Term!4!SPercAtt11],
	null as [Term!4!SAtt12],
	null as [Term!4!SPercAtt12],
	null as [Term!4!SAtt13],
	null as [Term!4!SPercAtt13],
	null as [Term!4!SAtt14],
	null as [Term!4!SPercAtt14],
	null as [Term!4!SAtt15],
	null as [Term!4!SPercAtt15],
	null as [Term!4!ChurchPresent],
	null as [Term!4!PercChurchPresent],
	null as [Term!4!ChurchAbsent],
	null as [Term!4!PercChurchAbsent],
	null as [Term!4!SSchoolPresent],
	null as [Term!4!PercSSchoolPresent],
	null as [Term!4!SSchoolAbsent],
	null as [Term!4!PercSSchoolAbsent],
	ClassTitle as [ClassField!5!ClassTitle],
	Period as [ClassField!5!Period],
	case
		when TermID in (Select TermID From #SemTerms) then
			case 
				when ((Select TranscriptID From #ClassesWithLastSubTermGrades Where StudentID = RD.StudentID and ClassTitle = RD.ClassTitle and ParentTermID = RD.TermID) is null) and (@ForceSemesterGrade != 'yes') then ' '
				when isnull(AlternativeGrade, '') != '' and  isnull(AlternativeGrade, '') != 'nm' then AlternativeGrade
				when AlternativeGrade = 'nm' then ' '
				when @GradeStyle = 'Letter' then  LetterGrade
				when ((Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = RD.CustomGradeScaleID) = 0) then LetterGrade
				when @GradeStyle = 'Percentage' then convert(nvarchar(3),convert(int, round(PercentageGrade, 0)))
			end 
		else
			case 
				when isnull(AlternativeGrade, '') != '' and  isnull(AlternativeGrade, '') != 'nm' then AlternativeGrade
				when AlternativeGrade = 'nm' then ' '
				when @GradeStyle = 'Letter' then  LetterGrade
				when ((Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = RD.CustomGradeScaleID) = 0) then LetterGrade
				when @GradeStyle = 'Percentage' then convert(nvarchar(10),convert(decimal(5,1), round(PercentageGrade, 1)))
			end 
	end as [ClassField!5!ClassGrade],
	case
	when @GradeStyle = 'Letter' then
	dbo.GetLetterGrade2(CustomGradeScaleID,
	(
		Select AvgGrade
		From #AvgGrades
		Where 
		StudentID = RD.StudentID
		and
		ClassTitle = RD.ClassTitle
	))
	when ((Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = RD.CustomGradeScaleID) = 0) then
	dbo.GetLetterGrade2(CustomGradeScaleID,
	(
		Select AvgGrade
		From #AvgGrades
		Where 
		StudentID = RD.StudentID
		and
		ClassTitle = RD.ClassTitle
	))		
	when @GradeStyle = 'Percentage' then
	(
		Select convert(nvarchar(5), convert(decimal(3,0), AvgGrade))
		From #AvgGrades
		Where 
		StudentID = RD.StudentID
		and
		ClassTitle = RD.ClassTitle
	)
	end as [ClassField!5!AvgGrade],
	case Effort
		when 1 then (Select Top 1 Category1Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)
		when 2 then (Select Top 1 Category2Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)
		when 3 then (Select Top 1 Category3Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)
		when 4 then (Select Top 1 Category4Symbol From #ReportCardData where ClassTypeID = RD.ClassTypeID Order By 1 desc)
	end	 as [ClassField!5!ClassEffort],
	ClassComments as [ClassField!5!ClassComments],
	case
	  when CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1) then convert(nvarchar(9), convert(decimal(7,2), ClassUnits))
	  else 'N/A'
	end as [ClassField!5!ClassCredits],
	CustomFieldName as [ClassField!5!FieldName],
	CustomFieldGrade as [ClassField!5!FieldGrade],
	case
		when ClassTypeID > 99 then CustomFieldOrder
		else ReportOrder
	end	as [ClassField!5!FieldOrder],
	Att1 as [ClassField!5!Att1],
	Att2 as [ClassField!5!Att2],
	Att3 as [ClassField!5!Att3],
	Att4 as [ClassField!5!Att4],
	Att5 as [ClassField!5!Att5]

From #ReportCardData RD
Where ClassTitle is not null


Order By [Student!2!SLname], [Student!2!SFname], [Student!2!SMname], [Student!2!StudentID], [ClassType!3!ClassTypeOrder], [Term!4!TermEnd], [Term!4!TermType], [ClassField!5!FieldOrder], [ClassField!5!ClassTitle]


FOR XML EXPLICIT

Drop Table #ReportCardData
Drop table #ClassesWithLastSubTermGrades
Drop Table #tmpTeachers
Drop Table #SemTerms

Drop Table #ClassTypeIDs
Drop Table #ExamOrParentTerms

Drop Table #SubCommentClassTypeIDs1
--Drop Table #SubCommentClassTypeIDs3
Drop Table #tmpTerms
Drop Table #ReportOrderTable
Drop Table #tmpCreditNoCredit
Drop Table #AvgGrades










GO
