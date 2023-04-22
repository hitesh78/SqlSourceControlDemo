SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--=============================================
-- Modified Dt: 01/24/2023 
-- Modified By: Joey 
-- Case #: 00177503
-- Notes: Fixed bold sub-grade name bug

-- Modified: 3/21/2023 By Don - Added ShowGPAasaPercentage profile option
--=============================================
CREATE     Procedure [dbo].[ReportCard1]

@RunOnUnconcludedClassesCheckBox nvarchar(3),
@ReportTitle nvarchar(100),
@GradePlacement nvarchar(10),
@DefaultName nvarchar(50),
@DisplayName nvarchar(50),
@ClassID int,
@EK Decimal(15,15),
@Gradelevel nvarchar(3),
@ReportType nvarchar(10),
@StudentIDs nvarchar(1000),
@Terms nvarchar(100),
@RunByClassSetting nvarchar(5),
@TheClassID int,
@ProfileID int,
@ReportProfileSettings nvarchar(4000),
@isPDF nvarchar(10)

as

SET NOCOUNT ON;

-- Start Of Report Card Stored Procedure (Don't Remove This Line)

DECLARE @StartTime datetime = (SELECT GETDATE())


-- Create and Define temp table of all data within date range
CREATE TABLE #ReportCardData (
	[TranscriptID] [int] NULL ,
	[TermID] [int] NOT NULL ,
	[ParentTermID] [int] NULL ,
	[ExamTerm] [bit] NULL ,
	[TermTitle] [nvarchar] (50) COLLATE DATABASE_DEFAULT NOT NULL ,
	[TermReportTitle] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[TermStart] [datetime] NOT NULL ,
	[TermEnd] [datetime] NOT NULL ,
	[StudentID] [int] NOT NULL ,
	[GradeLevel]  [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Fname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[Mname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[Lname] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[glname] [nvarchar] (100) COLLATE DATABASE_DEFAULT NULL ,
	[StaffTitle] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[TFname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[TLname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[TermComment] [nvarchar] (MAX) COLLATE DATABASE_DEFAULT NULL ,
	[ClassID] [int] NULL ,
	[ClassTitle] [nvarchar] (150) COLLATE DATABASE_DEFAULT NULL ,
	[ClassReportAvgGrade] [nvarchar] (10) COLLATE DATABASE_DEFAULT NULL ,
	[SpanishTitle] [nvarchar] (150) COLLATE DATABASE_DEFAULT NULL ,
	[ReportOrder] [int] NULL ,
	[ClassTypeID] [int] NOT NULL ,
	[ClassTypeID2] [int] NULL ,
	[ParentClassID] [int] NULL ,
	[SubCommentClassTypeID] [int] NULL ,
	[CustomGradeScaleID] [int] NULL ,
	[ClassUnits] [decimal](7,4) NULL ,
	[UnitsEarned] [decimal](7,4) NULL ,
	[LetterGrade] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
	[AlternativeGrade] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[PercentageGrade] [decimal](5,2) NULL ,
	[ClassReportGrade] [nvarchar] (100) COLLATE DATABASE_DEFAULT NULL ,
	[Effort] [tinyint] NULL ,
	[UnitGPA] [decimal](7,4) NULL ,
	[CustomFieldName] [nvarchar] (2000) COLLATE DATABASE_DEFAULT NULL ,
	[CustomFieldSpanishName] [nvarchar] (2000) COLLATE DATABASE_DEFAULT NULL ,
	[CustomFieldGrade] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
	[CustomFieldOrder] [int] NULL ,
	[FieldBolded] [int] Null,
	[FieldNotGraded] [int] Null,
	[GradeScaleLegend]  [nvarchar] (2000) COLLATE DATABASE_DEFAULT NULL ,
	[Indent] [tinyint] Null,
	[Bullet] [nvarchar] (20) COLLATE DATABASE_DEFAULT Null,
	[ClassComments] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
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
	[SchoolAtt1] [decimal](5, 2) NULL ,
	[PercSchoolAtt1] [decimal](5, 2) NULL ,
	[SchoolAtt2] [decimal](5, 2) NULL ,
	[PercSchoolAtt2] [decimal](5, 2) NULL ,
	[SchoolAtt3] [decimal](5, 2) NULL ,
	[PercSchoolAtt3] [decimal](5, 2) NULL ,
	[SchoolAtt4] [decimal](5, 2) NULL ,
	[PercSchoolAtt4] [decimal](5, 2) NULL ,
	[SchoolAtt5] [decimal](5, 2) NULL ,
	[PercSchoolAtt5] [decimal](5, 2) NULL ,
	[SchoolAtt6] [decimal](5, 2) NULL ,
	[PercSchoolAtt6] [decimal](5, 2) NULL ,
	[SchoolAtt7] [decimal](5, 2) NULL ,
	[PercSchoolAtt7] [decimal](5, 2) NULL ,
	[SchoolAtt8] [decimal](5, 2) NULL ,
	[PercSchoolAtt8] [decimal](5, 2) NULL ,
	[SchoolAtt9] [decimal](5, 2) NULL ,
	[PercSchoolAtt9] [decimal](5, 2) NULL ,
	[SchoolAtt10] [decimal](5, 2) NULL ,
	[PercSchoolAtt10] [decimal](5, 2) NULL ,
	[SchoolAtt11] [decimal](5, 2) NULL ,
	[PercSchoolAtt11] [decimal](5, 2) NULL ,
	[SchoolAtt12] [decimal](5, 2) NULL ,
	[PercSchoolAtt12] [decimal](5, 2) NULL ,
	[SchoolAtt13] [decimal](5, 2) NULL ,
	[PercSchoolAtt13] [decimal](5, 2) NULL ,
	[SchoolAtt14] [decimal](5, 2) NULL ,
	[PercSchoolAtt14] [decimal](5, 2) NULL ,
	[SchoolAtt15] [decimal](5, 2) NULL ,
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
	[CommentName] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[CommentAbbr] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment1] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment2] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment3] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment4] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment5] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment6] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment7] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment8] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment9] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment10] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment11] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment12] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment13] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment14] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment15] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment16] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment17] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment18] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment19] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment20] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment21] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment22] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment23] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment24] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment25] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment26] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment27] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment28] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment29] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment30] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[CategoryName] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
	[CategoryAbbr] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category1Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category1Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category2Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category2Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category3Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category3Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category4Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category4Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[GPABoost]decimal(5, 2),
	[CalculateGPA] bit, 
	[ConcludeDate] [nvarchar](40) COLLATE DATABASE_DEFAULT NULL,
	[ClassShowPercentageGrade] bit,
	[StandardsItemType] nvarchar(20) COLLATE DATABASE_DEFAULT
)


Create Index ReportCardData_Index on #ReportCardData (StudentID, ClassTypeID, TermID)



Declare @TermCount int
Declare @TheTermID int
Declare @TheTermTitle nvarchar(50)
Set @TermCount = (Select count(*) From SplitCSVIntegers(@Terms))

if @TermCount = 1
Begin
	Set @TheTermID = (Select * From SplitCSVIntegers(@Terms))
	if (Select charindex('20', TermTitle) From Terms Where TermID = @TheTermID) = 0
	Begin
		Select @TheTermTitle = (Select TermTitle From Terms Where TermID = @TheTermID)
	End
	Else
	Begin
		Select @TheTermTitle = left(TermTitle, charindex('20', TermTitle)-1) From Terms Where TermID = @TheTermID
	End
End

Create Table #tmpTermIDs
(
TermID int,
ParentTermID int,
TermStart smalldatetime,
TermEnd smalldatetime,
ExamTerm bit
)

Insert into #tmpTermIDs
Select Distinct 
TermID,
ParentTermID, 
TermStart,
TermEnd,
ExamTerm
From Transcript 
Where TermID in (Select IntegerID From SplitCSVIntegers(@Terms))

Insert into #tmpTermIDs
Select Distinct 
TermID as TermID, 
ParentTermID, 
StartDate as TermStart,
EndDate as TermEnd,
ExamTerm
From Terms 
Where 
TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
and
TermID not in (Select TermID From #tmpTermIDs)


Declare @SubTermCount int
Set @SubTermCount = (
Select count(*)
From #tmpTermIDs
Where
ParentTermID in (Select TermID From #tmpTermIDs)
)

Declare @ParentTermCount int
Set @ParentTermCount = (Select count(*) From #tmpTermIDs Where ParentTermID = 0)

-- IN LetterLandscape report card Make sure Semesters are always at the end if only one parentTermID
Declare @StartTermID int

If @DefaultName = 'Multi-Term Report Card' or @DefaultName = 'Multi-Term Two Column Report Card 2'  -- Don't update this line without checking with Don
Begin

	Set @StartTermID = 
	(
	Select top 1 TermID
	From #tmpTermIDs
	Where
	(
	case
		when @SubTermCount = 0 then 1
		when @SubTermCount > 0 and ParentTermID > 0 then 1
		else 0
	end) = 1
	Order By TermStart
	)

End
Else
Begin

	Set @StartTermID = 
	(
	Select top 1 TermID
	From #tmpTermIDs
	Where
	(
	case
		when @SubTermCount = 0 then 1
		when @ParentTermCount > 1 then 1
		when @SubTermCount > 0 and ParentTermID > 0 then 1
		else 0
	end) = 1
	Order By TermStart
	)

End

Declare @SupportAccount bit
If (Select AccountID From Accounts Where EncKey = @EK) = 'glinit' or (Select AccountID From Accounts Where EncKey = @EK) = 'gladmin'
Begin
	Set @SupportAccount = 1
End
Else
Begin
	Set @SupportAccount = 0
End

Declare @EndTermID int
Set @EndTermID = 
(
Select top 1 TermID
From #tmpTermIDs
Order By TermEnd desc, ParentTermID, ExamTerm desc
)

Declare @StartYear nvarchar(20)
Declare @EndYear nvarchar(20)
Declare @SchoolYear nvarchar(20)
Declare @NextStartYear nvarchar(20)
Declare @NextEndYear nvarchar(20)
Declare @NextSchoolYear nvarchar(20)


Set @StartYear = (Select top 1 DATEPART(year, TermStart) From #tmpTermIDs Where TermID in (Select IntegerID From SplitCSVIntegers(@Terms)) Order By TermStart) 
Set @EndYear = (Select top 1 DATEPART(year, TermEnd) From #tmpTermIDs Where TermID in (Select IntegerID From SplitCSVIntegers(@Terms)) Order By TermEnd desc)



If @StartYear = @EndYear
Begin
  Set @SchoolYear = convert(nvarchar(5), @StartYear) COLLATE DATABASE_DEFAULT
End
Else
Begin
  Set @SchoolYear = convert(nvarchar(5), @StartYear) + N' - ' + convert(nvarchar(5), @EndYear) COLLATE DATABASE_DEFAULT
End

Set @NextStartYear = @StartYear + 1
Set @NextEndYear = @EndYear + 1
 
If @NextStartYear = @NextEndYear
Begin
  Set @NextSchoolYear = convert(nvarchar(5), @NextStartYear) COLLATE DATABASE_DEFAULT
End
Else
Begin
  Set @NextSchoolYear = convert(nvarchar(5), @NextStartYear) + N' - ' + convert(nvarchar(5), @NextEndYear) COLLATE DATABASE_DEFAULT
End



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
	and
	case 
		when @ReportType = 'Individual' then 1
		when @RunByClassSetting = 'yes' and T.ClassID = @TheClassID then 1
		when T.GradeLevel = @GradeLevel then 1
		else 0
	end = 1
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
	and
	case 
		when @ReportType = 'Individual' then 1
		when @RunByClassSetting = 'yes' and T.ClassID = @TheClassID then 1
		when T.GradeLevel = @GradeLevel then 1
		else 0
	end = 1
)

--Print '****************************************Mark 0****************************************'





Declare
@CommentName nvarchar(20),
@CommentAbbr nvarchar(5),
@Comment1 nvarchar(50),
@Comment2 nvarchar(50),
@Comment3 nvarchar(50),
@Comment4 nvarchar(50),
@Comment5 nvarchar(50),
@Comment6 nvarchar(50),
@Comment7 nvarchar(50),
@Comment8 nvarchar(50),
@Comment9 nvarchar(50),
@Comment10 nvarchar(50),
@Comment11 nvarchar(50),
@Comment12 nvarchar(50),
@Comment13 nvarchar(50),
@Comment14 nvarchar(50),
@Comment15 nvarchar(50),
@Comment16 nvarchar(50),
@Comment17 nvarchar(50),
@Comment18 nvarchar(50),
@Comment19 nvarchar(50),
@Comment20 nvarchar(50),
@Comment21 nvarchar(50),
@Comment22 nvarchar(50),
@Comment23 nvarchar(50),
@Comment24 nvarchar(50),
@Comment25 nvarchar(50),
@Comment26 nvarchar(50),
@Comment27 nvarchar(50),
@Comment28 nvarchar(50),
@Comment29 nvarchar(50),
@Comment30 nvarchar(50),
@CategoryName nvarchar(50),
@CategoryAbbr nvarchar(20),
@Category1Symbol nvarchar(5),
@Category1Desc nvarchar(20),
@Category2Symbol nvarchar(5),
@Category2Desc nvarchar(20),
@Category3Symbol nvarchar(5),
@Category3Desc nvarchar(20),
@Category4Symbol nvarchar(5),
@Category4Desc nvarchar(20),
@TableID int,
@CSID int,
@ClassTypeID int,
@CSCFID int,
@TermID int,
@ParentTermID int,
@TermTitle nvarchar(20),
@TermReportTitle nvarchar(20),
@TermStart smalldatetime,
@TermEnd smalldatetime,
@ExamTerm bit,
@StudentID int,
@Fname nvarchar(30),
@Mname nvarchar(30),
@Lname nvarchar(30),
@glname nvarchar(100),
@StaffTitle nvarchar(20),
@TFname nvarchar(30),
@TLname nvarchar(30),
@ClassTitle nvarchar(50),
@ReportOrder int,
@ParentClassID int,
@SubCommentClassTypeID int,
@CCTranscriptID int


If @RunOnUnconcludedClassesCheckBox = 'on'
Begin

--------------------------------------------------------------------------------------
------------------------------Start of Unconcluded Classes----------------------------
--------------------------------------------------------------------------------------




Select
@CommentName = CommentName,
@CommentAbbr = CommentAbbr,
@Comment1 = Comment1,
@Comment2 = Comment2,
@Comment3 = Comment3,
@Comment4 = Comment4,
@Comment5 = Comment5,
@Comment6 = Comment6,
@Comment7 = Comment7,
@Comment8 = Comment8,
@Comment9 = Comment9,
@Comment10 = Comment10,
@Comment11 = Comment11,
@Comment12 = Comment12,
@Comment13 = Comment13,
@Comment14 = Comment14,
@Comment15 = Comment15,
@Comment16 = Comment16,
@Comment17 = Comment17,
@Comment18 = Comment18,
@Comment19 = Comment19,
@Comment20 = Comment20,
@Comment21 = Comment21,
@Comment22 = Comment22,
@Comment23 = Comment23,
@Comment24 = Comment24,
@Comment25 = Comment25,
@Comment26 = Comment26,
@Comment27 = Comment27,
@Comment28 = Comment28,
@Comment29 = Comment29,
@Comment30 = Comment30,
@CategoryName = CategoryName,
@CategoryAbbr = CategoryAbbr,
@Category1Symbol = Category1Symbol,
@Category1Desc = Category1Description,
@Category2Symbol = Category2Symbol,
@Category2Desc = Category2Description,
@Category3Symbol = Category3Symbol,
@Category3Desc = Category3Description,
@Category4Symbol = Category4Symbol,
@Category4Desc = Category4Description
From Settings
Where SettingID = 1

Create Table #tmpCSCustomClasses
(
[TableID] int identity,
[TranscriptID] int,
[TermID] [int] NOT NULL ,
[ParentTermID] [int] NULL ,
[ExamTerm] [bit] NULL ,
[TermTitle] [nvarchar] (50) COLLATE DATABASE_DEFAULT NOT NULL ,
[TermReportTitle] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
[TermStart] [datetime] NOT NULL ,
[TermEnd] [datetime] NOT NULL ,
[StudentID] [int] NOT NULL ,
[GradeLevel]  [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
[Fname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
[Mname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
[Lname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
[glname] [nvarchar] (100) COLLATE DATABASE_DEFAULT NULL ,
[StaffTitle] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
[TFname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
[TLname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
[TermComment] [nvarchar] (MAX) COLLATE DATABASE_DEFAULT NULL ,
[ClassID] [int] NULL ,
[ClassTitle] [nvarchar] (150) COLLATE DATABASE_DEFAULT NULL ,
[SpanishTitle] [nvarchar] (150) COLLATE DATABASE_DEFAULT NULL ,
[ReportOrder] [int] NULL ,
[ClassTypeID] [int] NOT NULL ,
[ClassTypeID2] [int] NULL,
[ParentClassID] [int] NULL ,
[SubCommentClassTypeID] [int] NULL,
[Comment1] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment2] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment3] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment4] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment5] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment6] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment7] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment8] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment9] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment10] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment11] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment12] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment13] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment14] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment15] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment16] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment17] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment18] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment19] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment20] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment21] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment22] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment23] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment24] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment25] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment26] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment27] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment28] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment29] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
[Comment30] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
)

Declare @tmpCSIDs table(CSID int)
Declare @tmpCSCFIDs table(CSCFID int)


Create Table #UCReportCardData
(
	[TranscriptID] int identity,
	[TermID] [int] NOT NULL ,
	[ParentTermID] [int] NULL ,
	[ExamTerm] [bit] NULL ,
	[TermTitle] [nvarchar] (50) COLLATE DATABASE_DEFAULT NOT NULL ,
	[TermReportTitle] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[TermStart] [datetime] NOT NULL ,
	[TermEnd] [datetime] NOT NULL ,
	[StudentID] [int] NOT NULL ,
	[GradeLevel]  [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Fname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[Mname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[Lname] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[glname] [nvarchar] (100) COLLATE DATABASE_DEFAULT NULL ,
	[StaffTitle] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[TFname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[TLname] [nvarchar] (30) COLLATE DATABASE_DEFAULT NULL ,
	[TermComment] [nvarchar] (MAX) COLLATE DATABASE_DEFAULT NULL ,
	[ClassID] [int] NULL ,
	[ClassTitle] [nvarchar] (150) COLLATE DATABASE_DEFAULT NULL ,
	[ClassReportAvgGrade] [nvarchar] (10) COLLATE DATABASE_DEFAULT NULL ,
	[SpanishTitle] [nvarchar] (150) COLLATE DATABASE_DEFAULT NULL ,
	[ReportOrder] [int] NULL ,
	[ClassTypeID] [int] NOT NULL ,
	[ClassTypeID2] [int] NULL ,
	[ParentClassID] [int] NULL ,
	[SubCommentClassTypeID] [int] NULL ,
	[CustomGradeScaleID] [int] NULL ,
	[ClassUnits] [decimal](7,4) NULL ,
	[UnitsEarned] [decimal](7,4) NULL ,
	[LetterGrade] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
	[AlternativeGrade] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	[PercentageGrade] [decimal](5,2) NULL ,
	[ClassReportGrade] [nvarchar] (100) COLLATE DATABASE_DEFAULT NULL ,
	[Effort] [tinyint] NULL ,
	[UnitGPA] [decimal](7,4) NULL ,
	[CustomFieldName] [nvarchar] (2000) COLLATE DATABASE_DEFAULT NULL ,
	[CustomFieldSpanishName] [nvarchar] (2000) COLLATE DATABASE_DEFAULT NULL ,
	[CustomFieldGrade] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
	[CustomFieldOrder] [int] NULL ,
	[FieldBolded] [int] Null,
	[FieldNotGraded] [int] Null,
	[GradeScaleLegend]  [nvarchar] (2000) COLLATE DATABASE_DEFAULT NULL ,
	[Indent] [tinyint] Null,
	[Bullet] [nvarchar] (20) COLLATE DATABASE_DEFAULT Null,
	[ClassComments] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
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
	[SchoolAtt1] [decimal](5, 2) NULL ,
	[PercSchoolAtt1] [decimal](5, 2) NULL ,
	[SchoolAtt2] [decimal](5, 2) NULL ,
	[PercSchoolAtt2] [decimal](5, 2) NULL ,
	[SchoolAtt3] [decimal](5, 2) NULL ,
	[PercSchoolAtt3] [decimal](5, 2) NULL ,
	[SchoolAtt4] [decimal](5, 2) NULL ,
	[PercSchoolAtt4] [decimal](5, 2) NULL ,
	[SchoolAtt5] [decimal](5, 2) NULL ,
	[PercSchoolAtt5] [decimal](5, 2) NULL ,
	[SchoolAtt6] [decimal](5, 2) NULL ,
	[PercSchoolAtt6] [decimal](5, 2) NULL ,
	[SchoolAtt7] [decimal](5, 2) NULL ,
	[PercSchoolAtt7] [decimal](5, 2) NULL ,
	[SchoolAtt8] [decimal](5, 2) NULL ,
	[PercSchoolAtt8] [decimal](5, 2) NULL ,
	[SchoolAtt9] [decimal](5, 2) NULL ,
	[PercSchoolAtt9] [decimal](5, 2) NULL ,
	[SchoolAtt10] [decimal](5, 2) NULL ,
	[PercSchoolAtt10] [decimal](5, 2) NULL ,
	[SchoolAtt11] [decimal](5, 2) NULL ,
	[PercSchoolAtt11] [decimal](5, 2) NULL ,
	[SchoolAtt12] [decimal](5, 2) NULL ,
	[PercSchoolAtt12] [decimal](5, 2) NULL ,
	[SchoolAtt13] [decimal](5, 2) NULL ,
	[PercSchoolAtt13] [decimal](5, 2) NULL ,
	[SchoolAtt14] [decimal](5, 2) NULL ,
	[PercSchoolAtt14] [decimal](5, 2) NULL ,
	[SchoolAtt15] [decimal](5, 2) NULL ,
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
	[CommentName] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[CommentAbbr] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment1] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment2] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment3] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment4] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment5] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment6] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment7] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment8] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment9] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment10] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment11] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment12] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment13] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment14] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment15] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment16] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment17] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment18] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment19] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment20] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment21] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment22] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment23] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment24] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment25] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment26] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment27] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment28] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment29] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[Comment30] [nvarchar] (60) COLLATE DATABASE_DEFAULT NULL ,
	[CategoryName] [nvarchar] (50) COLLATE DATABASE_DEFAULT NULL ,
	[CategoryAbbr] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category1Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category1Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category2Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category2Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category3Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category3Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[Category4Symbol] [nvarchar] (3) COLLATE DATABASE_DEFAULT NULL ,
	[Category4Desc] [nvarchar] (20) COLLATE DATABASE_DEFAULT NULL ,
	[GPABoost]decimal(5, 2),
	[CalculateGPA] bit, 
	[ConcludeDate] [nvarchar](40) COLLATE DATABASE_DEFAULT NULL,
	[ClassShowPercentageGrade] bit,
	[StandardsItemType] nvarchar(20) COLLATE DATABASE_DEFAULT
)



Declare @tmpAttendance table
(
CSID int,
TotalAttendance decimal(6,3),
TotalPresentValue decimal (6,3),
TotalAbsentValue decimal (6,3),
Att1 decimal(6,3),
Att2 decimal(6,3),
Att3 decimal(6,3),
Att4 decimal(6,3),
Att5 decimal(6,3),
Att6 decimal(6,3),
Att7 decimal(6,3),
Att8 decimal(6,3),
Att9 decimal(6,3),
Att10 decimal(6,3),
Att11 decimal(6,3),
Att12 decimal(6,3),
Att13 decimal(6,3),
Att14 decimal(6,3),
Att15 decimal(6,3),
ChurchPresent int,
ChurchAbsent int,
SSchoolPresent int,
SSchoolAbsent int
)

Insert into @tmpAttendance
Select
CS.CSID,
count(A.CSID) as TotalAttendance,
(
Sum(A.Att1) * (Select PresentValue From AttendanceSettings Where ID = 'Att1')
+
Sum(A.Att2) * (Select PresentValue From AttendanceSettings Where ID = 'Att2')
+
Sum(A.Att3) * (Select PresentValue From AttendanceSettings Where ID = 'Att3')
+
Sum(A.Att4) * (Select PresentValue From AttendanceSettings Where ID = 'Att4')
+
Sum(A.Att5) * (Select PresentValue From AttendanceSettings Where ID = 'Att5')
+
Sum(A.Att6)* (Select PresentValue From AttendanceSettings Where ID = 'Att6')
+
Sum(A.Att7) * (Select PresentValue From AttendanceSettings Where ID = 'Att7')
+
Sum(A.Att8) * (Select PresentValue From AttendanceSettings Where ID = 'Att8')
+
Sum(A.Att9) * (Select PresentValue From AttendanceSettings Where ID = 'Att9')
+
Sum(A.Att10) * (Select PresentValue From AttendanceSettings Where ID = 'Att10')
+
Sum(A.Att11) * (Select PresentValue From AttendanceSettings Where ID = 'Att11')
+
Sum(A.Att12)* (Select PresentValue From AttendanceSettings Where ID = 'Att12')
+
Sum(A.Att13) * (Select PresentValue From AttendanceSettings Where ID = 'Att13')
+
Sum(A.Att14) * (Select PresentValue From AttendanceSettings Where ID = 'Att14')
+
Sum(A.Att15)* (Select PresentValue From AttendanceSettings Where ID = 'Att15')
) as TotalPresentValue,
(
Sum(A.Att1) * (Select AbsentValue From AttendanceSettings Where ID = 'Att1')
+
Sum(A.Att2) * (Select AbsentValue From AttendanceSettings Where ID = 'Att2')
+
Sum(A.Att3) * (Select AbsentValue From AttendanceSettings Where ID = 'Att3')
+
Sum(A.Att4) * (Select AbsentValue From AttendanceSettings Where ID = 'Att4')
+
Sum(A.Att5) * (Select AbsentValue From AttendanceSettings Where ID = 'Att5')
+
Sum(A.Att6)* (Select AbsentValue From AttendanceSettings Where ID = 'Att6')
+
Sum(A.Att7) * (Select AbsentValue From AttendanceSettings Where ID = 'Att7')
+
Sum(A.Att8) * (Select AbsentValue From AttendanceSettings Where ID = 'Att8')
+
Sum(A.Att9) * (Select AbsentValue From AttendanceSettings Where ID = 'Att9')
+
Sum(A.Att10) * (Select AbsentValue From AttendanceSettings Where ID = 'Att10')
+
Sum(A.Att11) * (Select AbsentValue From AttendanceSettings Where ID = 'Att11')
+
Sum(A.Att12)* (Select AbsentValue From AttendanceSettings Where ID = 'Att12')
+
Sum(A.Att13) * (Select AbsentValue From AttendanceSettings Where ID = 'Att13')
+
Sum(A.Att14) * (Select AbsentValue From AttendanceSettings Where ID = 'Att14')
+
Sum(A.Att15)* (Select AbsentValue From AttendanceSettings Where ID = 'Att15')
) as TotalAbsentValue,
Sum(A.Att1) as Att1,
Sum(A.Att2) as Att2,
Sum(A.Att3) as Att3,
Sum(A.Att4) as Att4,
Sum(A.Att5) as Att5,
Sum(A.Att6) as Att6,
Sum(A.Att7) as Att7,
Sum(A.Att8) as Att8,
Sum(A.Att9) as Att9,
Sum(A.Att10) as Att10,
Sum(A.Att11) as Att11,
Sum(A.Att12) as Att12,
Sum(A.Att13) as Att13,
Sum(A.Att14) as Att14,
Sum(A.Att15) as Att15,
case
	when ClassTypeID != 6 then null
	else Sum(A.ChurchPresent) 
end as ChurchPresent,
case
	when ClassTypeID != 6 then null
	else Sum(A.ChurchAbsent) 
end as ChurchAbsent,
case
	when ClassTypeID != 6 then null
	else Sum(A.SSchoolPresent)
end as SSchoolPresent,
case
	when ClassTypeID != 6 then null
	else Sum(A.SSchoolAbsent)
end as SSchoolAbsent
From 
Attendance A
	inner join
ClassesStudents CS
	on CS.CSID = A.CSID
	inner join
Classes C
	on C.ClassID = CS.ClassID
	inner join
Students S
	on S.StudentID = CS.StudentID
Where
case
	when Att3 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att3' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att4 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att4' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att5 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att5' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att6 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att6' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att7 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att7' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att8 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att8' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att9 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att9' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att10 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att10' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att11 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att11' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att12 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att12' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att13 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att13' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att14 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att14' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	when Att15 = 1 and exists(Select * From AttendanceSettings Where ID = 'Att15' and ExcludedAttendance = 1 and MultiSelect = 0) then 0
	else 1
end = 1 
and
case
	when @ReportType = 'Individual' and S.StudentID in (Select IntegerID From SplitCSVIntegers(@StudentIDs)) then 1
	when 
		@RunByClassSetting = 'yes'
		and 
		S.StudentID in (Select StudentID From ClassesStudents Where ClassID = @TheClassID) then 1
	when @RunByClassSetting != 'yes' and S.GradeLevel = @GradeLevel then 1
	else 0
end = 1	

Group By CS.CSID, C.ClassTypeID



	Insert into #UCReportCardData
	(
--	[TranscriptID],
	[TermID],
	[ParentTermID],
	[ExamTerm],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[glname],
	[StaffTitle],
	[TFname],
	[TLname],
	[TermComment],	
	[ClassID],
	[ClassTitle],
	[SpanishTitle],
	[ReportOrder],
	[ClassTypeID],
	[ClassTypeID2],
	[ParentClassID],
	[SubCommentClassTypeID],
	[CustomGradeScaleID],
	[ClassUnits],
	[UnitsEarned],
	[LetterGrade],
	[AlternativeGrade],
	[PercentageGrade],
	[Effort],
	[UnitGPA],
	--[CustomFieldName],
	--[CustomFieldSpanishName],
	--[CustomFieldGrade],
	--[CustomFieldOrder],
	[FieldBolded],
	[FieldNotGraded],
	GradeScaleLegend,
	[Indent],
	[Bullet],
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
	--[Exceptional],
	--[PercExceptional],
	--[Good],
	--[PercGood],
	--[Poor],
	--[PercPoor],
	--[Unacceptable],
	--[PercUnacceptable],
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
	[GPABoost],
	[CalculateGPA],
--	[ConcludeDate]
	[ClassShowPercentageGrade]
	)	
	Select
--	[TranscriptID],
	Tm.TermID,
	Tm.ParentTermID,
	Tm.ExamTerm,
	Tm.TermTitle,
	Tm.ReportTitle as TermReportTitle,
	Tm.StartDate as TermStart,
	Tm.EndDate as TermEnd,
	S.StudentID,
	S.GradeLevel,
	S.Fname,
	S.Mname,
	S.Lname,
	S.glname,
	T.StaffTitle,
	T.Fname as TFname,
	T.Lname as TLname,
	case CS.TermComment
		when '<P>&nbsp;</P>' then null
		when '<P>


</P>' then null
		when '<p>
<br mce_bogus="1">
</p>' then null
		when '<P> </P>' then null
		when '' then null
		else REPLACE(REPLACE(REPLACE(REPLACE(CS.TermComment , '=atSymbol=' , '@' ) , '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )	
	end as [TermComment],	
	C.ClassID,
	case
		when C.ClassTypeID = 3 then 'Term Comments'
		when C.ClassTypeID = 5 then 'School Attendance'
		when CS.ClassLevel is null then C.ReportTitle
		when CS.ClassLevel = '' then C.ReportTitle
		When CS.ClassLevel = ' ' then C.ReportTitle
		else C.ReportTitle + ' (' + dbo.T(0.0, CS.ClassLevel) + ')'
	end	as [ClassTitle],
	case
		when C.SpanishTitle = '' then null
		else C.SpanishTitle
	end as SpanishTitle,
	C.ReportOrder,
	C.ClassTypeID,
	case
		when C.ClassTypeID = 5 then 5
		else 1
	end as [ClassTypeID2],
	case
		when C.ParentClassID > 99 then C.ParentClassID
		when C.ParentClassID > 0 then 1
		else 0
	end as [ParentClassID],
	C.SubCommentClassTypeID,
	C.CustomGradeScaleID,
	case
		when C.ClassTypeID in (3,5,6,7) then null
		else C.Units
	end as Units,
	case
		when C.ClassTypeID in (3,5,6,7) then null
		when dbo.GetLetterGrade(C.ClassID, CS.StudentGrade) = 'F' then 0
		when dbo.GetLetterGrade(C.ClassID, CS.StudentGrade) = 
		(
		Select top 1
		GradeSymbol
		from CustomGradeScaleGrades
		Where CustomGradeScaleID = C.CustomGradeScaleID
		Order By GradeOrder desc
		) then 0
		else C.Units
	end as UnitsEarned,
	case
		when ParentClassID > 0 then null
		when C.ClassTypeID in (3,5,6,7) then null
		when C.ClassTypeID = 8 and CS.StudentGrade < (Select CreditNoCreditPassingGrade From Settings Where SettingID = 1) then 'NC'
		when C.ClassTypeID = 8 then 'CR'
		else dbo.GetLetterGrade(C.ClassID, CS.StudentGrade)
	end as [LetterGrade],
	case
		when ClassTypeID not in (1,2,8) then null
		when CS.StudentGrade is null and CS.AlternativeGrade is null then 'nm'
		else CS.AlternativeGrade
	end as AlternativeGrade,
	CS.StudentGrade,
	case
		when CS.Exceptional = 1 then 1
		when CS.Good = 1 then 2
		when CS.Poor = 1 then 3
		when CS.Unacceptable = 1 then 4
	end as Effort,
	case 
		when C.ClassTypeID in (3,5,6,7) then null
		else dbo.getUnitGPA(C.ClassID, CS.StudentGrade)
	end as UnitGPA,
	--[CustomFieldName],
	--[CustomFieldSpanishName],
	--[CustomFieldGrade],
	--[CustomFieldOrder],
	0 as [FieldBolded],
	0 as [FieldNotGraded],
	case 
		when C.ClassTypeID in (1,2,8) then dbo.getGradeScaleLegend2 (C.CustomGradeScaleID)
		else null
	end as GradeScaleLegend,
	0 as [Indent],
	'none' as [Bullet],	
	replace(
		replace(ClassComments,' ',''),	-- First Remove spaces then replace commas with commas space (fixes issues where teach didn't put any spaces which are needed for proper breaking
		',', ', ')
		,
	A.Att1 as [Att1],
	case
		when ClassTypeID = 3 then null
		when ClassTypeID > 99 then null
		when A.TotalAttendance = 0 then 0
		else A.Att1 / A.TotalAttendance * 100
	end as [PercAtt1],
	A.Att2 as [Att2],
	case
		when ClassTypeID = 3 then null
		when ClassTypeID > 99 then null
		when A.TotalAttendance = 0 then 0
		else A.Att2 / A.TotalAttendance * 100
	end as [PercAtt2],
	A.Att3 as [Att3],
	case
		when ClassTypeID = 3 then null
		when ClassTypeID > 99 then null
		when A.TotalAttendance = 0 then 0
		else A.Att3 / A.TotalAttendance * 100
	end as [PercAtt3],
	A.Att4 as [Att4],
	case
		when ClassTypeID = 3 then null
		when ClassTypeID > 99 then null
		when A.TotalAttendance = 0 then 0
		else A.Att4 / A.TotalAttendance * 100
	end as [PercAtt4],
	A.Att5 as [Att5],
	case
		when ClassTypeID = 3 then null
		when ClassTypeID > 99 then null
		when A.TotalAttendance = 0 then 0
		else A.Att5 / A.TotalAttendance * 100
	end as [PercAtt5],
	case
		when ClassTypeID != 5 then null
		else A.TotalPresentValue 
	end as [SchoolAtt1],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.TotalPresentValue / A.TotalAttendance * 100
	end as [PercSchoolAtt1],
	case
		when ClassTypeID != 5 then null
		else A.TotalAbsentValue 
	end as [SchoolAtt2],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.TotalAbsentValue / A.TotalAttendance * 100
	end as [PercSchoolAtt2],
	case
		when ClassTypeID != 5 then null
		else A.Att3
	end as [SchoolAtt3],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att3 / A.TotalAttendance * 100
	end as [PercSchoolAtt3],
	case
		when ClassTypeID != 5 then null
		else A.Att4
	end as [SchoolAtt4],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att4 / A.TotalAttendance * 100
	end as [PercSchoolAtt4],
	case
		when ClassTypeID != 5 then null
		else A.Att5
	end as [SchoolAtt5],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att5 / A.TotalAttendance * 100
	end as [PercSchoolAtt5],	
	case
		when ClassTypeID != 5 then null
		else A.Att6
	end as [SchoolAtt6],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att6 / A.TotalAttendance * 100
	end as [PercSchoolAtt6],
	case
		when ClassTypeID != 5 then null
		else A.Att7
	end as [SchoolAtt7],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att7 / A.TotalAttendance * 100
	end as [PercSchoolAtt7],
	case
		when ClassTypeID != 5 then null
		else A.Att8
	end as [SchoolAtt8],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att8 / A.TotalAttendance * 100
	end as [PercSchoolAtt8],
	case
		when ClassTypeID != 5 then null
		else A.Att9
	end as [SchoolAtt9],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att9 / A.TotalAttendance * 100
	end as [PercSchoolAtt9],
	case
		when ClassTypeID != 5 then null
		else A.Att10
	end as [SchoolAtt10],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att10 / A.TotalAttendance * 100
	end as [PercSchoolAtt10],
	case
		when ClassTypeID != 5 then null
		else A.Att11
	end as [SchoolAtt11],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att11 / A.TotalAttendance * 100
	end as [PercSchoolAtt11],
	case
		when ClassTypeID != 5 then null
		else A.Att12
	end as [SchoolAtt12],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att12 / A.TotalAttendance * 100
	end as [PercSchoolAtt12],
	case
		when ClassTypeID != 5 then null
		else A.Att13
	end as [SchoolAtt13],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att13 / A.TotalAttendance * 100
	end as [PercSchoolAtt13],
	case
		when ClassTypeID != 5 then null
		else A.Att14
	end as [SchoolAtt14],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att14 / A.TotalAttendance * 100
	end as [PercSchoolAtt14],
	case
		when ClassTypeID != 5 then null
		else A.Att15
	end as [SchoolAtt15],
	case
		when ClassTypeID != 5 then null
		when A.TotalAttendance = 0 then 0
		else A.Att15 / A.TotalAttendance * 100
	end as [PercSchoolAtt15],
	A.ChurchPresent as [ChurchPresent],
	case
		when ClassTypeID != 6 then null
		when A.TotalAttendance = 0 then 0
		else A.ChurchPresent / A.TotalAttendance * 100
	end as [PercChurchPresent],	
	A.ChurchAbsent as [ChurchAbsent],
	case
		when ClassTypeID != 6 then null
		when A.TotalAttendance = 0 then 0
		else A.ChurchAbsent / A.TotalAttendance * 100
	end as [ChurchAbsent],	
	A.SSchoolPresent as [SSchoolPresent],
	case
		when ClassTypeID != 6 then null
		when A.TotalAttendance = 0 then 0
		else A.SSchoolPresent / A.TotalAttendance * 100
	end as [PercSSchoolPresent],	
	A.SSchoolAbsent as [SSchoolAbsent],
	case
		when ClassTypeID != 6 then null
		when A.TotalAttendance = 0 then 0
		else A.SSchoolAbsent / A.TotalAttendance * 100
	end as [PercSSchoolAbsent],	
	  

	--[Exceptional],
	--[PercExceptional],
	--[Good],
	--[PercGood],
	--[Poor],
	--[PercPoor],
	--[Unacceptable],
	--[PercUnacceptable],
	@CommentName as CommentName,
	@CommentAbbr as CommentAbbr,

	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 1) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment1) = '' then null
		else '1. ' + @Comment1
	end as Comment1,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 2) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment2) = '' then null
		else '2. ' + @Comment2
	end as Comment2,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 3) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment3) = '' then null
		else '3. ' + @Comment3
	end as Comment3,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 4) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment4) = '' then null
		else '4. ' + @Comment4
	end as Comment4,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 5) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment5) = '' then null
		else '5. ' + @Comment5
	end as Comment5,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 6) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment6) = '' then null
		else '6. ' + @Comment6
	end as Comment6,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 7) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment7) = '' then null
		else '7. ' + @Comment7
	end as Comment7,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 8) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment8) = '' then null
		else '8. ' + @Comment8
	end as Comment8,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 9) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment9) = '' then null
		else '9. ' + @Comment9
	end as Comment9,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 10) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment10) = '' then null
		else '10. ' + @Comment10
	end as Comment10,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 11) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment11) = '' then null
		else '11. ' + @Comment11
	end as Comment11,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 12) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment12) = '' then null
		else '12. ' + @Comment12
	end as Comment12,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 13) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment13) = '' then null
		else '13. ' + @Comment13
	end as Comment13,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 14) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment14) = '' then null
		else '14. ' + @Comment14
	end as Comment14,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 15) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment15) = '' then null
		else '15. ' + @Comment15
	end as Comment15,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 16) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment16) = '' then null
		else '16. ' + @Comment16
	end as Comment16,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 17) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment17) = '' then null
		else '17. ' + @Comment17
	end as Comment17,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 18) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment18) = '' then null
		else '18. ' + @Comment18
	end as Comment18,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 19) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment19) = '' then null
		else '19. ' + @Comment19
	end as Comment19,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 20) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment20) = '' then null
		else '20. ' + @Comment20
	end as Comment20,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 21) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment21) = '' then null
		else '21. ' + @Comment21
	end as Comment21,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 22) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment22) = '' then null
		else '22. ' + @Comment22
	end as Comment22,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 23) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment23) = '' then null
		else '23. ' + @Comment23
	end as Comment23,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 24) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment24) = '' then null
		else '24. ' + @Comment24
	end as Comment24,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 25) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment25) = '' then null
		else '25. ' + @Comment25
	end as Comment25,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 26) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment26) = '' then null
		else '26. ' + @Comment26
	end as Comment26,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 27) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment27) = '' then null
		else '27. ' + @Comment27
	end as Comment27,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 28) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment28) = '' then null
		else '28. ' + @Comment28
	end as Comment28,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 29) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment29) = '' then null
		else '29. ' + @Comment29
	end as Comment29,
	case
		when ClassTypeID > 99 then
		(Select convert(nvarchar(2), CommentNumber) + N'. ' + CommentDescription From CustomTypeComments Where ClassTypeID = C.ClassTypeID and CommentNumber = 30) COLLATE DATABASE_DEFAULT
		when ClassTypeID in (3,5,6) then null
		when LTRIM(@Comment30) = '' then null
		else '30. ' + @Comment30
	end as Comment30,
	@CategoryName as CategoryName,
	@CategoryAbbr as CategoryAbbr,
	@Category1Symbol as Category1Symbol,
	@Category1Desc as Category1Desc,
	@Category2Symbol as Category2Symbol,
	@Category2Desc as Category2Desc,
	@Category3Symbol as Category3Symbol,
	@Category3Desc as Category3Desc,
	@Category4Symbol as Category4Symbol,
	@Category4Desc as Category4Desc,
	(Select GPABoost From CustomGradeScale Where CustomGradeScaleID = C.CustomGradeScaleID) as GPABoost,
	(Select CalculateGPA From CustomGradeScale Where CustomGradeScaleID = C.CustomGradeScaleID) as CalculateGPA,
	(Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = C.CustomGradeScaleID) as ClassShowPercentageGrade
	From
	Terms Tm
		inner join
	Classes C
		on C.TermID = Tm.TermID
		inner join
	Teachers T
		on C.TeacherID = T.TeacherID
		inner join
	ClassesStudents CS
		on C.ClassID = CS.ClassID
		inner join
	Students S
		on S.StudentID = CS.StudentID
		left join
	@tmpAttendance A
		on CS.CSID = A.CSID
	Where 	
	Tm.TermID in (Select IntegerID From SplitCSVIntegers(@Terms))  
	and
	Tm.TermID not in (Select ParentTermID From Terms)
	and
	C.ClassTypeID !=  7	-- Exclude Sports Classes
	and
	C.ClassTypeID !=  9	-- Exclude Preschool Classes	
	and
	S.Active = 1
	and
	case
		when @ReportType = 'Individual' and S.StudentID in (Select IntegerID From SplitCSVIntegers(@StudentIDs)) then 1
		when 
			@RunByClassSetting = 'yes'
			and 
			S.StudentID in (Select StudentID From ClassesStudents Where ClassID = @TheClassID) then 1
		when @RunByClassSetting != 'yes' and S.GradeLevel = @GradeLevel then 1
		else 0
	end = 1
	and
	case
		when ParentClassID = 0 and C.NonAcademic = 0 then 1
		when ParentClassID != 0  and (select NonAcademic From Classes Where ClassID = C.ParentClassID) = 0 then 1
		else 0
	end = 1
	and
	case 
		when C.ClassTypeID = 5 and C.DefaultPresentValue = 0 then 0
		else 1
	end = 1
	
	Order By C.ClassTypeID, C.ClassTitle



	
	Insert into #tmpCSCustomClasses
	(
	[TranscriptID],
	[TermID],
	[ParentTermID],
	[ExamTerm],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[glname],
	[StaffTitle],
	[TFname],
	[TLname],
	[ClassID],
	[ClassTitle],
	[SpanishTitle],
	[ReportOrder],
	[ClassTypeID],
	[ClassTypeID2],
	[ParentClassID],
	[SubCommentClassTypeID],
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
	[Comment30]
	)
	Select 
	[TranscriptID],
	[TermID],
	[ParentTermID],
	[ExamTerm],
	[TermTitle],
	[TermReportTitle],
	[TermStart],
	[TermEnd],
	[StudentID],
	[GradeLevel],
	[Fname],
	[Mname],
	[Lname],
	[glname],
	[StaffTitle],
	[TFname],
	[TLname],
	[ClassID],
	[ClassTitle],
	[SpanishTitle],
	[ReportOrder],
	[ClassTypeID],
	[ClassTypeID2],
	[ParentClassID],
	[SubCommentClassTypeID],
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
	[Comment30]
	From #UCReportCardData
	Where ClassTypeID > 99
	
	
	
	
	-- Traverse all of the CustomType Classes
	While exists (Select * From #tmpCSCustomClasses)
	Begin
		
		Select top 1
		@TableID = TableID,
		@CCTranscriptID = TranscriptID,
		@TermID = TermID,
		@ParentTermID = ParentTermID,
		@TermTitle = TermTitle,
		@TermReportTitle = TermReportTitle,
		@TermStart = TermStart,
		@TermEnd = TermEnd,
		@ExamTerm = ExamTerm,
		@StudentID = StudentID,
		@GradeLevel = GradeLevel,
		@Fname = Fname,
		@Mname = Mname,
		@Lname = Lname,
		@glname = glname,
		@StaffTitle = StaffTitle,
		@TFname = TFname,
		@TLname = TLname,
		@ClassID = ClassID,
		@ClassTitle = ClassTitle,
		@ReportOrder = ReportOrder,
		@ClassTypeID = ClassTypeID,
		@ParentClassID = ParentClassID,
		@SubCommentClassTypeID = SubCommentClassTypeID,
		@Comment1 = Comment1,
		@Comment2 = Comment2,
		@Comment3 = Comment3,
		@Comment4 = Comment4,
		@Comment5 = Comment5,
		@Comment6 = Comment6,
		@Comment7 = Comment7,
		@Comment8 = Comment8,
		@Comment9 = Comment9,
		@Comment10 = Comment10,
		@Comment11 = Comment11,
		@Comment12 = Comment12,  
		@Comment13 = Comment13,
		@Comment14 = Comment14,
		@Comment15 = Comment15,
		@Comment16 = Comment16,
		@Comment17 = Comment17,
		@Comment18 = Comment18,
		@Comment19 = Comment19,
		@Comment20 = Comment20,
		@Comment21 = Comment21,
		@Comment22 = Comment22,
		@Comment23 = Comment23,
		@Comment24 = Comment24,
		@Comment25 = Comment25,
		@Comment26 = Comment26,
		@Comment27 = Comment27,
		@Comment28 = Comment28,
		@Comment29 = Comment29,
		@Comment30 = Comment30
		From #tmpCSCustomClasses
		

		Insert into @tmpCSIDs
		Select CSID
		From 
		ClassesStudents
		Where
		StudentID = @StudentID
		and
		ClassID = @ClassID
		

		-- Traverse all of the Students in the Custom ClassType
		While exists (Select * From @tmpCSIDs)
		Begin
			
			Select top 1
			@CSID = CSID
			From @tmpCSIDs
			
			
			
			Insert into @tmpCSCFIDs
			Select CSCFID
			from 	ClassesStudentsCF CSCF
						inner join CustomFields CF
						on CSCF.CustomFieldID = CF.CustomFieldID
			Where CSCF.CSID = @CSID and CF.ClassTypeID = @ClassTypeID			

				-- Traverse all of the Fields for the Student
				While exists (Select * From @tmpCSCFIDs)
				Begin
					
					Select top 1
					@CSCFID = CSCFID
					From @tmpCSCFIDs
					
					Insert into #UCReportCardData
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
						glname,
						StaffTitle,
						TFname,
						TLname,
						ClassID,
						ClassTitle,
						ReportOrder,
						ClassTypeID,
						ClassTypeID2,
						ParentClassID,
						SubCommentClassTypeID,
						CustomGradeScaleID,
						CustomFieldName,
						CustomFieldSpanishName,
						CustomFieldOrder,
						FieldBolded,
						FieldNotGraded,
						Indent,
						Bullet,
						GradeScaleLegend,
						--ReportSectionTitle,
						CustomFieldGrade,
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
						Comment30					
					)			
					Select
					@TermID as TermID,
					@ParentTermID as ParentTermID,
					@TermTitle as TermTitle,
					@TermReportTitle as TermReportTitle,
					@TermStart as TermStart,
					@TermEnd as TermEnd,
					@ExamTerm as ExamTerm,
					@StudentID as StudentID,
					@GradeLevel as GradeLevel,
					@Fname as Fname,
					@Mname as Mname,
					@Lname as Lname,
					@glname as glname,
					@StaffTitle as StaffTitle,
					@TFname as TFname,
					@TLname as TLname,
					@ClassID as ClassID,
					@ClassTitle as ClassTitle,
					@ReportOrder as ReportOrder,
					@ClassTypeID as ClassTypeID,
					1 as ClassTypeID2,
					@ParentClassID as ParentClassID,
					@SubCommentClassTypeID as SubCommentClassTypeID,
					0 as CustomGradeScaleID,	
					CF.CustomFieldName,
					CF.CustomFieldSpanishName,
					CF.CustomFieldOrder,
					CF.FieldBolded,
					CF.FieldNotGraded,
					CF.Indent,
					CF.Bullet,
					rtrim(dbo.getCustomGradeScaleLegend(@ClassTypeID)) as GradeScaleLegend,
					CSCF.CFGrade,
					CSCF.CFComments,
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
					@Comment30			
					From 
					CustomFields CF
						inner join
					ClassesStudentsCF CSCF
						on CF.CustomFieldID = CSCF.CustomFieldID
					Where CSCF.CSCFID = @CSCFID				
					
				
					Delete From @tmpCSCFIDs Where CSCFID = @CSCFID
				
				End		
				
		
		
			Delete From @tmpCSIDs Where CSID = @CSID
		
		End		
				
		-- remove orginal Custom class
		Delete From #UCReportCardData Where TranscriptID = @CCTranscriptID
	
		Delete From #tmpCSCustomClasses Where TableID = @TableID
	
	End
	
	
	--Select * From #UCReportCardData Order By ClassTypeID, ClassTitle, CustomFieldOrder
	
	
Drop table #tmpCSCustomClasses




insert into #ReportCardData
Select * From #UCReportCardData

Drop table #UCReportCardData




--------------------------------------------------------------------------------------
------------------------------End of Unconcluded Classes------------------------------
--------------------------------------------------------------------------------------

End

Else

Begin


	If @ReportType = 'Individual'
	Begin


		-- Populate Temp Table for a single Student
		Insert into #ReportCardData
		(
		[TranscriptID],
		[TermID],
		[ParentTermID],
		[ExamTerm],
		[TermTitle],
		[TermReportTitle],
		[TermStart],
		[TermEnd],
		[StudentID],
		[GradeLevel],
		[Fname],
		[Mname],
		[Lname],
		[glname],
		[StaffTitle],
		[TFname],
		[TLname],
		[TermComment],
		[ClassID],
		[ClassTitle],
		[SpanishTitle],
		[ReportOrder],
		[ClassTypeID],
		[ClassTypeID2],
		[ParentClassID],
		[SubCommentClassTypeID],
		[CustomGradeScaleID],
		[ClassUnits],
		[UnitsEarned],
		[LetterGrade],
		[AlternativeGrade],
		[PercentageGrade],
		[Effort],
		[UnitGPA],
		[CustomFieldName],
		[CustomFieldSpanishName],
		[CustomFieldGrade],
		[CustomFieldOrder],
		[FieldBolded],
		[FieldNotGraded],
		[GradeScaleLegend],
		[Indent],
		[Bullet],
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
		[GPABoost],
		[ConcludeDate],
		[ClassShowPercentageGrade],
		[StandardsItemType]
		)
		Select
		[TranscriptID],
		[TermID],
		[ParentTermID],
		[ExamTerm],
		[TermTitle],
		[TermReportTitle],
		[TermStart],
		[TermEnd],
		[StudentID],
		[GradeLevel],
		[Fname],
		ISNULL(Mname, ''),
		[Lname],
		[Sglname],
		[StaffTitle],
		[TFname],
		[TLname],
		case TermComment
			when '<P>&nbsp;</P>' then null
			when '<P>


</P>' then null
			when '<p>
<br mce_bogus="1">
</p>' then null
			when '<P> </P>' then null
			when '' then null
			else REPLACE(REPLACE(REPLACE(REPLACE(TermComment, '=atSymbol=', '@') , '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )
		end as [TermComment],
		[ClassID],
		case
			when ClassTypeID = 3 then 'Term Comments'
			when ClassTypeID = 5 then 'School Attendance'
			when ClassLevel is null then ClassTitle
			when ClassLevel = '' then ClassTitle
			When ClassLevel = ' ' then ClassTitle
			else ClassTitle + ' (' + dbo.T(0.0, ClassLevel) + ')'
		end	as [ClassTitle],
		case
			when SpanishTitle = '' then null
			else SpanishTitle
		end as SpanishTitle,
		[ReportOrder],
		ClassTypeID as [ClassTypeID],
		case
			when ClassTypeID = 5 then 5
			else 1
		end as [ClassTypeID2],
		case
			when ParentClassID > 0 then 1
			else 0
		end as [ParentClassID],
		[SubCommentClassTypeID],
		[CustomGradeScaleID],
		[ClassUnits],
		[UnitsEarned],
		case
			when ParentClassID > 0 then CustomFieldGrade
			else LetterGrade
		end as [LetterGrade],
		[AlternativeGrade],
		[PercentageGrade],
		[Effort],
		[UnitGPA],
		[CustomFieldName],
		[CustomFieldSpanishName],
		[CustomFieldGrade],
		[CustomFieldOrder],
		[FieldBolded],
		[FieldNotGraded],
		[GradeScaleLegend],
		[Indent],
		[Bullet],	
		replace(
			replace(ClassComments,' ',''),	-- First Remove spaces then replace commas with commas space (fixes issues where teach didn't put any spaces which are needed for proper breaking
			',', ', ')
			,
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
		[GPABoost],
		[ConcludeDate],
		(Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = T.CustomGradeScaleID) as ClassShowPercentageGrade,
		[StandardsItemType]
		From Transcript T
		Where 	
		TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
		and
		StudentID in (Select IntegerID From SplitCSVIntegers(@StudentIDs))
		and
		ClassTypeID !=  7	-- Exclude Sports Classes

	End
	Else
	Begin
		If @RunByClassSetting = 'yes'
		Begin

			Select StudentID
			into #Students
			From Transcript
			Where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
					and
					ClassID = @TheClassID
					and
					(case
						when @ActiveStudents < @InActiveStudents then 1 
						when StudentID in (Select StudentID From Students Where Active = 1) then 1
						else 0
					end) = 1
		
		
		
		-- Populate Temp Table for a single class
		Insert into #ReportCardData
		(
		[TranscriptID],
		[TermID],
		[ParentTermID],
		[ExamTerm],
		[TermTitle],
		[TermReportTitle],
		[TermStart],
		[TermEnd],
		[StudentID],
		[GradeLevel],
		[Fname],
		[Mname],
		[Lname],
		[glname],
		[StaffTitle],
		[TFname],
		[TLname],
		[TermComment],
		[ClassID],
		[ClassTitle],
		[SpanishTitle],
		[ReportOrder],
		[ClassTypeID],
		[ClassTypeID2],
		[ParentClassID],
		[SubCommentClassTypeID],
		[CustomGradeScaleID],
		[ClassUnits],
		[UnitsEarned],
		[LetterGrade],
		[AlternativeGrade],
		[PercentageGrade],
		[Effort],
		[UnitGPA],
		[CustomFieldName],
		[CustomFieldSpanishName],
		[CustomFieldGrade],
		[CustomFieldOrder],
		[FieldBolded],
		[FieldNotGraded],
		[GradeScaleLegend],
		[Indent],
		[Bullet],
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
		[GPABoost],
		[ConcludeDate],
		[ClassShowPercentageGrade],
		[StandardsItemType]
		)
		Select
		[TranscriptID],
		[TermID],
		[ParentTermID],
		[ExamTerm],
		[TermTitle],
		[TermReportTitle],
		[TermStart],
		[TermEnd],
		[StudentID],
		[GradeLevel],
		[Fname],
		ISNULL(Mname, ''),
		[Lname],
		[Sglname],
		[StaffTitle],
		[TFname],
		[TLname],
		case ltrim(rtrim(TermComment))
			when '<P>&nbsp;</P>' then null
			when '<P>


</P>' then null
			when '<p>
<br mce_bogus="1">
</p>' then null
			when '<P> </P>' then null
			when '' then null
			else REPLACE(REPLACE(REPLACE(REPLACE(TermComment, '=atSymbol=', '@') , '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )
		end as [TermComment],
		[ClassID],
		case
			when ClassTypeID = 3 then 'Term Comments'
			when ClassTypeID = 5 then 'School Attendance'
			when ClassLevel is null then ClassTitle
			when ClassLevel = '' then ClassTitle
			When ClassLevel = ' ' then ClassTitle
			else ClassTitle + ' (' + dbo.T(0.0, ClassLevel) + ')'
		end	as [ClassTitle],
		case
			when SpanishTitle = '' then null
			else SpanishTitle
		end as SpanishTitle,
		[ReportOrder],
		ClassTypeID as [ClassTypeID],
		case
			when ClassTypeID = 5 then 5
			else 1
		end as [ClassTypeID2],
		[ParentClassID],
		[SubCommentClassTypeID],
		[CustomGradeScaleID],
		[ClassUnits],
		[UnitsEarned],
		case
			when ParentClassID > 0 then CustomFieldGrade
			else LetterGrade
		end as [LetterGrade],
		[AlternativeGrade],
		[PercentageGrade],
		[Effort],
		[UnitGPA],
		[CustomFieldName],
		[CustomFieldSpanishName],
		[CustomFieldGrade],
		[CustomFieldOrder],
		[FieldBolded],
		[FieldNotGraded],
		[GradeScaleLegend],
		[Indent],
		[Bullet],
		replace(
			replace(ClassComments,' ',''),	-- First Remove spaces then replace commas with commas space (fixes issues where teach didn't put any spaces which are needed for proper breaking
			',', ', ')
			,
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
		[GPABoost],
		[ConcludeDate],
		(Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = T.CustomGradeScaleID) as ClassShowPercentageGrade,
		[StandardsItemType]
		From Transcript T
		Where 	
		TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
		and
		StudentID in (Select StudentID From #Students)
		and
		ClassTypeID !=  7	-- Exclude Sports Classes

		End
		Else
		Begin
		
		
		-- Populate Temp Table for all Students for a specific Gradelevel
		Insert into #ReportCardData
		(
		[TranscriptID],
		[TermID],
		[ParentTermID],
		[ExamTerm],
		[TermTitle],
		[TermReportTitle],
		[TermStart],
		[TermEnd],
		[StudentID],
		[GradeLevel],
		[Fname],
		[Mname],
		[Lname],
		[glname],
		[StaffTitle],
		[TFname],
		[TLname],
		[TermComment],
		[ClassID],
		[ClassTitle],
		[SpanishTitle],
		[ReportOrder],
		[ClassTypeID],
		[ClassTypeID2],
		[ParentClassID],
		[SubCommentClassTypeID],
		[CustomGradeScaleID],
		[ClassUnits],
		[UnitsEarned],
		[LetterGrade],
		[AlternativeGrade],
		[PercentageGrade],
		[Effort],
		[UnitGPA],
		[CustomFieldName],
		[CustomFieldSpanishName],
		[CustomFieldGrade],
		[CustomFieldOrder],
		[FieldBolded],
		[FieldNotGraded],
		[GradeScaleLegend],
		[Indent],
		[Bullet],
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
		[GPABoost],
		[ConcludeDate],
		[ClassShowPercentageGrade],
		[StandardsItemType]
		)
		Select
		[TranscriptID],
		[TermID],
		[ParentTermID],
		[ExamTerm],
		[TermTitle],
		[TermReportTitle],
		[TermStart],
		[TermEnd],
		[StudentID],
		[GradeLevel],
		[Fname],
		ISNULL(Mname, ''),
		[Lname],
		[Sglname],
		[StaffTitle],
		[TFname],
		[TLname],
		case TermComment
			when '<P>&nbsp;</P>' then null
			when '<P>


</P>' then null
			when '<p>
<br mce_bogus="1">
</p>' then null
			when '<P> </P>' then null
			when '' then null
			else REPLACE(REPLACE(REPLACE(REPLACE(TermComment, '=atSymbol=', '@') , '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )
		end as [TermComment],
		[ClassID],
		case
			when ClassTypeID = 3 then 'Term Comments'
			when ClassTypeID = 5 then 'School Attendance'
			when ClassLevel is null then ClassTitle
			when ClassLevel = '' then ClassTitle
			When ClassLevel = ' ' then ClassTitle
			else ClassTitle + ' (' + dbo.T(0.0, ClassLevel) + ')'
		end	as [ClassTitle],
		case
			when SpanishTitle = '' then null
			else SpanishTitle
		end as SpanishTitle,
		[ReportOrder],
		ClassTypeID as [ClassTypeID],
		case
			when ClassTypeID = 5 then 5
			else 1
		end as [ClassTypeID2],
		[ParentClassID],
		[SubCommentClassTypeID],
		[CustomGradeScaleID],
		[ClassUnits],
		[UnitsEarned],
		case
			when ParentClassID > 0 then CustomFieldGrade
			else LetterGrade
		end as [LetterGrade],
		[AlternativeGrade],
		[PercentageGrade],
		[Effort],
		[UnitGPA],
		[CustomFieldName],
		[CustomFieldSpanishName],
		[CustomFieldGrade],
		[CustomFieldOrder],
		[FieldBolded],
		[FieldNotGraded],
		[GradeScaleLegend],
		[Indent],
		[Bullet],
		replace(
			replace(ClassComments,' ',''),	-- First Remove spaces then replace commas with commas space (fixes issues where teach didn't put any spaces which are needed for proper breaking
			',', ', ')
			,
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
		[GPABoost],
		[ConcludeDate],
		(Select ShowPercentageGrade From CustomGradeScale Where CustomGradeScaleID = T.CustomGradeScaleID) as ClassShowPercentageGrade,
		[StandardsItemType]
		From Transcript T
		Where 	
		TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
		and
		GradeLevel = @Gradelevel
		and
		(case
			when @ActiveStudents < @InActiveStudents then 1 
			when StudentID in (Select StudentID From Students Where Active = 1) then 1
			else 0
		end) = 1
		and
		ClassTypeID !=  7	-- Exclude Sports Classes

		
		End

	End
	

End -- IF for Run on UNconcluded Classes 


---- Find the latest Term with Comments
Declare @LatestCommentTermID int

Select top 1
@LatestCommentTermID = TermID
From #ReportCardData
Where
ClassTypeID = 3
and
isnull(ltrim(rtrim(dbo.udf_StripHTML(TermComment))),'') != ''
Order By TermEnd desc

----------------------------------------------



Select
COUNT(*) as CommentCount,
MAX(TranscriptID) as TranscriptID,
StudentID,
TermID
into #tmpTermComments
From 
#ReportCardData
Where
ClassTypeID = 3
Group By StudentID, TermID



-- Remove null TermComments Classes
Delete From #ReportCardData
Where
ClassTypeID = 3
and
TranscriptID not in (Select TranscriptID From #tmpTermComments)



Declare @ReportOrderOfThirdColumn int
Set @ReportOrderOfThirdColumn = 1000






------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------------
----------------------------------- Get Report Profile Settings -----------------------------------------
---------------------------------------------------------------------------------------------------------



-- Declare All HTML Variables
Declare @TopFrontPageHTML nvarchar(max)
Declare @BottomFrontPageHTML nvarchar(max)
Declare @FrontPageGraphicHTML nvarchar(max)
Declare @InsideLeftSectionHTML nvarchar(max)
Declare @InsideRightSectionHTML nvarchar(max)
Declare @FrontPageHTML nvarchar(max)
Declare @AchievementCommentHTML nvarchar(max)
Declare @PrincipalSignatureHTML nvarchar(max)
Declare @BackPageHTML nvarchar(max)

-- Declare All Setting Variables
Declare @ShowGradePlacement nvarchar(20)
Declare @SecondColumnStartClass nvarchar(50)
Declare @ThirdColumnStartClass nvarchar(50)
Declare @ProfileTeacherName nvarchar(100)
Declare @ShowParentSignatureLine nvarchar(5)
Declare @PrincipalTeacherSignatureTitle nvarchar(100)
Declare @ClassTitleFontSize nvarchar(30)
Declare @SubgradeTitleFontSize nvarchar(30)
Declare @ClassSubgradeCellHeight nvarchar(30)
Declare @YearAvgTitle nvarchar(500)
Declare @ShowPrincipalSignature nvarchar(5)
Declare @ShowTeacherSignature nvarchar(5)
Declare @ShowNumberedComments nvarchar(5)
Declare @ShowTermComments nvarchar(5)
Declare @ShowYearAverageGrade nvarchar(5)
Declare @ShowTermGPA nvarchar(5)
Declare @ShowPercentageGrade nvarchar(5)
Declare @ShowSchoolAttendance nvarchar(5)
Declare @ShowWorshipAttendance nvarchar(5)
Declare @EnlargeFontAndSpacing nvarchar(5)
Declare @ShowTermPercentageAverage nvarchar(5)
Declare @CondenseClasses nvarchar(5)
Declare @ShowOverallGrade nvarchar(5)
Declare @ShowTenthDecimalPoint nvarchar(5)
Declare @BulletTopMargin nvarchar(5)
Declare @ShowTeacherName nvarchar(5)
Declare @TurnOffPreviewModeGraphic nvarchar(5)
Declare @ShowTeacherNameForEachSubject nvarchar(5)
Declare @ShowBothLetterAndPercentageGrade nvarchar(5)
Declare @ShowIncYearAverageIfIncTermGrade nvarchar(5) -- TFS 18556
Declare @DisplayGradeLevelAs nvarchar(30)
Declare @UseAttendanceClassForTeacherName nvarchar(5)
Declare @AllowDifferentClassUnits nvarchar(5)
Declare @TDLineHeight nvarchar(5)
Declare @WorshipAttendanceChurchTitle nvarchar(50)
Declare @WorshipAttendanceBibleClassTitle nvarchar(50)	
Declare @EnableLargeSingleTermCommentBox nvarchar(5)
Declare @GradeImageHeight nvarchar(10)
Declare @ShowTeacherNameOnTermComments bit
Declare @UseTermReportTitleOnTermComments nvarchar(10)
Declare @TurnOffBlackBackgrounds nvarchar(10)
Declare @PrincipalName nvarchar(100)
Declare @RenderWebpageInStandardsMode nvarchar(10)
Declare @PDFEngine nvarchar(10)


Declare @FooterHTML nvarchar(4000)
Declare @WatermarkHTML nvarchar(4000)
Declare @StandardClassesCustomLegendHTML nvarchar(4000)
Declare @SubgradeMarkAlignment nvarchar(10)

Declare @TopMargin nvarchar(20)
Declare @ShowAttendancePercentages nvarchar(5)
Declare @ShowGradeScaleForCustomClasses nvarchar(5)
Declare @SchoolAttendanceTitle nvarchar(50) 
Declare @GradeHeadingTitle nvarchar(30)
Declare @GradeHeadingAbbr nvarchar(5)
Declare @PageHeight nvarchar(10)

Declare @ForceSemesterGrade nvarchar(5)
Declare @ShowClassAttendance nvarchar(5)
Declare @ShowClassCredits nvarchar(5)
Declare @ShowClassEffort nvarchar(5)
Declare @ShowGradeScaleLegend nvarchar(5)
Declare @ShowSchoolNameAddress nvarchar(5)
Declare @ShowSubjectTeacherName nvarchar(5)
Declare @LeftAlignClassTitle nvarchar(5)
Declare @SemesterGradeAsLetterGrade nvarchar(5)
Declare @FootnoteText nvarchar(500)
Declare @PageBreak1 nvarchar(5)
Declare @PageBreak2 nvarchar(5)
Declare @PageBreak3 nvarchar(5)
Declare @PageBreak4 nvarchar(5)
Declare @PageBreak5 nvarchar(5)
Declare @PageBreaks nvarchar(50)
Declare @StandardClassesReportOrder tinyint
Declare @CustomClassesReportOrder tinyint
Declare @TermCommentsReportOrder tinyint
Declare @AttendanceReportOrder tinyint
Declare @ShowClassCategoryLegend nvarchar(5)
Declare @EnableSpanishSupport nvarchar(5)
Declare @EnableRightToLeft nvarchar(5)
Declare @AdjustNumCommentsWidth nvarchar(10)
Declare @CustomClassGradeColumnWidth nvarchar(10)
Declare @StandardClassGradeColumnWidth nvarchar(10)
Declare @CustomClassesSubjectHeadingText nvarchar(100)
Declare @StandardClassesSubjectHeadingText nvarchar(100)
Declare @AssignmentTypeSubgradeFormat nvarchar(10)
Declare @SubgradeNoGradeSymbol nvarchar(10)
Declare @EnableStartingNewColumnOnSubgrades nvarchar(10)
Declare @ShowStudentID nvarchar(10)
Declare @ShowStudentMailingAddressLabel nvarchar(10)
Declare @StudentMailingAddressLabelCSS nvarchar(200)



----------------------------- Populate Basic Settings Table ---------------------------------------
Declare @EndPosition int
Declare @StrLength int
Declare @StartPosition int
Declare @SettingName nvarchar(100)
Declare @SettingValue nvarchar(500)
Declare @BasicProfileSettings table (SettingName nvarchar(100) COLLATE DATABASE_DEFAULT, SettingValue nvarchar(500) COLLATE DATABASE_DEFAULT)

While (LEN(@ReportProfileSettings) > 0)
Begin

	--Get SettingName
	Set @EndPosition = PATINDEX ('%@%', @ReportProfileSettings) - 1
	Set @StartPosition = PATINDEX ('%@%', @ReportProfileSettings) + 1
	Set @SettingName = SUBSTRING (@ReportProfileSettings, 1, @EndPosition)
	Set @StrLength = LEN(@ReportProfileSettings)
	Set @ReportProfileSettings = SUBSTRING (@ReportProfileSettings, @StartPosition, @StrLength)
	
	--Get SettingValue
	Set @EndPosition = PATINDEX ('%@%', @ReportProfileSettings) - 1
	Set @StartPosition = PATINDEX ('%@%', @ReportProfileSettings) + 1
	Set @SettingValue = SUBSTRING (@ReportProfileSettings, 1, @EndPosition)
	Set @StrLength = LEN(@ReportProfileSettings)
	Set @ReportProfileSettings = SUBSTRING (@ReportProfileSettings, @StartPosition, @StrLength)

	Insert into @BasicProfileSettings
	Select 
	@SettingName,
	@SettingValue

End
----------------------------- Populate Basic Settings Table ---------------------------------------



-- Settings for all Report Cards


If @RunOnUnconcludedClassesCheckBox = 'on'
Begin
	Set @TurnOffPreviewModeGraphic = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Turn Off Preview Mode Warning Graphic')
End

Set @UseAttendanceClassForTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Use Attendance Class to get Teacher Name')
Set @TDLineHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'TD line-height (number only, e.g. 1.1)')
Set @GradeImageHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Grade Image Height')

Set @ShowGradePlacement = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowGradePlacement')

Set @AssignmentTypeSubgradeFormat = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'AssignmentType Subgrades Format(percentage, letter, both)')



If @DefaultName = 'Letter-Landscape Report Card'
Begin

	Set @TopFrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Top Front Page HTML')
	Set @BottomFrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Bottom Front Page HTML')
	Set @FrontPageGraphicHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page Graphic HTML')
	Set @InsideLeftSectionHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside Left Section HTML')
	Set @InsideRightSectionHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside Right Section HTML')
	Set @BackPageHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Back Page HTML')

	-- Remove line feed carriage returns 
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , CHAR(13) , '' )
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , CHAR(10) , '' )
	Set @BottomFrontPageHTML = REPLACE(@BottomFrontPageHTML , CHAR(13) , '' )
	Set @BottomFrontPageHTML = REPLACE(@BottomFrontPageHTML , CHAR(10) , '' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , CHAR(13) , '' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , CHAR(10) , '' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , CHAR(13) , '' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , CHAR(10) , '' )
	Set @InsideRightSectionHTML = REPLACE(@InsideRightSectionHTML , CHAR(13) , '' )
	Set @InsideRightSectionHTML = REPLACE(@InsideRightSectionHTML , CHAR(10) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(13) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , '''' , '\''' )
	Set @BottomFrontPageHTML = REPLACE(@BottomFrontPageHTML , '''' , '\''' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , '''' , '\''' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , '''' , '\''' )
	Set @InsideRightSectionHTML = REPLACE(@InsideRightSectionHTML , '''' , '\''' )
	Set @PrincipalTeacherSignatureTitle = REPLACE(@PrincipalTeacherSignatureTitle , '''' , '\''' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , '''' , '\''' )
	

	Set @TurnOffBlackBackgrounds = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Turn off Black Backgrounds')
	Set @SecondColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that second column of class grades starts')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowParentSignatureLine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Parent Signature Line')
	Set @PrincipalTeacherSignatureTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher/Principal Signature title')
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @YearAvgTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Year Avg. title')
	Set @YearAvgTitle = REPLACE(@YearAvgTitle , '''' , '\''' )
	Set @ShowTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name')
	Set @ShowTeacherNameForEachSubject = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name Next To Each Subject')

	Set @ShowBothLetterAndPercentageGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Both Letter Grade and Percentage Grade')
	Set @DisplayGradeLevelAs = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Display GradeLevel as')
	Set @AllowDifferentClassUnits = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Allow Different Class Unit Values Between Terms')
	Set @ShowTeacherSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Signature Line')
	Set @ShowOverallGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Overall Grade')	
	Set @WorshipAttendanceChurchTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Church Title')
	Set @WorshipAttendanceBibleClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Bible Class Title')
	Set @EnableLargeSingleTermCommentBox = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Large Single Term Comment Box (yes,no,split)')	
	Set @ShowTeacherNameOnTermComments = 
		case (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name on Term Comments')
			when 'yes' then 1
			else 0
		end
	Set @UseTermReportTitleOnTermComments = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Use TermReportTitle On TermComments')
	Set @SubgradeNoGradeSymbol = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Blank subgrade/standard/type symbol')

	
	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')
	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowWorshipAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowWorshipAttendance')
	Set @EnlargeFontAndSpacing = (Select SettingValue From @BasicProfileSettings Where SettingName = 'EnlargeFontandSpacing')

End

If @DefaultName = 'Multi-Term Two Column Report Card'
Begin
	
	Declare @TopLeftHTML nvarchar(max)
	Declare @BottomHTML nvarchar(max)
	Declare @NumberedCommentsHTML nvarchar(max)
	
	Set @TopLeftHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Top Left HTML')
	Set @BottomHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Bottom HTML')
	Set @NumberedCommentsHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Numbered Comments HTML')

	-- Remove line feed carriage returns 
	Set @TopLeftHTML = REPLACE(@TopLeftHTML , CHAR(13) , '' )
	Set @TopLeftHTML = REPLACE(@TopLeftHTML , CHAR(10) , '' )
	Set @BottomHTML = REPLACE(@BottomHTML , CHAR(13) , '' )
	Set @BottomHTML = REPLACE(@BottomHTML , CHAR(10) , '' )
	Set @NumberedCommentsHTML = REPLACE(@NumberedCommentsHTML , CHAR(13) , '' )
	Set @NumberedCommentsHTML = REPLACE(@NumberedCommentsHTML , CHAR(10) , '' )


	-- Replace single quotes with /' for javasript
	Set @TopLeftHTML = REPLACE(@TopLeftHTML , '''' , '\''' )
	Set @BottomHTML = REPLACE(@BottomHTML , '''' , '\''' )
	Set @NumberedCommentsHTML = REPLACE(@NumberedCommentsHTML , '''' , '\''' )
	
	Set @PrincipalName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Principal Name (leave blank to hide)')
	Set @TurnOffBlackBackgrounds = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Turn off Black Backgrounds')
	Set @SecondColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that second column of class grades starts')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowParentSignatureLine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Parent Signature Line')
	Set @PrincipalTeacherSignatureTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher/Principal Signature title')
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @YearAvgTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Year Avg. title')
	Set @YearAvgTitle = REPLACE(@YearAvgTitle , '''' , '\''' )
	Set @ShowTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name')
	Set @ShowTeacherNameForEachSubject = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name Next To Each Subject')
	Set @ShowBothLetterAndPercentageGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Both Letter Grade and Percentage Grade')
	Set @DisplayGradeLevelAs = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Display GradeLevel as')
	Set @AllowDifferentClassUnits = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Allow Different Class Unit Values Between Terms')
	Set @ShowTeacherSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Signature Line')
	Set @ShowOverallGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Overall Grade')	
	Set @WorshipAttendanceChurchTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Church Title')
	Set @WorshipAttendanceBibleClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Bible Class Title')
	Set @EnableLargeSingleTermCommentBox = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Large Single Term Comment Box (yes,no,split)')	
	Set @ShowTeacherNameOnTermComments = 
		case (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name on Term Comments')
			when 'yes' then 1
			else 0
		end
	Set @UseTermReportTitleOnTermComments = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Use TermReportTitle On TermComments')
	Set @EnableRightToLeft = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Right To Left')
	
	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')
	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowWorshipAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowWorshipAttendance')
	Set @EnlargeFontAndSpacing = (Select SettingValue From @BasicProfileSettings Where SettingName = 'EnlargeFontandSpacing')

End

If @DefaultName = 'Tri-fold Report Card'
Begin

	Set @FrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page HTML')
	Set @BackPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Back Page HTML')
	Set @PrincipalSignatureHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Principal Signature HTML')
	Set @AchievementCommentHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Achievement-Comment Legend HTML')


	-- Remove line feed carriage returns 
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , CHAR(13) , '' )
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , CHAR(10) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(13) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(10) , '' )
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(13) , '' )
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(10) , '' )
	Set @AchievementCommentHTML = REPLACE(@AchievementCommentHTML , CHAR(13) , '' )
	Set @AchievementCommentHTML = REPLACE(@AchievementCommentHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , '''' , '\''' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , '''' , '\''' )
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , '''' , '\''' )
	Set @AchievementCommentHTML = REPLACE(@AchievementCommentHTML , '''' , '\''' )

	Set @SecondColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that second column of class grades starts')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowPrincipalSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show principal signature')
	Set @ShowTeacherSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show teacher signature')
	Set @ShowParentSignatureLine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show parent signature')
	Set @AllowDifferentClassUnits = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Allow Different Class Unit Values Between Terms')	
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @ShowTeacherNameForEachSubject = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name Next To Each Subject')

	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')
	Set @CondenseClasses = (Select SettingValue From @BasicProfileSettings Where SettingName = 'CondenseClasses')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowTermPercentageAverage = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermPercentageAverage')
	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')

End


If @DefaultName = 'Legal-Landscape Report Card'
Begin

	Declare @TopLeftTitleHTML nvarchar(4000)
	Declare @TopLeftGraphicHTML nvarchar(4000)
	Declare @TopRightTitleHTML nvarchar(4000)
	Declare @EvaluationKeyHTML nvarchar(4000)
	Declare @TeacherSignatureHTML nvarchar(4000)
	Declare @BackgroundImageHTML nvarchar(1000)
	Declare @SchoolworkAffected nvarchar(5)
	

	Set @TopLeftTitleHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Top Left Title HTML')
	Set @TopLeftGraphicHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Top Left Graphic HTML')
	Set @TopRightTitleHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Top Right Title HTML')
	Set @EvaluationKeyHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Evaluation Key HTML')
	Set @TeacherSignatureHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Teacher Signature HTML')
	Set @BackgroundImageHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Background Image HTML')

	-- Remove line feed carriage returns 
	Set @TopLeftTitleHTML = REPLACE(@TopLeftTitleHTML , CHAR(13) , '' )
	Set @TopLeftTitleHTML = REPLACE(@TopLeftTitleHTML , CHAR(10) , '' )
	Set @TopLeftGraphicHTML = REPLACE(@TopLeftGraphicHTML , CHAR(13) , '' )
	Set @TopLeftGraphicHTML = REPLACE(@TopLeftGraphicHTML , CHAR(10) , '' )
	Set @TopRightTitleHTML = REPLACE(@TopRightTitleHTML , CHAR(13) , '' )
	Set @TopRightTitleHTML = REPLACE(@TopRightTitleHTML , CHAR(10) , '' )
	Set @EvaluationKeyHTML = REPLACE(@EvaluationKeyHTML , CHAR(13) , '' )
	Set @EvaluationKeyHTML = REPLACE(@EvaluationKeyHTML , CHAR(10) , '' )
	Set @TeacherSignatureHTML = REPLACE(@TeacherSignatureHTML , CHAR(13) , '' )
	Set @TeacherSignatureHTML = REPLACE(@TeacherSignatureHTML , CHAR(10) , '' )
	Set @BackgroundImageHTML = REPLACE(@BackgroundImageHTML , CHAR(13) , '' )
	Set @BackgroundImageHTML = REPLACE(@BackgroundImageHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @TopLeftTitleHTML = REPLACE(@TopLeftTitleHTML , '''' , '\''' )
	Set @TopLeftGraphicHTML = REPLACE(@TopLeftGraphicHTML , '''' , '\''' )
	Set @TopRightTitleHTML = REPLACE(@TopRightTitleHTML , '''' , '\''' )
	Set @EvaluationKeyHTML = REPLACE(@EvaluationKeyHTML , '''' , '\''' )
	Set @TeacherSignatureHTML = REPLACE(@TeacherSignatureHTML , '''' , '\''' )
	Set @BackgroundImageHTML = REPLACE(@BackgroundImageHTML , '''' , '\''' )

	Declare @LastCommentNumberToBold int
	
	Set @SecondColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that second column of class grades starts')
	Set @ThirdColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that third column of class grades starts')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @LastCommentNumberToBold = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Last comment number to bold')
	
	Set @SchoolworkAffected = (Select SettingValue From @BasicProfileSettings Where SettingName = 'Show(Schoolworkaffectedbyattendance)box')
	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')

End


If @DefaultName = 'Spanish Report Card'
Begin



	Set @TopFrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Top Front Page HTML')
	Set @BottomFrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Bottom Front Page HTML')
	Set @BackPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Back Page HTML')
	Set @InsideLeftSectionHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside Left HTML')


	-- Remove line feed carriage returns 
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , CHAR(13) , '' )
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , CHAR(10) , '' )
	Set @BottomFrontPageHTML = REPLACE(@BottomFrontPageHTML , CHAR(13) , '' )
	Set @BottomFrontPageHTML = REPLACE(@BottomFrontPageHTML , CHAR(10) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(13) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(10) , '' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , CHAR(13) , '' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , '''' , '\''' )
	Set @BottomFrontPageHTML = REPLACE(@BottomFrontPageHTML , '''' , '\''' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , '''' , '\''' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , '''' , '\''' )

	Set @SecondColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that second column of class grades starts')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowPrincipalSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show principal signature')
	Set @ShowTeacherSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show teacher signature')
	Set @ShowParentSignatureLine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show parent signature')
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @DisplayGradeLevelAs = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Display GradeLevel as')
	Set @CondenseClasses = (Select SettingValue From @BasicProfileSettings Where SettingName = 'CondenseClasses')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowTermPercentageAverage = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermPercentageAverage')
	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')


End


If @DefaultName = 'Letter-Landscape2 Report Card'
Begin

	Declare @InsideTopLeftHTML nvarchar(4000)
	Declare @InsideMiddleLeftHTML nvarchar(4000)
	Declare @InsideBottomLeftHTML nvarchar(4000)
	Declare @InsideTopRightHTML nvarchar(4000)
	Declare @InsideMiddleRightHTML nvarchar(4000)	
	Declare @BackPageMiddleHTML nvarchar(4000)
	Declare @BackPageBottomHTML nvarchar(4000)
	Declare @ShowInsideTopLeftStudentInfo nvarchar(10)
	Declare @ShowGeneralAverageGrade nvarchar(10)
	Declare @HideEndofYearGradeColumn nvarchar(5)
	Declare @CustomClassTypesOnInsideRight nvarchar(5)
	Declare @ADPFormat nvarchar(5)
	Declare @ShowLetterGradeWhenF nvarchar(5)
	Declare @ShowEnglishLanguageArtsHeaderRow nvarchar(5)

	Set @FrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page HTML')
	Set @BackPageMiddleHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Back Page Middle HTML')
	Set @BackPageBottomHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Back Page Bottom HTML')
	Set @InsideTopLeftHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside TopLeft HTML')
	Set @InsideMiddleLeftHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside MiddleLeft HTML')
	Set @InsideBottomLeftHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside BottomLeft HTML')
	Set @InsideTopRightHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside TopRight HTML')
	Set @InsideMiddleRightHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside MiddleRight HTML')
	
	-- Remove line feed carriage returns 
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , CHAR(13) , '' )
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , CHAR(10) , '' )
	Set @BackPageMiddleHTML = REPLACE(@BackPageMiddleHTML , CHAR(13) , '' )
	Set @BackPageMiddleHTML = REPLACE(@BackPageMiddleHTML , CHAR(10) , '' )
	Set @BackPageBottomHTML = REPLACE(@BackPageBottomHTML , CHAR(13) , '' )
	Set @BackPageBottomHTML = REPLACE(@BackPageBottomHTML , CHAR(10) , '' )	
	Set @InsideTopLeftHTML = REPLACE(@InsideTopLeftHTML , CHAR(13) , '' )
	Set @InsideTopLeftHTML = REPLACE(@InsideTopLeftHTML , CHAR(10) , '' )
	Set @InsideMiddleLeftHTML = REPLACE(@InsideMiddleLeftHTML , CHAR(13) , '' )
	Set @InsideMiddleLeftHTML = REPLACE(@InsideMiddleLeftHTML , CHAR(10) , '' )
	Set @InsideBottomLeftHTML = REPLACE(@InsideBottomLeftHTML , CHAR(13) , '' )
	Set @InsideBottomLeftHTML = REPLACE(@InsideBottomLeftHTML , CHAR(10) , '' )	
	Set @InsideTopRightHTML = REPLACE(@InsideTopRightHTML , CHAR(13) , '' )
	Set @InsideTopRightHTML = REPLACE(@InsideTopRightHTML , CHAR(10) , '' )
	Set @InsideMiddleRightHTML = REPLACE(@InsideMiddleRightHTML , CHAR(13) , '' )
	Set @InsideMiddleRightHTML = REPLACE(@InsideMiddleRightHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , '''' , '\''' )
	Set @BackPageMiddleHTML = REPLACE(@BackPageMiddleHTML , '''' , '\''' )
	Set @InsideTopLeftHTML = REPLACE(@InsideTopLeftHTML , '''' , '\''' )
	Set @InsideMiddleLeftHTML = REPLACE(@InsideMiddleLeftHTML , '''' , '\''' )
	Set @InsideBottomLeftHTML = REPLACE(@InsideBottomLeftHTML , '''' , '\''' )
	Set @InsideTopRightHTML = REPLACE(@InsideTopRightHTML , '''' , '\''' )
	Set @InsideMiddleRightHTML = REPLACE(@InsideMiddleRightHTML , '''' , '\''' )	

	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowTenthDecimalPoint = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show the Trimester Grades to the tenth decimal point')
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @YearAvgTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Year Avg. title')
	Set @ShowTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name')
	Set @ShowTeacherNameForEachSubject = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name Next To Each Subject')
	Set @ShowBothLetterAndPercentageGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Both Letter Grade and Percentage Grade')
	Set @DisplayGradeLevelAs = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Display GradeLevel as')
	Set @ShowInsideTopLeftStudentInfo = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Inside top-left Student Info')
	Set @ShowGeneralAverageGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show General Average Grade')
	Set @PrincipalName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Principal Name (leave blank to hide)')
	Set @HideEndofYearGradeColumn = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Hide End of Year Grade Column')
	Set @CustomClassTypesOnInsideRight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Custom Class Types on Inside Right')
	Set @ADPFormat = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'ADP Format')
	Set @ShowLetterGradeWhenF = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Letter Grade when Letter Grade is F')
	Set @TurnOffBlackBackgrounds = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Turn off Black Backgrounds')
	Set @ShowEnglishLanguageArtsHeaderRow = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Add ENGLISH LANGUAGE ARTS header row')

	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')


End

If @DefaultName = 'Tri-fold2 Report Card'
Begin

	Declare @LeftBackPageHTML nvarchar(4000)
	Declare @MiddleBackPageHTML nvarchar(4000)

	Set @TopFrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page HTML')
	Set @LeftBackPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Left Back Page HTML')
	Set @MiddleBackPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Middle Back Page HTML')
	Set @InsideLeftSectionHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside Left Section HTML')
	Set @InsideRightSectionHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Inside Right Section HTML')

	-- Remove line feed carriage returns 
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , CHAR(13) , '' )
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , CHAR(10) , '' )
	Set @LeftBackPageHTML = REPLACE(@LeftBackPageHTML , CHAR(13) , '' )
	Set @LeftBackPageHTML = REPLACE(@LeftBackPageHTML , CHAR(10) , '' )
	Set @MiddleBackPageHTML = REPLACE(@MiddleBackPageHTML , CHAR(13) , '' )
	Set @MiddleBackPageHTML = REPLACE(@MiddleBackPageHTML , CHAR(10) , '' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , CHAR(13) , '' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , CHAR(10) , '' )
	Set @InsideRightSectionHTML = REPLACE(@InsideRightSectionHTML , CHAR(13) , '' )
	Set @InsideRightSectionHTML = REPLACE(@InsideRightSectionHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @TopFrontPageHTML = REPLACE(@TopFrontPageHTML , '''' , '\''' )
	Set @LeftBackPageHTML = REPLACE(@LeftBackPageHTML , '''' , '\''' )
	Set @MiddleBackPageHTML = REPLACE(@MiddleBackPageHTML , '''' , '\''' )
	Set @InsideLeftSectionHTML = REPLACE(@InsideLeftSectionHTML , '''' , '\''' )
	Set @InsideRightSectionHTML = REPLACE(@InsideRightSectionHTML , '''' , '\''' )

	Set @SecondColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that second column of class grades starts')
	Set @ThirdColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that third column of class grades starts')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowTenthDecimalPoint = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show the Trimester Grades to the tenth decimal point')

	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')


	Set @ReportOrderOfThirdColumn = (Select top 1 ReportOrder From #ReportCardData Where ClassTitle = @ThirdColumnStartClass)


End


If @DefaultName = 'Tri-fold3 Report Card'
Begin


	Set @FrontPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page HTML')
	Set @BackPageHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Back Page HTML')
	Set @AchievementCommentHTML  = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Achievement-Comment Legend HTML')

	-- Remove line feed carriage returns 
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , CHAR(13) , '' )
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , CHAR(10) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(13) , '' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , CHAR(10) , '' )
	Set @AchievementCommentHTML = REPLACE(@AchievementCommentHTML , CHAR(13) , '' )
	Set @AchievementCommentHTML = REPLACE(@AchievementCommentHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @FrontPageHTML = REPLACE(@FrontPageHTML , '''' , '\''' )
	Set @BackPageHTML = REPLACE(@BackPageHTML , '''' , '\''' )
	Set @AchievementCommentHTML = REPLACE(@AchievementCommentHTML , '''' , '\''' )

	Set @SecondColumnStartClass = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title that second column of class grades starts')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @ShowOverallGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Overall Grade')
	Set @ShowPrincipalSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Principal Signature Line')
	Set @BulletTopMargin = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Bullet - Top Margin')
	Set @ShowTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name')
	Set @ShowTeacherNameForEachSubject = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name Next To Each Subject')
	Set @ShowBothLetterAndPercentageGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Both Letter Grade and Percentage Grade')
	Set @DisplayGradeLevelAs = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Display GradeLevel as')
	Set @AllowDifferentClassUnits = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Allow Different Class Unit Values Between Terms')
	Set @EnableLargeSingleTermCommentBox = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Large Single Term Comment Box (yes,no,split)')	
	Set @ShowTeacherNameOnTermComments = 
		case (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name on Term Comments')
			when 'yes' then 1
			else 0
		end		
	Set @YearAvgTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Year Avg. title')
	Set @YearAvgTitle = REPLACE(@YearAvgTitle , '''' , '\''' )

	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')
	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')

End

If @DefaultName = 'Multi-Term Report Card'
Begin

	Declare @StandardClassPageBreakTitle nvarchar(50)
	Declare @StandardClassPageBreakTitle2 nvarchar(50)
	Declare @StandardClassPageBreakTitle3 nvarchar(50)
	Declare @StandardClassPageBreakTitle4 nvarchar(50)
	Declare @StandardClassPageBreakTitle5 nvarchar(50)

	Declare @CustomHTMLSectionAboveStandardClassTitle nvarchar(50)
	Declare @HideGradeLevel nvarchar(5)
	Declare @StandardClassesCustomHTMLSection nvarchar(max)
	Declare @GradeLevelLabelText nvarchar(50)
	Declare @ShowClassAttendanceTotals nvarchar(5)
	Declare @OverwriteTermTitle nvarchar(100)
	Declare @ShowDivision bit
	Declare @AddPageBreakBeforeClassAttendance nvarchar(5)
	Declare @TeacherLabelText nvarchar(30)
	Declare @YearAvgAlign nvarchar(10)

	Set @PrincipalSignatureHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Principal Signature HTML')
	Set @FrontPageGraphicHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page Graphic HTML')
	Set @FooterHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Footer HTML')
	Set @WatermarkHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Watermark HTML')
	Set @StandardClassesCustomLegendHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Standard Classes Custom Legend HTML')
	Set @StandardClassesCustomHTMLSection = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Standard Classes Custom HTML Section')

	-- Remove line feed carriage returns 
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(13) , '' )
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(10) , '' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , CHAR(13) , '' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , CHAR(10) , '' )
	Set @FooterHTML = REPLACE(@FooterHTML , CHAR(13) , '' )
	Set @FooterHTML = REPLACE(@FooterHTML , CHAR(10) , '' )
	Set @WatermarkHTML = REPLACE(@WatermarkHTML , CHAR(13) , '' )
	Set @WatermarkHTML = REPLACE(@WatermarkHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , '''' , '\''' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , '''' , '\''' )
	Set @FooterHTML = REPLACE(@FooterHTML , '''' , '\''' )
	Set @WatermarkHTML = REPLACE(@WatermarkHTML , '''' , '\''' )

  
	Set @TopMargin = 
	(
	Select
	case
		when patindex('%px%', SettingValue) = 0 then SettingValue + 'px'
		else SettingValue
	end 
	From ReportSettings 
	Where 
	ProfileID = @ProfileID 
	and 
	SettingName = 'Top Margin'
	)
	
	
	
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowAttendancePercentages = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Attendance Percentages')
	Set @WorshipAttendanceChurchTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Church Title')
	Set @WorshipAttendanceBibleClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Bible Class Title')
	Set @ShowGradeScaleForCustomClasses = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Grade Scale for Custom Classes')					

	Set @ShowPrincipalSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Principal Signature')
	Set @ShowTeacherSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Signature')
	Set @ShowParentSignatureLine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Parent Signature')
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @SchoolAttendanceTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'School Attendance Title')
	Set @ShowTeacherNameOnTermComments = 
		case (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name on Term Comments')
			when 'yes' then 1
			else 0
		end
	Set @ShowDivision = 
		case (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Division in GradeLevel')
			when 'yes' then 1
			else 0
		end		
	Set @GradeHeadingTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Grade Scale Legend Title')
	Set @GradeHeadingAbbr = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Grade Heading Abbreviation')
	Set @PageHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page Height (Letter:1005px Legal:1295px)')
	Set @LeftAlignClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Align Class Titles to the Left')
	Set @SemesterGradeAsLetterGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Semester Grade as a Letter Grade')
	Set @ShowBothLetterAndPercentageGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Both Letter Grade and Percentage Grade')
	Set @DisplayGradeLevelAs = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Display GradeLevel as')
	Set @ShowClassCategoryLegend = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Class Category Legend')
	Set @AllowDifferentClassUnits = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Allow Different Class Unit Values Between Terms')
	Set @EnableSpanishSupport = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable bilingual Spanish Support')
	Set @EnableRightToLeft = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Right To Left')
	Set @EnableLargeSingleTermCommentBox = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Large Single Term Comment Box (yes,no,split)')
	Set @SubgradeMarkAlignment = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade Mark alignment (left,right,center)')
	Set @FootnoteText = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Footnote Text')
	Set @ShowTermPercentageAverage = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Term Percentage Average')
	set @StandardClassPageBreakTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Insert Page-Break on Standard Class Title')
	set @StandardClassPageBreakTitle2 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Insert Page-Break on Standard Class Title 2')
	set @StandardClassPageBreakTitle3 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Insert Page-Break on Standard Class Title 3')
	set @StandardClassPageBreakTitle4 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Insert Page-Break on Standard Class Title 4')
	set @StandardClassPageBreakTitle5 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Insert Page-Break on Standard Class Title 5')

	set @AdjustNumCommentsWidth = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Adjust #Comments width (blank is default)')
	set @RenderWebpageInStandardsMode = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Render Webpage in Standards Mode')
	set @PDFEngine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'PDF Engine(ex.IE, Mozilla, blank is default)')
	set @CustomClassGradeColumnWidth = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Custom Class Grade Column Width')
	set @StandardClassGradeColumnWidth = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Standard Class Grade Column Width (blank is default)')
	set @StandardClassesSubjectHeadingText = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Standard Classes Subject Heading Text')			
	set @CustomHTMLSectionAboveStandardClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Custom HTML Section Above Standard Class Title')			
	set @HideGradeLevel = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Hide Grade Level')			
	Set @ShowOverallGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Overall Grade')
	Set @TurnOffBlackBackgrounds = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Turn off Black Backgrounds')
	Set @YearAvgTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Year Avg. title')
	Set @SubgradeNoGradeSymbol = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Blank subgrade/standard/type symbol')
	Set @GradeLevelLabelText = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Grade Level Label Text')
	Set @ShowClassAttendanceTotals = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Class Attendance Totals')
	Set @OverwriteTermTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Overwrite TermTitle With')
	Set @AddPageBreakBeforeClassAttendance = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Add Page Break Before ClassAttendance')
	Set @ShowTenthDecimalPoint = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Percentage grades to the 10th decimal')
	Set @ShowStudentID = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Student ID')
	Set @ShowStudentMailingAddressLabel = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Student Mailing Address Label')
	Set @StudentMailingAddressLabelCSS = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Student Mailing Address Label CSS')
	Set @TeacherLabelText = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Label Text')
	Set @YearAvgAlign = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Year Average grade alignment (left,right,center)')
	Declare @ShowGPAasaPercentage nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show GPA as a Percentage')

	Set @ShowIncYearAverageIfIncTermGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Year Average as Inc If Any Inc Term Grades') -- zoho 18556, Duke 4/08/2015

	Set @ForceSemesterGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ForceSemesterGrade')
	Set @ShowClassAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowClassAttendance')
	Set @ShowClassCredits = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowClassCredits')
	Set @ShowClassEffort = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowClassEffort')
	Set @ShowGradeScaleLegend = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowGradeScaleLegend')
	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowSchoolNameAddress = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolName/Address')
	Set @ShowTeacherName = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTeacherName')
	Set @ShowSubjectTeacherName = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSubjectTeacherName')
	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowWorshipAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowWorshipAttendance')
	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')
	Set @PageBreak1 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak1')
	Set @PageBreak2 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak2')
	Set @PageBreak3 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak3')
	Set @PageBreak4 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak4')
	Set @PageBreak5 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak5')
	Set @StandardClassesReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'StandardClassesReportOrder')
	Set @CustomClassesReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'CustomClassesReportOrder')
	Set @TermCommentsReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'TermCommentsReportOrder')
	Set @AttendanceReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'AttendanceReportOrder')



	

	-- Set PageBreaks
	Set @PageBreaks = ','
	If @PageBreak1 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak1 + ','
	End
	If @PageBreak2 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak2 + ','
	End
	If @PageBreak3 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak3 + ','
	End
	If @PageBreak4 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak4 + ','
	End
	If @PageBreak5 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak5 + ','
	End
	
	
End


If	@DefaultName = 'Multi-Term Two Column Report Card 2' 
Begin



	Set @TopMargin = 
	(
	Select
	case
		when patindex('%px%', SettingValue) = 0 then SettingValue + 'px'
		else SettingValue
	end 
	From ReportSettings 
	Where 
	ProfileID = @ProfileID 
	and 
	SettingName = 'Top Margin'
	)

	Set @PrincipalSignatureHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Principal Signature HTML')
	Set @FrontPageGraphicHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page Graphic HTML')
	Set @FooterHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Footer HTML')
	Set @WatermarkHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Watermark HTML')
	Set @StandardClassesCustomLegendHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Standard Classes Custom Legend HTML')

	-- Remove line feed carriage returns 
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(13) , '' )
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , CHAR(10) , '' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , CHAR(13) , '' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , CHAR(10) , '' )
	Set @FooterHTML = REPLACE(@FooterHTML , CHAR(13) , '' )
	Set @FooterHTML = REPLACE(@FooterHTML , CHAR(10) , '' )
	Set @WatermarkHTML = REPLACE(@WatermarkHTML , CHAR(13) , '' )
	Set @WatermarkHTML = REPLACE(@WatermarkHTML , CHAR(10) , '' )

	-- Replace single quotes with /' for javasript
	Set @PrincipalSignatureHTML = REPLACE(@PrincipalSignatureHTML , '''' , '\''' )
	Set @FrontPageGraphicHTML = REPLACE(@FrontPageGraphicHTML , '''' , '\''' )
	Set @FooterHTML = REPLACE(@FooterHTML , '''' , '\''' )
	Set @WatermarkHTML = REPLACE(@WatermarkHTML , '''' , '\''' )
	

	Declare @StartRightColumnStandardClassTitle1 nvarchar(50)
	Declare @StartRightColumnStandardClassTitle2 nvarchar(50)
	Declare @StartRightColumnStandardClassTitle3 nvarchar(50)
	Declare @StartRightColumnStandardClassTitle4 nvarchar(50)
	Declare @StartRightColumnStandardClassTitle5 nvarchar(50)
	Declare @PageBreakbeforeStandardClassTitle1 nvarchar(50)
	Declare @PageBreakbeforeStandardClassTitle2 nvarchar(50)
	Declare @PageBreakbeforeStandardClassTitle3 nvarchar(50)
	Declare @PageBreakbeforeStandardClassTitle4 nvarchar(50)
	Declare @PageBreakbeforeStandardClassTitle5 nvarchar(50)
	Declare @StartRightColumnCustomClassTitle1 nvarchar(50)
	Declare @StartRightColumnCustomClassTitle2 nvarchar(50)
	Declare @StartRightColumnCustomClassTitle3 nvarchar(50)
	Declare @StartRightColumnCustomClassTitle4 nvarchar(50)
	Declare @StartRightColumnCustomClassTitle5 nvarchar(50)
	Declare @PageBreakbeforeCustomClassTitle1 nvarchar(50)
	Declare @PageBreakbeforeCustomClassTitle2 nvarchar(50)
	Declare @PageBreakbeforeCustomClassTitle3 nvarchar(50)
	Declare @PageBreakbeforeCustomClassTitle4 nvarchar(50)
	Declare @PageBreakbeforeCustomClassTitle5 nvarchar(50)
	Declare @StandardsCategoryFormat nvarchar(20)
	Declare @StandardsSubCategoryFormat nvarchar(20)
	Declare @StandardsMarzanoTopicFormat nvarchar(20)
	Declare @ShowGradesAffectedAttendanceBox nvarchar(3)
	Declare @ShowGPA nvarchar(3)
	Declare @ShowGPATableCSS nvarchar(200)
  
	Set @TopMargin = 
	(
	Select
	case
		when patindex('%px%', SettingValue) = 0 then SettingValue + 'px'
		else SettingValue
	end 
	From ReportSettings 
	Where 
	ProfileID = @ProfileID 
	and 
	SettingName = 'Top Margin'
	)
	
	
	Set @TurnOffBlackBackgrounds = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Turn off Black Backgrounds')
	Set @ProfileTeacherName = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Teacher Name')
	Set @ShowAttendancePercentages = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Attendance Percentages')
	Set @WorshipAttendanceChurchTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Church Title')
	Set @WorshipAttendanceBibleClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Worship Attendance - Bible Class Title')
	Set @ShowGradeScaleForCustomClasses = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Grade Scale for Custom Classes')					

	Set @ShowPrincipalSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Principal Signature')
	Set @ShowTeacherSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Signature')
	Set @ShowParentSignatureLine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Parent Signature')
	Set @ClassTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class title font size')
	Set @SubgradeTitleFontSize = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade title font size')
	Set @ClassSubgradeCellHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Class and sub-grade cell height')
	Set @SchoolAttendanceTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'School Attendance Title')
	Set @ShowTeacherNameOnTermComments = 
		case (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Teacher Name on Term Comments')
			when 'yes' then 1
			else 0
		end
	Set @ShowOverallGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Overall Grade')		
	Set @GradeHeadingTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Grade Scale Legend Title')
	Set @GradeHeadingAbbr = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Grade Heading Abbreviation')
	Set @PageHeight = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page Height (Letter:1005px Legal:1295px)')
	Set @LeftAlignClassTitle = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Align Class Titles to the Left')
	Set @SemesterGradeAsLetterGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Semester Grade as a Letter Grade')
	Set @ShowBothLetterAndPercentageGrade = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Both Letter Grade and Percentage Grade')
	Set @DisplayGradeLevelAs = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Display GradeLevel as')
	Set @ShowClassCategoryLegend = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Class Category Legend')
	Set @AllowDifferentClassUnits = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Allow Different Class Unit Values Between Terms')
	Set @EnableSpanishSupport = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable bilingual Spanish Support')
	Set @EnableRightToLeft = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Right To Left')
	Set @EnableLargeSingleTermCommentBox = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Large Single Term Comment Box (yes,no,split)')
	Set @SubgradeMarkAlignment = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Sub-grade Mark alignment (left,right,center)')
	Set @FootnoteText = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Footnote Text')
	Set @ShowTermPercentageAverage = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show Term Percentage Average')
	set @AdjustNumCommentsWidth = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Adjust #Comments width (blank is default)')
	set @RenderWebpageInStandardsMode = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Render Webpage in Standards Mode')
	set @PDFEngine = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'PDF Engine(ex.IE, Mozilla, blank is default)')
	set @CustomClassGradeColumnWidth = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Custom Class Grade Column Width')
	set @StandardClassGradeColumnWidth = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Standard Class Grade Column Width')
	set @StartRightColumnStandardClassTitle1 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Standard Class Title1')
	set @StartRightColumnStandardClassTitle2 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Standard Class Title2')
	set @StartRightColumnStandardClassTitle3 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Standard Class Title3')
	set @StartRightColumnStandardClassTitle4 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Standard Class Title4')
	set @StartRightColumnStandardClassTitle5 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Standard Class Title5')
	set @PageBreakbeforeStandardClassTitle1 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Standard Class Title1')	
	set @PageBreakbeforeStandardClassTitle2 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Standard Class Title2')	
	set @PageBreakbeforeStandardClassTitle3 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Standard Class Title3')	
	set @PageBreakbeforeStandardClassTitle4 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Standard Class Title4')	
	set @PageBreakbeforeStandardClassTitle5 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Standard Class Title5')	
	set @StartRightColumnCustomClassTitle1 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Custom Class Title1')	
	set @StartRightColumnCustomClassTitle2 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Custom Class Title2')	
	set @StartRightColumnCustomClassTitle3 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Custom Class Title3')	
	set @StartRightColumnCustomClassTitle4 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Custom Class Title4')	
	set @StartRightColumnCustomClassTitle5 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Start Right Column Custom Class Title5')	
	set @PageBreakbeforeCustomClassTitle1 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Custom Class Title1')	
	set @PageBreakbeforeCustomClassTitle2 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Custom Class Title2')	
	set @PageBreakbeforeCustomClassTitle3 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Custom Class Title3')	
	set @PageBreakbeforeCustomClassTitle4 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Custom Class Title4')	
	set @PageBreakbeforeCustomClassTitle5 = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Page-Break before Custom Class Title5')	
	set @CustomClassesSubjectHeadingText = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Custom Classes Subject Heading Text')	
	set @StandardClassesSubjectHeadingText = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Standard Classes Subject Heading Text')
	set @StandardsCategoryFormat = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Standards Category Format(GrayBG,Bold)')
	set @StandardsMarzanoTopicFormat = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Standards Marzano Topic Format(GrayBG,Bold)')

	set @StandardsSubCategoryFormat = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Standards SubCategory Format(GrayBG,Bold)')
	Set @SubgradeNoGradeSymbol = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Blank subgrade/standard/type symbol')
	Set @EnableStartingNewColumnOnSubgrades = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Enable Starting New Column on Subgrades')
	Set @ShowGradesAffectedAttendanceBox = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show (Grades affected by attendance) box')
	Set @ShowGPA = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show GPA')
	Set @ShowGPATableCSS = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Show GPA Table CSS')




	Set @ForceSemesterGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ForceSemesterGrade')
	Set @ShowClassAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowClassAttendance')
	Set @ShowClassCredits = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowClassCredits')
	Set @ShowClassEffort = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowClassEffort')
	Set @ShowGradeScaleLegend = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowGradeScaleLegend')
	Set @ShowNumberedComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowNumberedComments')
	Set @ShowPercentageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowPercentageGrade')
	Set @ShowSchoolAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolAttendance')
	Set @ShowSchoolNameAddress = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSchoolName/Address')
	Set @ShowTeacherName = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTeacherName')
	Set @ShowSubjectTeacherName = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowSubjectTeacherName')
	Set @ShowTermComments = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermComments')
	Set @ShowTermGPA = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowTermGPA')
	Set @ShowWorshipAttendance = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowWorshipAttendance')
	Set @ShowYearAverageGrade = (Select SettingValue From @BasicProfileSettings Where SettingName = 'ShowYearAverageGrade')
	Set @PageBreak1 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak1')
	Set @PageBreak2 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak2')
	Set @PageBreak3 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak3')
	Set @PageBreak4 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak4')
	Set @PageBreak5 = (Select SettingValue From @BasicProfileSettings Where SettingName = 'PageBreak5')
	Set @StandardClassesReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'StandardClassesReportOrder')
	Set @CustomClassesReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'CustomClassesReportOrder')
	Set @TermCommentsReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'TermCommentsReportOrder')
	Set @AttendanceReportOrder = (Select SettingValue From @BasicProfileSettings Where SettingName = 'AttendanceReportOrder')
	
	
	
	-- Set PageBreaks
	Set @PageBreaks = ','
	If @PageBreak1 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak1 + ','
	End
	If @PageBreak2 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak2 + ','
	End
	If @PageBreak3 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak3 + ','
	End
	If @PageBreak4 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak4 + ','
	End
	If @PageBreak5 != ''
	Begin
		Set @PageBreaks = @PageBreaks + @PageBreak5 + ','
	End
	
	
End





---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


Declare @GradeStyle nvarchar(12)

If @ShowPercentageGrade = 'yes'
Begin
	Set @GradeStyle = 'Percentage'
End
Else
Begin
	Set @GradeStyle = 'Letter'
End



-- ****************************************************************************************
-- If not using Spanish reset Spanish Title to '' for report cards that don't use spanish
-- to avoid report card issues due to inconsistent spanish titles


If	@DefaultName != 'Spanish Report Card' 
	and 
	@DefaultName != 'Multi-Term Report Card'
	and
	@DefaultName != 'Multi-Term Two Column Report Card 2'
Begin
	Update #ReportCardData
	Set SpanishTitle = ''
End

If	(@DefaultName = 'Multi-Term Report Card' and @EnableSpanishSupport = 'no')
	or
	(@DefaultName = 'Multi-Term Two Column Report Card 2' and @EnableSpanishSupport = 'no')
Begin
	Update #ReportCardData
	Set SpanishTitle = ''
End

If	(@DefaultName = 'Multi-Term Report Card' and @SubgradeNoGradeSymbol != '')
	or
	(@DefaultName = 'Multi-Term Two Column Report Card 2' and @SubgradeNoGradeSymbol != '')
	or
	(@DefaultName = 'Letter-Landscape Report Card' and @SubgradeNoGradeSymbol != '')	
Begin
	Update #ReportCardData
	Set CustomFieldGrade = @SubgradeNoGradeSymbol
	Where 
	CustomFieldOrder is not null
	and
	CustomFieldOrder < 0
	and
	isnull(CustomFieldGrade,'') = ''
End
If	@DefaultName = 'Multi-Term Two Column Report Card 2' and @SubgradeNoGradeSymbol != ''
Begin
	Update #ReportCardData
	Set 
	CustomFieldGrade = @SubgradeNoGradeSymbol,
	LetterGrade = 
		case
			when ParentClassID > 0 then @SubgradeNoGradeSymbol
			else LetterGrade
		end
	Where 
	CustomFieldOrder is not null
	and
	isnull(CustomFieldGrade,'') = ''
End


-- *******************************************************************************


IF @ShowNumberedComments = 'yes' and @DefaultName != 'Multi-Term Report Card'
Begin

	-- Add Record to hold numbered comments for each main class of ClassTypeID 1

	Insert Into #ReportCardData
	(	TermID,
		ParentTermID,
		TermTitle,
		TermReportTitle,
		TermStart,
		TermEnd,
		StudentID,
		Fname,
		Mname,
		Lname,
		glname,
		ClassTitle,
		ReportOrder,
		ClassTypeID,
		ParentClassID,
		CustomFieldName,
		CustomFieldGrade,
		CustomFieldOrder,
		FieldNotGraded
	)
	Select
	TermID,
	ParentTermID,
	TermTitle,
	TermReportTitle,
	TermStart,
	TermEnd,
	StudentID,
	Fname,
	Mname,
	Lname,
	glname,
	case 
		when CHARINDEX('(', ClassTitle) != 0 then LEFT(ClassTitle, CHARINDEX('(', ClassTitle)-2)
		else ClassTitle
	end as TheClassTitle,
	ReportOrder,
	1000,
	1,
	case
		when @DefaultName = 'Spanish Report Card' then 'Comments / Comentarios'
		else 'Comments'
	end,
	max(ClassComments),
	999,
	0
	From #ReportCardData
	Where
	ClassTypeID in (1, 2, 8)
	Group By
	TermID,
	ParentTermID,
	TermTitle,
	TermReportTitle,
	TermStart,
	TermEnd,
	StudentID,
	Fname,
	Mname,
	Lname,
	glname,
	case 
		when CHARINDEX('(', ClassTitle) != 0 then LEFT(ClassTitle, CHARINDEX('(', ClassTitle)-2)
		else ClassTitle
	end,
	ReportOrder


End




-- Set Grades For Credit / No Credit Classes
Declare @CreditNoCreditPassingGrade int
Set @CreditNoCreditPassingGrade = (Select CreditNoCreditPassingGrade From Settings Where SettingID = 1)


------------------------------------------------------------------------------------------
-------------------------------- Get Class Yearly Average and GPA ------------------------
------------------------------------------------------------------------------------------

Create table #AvgGrades
(
StudentID int,
ClassTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
ClassTypeID int,
ReportOrder int,
ClassUnits decimal(7,4),
UnitGPA decimal(7,4),
PercentageXClassUnits decimal(10,4),
CustomGradeScaleID int,
AvgGrade decimal(5,1),
LetterGrade nvarchar(10) COLLATE DATABASE_DEFAULT,
YearlyGPA decimal(6,2),
OverallPercentage nvarchar(10) COLLATE DATABASE_DEFAULT,
ClassShowPercentageGrade int,  -- zoho 10624
IncYearAverage bit default 0, -- zoho 18556, Duke 4/08/2015
ReportAvgGrade nvarchar(10) COLLATE DATABASE_DEFAULT default ''
)

Create Index AvgGrade_Index on #AvgGrades (StudentID, ClassTitle)



Insert into #AvgGrades
Select distinct
StudentID,
ClassTitle,
ClassTypeID,
(	
	Select top 1 
	ReportOrder 
	From 
	#ReportCardData
	Where
	StudentID = RD.StudentID
	and
	ClassTitle = RD.ClassTitle
	and
	ClassTypeID = 1
) as ReportOrder,
ClassUnits,
(
	case
	(
		Select top 1 -- top 1 added by duke on 6/19/14, see tfs 1221 and 1222...
		GPAValue 
		From CustomGradeScaleGrades 
		Where 
		CustomGradeScaleID = RD.CustomGradeScaleID 
		and 
		GradeSymbol = 
		dbo.GetLetterGrade2
		(	CustomGradeScaleID, 
			convert(decimal(5,1), 
			case	
				when (@ShowTenthDecimalPoint = 'yes' or @ShowBothLetterAndPercentageGrade = 'yes' or @GradeStyle = 'Letter') 
					then convert(decimal(5,1), avg(PercentageGrade)) 
				else convert(decimal(5,1), avg(round(PercentageGrade,0))) 
			end
			)
		)
	) 
	when 0 then 0
	else
		(
			Select top 1 -- top 1 added by duke on 6/19/14, see tfs 1221 and 1222...
			GPAValue 
			From CustomGradeScaleGrades 
			Where 
			CustomGradeScaleID = RD.CustomGradeScaleID 
			and 
			GradeSymbol = 
			dbo.GetLetterGrade2
			(	CustomGradeScaleID, 
				convert(decimal(5,1), 
				case	
					when (@ShowTenthDecimalPoint = 'yes' or @ShowBothLetterAndPercentageGrade = 'yes' or @GradeStyle = 'Letter') 
						then convert(decimal(5,1), avg(PercentageGrade)) 
					else convert(decimal(5,1), avg(round(PercentageGrade,0))) 
				end
				)
			)
		) + RD.GPABoost
	end
) * 
ClassUnits	-- this used to use UnitsEarned but this caused multiple records.. on where Failed and one Where not failed.  but 
			-- set this back to Class Units and then above with the case statement we set it to zero if they failed when averageing
as UnitGPA,
case	
	when @ShowTenthDecimalPoint = 'yes' or @ShowBothLetterAndPercentageGrade = 'yes' or @GradeStyle = 'Letter' then convert(decimal(5,1), avg(PercentageGrade)) * ClassUnits
	else convert(decimal(5,1), avg(round(PercentageGrade,0))) * ClassUnits
end as PercentageXClassUnits,
CustomGradeScaleID,
	case	
		when (@ShowTenthDecimalPoint = 'yes' or @ShowBothLetterAndPercentageGrade = 'yes' or @GradeStyle = 'Letter') 
			then convert(decimal(5,1), avg(PercentageGrade)) 
		else convert(decimal(5,1), avg(round(PercentageGrade,0))) 
	end	as AvgGrade,
case	
	when @ShowTenthDecimalPoint = 'yes' or @ShowBothLetterAndPercentageGrade = 'yes' or @GradeStyle = 'Letter'
		then dbo.GetLetterGrade2(CustomGradeScaleID, convert(decimal(5,1), avg(PercentageGrade)))
	when	
			ClassTypeID = 8 
			and
			case	
				when (@ShowTenthDecimalPoint = 'yes' or @ShowBothLetterAndPercentageGrade = 'yes' or @GradeStyle = 'Letter') 
					then convert(decimal(5,1), avg(PercentageGrade)) 
				else convert(decimal(5,1), avg(round(PercentageGrade,0))) 
			end 
			< @CreditNoCreditPassingGrade then  'NC'
	when	
			ClassTypeID = 8 
			and
			case	
				when (@ShowTenthDecimalPoint = 'yes' or @ShowBothLetterAndPercentageGrade = 'yes' or @GradeStyle = 'Letter') 
					then convert(decimal(5,1), avg(PercentageGrade)) 
				else convert(decimal(5,1), avg(round(PercentageGrade,0))) 
			end 
			>= @CreditNoCreditPassingGrade then  'CR'			
	else dbo.GetLetterGrade2(CustomGradeScaleID, convert(decimal(5,1), avg(round(PercentageGrade,0)))) 
end as LetterGrade,
null,
null,
max(case when ClassShowPercentageGrade = 1 then 1 else 0 end),  -- zoho 10624
case when max(AlternativeGrade) = 'Inc' then 1 else 0 end, -- zoho 18556
''	-- ReportAvgGrade
From 
#ReportCardData RD
Where 
ParentClassID = 0
and
CustomGradeScaleID is not null
and
(case
	when exists (Select * From #tmpTermIDs where ParentTermID = 0) and ParentTermID = 0 then 1
	when not exists (Select * From #tmpTermIDs where ParentTermID = 0) then 1
	else 0
end) = 1
and
(isnull(ltrim(rtrim(AlternativeGrade)), '') = '' or (@ShowIncYearAverageIfIncTermGrade='yes' and AlternativeGrade = 'Inc')) -- zoho 18556
Group By StudentID, ClassTitle, CustomGradeScaleID, ClassUnits, ClassTypeID, GPABoost;


Update #AvgGrades
Set ReportAvgGrade =
	case
		when ClassTypeID not in (1,2,8) then null
		when IncYearAverage = 1 then 'Inc' -- zoho 18556
		when @GradeStyle = 'Letter' and ClassTypeID = 8 and AvgGrade < @CreditNoCreditPassingGrade then 'NC'
		when @GradeStyle = 'Letter' and ClassTypeID = 8 and AvgGrade >= @CreditNoCreditPassingGrade	then 'CR'
		when @ShowBothLetterAndPercentageGrade = 'yes' and @DefaultName = 'Letter-Landscape Report Card' and ClassShowPercentageGrade = 1 
			then LetterGrade + ' ' +  			
					case
						when convert(decimal(4,1), AvgGrade)%1 = 0 then	convert(nvarchar(5), convert(decimal(3,0), AvgGrade)) 
						else convert(nvarchar(5), convert(decimal(4,1), AvgGrade))
					end COLLATE DATABASE_DEFAULT		
		when @ShowBothLetterAndPercentageGrade = 'yes' and ClassShowPercentageGrade = 1 
			 then
			LetterGrade + ' ' + 
			case 
				when ClassShowPercentageGrade = 1 
					then	 -- zoho 10624	
						case
							when convert(decimal(4,1), AvgGrade)%1 = 0 then	convert(nvarchar(5), convert(decimal(3,0), AvgGrade)) 
							else convert(nvarchar(5), convert(decimal(4,1), AvgGrade))
						end + '%'
				else '' 
			end COLLATE DATABASE_DEFAULT
		when @GradeStyle = 'Letter' then LetterGrade
		when ReportOrder >= @ReportOrderOfThirdColumn then dbo.GetLetterGrade2(CustomGradeScaleID, AvgGrade)	
		when ClassShowPercentageGrade = 0 then dbo.GetLetterGrade2(CustomGradeScaleID,AvgGrade)
		when @ShowLetterGradeWhenF = 'yes' and LetterGrade = 'F' then 'F'
		when @ShowTenthDecimalPoint = 'yes' and @GradeStyle = 'Percentage' then 
			case
				when ClassTypeID = 8 then LetterGrade
				else convert(nvarchar(6), convert(decimal(4,1),AvgGrade))
			end COLLATE DATABASE_DEFAULT			
		when @GradeStyle = 'Percentage' then
			case
				when ClassTypeID = 8 then LetterGrade			
				else convert(nvarchar(5), convert(decimal(3,0), AvgGrade))
			end COLLATE DATABASE_DEFAULT
	end;



Select 
StudentID,
case
	when Sum(ClassUnits) = 0 then 0
	else convert(decimal(7,4), Sum(convert(dec(7,4), UnitGPA)) / Sum(convert(dec(7,4), ClassUnits)))
end as YearlyGPA,
case
	when Sum(ClassUnits) = 0 then AVG(AvgGrade)
	else Sum(convert(dec(10,4), PercentageXClassUnits)) / Sum(convert(dec(10,4), ClassUnits))
end as OverallPercentage
into #tmpYearlyGPA
From 
#AvgGrades
Where
ClassTypeID = 1
and
UnitGPA is not null
and
LetterGrade is not null
and
case
	when @DefaultName = 'Letter-Landscape2 Report Card' and ReportOrder < 20 then 1
	when @DefaultName != 'Letter-Landscape2 Report Card' then 1
	else 0
end = 1
Group By StudentID



Update #AvgGrades
Set 
YearlyGPA = YG.YearlyGPA,
OverallPercentage = YG.OverallPercentage
From
#tmpYearlyGPA YG
	inner join
#AvgGrades AG
	on AG.StudentID = YG.StudentID
	and AG.IncYearAverage = 0 -- zoho 18556




-- ****************************************************************************************
Declare @CreditNotCreditClasses table(ClassID int)
insert into @CreditNotCreditClasses
Select distinct ClassID
From #ReportCardData
Where
ClassTypeID = 8

Update #ReportCardData
Set ClassTypeID = 1
Where
ClassTypeID = 8


-- Make SubComments Classes all ClassTypeID 1 and set ClassTypeOrder = ClassTypeOrder of ClassTypeID 1.
-- Also copy CustomFieldGrade into LetterGrade column.
-- Also For SubComments Classes in the same Primary Class Create a distinct ClassTitle by adding the CustomFieldOrder number to it.
Update #ReportCardData
Set ClassTypeID = 1,
	LetterGrade = CustomFieldGrade,
	ClassTitle = rtrim(left(ClassTitle + '(', charindex('(', ClassTitle + '(') - 1)) +  'ÿ_ZZZ(' +    right('00000' + replace(convert(nvarchar(10), CustomFieldOrder),'-','s'), 5) + ')'  COLLATE DATABASE_DEFAULT
	-- replaced CustomFieldOrder),'-','~'), 5) with CustomFieldOrder),'-','0'), 5) as the ~ character caused ordering issues when Fields Order is -1 or lower FD# 356292 - dp 12/6/2021
	-- replaced CustomFieldOrder),'-','0'), 5) with CustomFieldOrder),'-','s'), 5) as the 0 character caused ordering issues when School used both subgrade and assignmentypes as subgrades FD# 357451 - dp 12/13/2021
Where ParentClassID > 0

-- NOTES
-- Added a space before the ZZZ becuase some classes were not 
-- ordering correctly see below for example:

--PE and Penmanship both have same report order and use numbered comments

--Without the space it was odering it like

--PE
--PE
--PE
--Penmanship
--Penmanship
--Penmanship
--PEZZZZ Comments
--PEZZZZ Comments
--PEZZZZ Comments
--PenmanshipZZZ Comments
--PenmanshipZZZ Comments
--PenmanshipZZZ Comments

-- Below is another scenario where using only the space character caused an ordering issue 
-- I added _space and it seemed to work fine

-- Reading
-- Reading Group Master

--Resulting in both numbered comments rows appearing after Penmanship
 
-- Added another update by removing the space from ( _ZZZ)as Mathematics(Pre Algebra) class 
-- was not ordering correctly it was ordering it like
-- Mathematics _ZZZ(00005)	- Subgrade
-- Mathematics _ZZZ(00005)	- Subgrade
-- Mathematics(Pre Algebra	- Main class

-- sub grades needed to be ordered after class the main class, removing the space fixed this.  


-- Removing the space caused other issues:

--Bible
--Bible Memory
--Bible Memory_ZZZ
--Bible_ZZZ

--the space character is the first valid ascii character so I had to put it back in
--We'll just have to add a space to classes like Mathematics(Pre Algebra so they are Mathematics (Pre Algebra

------------------------------------------------------------------------------------------------------

-- Set ClassUnits and Report Order to be equal the latest classes settings

-- First get all combinations of distinct Students and Classes and their latest Report Order and Class Units

Create Table #StudentsClasses
(
StudentID int,
ClassTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
ReportOrder int,
ClassUnits decimal(7,3),
StaffTitle nvarchar(20) COLLATE DATABASE_DEFAULT,
TFname nvarchar(30) COLLATE DATABASE_DEFAULT,
TLname nvarchar(30) COLLATE DATABASE_DEFAULT
)


Insert into #StudentsClasses
Select distinct
StudentID,
ClassTitle,
(
Select top 1 ReportOrder
From #ReportCardData 
Where 
StudentID = R1.StudentID 
and 
ClassTitle = R1.ClassTitle
Order By TermEnd desc, ParentTermID desc
),
(
Select top 1 ClassUnits 
From #ReportCardData 
Where 
StudentID = R1.StudentID 
and 
ClassTitle = R1.ClassTitle
and 
ExamTerm != 1
Order By TermEnd desc, ParentTermID desc
),
(
Select top 1 StaffTitle 
From #ReportCardData 
Where 
StudentID = R1.StudentID 
and 
ClassTitle = R1.ClassTitle
Order By TermEnd desc, ParentTermID desc
),
(
Select top 1 TFname 
From #ReportCardData 
Where 
StudentID = R1.StudentID 
and 
ClassTitle = R1.ClassTitle
Order By TermEnd desc, ParentTermID desc
),
(
Select top 1 TLname 
From #ReportCardData 
Where 
StudentID = R1.StudentID 
and 
ClassTitle = R1.ClassTitle
Order By TermEnd desc, ParentTermID desc
)
From #ReportCardData R1


-- Update #ReportCardData with the latest Report Order and Class Units

If @AllowDifferentClassUnits = 'yes'
Begin

	Update #ReportCardData
	Set
	ReportOrder = SC.ReportOrder,
	StaffTitle = SC.StaffTitle,
	TFname = SC.TFname,
	TLname = SC.TLname
	From 
	#StudentsClasses SC
		inner join
	#ReportCardData R1
		on R1.StudentID = SC.StudentID and R1.ClassTitle = SC.ClassTitle

End
Else
Begin

	Update #ReportCardData
	Set
	ReportOrder = SC.ReportOrder,
	ClassUnits = SC.ClassUnits,
	StaffTitle = SC.StaffTitle,
	TFname = SC.TFname,
	TLname = SC.TLname
	From 
	#StudentsClasses SC
		inner join
	#ReportCardData R1
		on R1.StudentID = SC.StudentID and R1.ClassTitle = SC.ClassTitle

End


Drop table #StudentsClasses


------------------------------------------------------------------------------------------------------


-- Create ReportOrder table
-- Add 1000 to the ClassTypeOrder so each ClassType has big enough range that they won't overlap
-- Use the mod 1000 to translate back to ClassTypeID on the xslt side

Declare @ReportOrderTable as table (ClassTypeID int, ClassTypeOrder int)
Declare @CustomClassReportOrderTable as table(TermEnd datetime, ClassTypeID int, ClassTypeOrder int)


If @DefaultName = 'Multi-Term Report Card' or @DefaultName = 'Multi-Term Two Column Report Card 2'
Begin


	Declare @CustomClassTypeOrder as table
	(CustomClassOrder int, ClassTypeID int, ClassTitle nvarchar(100) COLLATE DATABASE_DEFAULT, ReportOrder int)

	Insert into @CustomClassTypeOrder		-- I believe this orders custom types Alphabetically if report order is left at defaults.
	Select distinct
	ROW_NUMBER() over (Order By ClassTitle) + (100*ReportOrder) as CustomClassOrder,  -- changed the * to a plus to fix issue with #127 K custom class ordering
	ClassTypeID, ClassTitle, ReportOrder
	From #ReportCardData
	Where
	--TermID = @StartTermID  -- I had commented this out to fix an issue in Sch 484 where they created custom classes in the 
	--and					 -- second Term that did not exist in the first term.  This seemed to fix it for the multi-term report card.
	ClassTypeID > 99
	and
	ParentClassID = 0
	Group By ClassTypeID, ClassTitle, ReportOrder
	Order By ClassTitle


	Insert into @ReportOrderTable (ClassTypeID, ClassTypeOrder)
	Select distinct
	ClassTypeID, 
	case
		when ClassTypeID in (1,2,8) then (@StandardClassesReportOrder * 100000000) + ClassTypeID
		when ClassTypeID = 3 then (@TermCommentsReportOrder * 100000000) + ClassTypeID
		when ClassTypeID = 5 then (@AttendanceReportOrder * 100000000) + ClassTypeID
		when ClassTypeID = 6 then (@AttendanceReportOrder * 100000000) + ClassTypeID
-- Fresh Desk #83240 - Incorrect report order on custom classes
-- The existing code looks incorrect; why would we want to sort by ClassTypeID 
-- if there is sort information available for custom class sorting.  So I moved the
-- 100x multiplier to any custom class sorting information making it higher precedent for sorting...
-- - Duke
--		else (@CustomClassesReportOrder * 100000000) + (ClassTypeID * 100)* ((Select top 1 CustomClassOrder From @CustomClassTypeOrder Where ClassTypeID = RD.ClassTypeID) + 1)
		else (@CustomClassesReportOrder * 100000000) + ClassTypeID + 100 * ((Select top 1 CustomClassOrder From @CustomClassTypeOrder Where ClassTypeID = RD.ClassTypeID) + 1)
	end as ClassTypeOrder
	From #ReportCardData RD

End
Else
Begin


	-- IF CustomClasses have the same Report Order Such as 0 
	-- This will order them by their ClassTypeOrder (Alphabetically) versus by ClassTypeID
	Insert into @CustomClassReportOrderTable
	Select
	TermEnd,
	ClassTypeID,
	ROW_NUMBER() over (Order By ReportOrder, ClassTitle) as theRownum
	From #ReportCardData
	Where
	ClassTypeID > 99
	Group By TermEnd, ClassTypeID, ClassTitle, ReportOrder




	Insert into @ReportOrderTable (ClassTypeID, ClassTypeOrder)
	Select distinct
	ClassTypeID, 
	case
		when ClassTypeID = 3 then 4000000 
		when ClassTypeID = 5 then 5000000
		when ClassTypeID = 6 then 6000000
		when ClassTypeID > 99 then ((Select top 1 ClassTypeOrder From @CustomClassReportOrderTable Where ClassTypeID = RD.ClassTypeID Order By TermEnd desc) * 100) + ((1 + ReportOrder) * 10000)
		else ReportOrder * 100 
	end as ClassTypeOrder
	From #ReportCardData RD

End



-- Get GradeScaleLegend from records of ClassTypeID 1
Declare @StandardGradeScaleLegend nvarchar(4000)
Declare @StandardGradeScaleLegend2 nvarchar(2000)
Declare @StandardGradeScaleLegend3 nvarchar(2000)

Set @StandardGradeScaleLegend = (Select top 1 GradeScaleLegend From #ReportCardData Where ClassTypeID = 1 and ParentClassID = 0 and GradeScaleLegend is not null Order By GradeScaleLegend) + ' ' 
Set @StandardGradeScaleLegend2 = (Select top 1 GradeScaleLegend From #ReportCardData Where ClassTypeID = 1 and ParentClassID = 0 and GradeScaleLegend is not null and GradeScaleLegend != @StandardGradeScaleLegend) + ' ' 
Set @StandardGradeScaleLegend3 = (Select top 1 GradeScaleLegend From #ReportCardData Where ClassTypeID = 1 and ParentClassID = 0 and GradeScaleLegend is not null and GradeScaleLegend != @StandardGradeScaleLegend and GradeScaleLegend != @StandardGradeScaleLegend2) + ' ' 

Set @StandardGradeScaleLegend = rtrim(@StandardGradeScaleLegend) + ' ' + Isnull(rtrim(@StandardGradeScaleLegend2), '') + ' ' + Isnull(rtrim(@StandardGradeScaleLegend3), '') 


-- Remove GradeScaleLegend for records with a classtypeID of 1
Update #ReportCardData
Set GradeScaleLegend = null
Where 
ClassTypeID = 1
and
GradeScaleLegend is not null

--------------------------------------------------------------------------------------------------------
-------------------------------Find the Correct Teacher Name-------------------------------------------
--------------------------------------------------------------------------------------------------------

Create table #tmpTeachers (StudentID int,Teacher nvarchar(50) COLLATE DATABASE_DEFAULT)  -- Holds Student Teachers



If @UseAttendanceClassForTeacherName = 'yes'
Begin

	Insert Into #tmpTeachers
	Select Distinct
	StudentID,
	(
	Select top 1
		case
			when R2.StaffTitle is null then R2.TFname + ' ' + R2.TLname
			when rtrim(R2.StaffTitle) = '' then R2.TFname + ' ' + R2.TLname
			else R2.StaffTitle + ' ' + R2.TLname
		end as Teacher
	From #ReportCardData R2
	Where 
	StudentID = R1.StudentID
	and
	ParentClassID = 0	
	and
	TFname is not null
	and
	ClassTypeID = 5
	Group by R2.StudentID, R2.TFname, R2.TLname, R2.StaffTitle, R2.TermEnd
	Order By TermEnd desc, sum(ClassTypeID2) desc
	) as Teacher
	From #ReportCardData R1
	
End
Else
Begin
--	-- Populate #tmpTeachers with the teacher that teaches the most classes for this student

	Insert Into #tmpTeachers
	Select Distinct
	StudentID,
	(
	Select top 1
		case
			when R2.StaffTitle is null then R2.TFname + ' ' + R2.TLname
			when rtrim(R2.StaffTitle) = '' then R2.TFname + ' ' + R2.TLname
			else R2.StaffTitle + ' ' + R2.TLname
		end as Teacher
	From #ReportCardData R2
	Where 
	StudentID = R1.StudentID
	and
	ParentClassID = 0	
	and
	TFname is not null
	Group by R2.StudentID, R2.TFname, R2.TLname, R2.StaffTitle, R2.TermEnd
	Having Count(*) > 2
	Order By TermEnd desc, sum(ClassTypeID2) desc
	) as Teacher
	From #ReportCardData R1

End

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------



-- Print '****************************************Mark 1****************************************'

-- Make Sure all students have all classtypes and all terms


Declare @termstb table
(
TermID int,
ParentTermID int,
ExamTerm bit,
TermTitle nvarchar(50) COLLATE DATABASE_DEFAULT,
TermReportTitle nvarchar(20) COLLATE DATABASE_DEFAULT,
TermStart smalldatetime,
TermEnd smalldatetime
)

Insert into @termstb
Select Distinct 
	TermID, 
	ParentTermID,
	ExamTerm,
	TermTitle, 
	TermReportTitle,
	TermStart, 
	TermEnd
From #ReportCardData
Where 
ParentTermID is not null
and
ExamTerm is not null


Union

Select distinct					-- Add Non-Transcript or other Terms that were selected but are not in 
	TermID,						--#ReportCardData because the terms weren't in the selected ClassTypeIDs 
	ParentTermID,
	ExamTerm,
	TermTitle, 
	ReportTitle,
	StartDate as TermStart, 
	EndDate as TermEnd
From Terms
where 	TermID in (Select IntegerID From SplitCSVIntegers(@Terms))
		and
		TermID not in (Select TermID From #ReportCardData)







-- Get a List of all the distinct ClassTypes
Declare @ClassTypeIDs as table (ClassTypeID int, GradeScaleLegend nvarchar(1000))
Insert Into @ClassTypeIDs
Select Distinct ClassTypeID, GradeScaleLegend
From #ReportCardData



Create table #Students2
(
StudentID int,
Fname nvarchar(30) COLLATE DATABASE_DEFAULT,
Mname nvarchar(30) COLLATE DATABASE_DEFAULT,
Lname nvarchar(30) COLLATE DATABASE_DEFAULT,
glname nvarchar(100) COLLATE DATABASE_DEFAULT
)

insert into #Students2
Select distinct 
StudentID,
Fname,
Mname,
Lname,
glname
From 
#ReportCardData


Create table #AllCombinationsTSC
(
TermID int,
ParentTermID int,
ExamTerm bit,
TermTitle nvarchar(50) COLLATE DATABASE_DEFAULT,
TermReportTitle nvarchar(30) COLLATE DATABASE_DEFAULT,
TermStart smalldatetime,
TermEnd smalldatetime,
StudentID int,
Fname nvarchar(30) COLLATE DATABASE_DEFAULT,
Mname nvarchar(30) COLLATE DATABASE_DEFAULT,
Lname nvarchar(30) COLLATE DATABASE_DEFAULT,
glname nvarchar(100) COLLATE DATABASE_DEFAULT,
ClassTypeID int,
GradeScaleLegend nvarchar(1000)
)




insert into #AllCombinationsTSC
Select 
T.TermID,
T.ParentTermID,
T.ExamTerm,
T.TermTitle,
T.TermReportTitle,
T.TermStart,
T.TermEnd,
S.StudentID,
S.Fname,
S.Mname,
S.Lname,
S.glname,
CT.ClassTypeID,
CT.GradeScaleLegend
From
@termstb T
	cross join
#Students2 S
	cross join
@ClassTypeIDs CT



create table #RDCombinationsTSC
(
TermID int,
StudentID int,
ClassTypeID int
)


insert into #RDCombinationsTSC
Select distinct 
TermID,
StudentID,
ClassTypeID
From #ReportCardData


insert into #ReportCardData
(
TermID,
ParentTermID,
ExamTerm,
TermTitle,
TermReportTitle,
TermStart,
TermEnd,
StudentID,
Fname,
Mname,
Lname,
glname,
ClassTypeID,
GradeScaleLegend
)
Select 
TermID,
ParentTermID,
ExamTerm,
TermTitle,
TermReportTitle,
TermStart,
TermEnd,
StudentID,
Fname,
Mname,
Lname,
glname,
ClassTypeID,
GradeScaleLegend
From 
#AllCombinationsTSC AC
where
not exists
(
Select *
From
#RDCombinationsTSC
Where
TermID = AC.TermID
and
StudentID = AC.StudentID
and
ClassTypeID = AC.ClassTypeID
)



-- Print '****************************************Mark 2****************************************'

-- For each student in each classtype in each term add all unique classes that each particular student has.

Create table #RDCombinationsStudentClasses
(
TermID int,
StudentID int,
ClassTypeID int,
ParentClassID int,
StaffTitle nvarchar(30) COLLATE DATABASE_DEFAULT,
TFname nvarchar(30) COLLATE DATABASE_DEFAULT,
TLname nvarchar(30) COLLATE DATABASE_DEFAULT,
ClassTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
SpanishTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
ClassUnits decimal(7,4),
CustomGradeScaleID int,
ReportOrder int,
CustomFieldName nvarchar(2000) COLLATE DATABASE_DEFAULT,
CustomFieldSpanishName nvarchar(2000) COLLATE DATABASE_DEFAULT,
CustomFieldOrder int,
FieldBolded bit,
FieldNotGraded bit,
StandardsItemType nvarchar(20) COLLATE DATABASE_DEFAULT,
GradeScaleLegend nvarchar(1000) COLLATE DATABASE_DEFAULT
)


Insert into #RDCombinationsStudentClasses
Select distinct 
TermID,
StudentID,
ClassTypeID,
case
	when ParentClassID > 0 then 1
	else 0
end as ParentClassID,
(Select top 1 StaffTitle From #ReportCardData Where ClassTitle = RD.ClassTitle and StudentID = RD.StudentID) as StaffTitle,
(Select top 1 TFname From #ReportCardData Where ClassTitle = RD.ClassTitle and StudentID = RD.StudentID) as TFname,
(Select top 1 TLname From #ReportCardData Where ClassTitle = RD.ClassTitle and StudentID = RD.StudentID) as TLname,
ClassTitle,
SpanishTitle,
ClassUnits,
CustomGradeScaleID,
ReportOrder,
CustomFieldName,
CustomFieldSpanishName,
CustomFieldOrder,
FieldBolded,
FieldNotGraded,
StandardsItemType,
GradeScaleLegend
From #ReportCardData RD




Create table #AllCombinationsStudentClasses
(
TermID int,
ParentTermID int,
ExamTerm bit,
TermTitle nvarchar(50) COLLATE DATABASE_DEFAULT,
TermReportTitle nvarchar(30) COLLATE DATABASE_DEFAULT,
TermStart smalldatetime,
TermEnd smalldatetime,
StudentID int,
Fname nvarchar(30) COLLATE DATABASE_DEFAULT,
Mname nvarchar(30) COLLATE DATABASE_DEFAULT,
Lname nvarchar(30) COLLATE DATABASE_DEFAULT,
glname nvarchar(100) COLLATE DATABASE_DEFAULT,
ClassTypeID int,
ParentClassID int,
StaffTitle nvarchar(30) COLLATE DATABASE_DEFAULT,
TFname nvarchar(30) COLLATE DATABASE_DEFAULT,
TLname nvarchar(30) COLLATE DATABASE_DEFAULT,
ClassTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
SpanishTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
ClassUnits decimal(7,4),
CustomGradeScaleID int,
ReportOrder int,
CustomFieldName nvarchar(2000) COLLATE DATABASE_DEFAULT,
CustomFieldSpanishName nvarchar(2000) COLLATE DATABASE_DEFAULT,
CustomFieldOrder int,
FieldBolded bit,
FieldNotGraded bit,
StandardsItemType nvarchar(20) COLLATE DATABASE_DEFAULT,
GradeScaleLegend nvarchar(1000) COLLATE DATABASE_DEFAULT
)



Insert into #AllCombinationsStudentClasses
Select distinct
TSC.TermID,
TSC.ParentTermID,
TSC.ExamTerm,
TSC.TermTitle,
TSC.TermReportTitle,
TSC.TermStart,
TSC.TermEnd,
TSC.StudentID,
TSC.Fname,
TSC.Mname,
TSC.Lname,
TSC.glname,
TSC.ClassTypeID,
SC.ParentClassID,
SC.StaffTitle,
SC.TFname,
SC.TLname,
SC.ClassTitle,
SC.SpanishTitle,
SC.ClassUnits,
SC.CustomGradeScaleID,
SC.ReportOrder,
SC.CustomFieldName,
SC.CustomFieldSpanishName,
SC.CustomFieldOrder,
SC.FieldBolded,
SC.FieldNotGraded,
SC.StandardsItemType,
SC.GradeScaleLegend
From 
#AllCombinationsTSC TSC
	cross join
#RDCombinationsStudentClasses SC
Where
TSC.StudentID = SC.StudentID
and
TSC.ClassTypeID = SC.ClassTypeID



Insert into #ReportCardData
(
TermID,
ParentTermID,
ExamTerm,
TermTitle,
TermReportTitle,
TermStart,
TermEnd,
StudentID,
Fname,
Mname,
Lname,
glname,
ClassTypeID,
ParentClassID,
StaffTitle,
TFname,
TLname,
ClassTitle,
SpanishTitle,
ClassUnits,
CustomGradeScaleID,
ReportOrder,
CustomFieldName,
CustomFieldSpanishName,
CustomFieldOrder,
FieldBolded,
FieldNotGraded,
StandardsItemType,
GradeScaleLegend
)
Select distinct
TermID,
ParentTermID,
ExamTerm,
TermTitle,
TermReportTitle,
TermStart,
TermEnd,
StudentID,
Fname,
Mname,
Lname,
glname,
ClassTypeID,
ParentClassID,
StaffTitle,
TFname,
TLname,
ClassTitle,
SpanishTitle,
ClassUnits,
CustomGradeScaleID,
ReportOrder,
CustomFieldName,
CustomFieldSpanishName,
CustomFieldOrder,
FieldBolded,
FieldNotGraded,
StandardsItemType,
GradeScaleLegend
From 
#AllCombinationsStudentClasses AC
where
not exists
(
Select *
From
#RDCombinationsStudentClasses
Where
TermID = AC.TermID
and
StudentID = AC.StudentID
and
ClassTypeID = AC.ClassTypeID
and
ClassTitle = AC.ClassTitle
and
Isnull(CustomFieldName, 1) = Isnull(AC.CustomFieldName, 1)
)
and
ClassTypeID != 1000
and
ClassTitle is not null


Delete From #ReportCardData Where ClassTitle is null or (ClassTypeID not in (1,8) and ExamTerm = 1);

-- Print '****************************************Mark 3****************************************'



---- Set ClassUnits and Report Order to be equal the latest classes settings

---- First get all combinations of distinct Students and Classes and their latest Report Order and Class Units

--Create Table #StudentsClasses
--(
--StudentID int,
--ClassTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
--ReportOrder int,
--ClassUnits decimal(7,3)
--)

--Insert into #StudentsClasses
--Select distinct
--StudentID,
--ClassTitle,
--(
--Select top 1 ReportOrder
--From #ReportCardData 
--Where 
--StudentID = R1.StudentID 
--and 
--ClassTitle = R1.ClassTitle
--Order By TermEnd desc
--),
--(
--Select top 1 ClassUnits 
--From #ReportCardData 
--Where 
--StudentID = R1.StudentID 
--and 
--ClassTitle = R1.ClassTitle
--Order By TermEnd desc
--)
--From #ReportCardData R1



---- Update #ReportCardData with the latest Report Order and Class Units

--Update #ReportCardData
--Set
--ReportOrder = SC.ReportOrder,
--ClassUnits = SC.ClassUnits
--From 
--#StudentsClasses SC
--	inner join
--#ReportCardData R1
--	on R1.StudentID = SC.StudentID and R1.ClassTitle = SC.ClassTitle


--Drop table #StudentsClasses



----------------------------------------------------------------------------------------------------------


Declare @SchoolName nvarchar(100)
Declare @SchoolAddress nvarchar(200)
Declare @SchoolPhone nvarchar(30)
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

If @DefaultName = 'Multi-Term Report Card'
Begin
	Select top 1
	@CommentName = ltrim(CommentName),
	@CommentAbbr = ltrim(CommentAbbr),
	@Comment1 = ltrim(Comment1),
	@Comment2 = ltrim(Comment2),
	@Comment3 = ltrim(Comment3),
	@Comment4 = ltrim(Comment4),
	@Comment5 = ltrim(Comment5),
	@Comment6 = ltrim(Comment6),
	@Comment7 = ltrim(Comment7),
	@Comment8 = ltrim(Comment8),
	@Comment9 = ltrim(Comment9),
	@Comment10 = ltrim(Comment10),
	@Comment11 = ltrim(Comment11),
	@Comment12 = ltrim(Comment12),
	@Comment13 = ltrim(Comment13),
	@Comment14 = ltrim(Comment14),
	@Comment15 = ltrim(Comment15),
	@Comment16 = ltrim(Comment16),
	@Comment17 = ltrim(Comment17),
	@Comment18 = ltrim(Comment18),
	@Comment19 = ltrim(Comment19),
	@Comment20 = ltrim(Comment20),
	@Comment21 = ltrim(Comment21),
	@Comment22 = ltrim(Comment22),
	@Comment23 = ltrim(Comment23),
	@Comment24 = ltrim(Comment24),
	@Comment25 = ltrim(Comment25),
	@Comment26 = ltrim(Comment26),
	@Comment27 = ltrim(Comment27),
	@Comment28 = ltrim(Comment28),
	@Comment29 = ltrim(Comment29),
	@Comment30 = ltrim(Comment30),
	@CommentRows =
		case
			when ltrim(isnull(Comment1, '')) = '' then 0
			when ltrim(isnull(Comment4, '')) = '' then 1
			when ltrim(isnull(Comment7, '')) = '' then 2
			when ltrim(isnull(Comment10, '')) = '' then 3
			when ltrim(isnull(Comment13, '')) = '' then 4
			when ltrim(isnull(Comment16, '')) = '' then 5
			when ltrim(isnull(Comment19, '')) = '' then 6
			when ltrim(isnull(Comment22, '')) = '' then 7
			when ltrim(isnull(Comment25, '')) = '' then 8
			when ltrim(isnull(Comment28, '')) = '' then 9
			else 10
		end,
	@CategoryName = CategoryName,
	@CategoryAbbr = CategoryAbbr,
	@Category1Symbol = Category1Symbol,
	@Category1Desc = Category1Desc,
	@Category2Symbol = Category2Symbol,
	@Category2Desc = Category2Desc,
	@Category3Symbol = Category3Symbol,
	@Category3Desc = Category3Desc,
	@Category4Symbol = Category4Symbol,
	@Category4Desc = Category4Desc 
	From 
	#ReportCardData
	Where 
	GradeLevel is not null
	and	
	ClassTypeID = 1
	and
	Category1Symbol is not null
	Order By TranscriptID desc
	
	
End
Else
Begin
	Select top 1
	@CommentName = ltrim(CommentName),
	@CommentAbbr = ltrim(CommentAbbr),
	@Comment1 = ltrim(substring(Comment1, 4, 100)),
	@Comment2 = ltrim(substring(Comment2, 4, 100)),
	@Comment3 = ltrim(substring(Comment3, 4, 100)),
	@Comment4 = ltrim(substring(Comment4, 4, 100)),
	@Comment5 = ltrim(substring(Comment5, 4, 100)),
	@Comment6 = ltrim(substring(Comment6, 4, 100)),
	@Comment7 = ltrim(substring(Comment7, 4, 100)),
	@Comment8 = ltrim(substring(Comment8, 4, 100)),
	@Comment9 = ltrim(substring(Comment9, 4, 100)),
	@Comment10 = ltrim(substring(Comment10, 4, 100)),
	@Comment11 = ltrim(substring(Comment11, 4, 100)),
	@Comment12 = ltrim(substring(Comment12, 4, 100)),
	@Comment13 = ltrim(substring(Comment13, 4, 100)),
	@Comment14 = ltrim(substring(Comment14, 4, 100)),
	@Comment15 = ltrim(substring(Comment15, 4, 100)),
	@Comment16 = ltrim(substring(Comment16, 4, 100)),
	@Comment17 = ltrim(substring(Comment17, 4, 100)),
	@Comment18 = ltrim(substring(Comment18, 4, 100)),
	@Comment19 = ltrim(substring(Comment19, 4, 100)),
	@Comment20 = ltrim(substring(Comment20, 4, 100)),
	@Comment21 = ltrim(substring(Comment21, 4, 100)),
	@Comment22 = ltrim(substring(Comment22, 4, 100)),
	@Comment23 = ltrim(substring(Comment23, 4, 100)),
	@Comment24 = ltrim(substring(Comment24, 4, 100)),
	@Comment25 = ltrim(substring(Comment25, 4, 100)),
	@Comment26 = ltrim(substring(Comment26, 4, 100)),
	@Comment27 = ltrim(substring(Comment27, 4, 100)),
	@Comment28 = ltrim(substring(Comment28, 4, 100)),
	@Comment29 = ltrim(substring(Comment29, 4, 100)),
	@Comment30 = ltrim(substring(Comment30, 4, 100)),
	@CategoryName = CategoryName,
	@CategoryAbbr = CategoryAbbr,
	@Category1Symbol = Category1Symbol,
	@Category1Desc = Category1Desc,
	@Category2Symbol = Category2Symbol,
	@Category2Desc = Category2Desc,
	@Category3Symbol = Category3Symbol,
	@Category3Desc = Category3Desc,
	@Category4Symbol = Category4Symbol,
	@Category4Desc = Category4Desc 
	From 
	#ReportCardData
	Where 
	GradeLevel is not null
	and
	ClassTypeID = 1
	and
	Category1Symbol is not null	
	Order By TranscriptID desc
	
	
End




Set @SchoolName = (Select SchoolName From Settings Where SettingID = 1)
Set @SchoolAddress = 	(Select SchoolStreet From Settings Where SettingID = 1) + ', ' +
						(Select SchoolCity From Settings Where SettingID = 1) + ', ' +
						(Select SchoolState From Settings Where SettingID = 1) + ' ' +
						(Select SchoolZip From Settings Where SettingID = 1)
Set @SchoolPhone = (Select SchoolPhone From Settings Where SettingID = 1)

Declare @ShowOnlyChurchAttendance nvarchar(5)
IF (Select ShowOnlyChurchAttendance From Settings Where SettingID = 1) = 1
Begin
	Set @ShowOnlyChurchAttendance = 'yes'
End
Else
Begin
	Set @ShowOnlyChurchAttendance = 'no'
End



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



--Print '****************************************Mark 4****************************************'





-----------------------------------Get First CustomClassTypeID-----------------------------

Declare @FirstCustomClassTypeID int
Declare @LastCustomClassTypeID int

Select top 1
@FirstCustomClassTypeID = ClassTypeID
From 
@ReportOrderTable
Where 
ClassTypeID > 99
and
ClassTypeID in (Select ClassTypeID From @ClassTypeIDs)
Order By ClassTypeOrder


Select top 1
@LastCustomClassTypeID = ClassTypeID
From 
@ReportOrderTable
Where 
ClassTypeID > 99
and
ClassTypeID in (Select ClassTypeID From @ClassTypeIDs)
Order By ClassTypeOrder desc


Create table #CustomAvgGrades
(
StudentID int,
ClassTitle nvarchar(100) COLLATE DATABASE_DEFAULT,
CustomAvgGrade nvarchar(8) COLLATE DATABASE_DEFAULT
)


If @DefaultName = 'Tri-fold2 Report Card' or @DefaultName = 'Letter-Landscape2 Report Card'
Begin

----------------------------------------------------------------------------------------
----------------------- Get Custom Class Yearly Average --------------------------------
----------------------------------------------------------------------------------------


Create Index CustomAvgGrade_Index on #CustomAvgGrades (StudentID, ClassTitle)

Insert into #CustomAvgGrades
Select
StudentID,
ClassTitle,
convert(nvarchar(8), convert(decimal(5,0), avg(convert(decimal(5,2),CustomFieldGrade))))  COLLATE DATABASE_DEFAULT as CustomAvgGrade
From 
#ReportCardData
Where 
ClassTypeID > 99
and
ParentClassID = 0
and
ClassID is not null
and
CustomFieldOrder = 1
Group By StudentID, ClassTitle, CustomFieldOrder, ParentClassID



----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

End



-------------------------------------------------------------------------------------------





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

Select 
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





-- This code removes duplicate subgrades if they have two classes with the same
-- name such as Mathematics and Mathematics (Algebra) in the same term.
-- normally this is not a problem when they are in different terms but if they are in the 
-- same term the subgrades are doubled.  This code will remove the dupicates so only 
-- the subgrades from the last concluded class will show.

Declare @DuplicateSubgrades table (ClassTitle nvarchar(70), StudentID int, TermID int)
Declare @DuplicateClassTitle nvarchar(70)
Declare @DuplicateStudentID int
Declare @DuplicateTermID int
Declare @TranscriptIDToDelete int


Insert Into @DuplicateSubgrades
Select
ClassTitle,
StudentID,
TermID
From #ReportCardData
Where
ParentClassID > 0
Group By TermID, StudentID, ClassTitle
Having COUNT(*) > 1


While exists (Select * From @DuplicateSubgrades)
Begin

	Select top 1 
	@DuplicateClassTitle = isnull(ClassTitle,''), 
	@DuplicateStudentID = StudentID,
	@DuplicateTermID = TermID
	From @DuplicateSubgrades
	
	Set @TranscriptIDToDelete = (Select top 1 TranscriptID From #ReportCardData Where ClassTitle = @DuplicateClassTitle and StudentID = @DuplicateStudentID and TermID = @DuplicateTermID)
	
	Delete From #ReportCardData Where TranscriptID = @TranscriptIDToDelete
	
	Delete From @DuplicateSubgrades 
	Where 
	isnull(ClassTitle,'') = @DuplicateClassTitle 
	and
	StudentID = @DuplicateStudentID
	and
	TermID = @DuplicateTermID


End



------------------------------------------------------------------------------------------------
-- Used on MultiTermReportCard to see if subgrades exist
-- If so the parent Classes will have black background and be bolded
Declare @SubGradeExist bit = 0

IF exists
(	-- check for subgrades
Select *
From #ReportCardData
Where
ClassTypeID = 1
and
ParentClassID != 0
)
Begin
	Set @SubGradeExist = 1
End
----------------------------------------------------------------------------------------------


if len(@OverwriteTermTitle) > 0
Begin
  Update #ReportCardData
  Set TermReportTitle = @OverwriteTermTitle
End

if @ShowDivision = 1
Begin	-- Only shows current division
	Update #ReportCardData
	Set GradeLevel += case when len(S.Class) > 0 then '-' + S.Class else '' end
	From
	#ReportCardData R
		inner join
	Students S
		on R.StudentID = S.StudentID
End



-- Print '****************************************Mark 5****************************************'

EXEC SchoolSpecificCustomizations

--
-- For school #1631, multi-term report cards with more than one custom class / subgrade
-- grade scales only presented the grade scale legend for the class that appeared last 
-- on the report card.  See DS-269 / FD 115231.
-- NOTE: I've scoped this change to school #1631 only because it doesn't cover
-- all use-cases and it is possible that it could fail for some use-cases...
-- For example, it only covers up to two distinct custom scales (although that's
-- better than just one for all use cases.)  But it hasn't been fully tested for
-- all scenarios of control-break within multi-term cards or all scenarios of a
-- mix of standard and custom classes.  So I'll release just for 1631 for now... - Duke

-- The above comment has been there for 3-4 years. I found another school that needed this #3137
-- So I added it and the report card shows the two distinct gradescales in the legend. This school
-- only has two distinct legends for customtype classes so this hack works for them
-- This likely shouldn't be made live as some report cards show each customclass secton seperately
-- each with it's own GradeScale legend area.  So overwriting this section to all be the same with combined
-- gradescales would not be wanted. But for the "Multi-Term Two Column Report Card 2" which is used by #3137
-- and #1631 they only have one area for the GradeScale legend so combinging them in this case makes sense.

-- I have changed it so that this code below runs for the "Multi-Term Two Column Report Card 2" report card
-- It still only does two scale just getting the grades scale from the first and last customclass however
-- if the first and last are not different or but a middle one is they it won't work

-- 

--
--IF (@DefaultName LIKE 'Multi%' AND (DB_NAME() LIKE '1631%' or DB_NAME() LIKE '3137%')) 



IF (@DefaultName = 'Multi-Term Two Column Report Card 2')
BEGIN

	Declare @CombinedGradeScales nvarchar(500) = (
		SELECT Stuff(
		  (SELECT distinct N' ' + GradeScaleLegend FROM #ReportCardData Where ClassTypeID > 99 FOR XML PATH(''),TYPE)
		  .value('text()[1]','nvarchar(max)'),1,1,N'')
	); 

	UPDATE #ReportCardData 
	SET GradeScaleLegend = @CombinedGradeScales
	WHERE ClassTypeID>99;

END

-- select distinct ClassTypeID,GradeScaleLegend from #ReportCardData

-- Patch to ensure overall grades are surpressed; 
-- they were showing but misprinting after last column
-- on trifold, when teacher had entered assignment grades!!!
-- 11/6/2012 - Duke

-- This patch caused subgrades to not show when @ShowOverallGrades is set to 'no', 
-- For now I am commenting this out and will review the original issues with Duke later.
--if @ShowOverallGrade = 'no'
--begin
--  update #ReportCardData set LetterGrade = null
--end

Declare @CalculateGPAto3Decimals bit = (Select CalculateGPAto3Decimals From Settings Where SettingID = 1) 



Declare @CommentData table (
ClassTypeID int INDEX CommentDataIX NONCLUSTERED,
CommentName nvarchar(100),
CommentAbbr nvarchar(10),
Comment1 nvarchar(100),
Comment2 nvarchar(100),
Comment3 nvarchar(100),
Comment4 nvarchar(100),
Comment5 nvarchar(100),
Comment6 nvarchar(100),
Comment7 nvarchar(100),
Comment8 nvarchar(100),
Comment9 nvarchar(100),
Comment10 nvarchar(100),
Comment11 nvarchar(100),
Comment12 nvarchar(100),
Comment13 nvarchar(100),
Comment14 nvarchar(100),
Comment15 nvarchar(100),
Comment16 nvarchar(100),
Comment17 nvarchar(100),
Comment18 nvarchar(100),
Comment19 nvarchar(100),
Comment20 nvarchar(100),
Comment21 nvarchar(100),
Comment22 nvarchar(100),
Comment23 nvarchar(100),
Comment24 nvarchar(100),
Comment25 nvarchar(100),
Comment26 nvarchar(100),
Comment27 nvarchar(100),
Comment28 nvarchar(100),
Comment29 nvarchar(100),
Comment30 nvarchar(100)
);

--Create Index CommentData_Index on @CommentData (ClassTypeID);

Insert into @CommentData
Select distinct 
ClassTypeID,
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
Comment30
From
#ReportCardData
Where
Comment1 is not null;



	--case
	--  when	RD.ExamTerm = 1 then 'xExamTerm'
	--  when  RD.ParentTermID > 0 then 'SubTerm'
	--  when	exists (
	--		Select *
	--		From #ReportCardData
	--		Where 
	--			ParentTermID = RD.TermID
	--		) then 'xParentTerm'
	--  when	exists (
	--		Select *
	--		From Terms
	--		Where 
	--			ParentTermID = RD.TermID
	--		) then 'xParentTerm'
	--  else	'xRegularTerm'
	--end as [ClassField!4!TermType],

Declare @ParentTermIDs table (TermID int)

Insert into @ParentTermIDs
Select distinct ParentTermID 
From #ReportCardData 
Where ParentTermID != 0





Update #ReportCardData
Set ClassReportGrade = 
	case

		when CustomFieldOrder<0 
				and @AssignmentTypeSubgradeFormat in ('letter','both')
				and ISNUMERIC(LetterGrade)=0
			then LetterGrade -- 12/5/2013 - avoid errors with schools that have both computed class type subgrades and manual ones. Duke
	
		/*1*/when CustomFieldOrder < 0 and @AssignmentTypeSubgradeFormat = 'letter' 
			then  dbo.GetLetterGrade2(CustomGradeScaleID, convert(decimal(10,4),LetterGrade))
		
		/*2*/when CustomFieldOrder < 0 and @AssignmentTypeSubgradeFormat = 'both' 
			then  dbo.GetLetterGrade2(CustomGradeScaleID, 
				convert(decimal(10,4),LetterGrade)) + ' ('+ LetterGrade + ')'
				
		/*3*/when ClassTypeID not in (1,2,8) then null
		
		/*4*/when isnull(AlternativeGrade, '') != '' 
				and  isnull(AlternativeGrade, '') != 'nm' 
				then replace(AlternativeGrade, ' ', '')
				
		/*5*/when AlternativeGrade = 'nm' then ''
		
		/*6*/when LetterGrade = CustomFieldGrade then LetterGrade
		
		/*7*/when @ShowBothLetterAndPercentageGrade = 'yes'  and ClassShowPercentageGrade = 1 
			and @DefaultName = 'Letter-Landscape Report Card' 
			then  replace(LetterGrade, ' ', '') + '
'			+  convert(nvarchar(6), convert(decimal(4,1),PercentageGrade)) COLLATE DATABASE_DEFAULT

		/*8*/when @ShowBothLetterAndPercentageGrade = 'yes' and ClassShowPercentageGrade = 1 
			then  replace(LetterGrade, ' ', '') + '
'			+  convert(nvarchar(6), convert(decimal(4,1),PercentageGrade)) + '%' COLLATE DATABASE_DEFAULT

		/*9*/when @ShowLetterGradeWhenF = 'yes' and LetterGrade = 'F' then 'F'
		
		/*10*/when ClassID in (Select ClassID From @CreditNotCreditClasses)  then LetterGrade
		
		/*11*/when @GradeStyle = 'Letter' and LetterGrade = 'nm' then  '' 
		
		/*12*/when ReportOrder >= @ReportOrderOfThirdColumn then LetterGrade
		
		/*13*/when @GradeStyle = 'Letter' then  replace(LetterGrade, ' ', '')
		
		/*14*/when ClassShowPercentageGrade = 0 
				then replace(LetterGrade, ' ', '')
				
		/*15*/when @SemesterGradeAsLetterGrade = 'yes' and ParentTermID = 0 
			then replace(LetterGrade, ' ', '')
			
		/*16*/when @ShowTenthDecimalPoint = 'yes' and @GradeStyle = 'Percentage' and ParentClassID = 0 
			then convert(nvarchar(6), convert(decimal(4,1),PercentageGrade)) COLLATE DATABASE_DEFAULT
			
		/*17*/when @GradeStyle = 'Percentage' and ParentClassID = 0 
			then convert(nvarchar(3),convert(int, round(PercentageGrade, 0))) COLLATE DATABASE_DEFAULT
			
		/*18*/else LetterGrade
		
	end;


Update #ReportCardData
Set [ClassReportAvgGrade] = A.ReportAvgGrade
From
#ReportCardData R
	inner join
#AvgGrades A
	on R.ClassTitle = A.ClassTitle and R.StudentID = A.StudentID;




--Select distinct 
--TermID,
--ExamTerm,
--ParentTermID,
--case
--  when ExamTerm = 1 then 'xExamTerm'
--  when ParentTermID > 0 then 'SubTerm'
--  when exists (Select * From @ParentTermIDs Where TermID = RD.TermID) then 'xParentTerm'
--  else	'xRegularTerm'
--end
--From #ReportCardData RD

--Select count(*)
--From #ReportCardData

-- Select @FooterHTML as FooterHTML




Select Distinct
	1 as tag,
	null as parent,
	@ShowGPAasaPercentage as [Report!1!ShowGPAasaPercentage],
	@TeacherLabelText as [Report!1!TeacherLabelText],
	@YearAvgAlign as [Report!1!YearAvgAlign],
	@ShowStudentID as [Report!1!ShowStudentID],
	@ShowStudentMailingAddressLabel as [Report!1!ShowStudentMailingAddressLabel],
	@StudentMailingAddressLabelCSS as [Report!1!StudentMailingAddressLabelCSS],
	@ShowGPATableCSS as [Report!1!ShowGPATableCSS],
	@ShowGradesAffectedAttendanceBox as [Report!1!ShowGradesAffectedAttendanceBox],
	@ShowGPA as [Report!1!ShowGPA],
	@AddPageBreakBeforeClassAttendance as [Report!1!AddPageBreakBeforeClassAttendance],
	@EnableStartingNewColumnOnSubgrades as [Report!1!EnableStartingNewColumnOnSubgrades],
	@ShowClassAttendanceTotals as [Report!1!ShowClassAttendanceTotals],
	@GradeLevelLabelText as [Report!1!GradeLevelLabelText],
	@ShowEnglishLanguageArtsHeaderRow as [Report!1!ShowEnglishLanguageArtsHeaderRow],
	@StandardsCategoryFormat as [Report!1!StandardsCategoryFormat],
	@StandardsMarzanoTopicFormat as [Report!1!StandardsMarzanoTopicFormat],
	@StandardsSubCategoryFormat as [Report!1!StandardsSubCategoryFormat],
	@HideGradeLevel as [Report!1!HideGradeLevel],
	@CustomHTMLSectionAboveStandardClassTitle as [Report!1!CustomHTMLSectionAboveStandardClassTitle],
	@StandardClassesCustomHTMLSection as [Report!1!StandardClassesCustomHTMLSection],
	@CustomClassesSubjectHeadingText as [Report!1!CustomClassesSubjectHeadingText],
	@StandardClassesSubjectHeadingText as [Report!1!StandardClassesSubjectHeadingText],		
	@StartRightColumnStandardClassTitle1 as [Report!1!StartRightColumnStandardClassTitle1],
	@StartRightColumnStandardClassTitle2 as [Report!1!StartRightColumnStandardClassTitle2],
	@StartRightColumnStandardClassTitle3 as [Report!1!StartRightColumnStandardClassTitle3],
	@StartRightColumnStandardClassTitle4 as [Report!1!StartRightColumnStandardClassTitle4],
	@StartRightColumnStandardClassTitle5 as [Report!1!StartRightColumnStandardClassTitle5],
	@PageBreakbeforeStandardClassTitle1 as [Report!1!PageBreakbeforeStandardClassTitle1],
	@PageBreakbeforeStandardClassTitle2 as [Report!1!PageBreakbeforeStandardClassTitle2],
	@PageBreakbeforeStandardClassTitle3 as [Report!1!PageBreakbeforeStandardClassTitle3],
	@PageBreakbeforeStandardClassTitle4 as [Report!1!PageBreakbeforeStandardClassTitle4],
	@PageBreakbeforeStandardClassTitle5 as [Report!1!PageBreakbeforeStandardClassTitle5],
	@StartRightColumnCustomClassTitle1 as [Report!1!StartRightColumnCustomClassTitle1],
	@StartRightColumnCustomClassTitle2 as [Report!1!StartRightColumnCustomClassTitle2],
	@StartRightColumnCustomClassTitle3 as [Report!1!StartRightColumnCustomClassTitle3],
	@StartRightColumnCustomClassTitle4 as [Report!1!StartRightColumnCustomClassTitle4],
	@StartRightColumnCustomClassTitle5 as [Report!1!StartRightColumnCustomClassTitle5],
	@PageBreakbeforeCustomClassTitle1 as [Report!1!PageBreakbeforeCustomClassTitle1],
	@PageBreakbeforeCustomClassTitle2 as [Report!1!PageBreakbeforeCustomClassTitle2],
	@PageBreakbeforeCustomClassTitle3 as [Report!1!PageBreakbeforeCustomClassTitle3],
	@PageBreakbeforeCustomClassTitle4 as [Report!1!PageBreakbeforeCustomClassTitle4],
	@PageBreakbeforeCustomClassTitle5 as [Report!1!PageBreakbeforeCustomClassTitle5],
	@StandardClassGradeColumnWidth as [Report!1!StandardClassGradeColumnWidth],
	@CustomClassGradeColumnWidth as [Report!1!CustomClassGradeColumnWidth],
	@RenderWebpageInStandardsMode as [Report!1!RenderWebpageInStandardsMode],
	@PDFEngine as [Report!1!PDFEngine],
	@isPDF as [Report!1!isPDF],
	@AdjustNumCommentsWidth as [Report!1!AdjustNumCommentsWidth],
	@StandardClassPageBreakTitle as [Report!1!StandardClassPageBreakTitle],
	@StandardClassPageBreakTitle2 as [Report!1!StandardClassPageBreakTitle2],
	@StandardClassPageBreakTitle3 as [Report!1!StandardClassPageBreakTitle3],
	@StandardClassPageBreakTitle4 as [Report!1!StandardClassPageBreakTitle4],
	@StandardClassPageBreakTitle5 as [Report!1!StandardClassPageBreakTitle5],
	@TopLeftHTML as [Report!1!TopLeftHTML],
	@BottomHTML as [Report!1!BottomHTML],
	@NumberedCommentsHTML as [Report!1!NumberedCommentsHTML],
	@UseTermReportTitleOnTermComments as [Report!1!UseTermReportTitleOnTermComments],
	@CalculateGPAto3Decimals as [Report!1!CalculateGPAto3Decimals],
	@ADPFormat as [Report!1!ADPFormat],
	@GradeImageHeight as [Report!1!GradeImageHeight], 
	@SubgradeMarkAlignment as [Report!1!SubgradeMarkAlignment], 
	@EnableLargeSingleTermCommentBox as [Report!1!EnableLargeSingleTermCommentBox],
	@LatestCommentTermID as [Report!1!LatestCommentTermID],
	@SupportAccount as [Report!1!SupportAccount],
	@StandardClassesCustomLegendHTML as [Report!1!StandardClassesCustomLegendHTML],
	@ShowClassCategoryLegend as [Report!1!ShowClassCategoryLegend],
	@SubGradeExist as [Report!1!SubGradeExist],
	@ProfileID as [Report!1!ProfileID],
	@DisplayGradeLevelAs as [Report!1!DisplayGradeLevelAs],
	@ShowBothLetterAndPercentageGrade as [Report!1!ShowBothLetterAndPercentageGrade],
	@ShowTeacherNameForEachSubject as [Report!1!ShowTeacherNameForEachSubject],
	@TurnOffPreviewModeGraphic as [Report!1!TurnOffPreviewModeGraphic],
	@LeftAlignClassTitle as [Report!1!LeftAlignClassTitle],
	@PageHeight as [Report!1!PageHeight],
	@GradeHeadingAbbr as [Report!1!GradeHeadingAbbr],
	@GradeHeadingTitle as [Report!1!GradeHeadingTitle],
	@PageBreaks as [Report!1!PageBreaks],
	@StandardGradeScaleLegend as [Report!1!StandardGradeScaleLegend],
	@ReportTitle as [Report!1!ReportTitle],
	@ShowOverallGrade as [Report!1!ShowOverallGrade],
	@GradePlacement as [Report!1!GradePlacement],
	@DefaultName as [Report!1!DefaultName],
	@DisplayName as [Report!1!DisplayName],
	@TopMargin as [Report!1!TopMargin],
	@ShowAttendancePercentages as [Report!1!ShowAttendancePercentages],
	@WorshipAttendanceChurchTitle as [Report!1!WorshipAttendanceChurchTitle],
	@WorshipAttendanceBibleClassTitle as [Report!1!WorshipAttendanceBibleClassTitle],
	@ShowGradeScaleForCustomClasses as [Report!1!ShowGradeScaleForCustomClasses],
	@SchoolAttendanceTitle as [Report!1!SchoolAttendanceTitle],
	@ShowTeacherNameOnTermComments as [Report!1!ShowTeacherNameOnTermComments],
	@ForceSemesterGrade as [Report!1!ForceSemesterGrade],
	@ShowClassAttendance as [Report!1!ShowClassAttendance],
	@ShowClassCredits as [Report!1!ShowClassCredits],
	@ShowClassEffort as [Report!1!ShowClassEffort],
	@ShowNumberedComments as [Report!1!ShowNumberedComments],
	@ShowGradeScaleLegend as [Report!1!ShowGradeScaleLegend],
	@StandardClassesReportOrder as [Report!1!StandardClassesReportOrder],
	@ShowSchoolNameAddress as [Report!1!ShowSchoolNameAddress],
	@ShowTeacherName as [Report!1!ShowTeacherName],
	@ShowSubjectTeacherName as [Report!1!ShowSubjectTeacherName],
	@FootnoteText as [Report!1!FootnoteText],
	@TurnOffBlackBackgrounds as [Report!1!TurnOffBlackBackgrounds],
	@ShowInsideTopLeftStudentInfo as [Report!1!ShowInsideTopLeftStudentInfo],
	@ShowGeneralAverageGrade as [Report!1!ShowGeneralAverageGrade],
	@TDLineHeight as [Report!1!TDLineHeight],
	@EnableSpanishSupport as [Report!1!EnableSpanishSupport],
	@EnableRightToLeft as [Report!1!EnableRightToLeft],
	@PrincipalName as [Report!1!PrincipalName],
	@HideEndofYearGradeColumn as [Report!1!HideEndofYearGradeColumn],
	@CustomClassTypesOnInsideRight as [Report!1!CustomClassTypesOnInsideRight],
	@PageBreak1 as [Report!1!PageBreak1],
	@PageBreak2 as [Report!1!PageBreak2],
	@PageBreak3 as [Report!1!PageBreak3],
	@PageBreak4 as [Report!1!PageBreak4],
	@PageBreak5 as [Report!1!PageBreak5],
	@FooterHTML as [Report!1!FooterHTML],
	@InsideTopLeftHTML as [Report!1!InsideTopLeftHTML],				-- Letter-Landscape2 Report Card
	@InsideMiddleLeftHTML as [Report!1!InsideMiddleLeftHTML],		-- Letter-Landscape2 Report Card
	@InsideBottomLeftHTML as [Report!1!InsideBottomLeftHTML],		-- Letter-Landscape2 Report Card
	@InsideTopRightHTML as [Report!1!InsideTopRightHTML],			-- Letter-Landscape2 Report Card
	@InsideMiddleRightHTML as [Report!1!InsideMiddleRightHTML],		-- Letter-Landscape2 Report Card
	@BackPageMiddleHTML as [Report!1!BackPageMiddleHTML],			-- Letter-Landscape2 Report Card
	@BackPageBottomHTML as [Report!1!BackPageBottomHTML],			-- Letter-Landscape2 Report Card
	@FrontPageHTML as [Report!1!FrontPageHTML],
	@WatermarkHTML as [Report!1!WatermarkHTML], 
	@BackPageHTML as [Report!1!BackPageHTML],
	@LeftBackPageHTML as [Report!1!LeftBackPageHTML],
	@MiddleBackPageHTML as [Report!1!MiddleBackPageHTML],
	@PrincipalSignatureHTML as [Report!1!PrincipalSignatureHTML],
	@AchievementCommentHTML as [Report!1!AchievementCommentHTML],
	@TopFrontPageHTML as [Report!1!TopFrontPageHTML],
	@BottomFrontPageHTML as [Report!1!BottomFrontPageHTML],
	@FrontPageGraphicHTML as [Report!1!FrontPageGraphicHTML],
	@InsideLeftSectionHTML as [Report!1!InsideLeftSectionHTML],
	@InsideRightSectionHTML as [Report!1!InsideRightSectionHTML],
	@TopLeftTitleHTML as [Report!1!TopLeftTitleHTML],				-- Legal-Landscape Report Card
	@TopLeftGraphicHTML as [Report!1!TopLeftGraphicHTML],			-- Legal-Landscape Report Card
	@TopRightTitleHTML as [Report!1!TopRightTitleHTML],				-- Legal-Landscape Report Card
	@EvaluationKeyHTML as [Report!1!EvaluationKeyHTML],				-- Legal-Landscape Report Card
	@TeacherSignatureHTML as [Report!1!TeacherSignatureHTML],		-- Legal-Landscape Report Card
	@BackgroundImageHTML as [Report!1!BackgroundImageHTML],			-- Legal-Landscape Report Card	
	@FirstCustomClassTypeID as [Report!1!FirstCustomClassTypeID],	
	@LastCustomClassTypeID as [Report!1!LastCustomClassTypeID],
	@TheTermTitle as [Report!1!TheTermTitle],
	@PrincipalTeacherSignatureTitle as [Report!1!PrincipalTeacherSignatureTitle],
	@ShowOnlyChurchAttendance as [Report!1!ShowOnlyChurchAttendance],
	@CondenseClasses as [Report!1!CondenseClasses],
	@BulletTopMargin as [Report!1!BulletTopMargin],
	@ClassTitleFontSize as [Report!1!ClassTitleFontSize],
	@SubgradeTitleFontSize as [Report!1!SubgradeTitleFontSize],
	@ClassSubgradeCellHeight as [Report!1!ClassSubgradeCellHeight],
	@YearAvgTitle as [Report!1!YearAvgTitle],
	@ShowYearAverageGrade as [Report!1!ShowYearlyAvg],
	@ShowPrincipalSignature as [Report!1!ShowPrincipalSignature],
	@ShowTeacherSignature as [Report!1!ShowTeacherSignature],	
	@ShowParentSignatureLine as [Report!1!ShowParentSignatureLine],
	@ShowGradePlacement as [Report!1!ShowGradePlacement],
	@ProfileTeacherName as [Report!1!ProfileTeacherName],
	@SecondColumnStartClass as [Report!1!SecondColumnStartClass],
	@ThirdColumnStartClass as [Report!1!ThirdColumnStartClass],				-- Legal-Landscape Report Card
	@LastCommentNumberToBold as [Report!1!LastCommentNumberToBold],			-- Legal-Landscape Report Card
	@SchoolworkAffected as [Report!1!SchoolworkAffected],					-- Legal-Landscape Report Card
	@SchoolYear as [Report!1!SchoolYear],
	@NextSchoolYear as [Report!1!NextSchoolYear],
	@TermCount as [Report!1!TermCount],
	@SubTermCount as [Report!1!SubTermCount],
	@EndTermID as [Report!1!EndTermID],
	@CAttendance1 as [Report!1!CAttendance1],
	@CAttendance2 as [Report!1!CAttendance2],
	@CAttendance3 as [Report!1!CAttendance3],
	@CAttendance4 as [Report!1!CAttendance4],
	@CAttendance5 as [Report!1!CAttendance5],
	@CAttendanceAbbr1 as [Report!1!CAttendanceAbbr1],
	@CAttendanceAbbr2 as [Report!1!CAttendanceAbbr2],
	@CAttendanceAbbr3 as [Report!1!CAttendanceAbbr3],
	@CAttendanceAbbr4 as [Report!1!CAttendanceAbbr4],
	@CAttendanceAbbr5 as [Report!1!CAttendanceAbbr5],
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
	@ClassID as [Report!1!ClassID],	
	@EK as [Report!1!EK],
	@ShowTermComments as [Report!1!TermComments],
	@ShowTermGPA as [Report!1!GPA],
	@ShowTermPercentageAverage as [Report!1!PercentageAvg],
	@ShowSchoolAttendance as [Report!1!SchoolAttendance],
	@ShowWorshipAttendance as [Report!1!WorshipAttendance],
	@EnlargeFontAndSpacing as [Report!1!EnlargeFont],
	@SchoolName as [Report!1!SchoolName],
	@SchoolAddress as [Report!1!SchoolAddress],
	@SchoolPhone as [Report!1!SchoolPhone],
	@CommentName as [Report!1!CommentName],
	@CommentAbbr as [Report!1!CommentAbbr],
	@Comment1 as  [Report!1!Comment1],
	@Comment2 as  [Report!1!Comment2],
	@Comment3 as  [Report!1!Comment3],
	@Comment4 as  [Report!1!Comment4],
	@Comment5 as  [Report!1!Comment5],
	@Comment6 as  [Report!1!Comment6],
	@Comment7 as  [Report!1!Comment7],
	@Comment8 as  [Report!1!Comment8],
	@Comment9 as  [Report!1!Comment9],
	@Comment10 as  [Report!1!Comment10],
	@Comment11 as  [Report!1!Comment11],
	@Comment12 as  [Report!1!Comment12],
	@Comment13 as  [Report!1!Comment13],
	@Comment14 as  [Report!1!Comment14],
	@Comment15 as  [Report!1!Comment15],
	@Comment16 as  [Report!1!Comment16],
	@Comment17 as  [Report!1!Comment17],
	@Comment18 as  [Report!1!Comment18],
	@Comment19 as  [Report!1!Comment19],
	@Comment20 as  [Report!1!Comment20],
	@Comment21 as  [Report!1!Comment21],
	@Comment22 as  [Report!1!Comment22],
	@Comment23 as  [Report!1!Comment23],
	@Comment24 as  [Report!1!Comment24],
	@Comment25 as  [Report!1!Comment25],
	@Comment26 as  [Report!1!Comment26],
	@Comment27 as  [Report!1!Comment27],
	@Comment28 as  [Report!1!Comment28],
	@Comment29 as  [Report!1!Comment29],
	@Comment30 as  [Report!1!Comment30],
	@CommentRows as [Report!1!CommentRows],
	@CategoryName as [Report!1!CategoryName],
	@CategoryAbbr as [Report!1!CategoryAbbr],
	@Category1Symbol as [Report!1!Category1Symbol],
	@Category1Desc as [Report!1!Category1Desc],
	@Category2Symbol as [Report!1!Category2Symbol],
	@Category2Desc as [Report!1!Category2Desc],
	@Category3Symbol as [Report!1!Category3Symbol],
	@Category3Desc as [Report!1!Category3Desc],
	@Category4Symbol as [Report!1!Category4Symbol],
	@Category4Desc as [Report!1!Category4Desc],
	null as [Student!2!StudentID],
	null as [Student!2!xStudentID],
	null as [Student!2!Father],
	null as [Student!2!Mother],
	null as [Student!2!Street],
	null as [Student!2!City],
	null as [Student!2!State],
	null as [Student!2!Zip],
	null as [Student!2!SFname],
	null as [Student!2!SMname],
	null as [Student!2!SLname],
	null as [Student!2!Sglname],
	null as [Student!2!GradeLevel],
	null as [Student!2!YearlyGPA],
	null as [Student!2!OverallGrade],	
	null as [Student!2!Teacher],
	null as [Student!2!SchoolAtt1Total],
	null as [Student!2!SchoolAtt2Total],
	null as [Student!2!SchoolAtt3Total],
	null as [Student!2!SchoolAtt4Total],
	null as [Student!2!SchoolAtt5Total],
	null as [Student!2!SchoolAtt6Total],
	null as [Student!2!SchoolAtt7Total],
	null as [Student!2!SchoolAtt8Total],
	null as [Student!2!SchoolAtt9Total],
	null as [Student!2!SchoolAtt10Total],
	null as [Student!2!SchoolAtt11Total],
	null as [Student!2!SchoolAtt12Total],
	null as [Student!2!SchoolAtt13Total],
	null as [Student!2!SchoolAtt14Total],
	null as [Student!2!SchoolAtt15Total],
	null as [Student!2!ChurchPresentTotal],
	null as [Student!2!ChurchAbsentTotal],
	null as [Student!2!SSchoolPresentTotal],
	null as [Student!2!SSchoolAbsentTotal],
	null as [ClassType!3!ClassTypeID],
	null as [ClassType!3!ClassTypeOrder],
	null as [ClassType!3!GradeScaleLegend],
	null as [ClassType!3!CommentRows],
	null as [ClassType!3!CommentName],
	null as  [ClassType!3!CommentAbbr],
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
	null as [ClassField!4!ParentClassID],
	null as [ClassField!4!ClassTitle],
	null as [ClassField!4!SpanishTitle],
	null as [ClassField!4!Teacher],
	null as [ClassField!4!ReportOrder],
	null as [ClassField!4!ClassUnits],
	null as [ClassField!4!ClassGrade],
	null as [ClassField!4!AvgGrade],
	null as [ClassField!4!Effort],
	null as [ClassField!4!ClassComments],
	null as [ClassField!4!FieldName],
	null as [ClassField!4!FieldSpanishName],
	null as [ClassField!4!FieldGrade],
	null as [ClassField!4!AvgFieldGrade],
	null as [ClassField!4!FieldOrder],
	null as [ClassField!4!FieldBolded],
	null as [ClassField!4!FieldNotGraded],
	null as [ClassField!4!Indent],
	null as [ClassField!4!Bullet],	
	null as [ClassField!4!TermID],
	null as [ClassField!4!TermType],
	null as [ClassField!4!StartTerm],
	null as [ClassField!4!TermReportTitle],
	null as [ClassField!4!TermEnd],
	null as [ClassField!4!TermGPA],
	null as [ClassField!4!TermPercentageAverage],	
	null as [ClassField!4!TermComment],
	null as [ClassField!4!SAtt1],
	null as [ClassField!4!SPercAtt1],
	null as [ClassField!4!SAtt2],
	null as [ClassField!4!SPercAtt2],
	null as [ClassField!4!SAtt3],
	null as [ClassField!4!SPercAtt3],
	null as [ClassField!4!SAtt4],
	null as [ClassField!4!SPercAtt4],
	null as [ClassField!4!SAtt5],
	null as [ClassField!4!SPercAtt5],
	null as [ClassField!4!SAtt6],
	null as [ClassField!4!SPercAtt6],
	null as [ClassField!4!SAtt7],
	null as [ClassField!4!SPercAtt7],
	null as [ClassField!4!SAtt8],
	null as [ClassField!4!SPercAtt8],
	null as [ClassField!4!SAtt9],
	null as [ClassField!4!SPercAtt9],
	null as [ClassField!4!SAtt10],
	null as [ClassField!4!SPercAtt10],
	null as [ClassField!4!SAtt11],
	null as [ClassField!4!SPercAtt11],
	null as [ClassField!4!SAtt12],
	null as [ClassField!4!SPercAtt12],
	null as [ClassField!4!SAtt13],
	null as [ClassField!4!SPercAtt13],
	null as [ClassField!4!SAtt14],
	null as [ClassField!4!SPercAtt14],
	null as [ClassField!4!SAtt15],
	null as [ClassField!4!SPercAtt15],
	null as [ClassField!4!ChurchPresent],
	null as [ClassField!4!PercChurchPresent],
	null as [ClassField!4!ChurchAbsent],
	null as [ClassField!4!PercChurchAbsent],
	null as [ClassField!4!SSchoolPresent],
	null as [ClassField!4!PercSSchoolPresent],
	null as [ClassField!4!SSchoolAbsent],
	null as [ClassField!4!PercSSchoolAbsent],
	null as [ClassField!4!Att1],
	null as [ClassField!4!Att2],
	null as [ClassField!4!Att3],
	null as [ClassField!4!Att4],
	null as [ClassField!4!Att5],
	null as [ClassField!4!TermAtt1Total],
	null as [ClassField!4!TermAtt2Total],
	null as [ClassField!4!TermAtt3Total],
	null as [ClassField!4!TermAtt4Total],
	null as [ClassField!4!TermAtt5Total],	
	null as [ClassField!4!ClassShowPercentageGrade],
	null as [ClassField!4!StandardsItemType]

Union All

Select Distinct
	2 as tag,
	1 as parent,
	null as [Report!1!ShowGPAasaPercentage],
	null as [Report!1!TeacherLabelText],
	null as [Report!1!YearAvgAlign],
	null as [Report!1!ShowStudentID],
	null as [Report!1!ShowStudentMailingAddressLabel],
	null as [Report!1!StudentMailingAddressLabelCSS],
	null as [Report!1!ShowGPATableCSS],
	null as [Report!1!ShowGradesAffectedAttendanceBox],
	null as [Report!1!ShowGPA],
	null as [Report!1!AddPageBreakBeforeClassAttendance],
	null as [Report!1!EnableStartingNewColumnOnSubgrades],
	null as [Report!1!ShowClassAttendanceTotals],	
	null as [Report!1!GradeLevelLabelText],
	null as [Report!1!ShowEnglishLanguageArtsHeaderRow],
	null as [Report!1!StandardsCategoryFormat],
	null as [Report!1!StandardsMarzanoTopicFormat],
	null as [Report!1!StandardsSubCategoryFormat],	
	null as [Report!1!HideGradeLevel],
	null as [Report!1!CustomHTMLSectionAboveStandardClassTitle],
	null as [Report!1!StandardClassesCustomHTMLSection],	
	null as [Report!1!CustomClassesSubjectHeadingText],
	null as [Report!1!StandardClassesSubjectHeadingText],	
	null as [Report!1!StartRightColumnStandardClassTitle1],
	null as [Report!1!StartRightColumnStandardClassTitle2],
	null as [Report!1!StartRightColumnStandardClassTitle3],
	null as [Report!1!StartRightColumnStandardClassTitle4],
	null as [Report!1!StartRightColumnStandardClassTitle5],
	null as [Report!1!PageBreakbeforeStandardClassTitle1],
	null as [Report!1!PageBreakbeforeStandardClassTitle2],
	null as [Report!1!PageBreakbeforeStandardClassTitle3],
	null as [Report!1!PageBreakbeforeStandardClassTitle4],
	null as [Report!1!PageBreakbeforeStandardClassTitle5],
	null as [Report!1!StartRightColumnCustomClassTitle1],
	null as [Report!1!StartRightColumnCustomClassTitle2],
	null as [Report!1!StartRightColumnCustomClassTitle3],
	null as [Report!1!StartRightColumnCustomClassTitle4],
	null as [Report!1!StartRightColumnCustomClassTitle5],
	null as [Report!1!PageBreakbeforeCustomClassTitle1],
	null as [Report!1!PageBreakbeforeCustomClassTitle2],
	null as [Report!1!PageBreakbeforeCustomClassTitle3],
	null as [Report!1!PageBreakbeforeCustomClassTitle4],
	null as [Report!1!PageBreakbeforeCustomClassTitle5],
	null as [Report!1!StandardClassGradeColumnWidth],	
	null as [Report!1!CustomClassGradeColumnWidth],
	null as [Report!1!RenderWebpageInStandardsMode],
	null as [Report!1!PDFEngine],
	null as [Report!1!isPDF],	
	null as [Report!1!AdjustNumCommentsWidth],
	null as [Report!1!StandardClassPageBreakTitle],
	null as [Report!1!StandardClassPageBreakTitle2],
	null as [Report!1!StandardClassPageBreakTitle3],
	null as [Report!1!StandardClassPageBreakTitle4],
	null as [Report!1!StandardClassPageBreakTitle5],
	null as [Report!1!TopLeftHTML],
	null as [Report!1!BottomHTML],
	null as [Report!1!NumberedCommentsHTML],	
	null as [Report!1!UseTermReportTitleOnTermComments],
	null as [Report!1!CalculateGPAto3Decimals],
	null as [Report!1!ADPFormat], 
	null as [Report!1!GradeImageHeight],
	null as [Report!1!SubgradeMarkAlignment], 
	null as [Report!1!EnableLargeSingleTermCommentBox],
	null as [Report!1!LatestCommentTermID],
	null as [Report!1!SupportAccount],
	null as [Report!1!StandardClassesCustomLegendHTML],
	null as [Report!1!ShowClassCategoryLegend],
	null as [Report!1!SubGradeExist],
	null as [Report!1!ProfileID],
	null as [Report!1!DisplayGradeLevelAs],
	null as [Report!1!ShowBothLetterAndPercentageGrade],
	null as [Report!1!ShowTeacherNameForEachSubject],
	null as [Report!1!TurnOffPreviewModeGraphic],
	null as [Report!1!LeftAlignClassTitle],	
	null as [Report!1!PageHeight],
	null as [Report!1!GradeHeadingAbbr],
	null as [Report!1!GradeHeadingTitle],
	null as [Report!1!PageBreaks],
	null as [Report!1!StandardGradeScaleLegend],
	null as [Report!1!ReportTitle],
	null as [Report!1!ShowOverallGrade],
	null as [Report!1!GradePlacement],
	null as [Report!1!DefaultName],
	null as [Report!1!DisplayName],
	null as [Report!1!TopMargin],
	null as [Report!1!ShowAttendancePercentages],
	null as [Report!1!WorshipAttendanceChurchTitle],
	null as [Report!1!WorshipAttendanceBibleClassTitle],
	null as [Report!1!ShowGradeScaleForCustomClasses],
	null as [Report!1!SchoolAttendanceTitle],
	null as [Report!1!ShowTeacherNameOnTermComments],
	null as [Report!1!ForceSemesterGrade],
	null as [Report!1!ShowClassAttendance],
	null as [Report!1!ShowClassCredits],
	null as [Report!1!ShowClassEffort],
	null as [Report!1!ShowNumberedComments],
	null as [Report!1!ShowGradeScaleLegend],
	null as [Report!1!StandardClassesReportOrder],
	null as [Report!1!ShowSchoolNameAddress],
	null as [Report!1!ShowTeacherName],
	null as [Report!1!ShowSubjectTeacherName],
	null as [Report!1!FootnoteText],
	null as [Report!1!TurnOffBlackBackgrounds],
	null as [Report!1!ShowInsideTopLeftStudentInfo],
	null as [Report!1!ShowGeneralAverageGrade],
	null as [Report!1!TDLineHeight],
	null as [Report!1!EnableSpanishSupport],
	null as [Report!1!EnableRightToLeft],
	null as [Report!1!PrincipalName],
	null as [Report!1!HideEndofYearGradeColumn],
	null as [Report!1!CustomClassTypesOnInsideRight],
	null as [Report!1!PageBreak1],
	null as [Report!1!PageBreak2],
	null as [Report!1!PageBreak3],
	null as [Report!1!PageBreak4],
	null as [Report!1!PageBreak5],
	null as [Report!1!FooterHTML],
	null as [Report!1!InsideTopLeftHTML],
	null as [Report!1!InsideMiddleLeftHTML],
	null as [Report!1!InsideBottomLeftHTML],
	null as [Report!1!InsideTopRightHTML],
	null as [Report!1!InsideMiddleRightHTML],
	null as [Report!1!BackPageMiddleHTML],
	null as [Report!1!BackPageBottomHTML],		
	null as [Report!1!FrontPageHTML],
	null as [Report!1!WatermarkHTML],
	null as [Report!1!BackPageHTML],
	null as [Report!1!LeftBackPageHTML],
	null as [Report!1!MiddleBackPageHTML],
	null as [Report!1!PrincipalSignatureHTML],
	null as [Report!1!AchievementCommentHTML],
	null as [Report!1!TopFrontPageHTML],
	null as [Report!1!BottomFrontPageHTML],
	null as [Report!1!FrontPageGraphicHTML],
	null as [Report!1!InsideLeftSectionHTML],
	null as [Report!1!InsideRightSectionHTML],
	null as [Report!1!TopLeftTitleHTML],
	null as [Report!1!TopLeftGraphicHTML],
	null as [Report!1!TopRightTitleHTML],
	null as [Report!1!EvaluationKeyHTML],
	null as [Report!1!TeacherSignatureHTML],
	null as [Report!1!BackgroundImageHTML],
	null as [Report!1!FirstCustomClassTypeID],	
	null as [Report!1!LastCustomClassTypeID],
	null as [Report!1!TheTermTitle],
	null as [Report!1!PrincipalTeacherSignatureTitle],		
	null as [Report!1!ShowOnlyChurchAttendance],
	null as [Report!1!CondenseClasses],
	null as [Report!1!BulletTopMargin],
	null as [Report!1!ClassTitleFontSize],
	null as [Report!1!SubgradeTitleFontSize],
	null as [Report!1!ClassSubgradeCellHeight],
	null as [Report!1!YearAvgTitle],
	null as [Report!1!ShowYearlyAvg],
	null as [Report!1!ShowPrincipalSignature],
	null as [Report!1!ShowTeacherSignature],	
	null as [Report!1!ShowParentSignatureLine],
	null as [Report!1!ShowGradePlacement],
	null as [Report!1!ProfileTeacherName],
	null as [Report!1!SecondColumnStartClass],
	null as [Report!1!ThirdColumnStartClass],
	null as [Report!1!LastCommentNumberToBold],
	null as [Report!1!SchoolworkAffected],
	null as [Report!1!SchoolYear],
	null as [Report!1!NextSchoolYear],
	null as [Report!1!TermCount],
	null as [Report!1!SubTermCount],
	null as [Report!1!EndTermID],
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
	null as [Report!1!ClassID],	
	null as [Report!1!EK],
	null as [Report!1!TermComments],
	null as [Report!1!GPA],
	null as [Report!1!PercentageAvg],
	null as [Report!1!SchoolAttendance],
	null as [Report!1!WorshipAttendance],
	null as [Report!1!EnlargeFont],
	null as [Report!1!SchoolName],
	null as [Report!1!SchoolAddress],
	null as [Report!1!SchoolPhone],
	null as [Report!1!CommentName],
	null as [Report!1!CommentAbbr],
	null as  [Report!1!Comment1],
	null as  [Report!1!Comment2],
	null as  [Report!1!Comment3],
	null as  [Report!1!Comment4],
	null as  [Report!1!Comment5],
	null as  [Report!1!Comment6],
	null as  [Report!1!Comment7],
	null as  [Report!1!Comment8],
	null as  [Report!1!Comment9],
	null as  [Report!1!Comment10],
	null as  [Report!1!Comment11],
	null as  [Report!1!Comment12],
	null as  [Report!1!Comment13],
	null as  [Report!1!Comment14],
	null as  [Report!1!Comment15],
	null as  [Report!1!Comment16],
	null as  [Report!1!Comment17],
	null as  [Report!1!Comment18],
	null as  [Report!1!Comment19],
	null as  [Report!1!Comment20],
	null as  [Report!1!Comment21],
	null as  [Report!1!Comment22],
	null as  [Report!1!Comment23],
	null as  [Report!1!Comment24],
	null as  [Report!1!Comment25],
	null as  [Report!1!Comment26],
	null as  [Report!1!Comment27],
	null as  [Report!1!Comment28],
	null as  [Report!1!Comment29],
	null as  [Report!1!Comment30],
	null as [Report!1!CommentRows],
	null as [Report!1!CategoryName],
	null as [Report!1!CategoryAbbr],
	null as [Report!1!Category1Symbol],
	null as [Report!1!Category1Desc],
	null as [Report!1!Category2Symbol],
	null as [Report!1!Category2Desc],
	null as [Report!1!Category3Symbol],
	null as [Report!1!Category3Desc],
	null as [Report!1!Category4Symbol],
	null as [Report!1!Category4Desc],	
	StudentID as [Student!2!StudentID],
	(Select xStudentID from Students where StudentID = RD.StudentID) as [Student!2!xStudentID],
	(Select Father from Students where StudentID = RD.StudentID) as [Student!2!Father],
	(Select Mother from Students where StudentID = RD.StudentID) as [Student!2!Mother],
	(Select Street from Students where StudentID = RD.StudentID) as [Student!2!Street],
	(Select City from Students where StudentID = RD.StudentID) as [Student!2!City],
	(Select State from Students where StudentID = RD.StudentID) as [Student!2!State],
	(Select Zip from Students where StudentID = RD.StudentID) as [Student!2!Zip],
	Fname as [Student!2!SFname],
	Mname as [Student!2!SMname],
	Lname as [Student!2!SLname],
	glname as [Student!2!Sglname],
	GradeLevel as [Student!2!GradeLevel],
	(
	Select top 1 YearlyGPA
	From #AvgGrades
	Where 
	StudentID = RD.StudentID	
	) as [Student!2!YearlyGPA],	
	(
	Select top 1 
	case
		when @GradeStyle = 'Letter' then
			dbo.GetLetterGrade2(CustomGradeScaleID, OverallPercentage)
		when @ShowTenthDecimalPoint = 'yes' then convert(nvarchar(10), convert(decimal(5,1), OverallPercentage)) COLLATE DATABASE_DEFAULT
		else convert(nvarchar(10), round(OverallPercentage,0))  COLLATE DATABASE_DEFAULT
	end	
	From #AvgGrades
	Where 
	StudentID = RD.StudentID
	and
	case
		when @DefaultName = 'Letter-Landscape2 Report Card' and ReportOrder < 20 then 1
		when @DefaultName != 'Letter-Landscape2 Report Card' then 1
		else 0
	end = 1	
	) as [Student!2!OverallGrade],		
	(	
		Select	top 1 Teacher
		From #tmpTeachers T
		Where T.StudentID = RD.StudentID
	) 
	as [Student!2!Teacher],
	case
		when sum(SchoolAtt1) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt1))) COLLATE DATABASE_DEFAULT
		when sum(SchoolAtt1) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt1))) COLLATE DATABASE_DEFAULT
		when sum(SchoolAtt1) % .1 < .1  and sum(SchoolAtt1) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt1),0))) COLLATE DATABASE_DEFAULT
		when sum(SchoolAtt1) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt1))) COLLATE DATABASE_DEFAULT
		else convert(nvarchar(6),sum(SchoolAtt1))  COLLATE DATABASE_DEFAULT
	end as [Student!2!SchoolAtt1Total],
	case
		when sum(SchoolAtt2) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt2))) COLLATE DATABASE_DEFAULT
		when sum(SchoolAtt2) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt2))) COLLATE DATABASE_DEFAULT
		when sum(SchoolAtt2) % .1 < .1  and sum(SchoolAtt2) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt2),0))) COLLATE DATABASE_DEFAULT
		when sum(SchoolAtt2) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt2))) COLLATE DATABASE_DEFAULT
		else convert(nvarchar(6),sum(SchoolAtt2))  COLLATE DATABASE_DEFAULT
	end as [Student!2!SchoolAtt2Total],
	case
		when sum(SchoolAtt3) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt3)))
		when sum(SchoolAtt3) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt3)))
		when sum(SchoolAtt3) % .1 < .1  and sum(SchoolAtt3) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt3),0)))
		when sum(SchoolAtt3) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt3)))
		else convert(nvarchar(6),sum(SchoolAtt3)) 
	end  COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt3Total],
	case
		when sum(SchoolAtt4) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt4)))
		when sum(SchoolAtt4) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt4)))
		when sum(SchoolAtt4) % .1 < .1  and sum(SchoolAtt4) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt4),0)))
		when sum(SchoolAtt4) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt4)))
		else convert(nvarchar(6),sum(SchoolAtt4)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt4Total],
	case
		when sum(SchoolAtt5) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt5)))
		when sum(SchoolAtt5) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt5)))
		when sum(SchoolAtt5) % .1 < .1  and sum(SchoolAtt5) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt5),0)))
		when sum(SchoolAtt5) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt5)))
		else convert(nvarchar(6),sum(SchoolAtt5)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt5Total],
	case
		when sum(SchoolAtt6) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt6)))
		when sum(SchoolAtt6) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt6)))
		when sum(SchoolAtt6) % .1 < .1  and sum(SchoolAtt6) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt6),0)))
		when sum(SchoolAtt6) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt6)))
		else convert(nvarchar(6),sum(SchoolAtt6)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt6Total],
	case
		when sum(SchoolAtt7) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt7)))
		when sum(SchoolAtt7) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt7)))
		when sum(SchoolAtt7) % .1 < .1  and sum(SchoolAtt7) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt7),0)))
		when sum(SchoolAtt7) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt7)))
		else convert(nvarchar(6),sum(SchoolAtt7)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt7Total],
	case
		when sum(SchoolAtt8) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt8)))
		when sum(SchoolAtt8) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt8)))
		when sum(SchoolAtt8) % .1 < .1  and sum(SchoolAtt8) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt8),0)))
		when sum(SchoolAtt8) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt8)))
		else convert(nvarchar(6),sum(SchoolAtt8)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt8Total],
	case
		when sum(SchoolAtt9) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt9)))
		when sum(SchoolAtt9) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt9)))
		when sum(SchoolAtt9) % .1 < .1  and sum(SchoolAtt9) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt9),0)))
		when sum(SchoolAtt9) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt9)))
		else convert(nvarchar(6),sum(SchoolAtt9)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt9Total],
	case
		when sum(SchoolAtt10) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt10)))
		when sum(SchoolAtt10) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt10)))
		when sum(SchoolAtt10) % .1 < .1  and sum(SchoolAtt10) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt10),0)))
		when sum(SchoolAtt10) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt10)))
		else convert(nvarchar(6),sum(SchoolAtt10)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt10Total],
	case
		when sum(SchoolAtt11) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt11)))
		when sum(SchoolAtt11) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt11)))
		when sum(SchoolAtt11) % .1 < .1  and sum(SchoolAtt11) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt11),0)))
		when sum(SchoolAtt11) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt11)))
		else convert(nvarchar(6),sum(SchoolAtt11)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt11Total],
	case
		when sum(SchoolAtt12) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt12)))
		when sum(SchoolAtt12) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt12)))
		when sum(SchoolAtt12) % .1 < .1  and sum(SchoolAtt12) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt12),0)))
		when sum(SchoolAtt12) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt12)))
		else convert(nvarchar(6),sum(SchoolAtt12)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt12Total],
	case
		when sum(SchoolAtt13) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt13)))
		when sum(SchoolAtt13) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt13)))
		when sum(SchoolAtt13) % .1 < .1  and sum(SchoolAtt13) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt13),0)))
		when sum(SchoolAtt13) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt13)))
		else convert(nvarchar(6),sum(SchoolAtt13)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt13Total],
	case
		when sum(SchoolAtt14) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt14)))
		when sum(SchoolAtt14) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt14)))
		when sum(SchoolAtt14) % .1 < .1  and sum(SchoolAtt14) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt14),0)))
		when sum(SchoolAtt14) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt14)))
		else convert(nvarchar(6),sum(SchoolAtt14)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt14Total],
	case
		when sum(SchoolAtt15) % 1 = 0 then convert(nvarchar(6),convert(int, sum(SchoolAtt15)))
		when sum(SchoolAtt15) % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), sum(SchoolAtt15)))
		when sum(SchoolAtt15) % .1 < .1  and sum(SchoolAtt15) % 1 > .9 then convert(nvarchar(6), convert(int,round(sum(SchoolAtt15),0)))
		when sum(SchoolAtt15) % .1 < .1 then convert(nvarchar(6),convert(decimal(6,2), sum(SchoolAtt15)))
		else convert(nvarchar(6),sum(SchoolAtt15)) 
	end COLLATE DATABASE_DEFAULT as [Student!2!SchoolAtt15Total],
	convert(nvarchar(6),sum(ChurchPresent)) COLLATE DATABASE_DEFAULT as [Student!2!ChurchPresentTotal],
	convert(nvarchar(6),sum(ChurchAbsent)) COLLATE DATABASE_DEFAULT as [Student!2!ChurchAbsentTotal],
	convert(nvarchar(6),sum(SSchoolPresent)) COLLATE DATABASE_DEFAULT as [Student!2!SSchoolPresentTotal],
	convert(nvarchar(6),sum(SSchoolAbsent)) COLLATE DATABASE_DEFAULT as [Student!2!SSchoolAbsentTotal],
	null as [ClassType!3!ClassTypeID],
	null as [ClassType!3!ClassTypeOrder],
	null as [ClassType!3!GradeScaleLegend],
	null as [ClassType!3!CommentRows],
	null as [ClassType!3!CommentName],
	null as  [ClassType!3!CommentAbbr],
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
	null as [ClassField!4!ParentClassID],
	null as [ClassField!4!ClassTitle],
	null as [ClassField!4!SpanishTitle],
	null as [ClassField!4!Teacher],
	null as [ClassField!4!ReportOrder],
	null as [ClassField!4!ClassUnits],
	null as [ClassField!4!ClassGrade],
	null as [ClassField!4!AvgGrade],
	null as [ClassField!4!Effort],
	null as [ClassField!4!ClassComments],
	null as [ClassField!4!FieldName],
	null as [ClassField!4!FieldSpanishName],
	null as [ClassField!4!FieldGrade],
	null as [ClassField!4!AvgFieldGrade],
	null as [ClassField!4!FieldOrder],
	null as [ClassField!4!FieldBolded],
	null as [ClassField!4!FieldNotGraded],
	null as [ClassField!4!Indent],
	null as [ClassField!4!Bullet],	
	null as [ClassField!4!TermID],
	null as [ClassField!4!TermType],
	null as [ClassField!4!StartTerm],
	null as [ClassField!4!TermReportTitle],
	null as [ClassField!4!TermEnd],
	null as [ClassField!4!TermGPA],
	null as [ClassField!4!TermPercentageAverage],
	null as [ClassField!4!TermComment],
	null as [ClassField!4!SAtt1],
	null as [ClassField!4!SPercAtt1],
	null as [ClassField!4!SAtt2],
	null as [ClassField!4!SPercAtt2],
	null as [ClassField!4!SAtt3],
	null as [ClassField!4!SPercAtt3],
	null as [ClassField!4!SAtt4],
	null as [ClassField!4!SPercAtt4],
	null as [ClassField!4!SAtt5],
	null as [ClassField!4!SPercAtt5],
	null as [ClassField!4!SAtt6],
	null as [ClassField!4!SPercAtt6],
	null as [ClassField!4!SAtt7],
	null as [ClassField!4!SPercAtt7],
	null as [ClassField!4!SAtt8],
	null as [ClassField!4!SPercAtt8],
	null as [ClassField!4!SAtt9],
	null as [ClassField!4!SPercAtt9],
	null as [ClassField!4!SAtt10],
	null as [ClassField!4!SPercAtt10],
	null as [ClassField!4!SAtt11],
	null as [ClassField!4!SPercAtt11],
	null as [ClassField!4!SAtt12],
	null as [ClassField!4!SPercAtt12],
	null as [ClassField!4!SAtt13],
	null as [ClassField!4!SPercAtt13],
	null as [ClassField!4!SAtt14],
	null as [ClassField!4!SPercAtt14],
	null as [ClassField!4!SAtt15],
	null as [ClassField!4!SPercAtt15],
	null as [ClassField!4!ChurchPresent],
	null as [ClassField!4!PercChurchPresent],
	null as [ClassField!4!ChurchAbsent],
	null as [ClassField!4!PercChurchAbsent],
	null as [ClassField!4!SSchoolPresent],
	null as [ClassField!4!PercSSchoolPresent],
	null as [ClassField!4!SSchoolAbsent],
	null as [ClassField!4!PercSSchoolAbsent],
	null as [ClassField!4!Att1],
	null as [ClassField!4!Att2],
	null as [ClassField!4!Att3],
	null as [ClassField!4!Att4],
	null as [ClassField!4!Att5],
	null as [ClassField!4!TermAtt1Total],
	null as [ClassField!4!TermAtt2Total],
	null as [ClassField!4!TermAtt3Total],
	null as [ClassField!4!TermAtt4Total],
	null as [ClassField!4!TermAtt5Total],	
	null as [ClassField!4!ClassShowPercentageGrade],
	null as [ClassField!4!StandardsItemType]

From #ReportCardData RD
Where GradeLevel is not null
Group By
StudentID,
Fname,
Mname,
Lname,
glname,
GradeLevel

Union All

Select Distinct
	3 as tag,
	2 as parent,
	null as [Report!1!ShowGPAasaPercentage],
	null as [Report!1!TeacherLabelText],
	null as [Report!1!YearAvgAlign],
	null as [Report!1!ShowStudentID],
	null as [Report!1!ShowStudentMailingAddressLabel],
	null as [Report!1!StudentMailingAddressLabelCSS],
	null as [Report!1!ShowGPATableCSS],
	null as [Report!1!ShowGradesAffectedAttendanceBox],
	null as [Report!1!ShowGPA],
	null as [Report!1!AddPageBreakBeforeClassAttendance],
	null as [Report!1!EnableStartingNewColumnOnSubgrades],
	null as [Report!1!ShowClassAttendanceTotals],
	null as [Report!1!GradeLevelLabelText],
	null as [Report!1!ShowEnglishLanguageArtsHeaderRow],
	null as [Report!1!StandardsCategoryFormat],
	null as [Report!1!StandardsMarzanoTopicFormat],
	null as [Report!1!StandardsSubCategoryFormat],	
	null as [Report!1!HideGradeLevel],
	null as [Report!1!CustomHTMLSectionAboveStandardClassTitle],
	null as [Report!1!StandardClassesCustomHTMLSection],	
	null as [Report!1!CustomClassesSubjectHeadingText],
	null as [Report!1!StandardClassesSubjectHeadingText],	
	null as [Report!1!StartRightColumnStandardClassTitle1],
	null as [Report!1!StartRightColumnStandardClassTitle2],
	null as [Report!1!StartRightColumnStandardClassTitle3],
	null as [Report!1!StartRightColumnStandardClassTitle4],
	null as [Report!1!StartRightColumnStandardClassTitle5],
	null as [Report!1!PageBreakbeforeStandardClassTitle1],
	null as [Report!1!PageBreakbeforeStandardClassTitle2],
	null as [Report!1!PageBreakbeforeStandardClassTitle3],
	null as [Report!1!PageBreakbeforeStandardClassTitle4],
	null as [Report!1!PageBreakbeforeStandardClassTitle5],
	null as [Report!1!StartRightColumnCustomClassTitle1],
	null as [Report!1!StartRightColumnCustomClassTitle2],
	null as [Report!1!StartRightColumnCustomClassTitle3],
	null as [Report!1!StartRightColumnCustomClassTitle4],
	null as [Report!1!StartRightColumnCustomClassTitle5],
	null as [Report!1!PageBreakbeforeCustomClassTitle1],
	null as [Report!1!PageBreakbeforeCustomClassTitle2],
	null as [Report!1!PageBreakbeforeCustomClassTitle3],
	null as [Report!1!PageBreakbeforeCustomClassTitle4],
	null as [Report!1!PageBreakbeforeCustomClassTitle5],
	null as [Report!1!StandardClassGradeColumnWidth],	
	null as [Report!1!CustomClassGradeColumnWidth],
	null as [Report!1!RenderWebpageInStandardsMode],
	null as [Report!1!PDFEngine],
	null as [Report!1!isPDF],		
	null as [Report!1!AdjustNumCommentsWidth],
	null as [Report!1!StandardClassPageBreakTitle],
	null as [Report!1!StandardClassPageBreakTitle2],
	null as [Report!1!StandardClassPageBreakTitle3],
	null as [Report!1!StandardClassPageBreakTitle4],
	null as [Report!1!StandardClassPageBreakTitle5],
	null as [Report!1!TopLeftHTML],
	null as [Report!1!BottomHTML],
	null as [Report!1!NumberedCommentsHTML],		
	null as [Report!1!UseTermReportTitleOnTermComments],
	null as [Report!1!CalculateGPAto3Decimals],
	null as [Report!1!ADPFormat], 
	null as [Report!1!GradeImageHeight],
	null as [Report!1!SubgradeMarkAlignment], 
	null as [Report!1!EnableLargeSingleTermCommentBox],
	null as [Report!1!LatestCommentTermID],
	null as [Report!1!SupportAccount],
	null as [Report!1!StandardClassesCustomLegendHTML],
	null as [Report!1!ShowClassCategoryLegend],
	null as [Report!1!SubGradeExist],
	null as [Report!1!ProfileID],
	null as [Report!1!DisplayGradeLevelAs],
	null as [Report!1!ShowBothLetterAndPercentageGrade],
	null as [Report!1!ShowTeacherNameForEachSubject],
	null as [Report!1!TurnOffPreviewModeGraphic],
	null as [Report!1!LeftAlignClassTitle],	
	null as [Report!1!PageHeight],
	null as [Report!1!GradeHeadingAbbr],
	null as [Report!1!GradeHeadingTitle],
	null as [Report!1!PageBreaks],
	null as [Report!1!StandardGradeScaleLegend],
	null as [Report!1!ReportTitle],
	null as [Report!1!ShowOverallGrade],
	null as [Report!1!GradePlacement],
	null as [Report!1!DefaultName],
	null as [Report!1!DisplayName],	
	null as [Report!1!TopMargin],
	null as [Report!1!ShowAttendancePercentages],
	null as [Report!1!WorshipAttendanceChurchTitle],
	null as [Report!1!WorshipAttendanceBibleClassTitle],
	null as [Report!1!ShowGradeScaleForCustomClasses],
	null as [Report!1!SchoolAttendanceTitle],
	null as [Report!1!ShowTeacherNameOnTermComments],
	null as [Report!1!ForceSemesterGrade],
	null as [Report!1!ShowClassAttendance],
	null as [Report!1!ShowClassCredits],
	null as [Report!1!ShowClassEffort],
	null as [Report!1!ShowNumberedComments],
	null as [Report!1!ShowGradeScaleLegend],
	null as [Report!1!StandardClassesReportOrder],
	null as [Report!1!ShowSchoolNameAddress],
	null as [Report!1!ShowTeacherName],
	null as [Report!1!ShowSubjectTeacherName],
	null as [Report!1!FootnoteText],
	null as [Report!1!TurnOffBlackBackgrounds],
	null as [Report!1!ShowInsideTopLeftStudentInfo],
	null as [Report!1!ShowGeneralAverageGrade],	
	null as [Report!1!TDLineHeight],
	null as [Report!1!EnableSpanishSupport],
	null as [Report!1!EnableRightToLeft],
	null as [Report!1!PrincipalName],
	null as [Report!1!HideEndofYearGradeColumn],
	null as [Report!1!CustomClassTypesOnInsideRight],
	null as [Report!1!PageBreak1],
	null as [Report!1!PageBreak2],
	null as [Report!1!PageBreak3],
	null as [Report!1!PageBreak4],
	null as [Report!1!PageBreak5],
	null as [Report!1!FooterHTML],
	null as [Report!1!InsideTopLeftHTML],
	null as [Report!1!InsideMiddleLeftHTML],
	null as [Report!1!InsideBottomLeftHTML],
	null as [Report!1!InsideTopRightHTML],
	null as [Report!1!InsideMiddleRightHTML],
	null as [Report!1!BackPageMiddleHTML],
	null as [Report!1!BackPageBottomHTML],		
	null as [Report!1!FrontPageHTML],
	null as [Report!1!WatermarkHTML],
	null as [Report!1!BackPageHTML],
	null as [Report!1!LeftBackPageHTML],
	null as [Report!1!MiddleBackPageHTML],	
	null as [Report!1!PrincipalSignatureHTML],
	null as [Report!1!AchievementCommentHTML],
	null as [Report!1!TopFrontPageHTML],
	null as [Report!1!BottomFrontPageHTML],
	null as [Report!1!FrontPageGraphicHTML],
	null as [Report!1!InsideLeftSectionHTML],
	null as [Report!1!InsideRightSectionHTML],
	null as [Report!1!TopLeftTitleHTML],
	null as [Report!1!TopLeftGraphicHTML],
	null as [Report!1!TopRightTitleHTML],
	null as [Report!1!EvaluationKeyHTML],
	null as [Report!1!TeacherSignatureHTML],
	null as [Report!1!BackgroundImageHTML],
	null as [Report!1!FirstCustomClassTypeID],
	null as [Report!1!LastCustomClassTypeID],	
	null as [Report!1!TheTermTitle],
	null as [Report!1!PrincipalTeacherSignatureTitle],
	null as [Report!1!ShowOnlyChurchAttendance],
	null as [Report!1!CondenseClasses],
	null as [Report!1!BulletTopMargin],
	null as [Report!1!ClassTitleFontSize],
	null as [Report!1!SubgradeTitleFontSize],
	null as [Report!1!ClassSubgradeCellHeight],
	null as [Report!1!YearAvgTitle],
	null as [Report!1!ShowYearlyAvg],
	null as [Report!1!ShowPrincipalSignature],
	null as [Report!1!ShowTeacherSignature],	
	null as [Report!1!ShowParentSignatureLine],
	null as [Report!1!ShowGradePlacement],
	null as [Report!1!ProfileTeacherName],
	null as [Report!1!SecondColumnStartClass],
	null as [Report!1!ThirdColumnStartClass],
	null as [Report!1!LastCommentNumberToBold],
	null as [Report!1!SchoolworkAffected],
	null as [Report!1!SchoolYear],
	null as [Report!1!NextSchoolYear],
	null as [Report!1!TermCount],
	null as [Report!1!SubTermCount],
	null as [Report!1!EndTermID],
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
	null as [Report!1!ClassID],	
	null as [Report!1!EK],
	null as [Report!1!TermComments],
	null as [Report!1!GPA],
	null as [Report!1!PercentageAvg],
	null as [Report!1!SchoolAttendance],
	null as [Report!1!WorshipAttendance],
	null as [Report!1!EnlargeFont],
	null as [Report!1!SchoolName],
	null as [Report!1!SchoolAddress],
	null as [Report!1!SchoolPhone],
	null as [Report!1!CommentName],
	null as [Report!1!CommentAbbr],
	null as  [Report!1!Comment1],
	null as  [Report!1!Comment2],
	null as  [Report!1!Comment3],
	null as  [Report!1!Comment4],
	null as  [Report!1!Comment5],
	null as  [Report!1!Comment6],
	null as  [Report!1!Comment7],
	null as  [Report!1!Comment8],
	null as  [Report!1!Comment9],
	null as  [Report!1!Comment10],
	null as  [Report!1!Comment11],
	null as  [Report!1!Comment12],
	null as  [Report!1!Comment13],
	null as  [Report!1!Comment14],
	null as  [Report!1!Comment15],
	null as  [Report!1!Comment16],
	null as  [Report!1!Comment17],
	null as  [Report!1!Comment18],
	null as  [Report!1!Comment19],
	null as  [Report!1!Comment20],
	null as  [Report!1!Comment21],
	null as  [Report!1!Comment22],
	null as  [Report!1!Comment23],
	null as  [Report!1!Comment24],
	null as  [Report!1!Comment25],
	null as  [Report!1!Comment26],
	null as  [Report!1!Comment27],
	null as  [Report!1!Comment28],
	null as  [Report!1!Comment29],
	null as  [Report!1!Comment30],
	null as [Report!1!CommentRows],
	null as [Report!1!CategoryName],
	null as [Report!1!CategoryAbbr],
	null as [Report!1!Category1Symbol],
	null as [Report!1!Category1Desc],
	null as [Report!1!Category2Symbol],
	null as [Report!1!Category2Desc],
	null as [Report!1!Category3Symbol],
	null as [Report!1!Category3Desc],
	null as [Report!1!Category4Symbol],
	null as [Report!1!Category4Desc],
	StudentID as [Student!2!StudentID],
	null as [Student!2!xStudentID],
	null as [Student!2!Father],
	null as [Student!2!Mother],
	null as [Student!2!Street],
	null as [Student!2!City],
	null as [Student!2!State],
	null as [Student!2!Zip],
	Fname as [Student!2!SFname],
	Mname as [Student!2!SMname],
	Lname as [Student!2!SLname],
	glname as [Student!2!Sglname],
	null as [Student!2!GradeLevel],
	null as [Student!2!YearlyGPA],
	null as [Student!2!OverallGrade],
	null as [Student!2!Teacher],
	null as [Student!2!SchoolAtt1Total],
	null as [Student!2!SchoolAtt2Total],
	null as [Student!2!SchoolAtt3Total],
	null as [Student!2!SchoolAtt4Total],
	null as [Student!2!SchoolAtt5Total],
	null as [Student!2!SchoolAtt6Total],
	null as [Student!2!SchoolAtt7Total],
	null as [Student!2!SchoolAtt8Total],
	null as [Student!2!SchoolAtt9Total],
	null as [Student!2!SchoolAtt10Total],
	null as [Student!2!SchoolAtt11Total],
	null as [Student!2!SchoolAtt12Total],
	null as [Student!2!SchoolAtt13Total],
	null as [Student!2!SchoolAtt14Total],
	null as [Student!2!SchoolAtt15Total],
	null as [Student!2!ChurchPresentTotal],
	null as [Student!2!ChurchAbsentTotal],
	null as [Student!2!SSchoolPresentTotal],
	null as [Student!2!SSchoolAbsentTotal],
	ClassTypeID as [ClassType!3!ClassTypeID],
	Isnull((
	Select top 1 ClassTypeOrder
	From @ReportOrderTable
	Where ClassTypeID = RD.ClassTypeID
	), 9999) as [ClassType!3!ClassTypeOrder],
	GradeScaleLegend as [ClassType!3!GradeScaleLegend],
	case
		when (Select Top 1 Comment1 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 0
		when (Select Top 1 Comment4 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 1
		when (Select Top 1 Comment7 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 2
		when (Select Top 1 Comment10 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 3
		when (Select Top 1 Comment13 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 4
		when (Select Top 1 Comment16 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 5
		when (Select Top 1 Comment19 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 6
		when (Select Top 1 Comment22 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 7
		when (Select Top 1 Comment25 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 8
		when (Select Top 1 Comment28 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) is null then 9
		else 10
	end as [ClassType!3!CommentRows],
	(Select Top 1 CommentName From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as [ClassType!3!CommentName],
	(Select Top 1 CommentAbbr From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!CommentAbbr],
	(Select Top 1 Comment1 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment1],
	(Select Top 1 Comment2 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment2],
	(Select Top 1 Comment3 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment3],
	(Select Top 1 Comment4 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment4],
	(Select Top 1 Comment5 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment5],
	(Select Top 1 Comment6 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment6],
	(Select Top 1 Comment7 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment7],
	(Select Top 1 Comment8 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment8],
	(Select Top 1 Comment9 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment9],
	(Select Top 1 Comment10 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment10],
	(Select Top 1 Comment11 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment11],
	(Select Top 1 Comment12 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment12],
	(Select Top 1 Comment13 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment13],
	(Select Top 1 Comment14 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment14],
	(Select Top 1 Comment15 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment15],
	(Select Top 1 Comment16 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment16],
	(Select Top 1 Comment17 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment17],
	(Select Top 1 Comment18 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment18],
	(Select Top 1 Comment19 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment19],
	(Select Top 1 Comment20 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment20],
	(Select Top 1 Comment21 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment21],
	(Select Top 1 Comment22 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment22],
	(Select Top 1 Comment23 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment23],
	(Select Top 1 Comment24 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment24],
	(Select Top 1 Comment25 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment25],
	(Select Top 1 Comment26 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment26],
	(Select Top 1 Comment27 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment27],
	(Select Top 1 Comment28 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment28],
	(Select Top 1 Comment29 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment29],
	(Select Top 1 Comment30 From @CommentData where ClassTypeID = RD.ClassTypeID Order By 1 desc) as  [ClassType!3!Comment30],
	null as [ClassField!4!ParentClassID],
	null as [ClassField!4!ClassTitle],
	null as [ClassField!4!SpanishTitle],
	null as [ClassField!4!Teacher],
	null as [ClassField!4!ReportOrder],
	null as [ClassField!4!ClassUnits],
	null as [ClassField!4!ClassGrade],
	null as [ClassField!4!AvgGrade],
	null as [ClassField!4!Effort],
	null as [ClassField!4!ClassComments],
	null as [ClassField!4!FieldName],
	null as [ClassField!4!FieldSpanishName],
	null as [ClassField!4!FieldGrade],
	null as [ClassField!4!AvgFieldGrade],
	null as [ClassField!4!FieldOrder],
	null as [ClassField!4!FieldBolded],
	null as [ClassField!4!FieldNotGraded],
	null as [ClassField!4!Indent],
	null as [ClassField!4!Bullet],
	null as [ClassField!4!TermID],
	null as [ClassField!4!TermType],
	null as [ClassField!4!StartTerm],
	null as [ClassField!4!TermReportTitle],
	null as [ClassField!4!TermEnd],
	null as [ClassField!4!TermGPA],
	null as [ClassField!4!TermPercentageAverage],
	null as [ClassField!4!TermComment],
	null as [ClassField!4!SAtt1],
	null as [ClassField!4!SPercAtt1],
	null as [ClassField!4!SAtt2],
	null as [ClassField!4!SPercAtt2],
	null as [ClassField!4!SAtt3],
	null as [ClassField!4!SPercAtt3],
	null as [ClassField!4!SAtt4],
	null as [ClassField!4!SPercAtt4],
	null as [ClassField!4!SAtt5],
	null as [ClassField!4!SPercAtt5],
	null as [ClassField!4!SAtt6],
	null as [ClassField!4!SPercAtt6],
	null as [ClassField!4!SAtt7],
	null as [ClassField!4!SPercAtt7],
	null as [ClassField!4!SAtt8],
	null as [ClassField!4!SPercAtt8],
	null as [ClassField!4!SAtt9],
	null as [ClassField!4!SPercAtt9],
	null as [ClassField!4!SAtt10],
	null as [ClassField!4!SPercAtt10],
	null as [ClassField!4!SAtt11],
	null as [ClassField!4!SPercAtt11],
	null as [ClassField!4!SAtt12],
	null as [ClassField!4!SPercAtt12],
	null as [ClassField!4!SAtt13],
	null as [ClassField!4!SPercAtt13],
	null as [ClassField!4!SAtt14],
	null as [ClassField!4!SPercAtt14],
	null as [ClassField!4!SAtt15],
	null as [ClassField!4!SPercAtt15],
	null as [ClassField!4!ChurchPresent],
	null as [ClassField!4!PercChurchPresent],
	null as [ClassField!4!ChurchAbsent],
	null as [ClassField!4!PercChurchAbsent],
	null as [ClassField!4!SSchoolPresent],
	null as [ClassField!4!PercSSchoolPresent],
	null as [ClassField!4!SSchoolAbsent],
	null as [ClassField!4!PercSSchoolAbsent],
	null as [ClassField!4!Att1],
	null as [ClassField!4!Att2],
	null as [ClassField!4!Att3],
	null as [ClassField!4!Att4],
	null as [ClassField!4!Att5],
	null as [ClassField!4!TermAtt1Total],
	null as [ClassField!4!TermAtt2Total],
	null as [ClassField!4!TermAtt3Total],
	null as [ClassField!4!TermAtt4Total],
	null as [ClassField!4!TermAtt5Total],		
	null as [ClassField!4!ClassShowPercentageGrade],
	null as [ClassField!4!StandardsItemType]

From #ReportCardData RD
Where
ClassTitle is not null
--and
--case 
--	when ClassTypeID = 6 and @ShowWorshipAttendance = 'no' then 0
--	else 1
--end = 1
--and
--ExamTerm = 0		-- Exclude Exam Terms as it was causing duplicate records due to exam terms not havnig a gradescale legend


-- I removed this code from above and replaced it with the above code which is the same Where code for the query below.
-- It was causing the following issue: FD:383999 / DK-3268
-- Remove this later if no issues found dp - 7/19/2022
--case 
--	when ClassTypeID = 6 and @ShowWorshipAttendance = 'no' then 0
--	when @RunOnUnconcludedClassesCheckBox = 'on' then 1
--	when TranscriptID is not null and GradeScaleLegend is not null then 1
--	else 0
--end = 1 
-- This needed to be updated again as it caused an issue with 904 where the Attendance class was showing twice
-- I fixed this by adding
-- where ExamTerm = 0	

-- So if further modifications are needed just be sure to check it against 904 and 1709
-- FD:383999 / DK-3268 and FD:383999 / DK-3268


Union All



Select Distinct
	4 as tag,
	3 as parent,
	null as [Report!1!ShowGPAasaPercentage],
	null as [Report!1!TeacherLabelText],
	null as [Report!1!YearAvgAlign],
	null as [Report!1!ShowStudentID],
	null as [Report!1!ShowStudentMailingAddressLabel],
	null as [Report!1!StudentMailingAddressLabelCSS],
	null as [Report!1!ShowGPATableCSS],
	null as [Report!1!ShowGradesAffectedAttendanceBox],
	null as [Report!1!ShowGPA],
	null as [Report!1!AddPageBreakBeforeClassAttendance],
	null as [Report!1!EnableStartingNewColumnOnSubgrades],
	null as [Report!1!ShowClassAttendanceTotals],
	null as [Report!1!GradeLevelLabelText],
	null as [Report!1!ShowEnglishLanguageArtsHeaderRow],
	null as [Report!1!StandardsCategoryFormat],
	null as [Report!1!StandardsMarzanoTopicFormat],
	null as [Report!1!StandardsSubCategoryFormat],	
	null as [Report!1!HideGradeLevel],
	null as [Report!1!CustomHTMLSectionAboveStandardClassTitle],
	null as [Report!1!StandardClassesCustomHTMLSection],	
	null as [Report!1!CustomClassesSubjectHeadingText],
	null as [Report!1!StandardClassesSubjectHeadingText],	
	null as [Report!1!StartRightColumnStandardClassTitle1],
	null as [Report!1!StartRightColumnStandardClassTitle2],
	null as [Report!1!StartRightColumnStandardClassTitle3],
	null as [Report!1!StartRightColumnStandardClassTitle4],
	null as [Report!1!StartRightColumnStandardClassTitle5],
	null as [Report!1!PageBreakbeforeStandardClassTitle1],
	null as [Report!1!PageBreakbeforeStandardClassTitle2],
	null as [Report!1!PageBreakbeforeStandardClassTitle3],
	null as [Report!1!PageBreakbeforeStandardClassTitle4],
	null as [Report!1!PageBreakbeforeStandardClassTitle5],
	null as [Report!1!StartRightColumnCustomClassTitle1],
	null as [Report!1!StartRightColumnCustomClassTitle2],
	null as [Report!1!StartRightColumnCustomClassTitle3],
	null as [Report!1!StartRightColumnCustomClassTitle4],
	null as [Report!1!StartRightColumnCustomClassTitle5],
	null as [Report!1!PageBreakbeforeCustomClassTitle1],
	null as [Report!1!PageBreakbeforeCustomClassTitle2],
	null as [Report!1!PageBreakbeforeCustomClassTitle3],
	null as [Report!1!PageBreakbeforeCustomClassTitle4],
	null as [Report!1!PageBreakbeforeCustomClassTitle5],
	null as [Report!1!StandardClassGradeColumnWidth],	
	null as [Report!1!CustomClassGradeColumnWidth],
	null as [Report!1!RenderWebpageInStandardsMode],
	null as [Report!1!PDFEngine],
	null as [Report!1!isPDF],		
	null as [Report!1!AdjustNumCommentsWidth],
	null as [Report!1!StandardClassPageBreakTitle],
	null as [Report!1!StandardClassPageBreakTitle2],
	null as [Report!1!StandardClassPageBreakTitle3],
	null as [Report!1!StandardClassPageBreakTitle4],
	null as [Report!1!StandardClassPageBreakTitle5],
	null as [Report!1!TopLeftHTML],
	null as [Report!1!BottomHTML],
	null as [Report!1!NumberedCommentsHTML],		
	null as [Report!1!UseTermReportTitleOnTermComments],
	null as [Report!1!CalculateGPAto3Decimals],
	null as [Report!1!ADPFormat], 
	null as [Report!1!GradeImageHeight],
	null as [Report!1!SubgradeMarkAlignment], 
	null as [Report!1!EnableLargeSingleTermCommentBox],
	null as [Report!1!LatestCommentTermID],
	null as [Report!1!SupportAccount],
	null as [Report!1!StandardClassesCustomLegendHTML],
	null as [Report!1!ShowClassCategoryLegend],
	null as [Report!1!SubGradeExist],
	null as [Report!1!ProfileID],
	null as [Report!1!DisplayGradeLevelAs],
	null as [Report!1!ShowBothLetterAndPercentageGrade],
	null as [Report!1!ShowTeacherNameForEachSubject],
	null as [Report!1!TurnOffPreviewModeGraphic],
	null as [Report!1!LeftAlignClassTitle],	
	null as [Report!1!PageHeight],
	null as [Report!1!GradeHeadingAbbr],
	null as [Report!1!GradeHeadingTitle],
	null as [Report!1!PageBreaks],
	null as [Report!1!StandardGradeScaleLegend],
	null as [Report!1!ReportTitle],
	null as [Report!1!ShowOverallGrade],
	null as [Report!1!GradePlacement],
	null as [Report!1!DefaultName],
	null as [Report!1!DisplayName],
	null as [Report!1!TopMargin],
	null as [Report!1!ShowAttendancePercentages],
	null as [Report!1!WorshipAttendanceChurchTitle],
	null as [Report!1!WorshipAttendanceBibleClassTitle],
	null as [Report!1!ShowGradeScaleForCustomClasses],
	null as [Report!1!SchoolAttendanceTitle],
	null as [Report!1!ShowTeacherNameOnTermComments],
	null as [Report!1!ForceSemesterGrade],
	null as [Report!1!ShowClassAttendance],
	null as [Report!1!ShowClassCredits],
	null as [Report!1!ShowClassEffort],
	null as [Report!1!ShowNumberedComments],
	null as [Report!1!ShowGradeScaleLegend],
	null as [Report!1!StandardClassesReportOrder],
	null as [Report!1!ShowSchoolNameAddress],
	null as [Report!1!ShowTeacherName],
	null as [Report!1!ShowSubjectTeacherName],
	null as [Report!1!FootnoteText],
	null as [Report!1!TurnOffBlackBackgrounds],
	null as [Report!1!ShowInsideTopLeftStudentInfo],
	null as [Report!1!ShowGeneralAverageGrade],
	null as [Report!1!TDLineHeight],
	null as [Report!1!EnableSpanishSupport],
	null as [Report!1!EnableRightToLeft],
	null as [Report!1!PrincipalName],
	null as [Report!1!HideEndofYearGradeColumn],
	null as [Report!1!CustomClassTypesOnInsideRight],
	null as [Report!1!PageBreak1],
	null as [Report!1!PageBreak2],
	null as [Report!1!PageBreak3],
	null as [Report!1!PageBreak4],
	null as [Report!1!PageBreak5],
	null as [Report!1!FooterHTML],
	null as [Report!1!InsideTopLeftHTML],
	null as [Report!1!InsideMiddleLeftHTML],
	null as [Report!1!InsideBottomLeftHTML],
	null as [Report!1!InsideTopRightHTML],
	null as [Report!1!InsideMiddleRightHTML],
	null as [Report!1!BackPageMiddleHTML],
	null as [Report!1!BackPageBottomHTML],		
	null as [Report!1!FrontPageHTML],
	null as [Report!1!WatermarkHTML],
	null as [Report!1!BackPageHTML],
	null as [Report!1!LeftBackPageHTML],
	null as [Report!1!MiddleBackPageHTML],
	null as [Report!1!PrincipalSignatureHTML],
	null as [Report!1!AchievementCommentHTML],
	null as [Report!1!TopFrontPageHTML],
	null as [Report!1!BottomFrontPageHTML],
	null as [Report!1!FrontPageGraphicHTML],
	null as [Report!1!InsideLeftSectionHTML],
	null as [Report!1!InsideRightSectionHTML],
	null as [Report!1!TopLeftTitleHTML],
	null as [Report!1!TopLeftGraphicHTML],
	null as [Report!1!TopRightTitleHTML],
	null as [Report!1!EvaluationKeyHTML],
	null as [Report!1!TeacherSignatureHTML],
	null as [Report!1!BackgroundImageHTML],	
	null as [Report!1!FirstCustomClassTypeID],
	null as [Report!1!LastCustomClassTypeID],	
	null as [Report!1!TheTermTitle],
	null as [Report!1!PrincipalTeacherSignatureTitle],	
	null as [Report!1!ShowOnlyChurchAttendance],
	null as [Report!1!CondenseClasses],
	null as [Report!1!BulletTopMargin],
	null as [Report!1!ClassTitleFontSize],
	null as [Report!1!SubgradeTitleFontSize],
	null as [Report!1!ClassSubgradeCellHeight],
	null as [Report!1!YearAvgTitle],
	null as [Report!1!ShowYearlyAvg],
	null as [Report!1!ShowPrincipalSignature],
	null as [Report!1!ShowTeacherSignature],	
	null as [Report!1!ShowParentSignatureLine],
	null as [Report!1!ShowGradePlacement],
	null as [Report!1!ProfileTeacherName],
	null as [Report!1!SecondColumnStartClass],
	null as [Report!1!ThirdColumnStartClass],
	null as [Report!1!LastCommentNumberToBold],
	null as [Report!1!SchoolworkAffected],
	null as [Report!1!SchoolYear],
	null as [Report!1!NextSchoolYear],
	null as [Report!1!TermCount],
	null as [Report!1!SubTermCount],
	null as [Report!1!EndTermID],
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
	null as [Report!1!ClassID],	
	null as [Report!1!EK],
	null as [Report!1!TermComments],
	null as [Report!1!GPA],
	null as [Report!1!PercentageAvg],
	null as [Report!1!SchoolAttendance],
	null as [Report!1!WorshipAttendance],
	null as [Report!1!EnlargeFont],
	null as [Report!1!SchoolName],
	null as [Report!1!SchoolAddress],
	null as [Report!1!SchoolPhone],
	null as [Report!1!CommentName],
	null as [Report!1!CommentAbbr],
	null as  [Report!1!Comment1],
	null as  [Report!1!Comment2],
	null as  [Report!1!Comment3],
	null as  [Report!1!Comment4],
	null as  [Report!1!Comment5],
	null as  [Report!1!Comment6],
	null as  [Report!1!Comment7],
	null as  [Report!1!Comment8],
	null as  [Report!1!Comment9],
	null as  [Report!1!Comment10],
	null as  [Report!1!Comment11],
	null as  [Report!1!Comment12],
	null as  [Report!1!Comment13],
	null as  [Report!1!Comment14],
	null as  [Report!1!Comment15],
	null as  [Report!1!Comment16],
	null as  [Report!1!Comment17],
	null as  [Report!1!Comment18],
	null as  [Report!1!Comment19],
	null as  [Report!1!Comment20],
	null as  [Report!1!Comment21],
	null as  [Report!1!Comment22],
	null as  [Report!1!Comment23],
	null as  [Report!1!Comment24],
	null as  [Report!1!Comment25],
	null as  [Report!1!Comment26],
	null as  [Report!1!Comment27],
	null as  [Report!1!Comment28],
	null as  [Report!1!Comment29],
	null as  [Report!1!Comment30],
	null as [Report!1!CommentRows],
	null as [Report!1!CategoryName],
	null as [Report!1!CategoryAbbr],
	null as [Report!1!Category1Symbol],
	null as [Report!1!Category1Desc],
	null as [Report!1!Category2Symbol],
	null as [Report!1!Category2Desc],
	null as [Report!1!Category3Symbol],
	null as [Report!1!Category3Desc],
	null as [Report!1!Category4Symbol],
	null as [Report!1!Category4Desc],
	StudentID as [Student!2!StudentID],
	null as [Student!2!xStudentID],
	null as [Student!2!Father],
	null as [Student!2!Mother],
	null as [Student!2!Street],
	null as [Student!2!City],
	null as [Student!2!State],
	null as [Student!2!Zip],
	Fname as [Student!2!SFname],
	Mname as [Student!2!SMname],
	Lname as [Student!2!SLname],
	glname as [Student!2!Sglname],
	null as [Student!2!GradeLevel],
	null as [Student!2!YearlyGPA],
	null as [Student!2!OverallGrade],
	null as [Student!2!Teacher],
	null as [Student!2!SchoolAtt1Total],
	null as [Student!2!SchoolAtt2Total],
	null as [Student!2!SchoolAtt3Total],
	null as [Student!2!SchoolAtt4Total],
	null as [Student!2!SchoolAtt5Total],
	null as [Student!2!SchoolAtt6Total],
	null as [Student!2!SchoolAtt7Total],
	null as [Student!2!SchoolAtt8Total],
	null as [Student!2!SchoolAtt9Total],
	null as [Student!2!SchoolAtt10Total],
	null as [Student!2!SchoolAtt11Total],
	null as [Student!2!SchoolAtt12Total],
	null as [Student!2!SchoolAtt13Total],
	null as [Student!2!SchoolAtt14Total],
	null as [Student!2!SchoolAtt15Total],
	null as [Student!2!ChurchPresentTotal],
	null as [Student!2!ChurchAbsentTotal],
	null as [Student!2!SSchoolPresentTotal],
	null as [Student!2!SSchoolAbsentTotal],
	ClassTypeID as [ClassType!3!ClassTypeID],
	Isnull((
	Select top 1 ClassTypeOrder
	From @ReportOrderTable
	Where ClassTypeID = RD.ClassTypeID
	), 9999) as [ClassType!3!ClassTypeOrder],
	null as [ClassType!3!GradeScaleLegend],
	null as [ClassType!3!CommentRows],
	null as [ClassType!3!CommentName],
	null as  [ClassType!3!CommentAbbr],
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
	ParentClassID as [ClassField!4!ParentClassID],	
	ClassTitle as [ClassField!4!ClassTitle],
	SpanishTitle as [ClassField!4!SpanishTitle],
	case
		when StaffTitle is null then TFname + ' ' + TLname
		when rtrim(StaffTitle) = '' then TFname + ' ' + TLname
		else StaffTitle + ' ' + TLname
	end as [ClassField!4!Teacher],
	ReportOrder as [ClassField!4!ReportOrder],
	dbo.trimzeros2(ClassUnits) as [ClassField!4!ClassUnits],
	ClassReportGrade as [ClassField!4!ClassGrade],
	case 
		when ParentClassID = 0 then ClassReportAvgGrade
		else ''
	end as [ClassField!4!AvgGrade],

	case Effort
		when 1 then @Category1Symbol
		when 2 then @Category2Symbol
		when 3 then @Category3Symbol
		when 4 then @Category4Symbol
	end as [ClassField!4!Effort],
	ClassComments as [ClassField!4!ClassComments],
	CustomFieldName as [ClassField!4!FieldName],
	CustomFieldSpanishName as [ClassField!4!FieldSpanishName],
	case 
		when replace(isnull(CustomFieldGrade,''), ' ', '') = '' then ''
		when CustomFieldGrade = @SubgradeNoGradeSymbol then @SubgradeNoGradeSymbol
		when CustomFieldOrder < 0 and @AssignmentTypeSubgradeFormat = 'letter' then  dbo.GetLetterGrade2(CustomGradeScaleID, CustomFieldGrade)
		when CustomFieldOrder < 0 and @AssignmentTypeSubgradeFormat = 'both' then  dbo.GetLetterGrade2(CustomGradeScaleID, CustomFieldGrade) + '('+ CustomFieldGrade + ')'
		else replace(CustomFieldGrade, ' ', '') 
	end as [ClassField!4!FieldGrade],
	-- Commented this code out and replaced it with the code below.. not sure why it was like this but it caused
	-- the following issue where the AvgFieldGrade was set to '' resulting in DK-3196 / FD #381269 
	--  if this causes other issues we'll have to reveiw both scenarios when updating. - dp 2022/6/15
	--case 
	--	when ParentClassID = 0 then ''
	--	else
	--		(
	--			Select CustomAvgGrade
	--			From #CustomAvgGrades
	--			Where 
	--			StudentID = RD.StudentID
	--			and
	--			ClassTitle = RD.ClassTitle
	--		) 
	--end as [ClassField!4!AvgFieldGrade],	
	(
		Select CustomAvgGrade
		From #CustomAvgGrades
		Where 
		StudentID = RD.StudentID
		and
		ClassTitle = RD.ClassTitle
	) as [ClassField!4!AvgFieldGrade],		
	CustomFieldOrder as [ClassField!4!FieldOrder],
	FieldBolded as [ClassField!4!FieldBolded],
	FieldNotGraded as [ClassField!4!FieldNotGraded],
	Indent as [ClassField!4!Indent],
	Bullet as [ClassField!4!Bullet],
	TermID as [ClassField!4!TermID],
	case
	  when ExamTerm = 1 then 'xExamTerm'
	  when ParentTermID > 0 then 'SubTerm'
	  when exists (Select * From @ParentTermIDs Where TermID = RD.TermID) then 'xParentTerm'
	  else	'xRegularTerm'
	end as [ClassField!4!TermType],
	case
		when TermID = @StartTermID then 1
		else 0
	end as [ClassField!4!StartTerm],
	TermReportTitle as [ClassField!4!TermReportTitle],
	TermEnd as [ClassField!4!TermEnd],
	case
		when 	(	
				Select sum(ClassUnits) 
				From #ReportCardData
				Where 	
				TermID = RD.TermID 
				and 
				StudentID = RD.StudentID 
				and 
				GradeLevel is not null
				and
				CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1) 
				and 
				ClassTypeID in (1,2)
				and
				(AlternativeGrade is null or AlternativeGrade = '')
				and
				LetterGrade is not null
				and
				LetterGrade != 'CR'
				and
				LetterGrade != 'NC'				
			) = 0 Then 0
		else (
				Select 
				case 
					when @CalculateGPAto3Decimals = 1 then
						convert(decimal(6,3), Sum(convert(dec(7,4), UnitGPA)) / nullif(Sum(convert(dec(7,4), ClassUnits)),0) )
					else
						convert(decimal(6,2), Sum(convert(dec(7,4), UnitGPA)) / nullif(Sum(convert(dec(7,4), ClassUnits)),0) )
				end	
				From #ReportCardData
				Where 	
				TermID = RD.TermID 
				and 
				StudentID = RD.StudentID 
				and
				ParentClassID = 0				
				and
				GradeLevel is not null
				and
				CustomGradeScaleID in (Select CustomGradeScaleID From CustomGradeScale Where CalculateGPA = 1) 
				and 
				ClassTypeID in (1,2)
				and
				(AlternativeGrade is null or AlternativeGrade = '')
				and
				LetterGrade is not null
				and
				LetterGrade != 'CR'
				and
				LetterGrade != 'NC'				
			)
	end as [ClassField!4!TermGPA],
	case
		when 	(	
			Select sum(ClassUnits) 
			From #ReportCardData
			Where 	TermID = RD.TermID 
				and 
				StudentID = RD.StudentID 
				and
				GradeLevel is not null
				and 
				ClassTypeID in (1,2)
				and
				AlternativeGrade is null
			) = 0 Then 0
		else (
			Select convert(decimal(7,2),round((sum(PercentageGrade*ClassUnits) / nullif(sum(ClassUnits),0) ),4))
			From #ReportCardData
			Where 	TermID = RD.TermID 
				and 
				StudentID = RD.StudentID 
				and
				GradeLevel is not null
				and 
				ClassTypeID in (1,2)
				and
				(AlternativeGrade is null or AlternativeGrade = '')
			)
	end as [ClassField!4!TermPercentageAverage],
	case 
		when	ClassTypeID = 3
				and
				(
					(
					Select CommentCount 
					From #tmpTermComments 
					Where
					TermID = RD.TermID 
					and 
					StudentID = RD.StudentID
					) > 1
					or
					@ShowTeacherNameOnTermComments = 1
				)
		then 
			case @RunOnUnconcludedClassesCheckBox
				when 'on' then (SELECT * FROM dbo.ConcatComments3(RD.TermID, RD.StudentID, @ShowTeacherNameOnTermComments))
				else (SELECT * FROM dbo.ConcatComments2(RD.TermID, RD.StudentID, @ShowTeacherNameOnTermComments))
			end
		else Replace(TermComment, '> </p>', '><br/></p>')		
	end	as [ClassField!4!TermComment],

	case
		when SchoolAtt1 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt1))	
		when SchoolAtt1 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt1,0)))
		when SchoolAtt1 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt1))
		else convert(nvarchar(6),SchoolAtt1) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt1],
	PercSchoolAtt1 as [ClassField!4!SPercAtt1],
	case
		when SchoolAtt2 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt2))
		when SchoolAtt2 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt2,0)))
		when SchoolAtt2 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt2))
		else convert(nvarchar(6),SchoolAtt2) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt2],
	PercSchoolAtt2 as [ClassField!4!SPercAtt2],
	case
		when SchoolAtt3 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt3))
		when SchoolAtt3 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt3,0)))
		when SchoolAtt3 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt3))
		else convert(nvarchar(6),SchoolAtt3) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt3],
	PercSchoolAtt3 as [ClassField!4!SPercAtt3],
	case
		when SchoolAtt4 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt4))
		when SchoolAtt4 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt4,0)))
		when SchoolAtt4 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt4))
		else convert(nvarchar(6),SchoolAtt4) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt4],
	PercSchoolAtt4 as [ClassField!4!SPercAtt4],
	case
		when SchoolAtt5 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt5))
		when SchoolAtt5 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt5,0)))
		when SchoolAtt5 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt5))
		else convert(nvarchar(6),SchoolAtt5) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt5],
	PercSchoolAtt5 as [ClassField!4!SPercAtt5],
	case
		when SchoolAtt6 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt6))
		when SchoolAtt6 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt6,0)))
		when SchoolAtt6 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt6))
		else convert(nvarchar(6),SchoolAtt6) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt6],
	PercSchoolAtt6 as [ClassField!4!SPercAtt6],
	case
		when SchoolAtt7 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt7))
		when SchoolAtt7 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt7,0)))
		when SchoolAtt7 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt7))
		else convert(nvarchar(6),SchoolAtt7) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt7],
	PercSchoolAtt7 as [ClassField!4!SPercAtt7],
	case
		when SchoolAtt8 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt8))
		when SchoolAtt8 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt8,0)))
		when SchoolAtt8 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt8))
		else convert(nvarchar(6),SchoolAtt8) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt8],
	PercSchoolAtt8 as [ClassField!4!SPercAtt8],
	case
		when SchoolAtt9 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt9))
		when SchoolAtt9 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt9,0)))
		when SchoolAtt9 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt9))
		else convert(nvarchar(6),SchoolAtt9) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt9],
	PercSchoolAtt9 as [ClassField!4!SPercAtt9],
	case
		when SchoolAtt10 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt10))
		when SchoolAtt10 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt10,0)))
		when SchoolAtt10 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt10))
		else convert(nvarchar(6),SchoolAtt10) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt10],
	PercSchoolAtt10 as [ClassField!4!SPercAtt10],
	case
		when SchoolAtt11 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt11))
		when SchoolAtt11 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt11,0)))
		when SchoolAtt11 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt11))
		else convert(nvarchar(6),SchoolAtt11) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt11],
	PercSchoolAtt11 as [ClassField!4!SPercAtt11],
	case
		when SchoolAtt12 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt12))
		when SchoolAtt12 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt12,0)))
		when SchoolAtt12 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt12))
		else convert(nvarchar(6),SchoolAtt12) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt12],
	PercSchoolAtt12 as [ClassField!4!SPercAtt12],
	case
		when SchoolAtt13 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt13))
		when SchoolAtt13 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt13,0)))
		when SchoolAtt13 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt13))
		else convert(nvarchar(6),SchoolAtt13) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt13],
	PercSchoolAtt13 as [ClassField!4!SPercAtt13],
	case
		when SchoolAtt14 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt14))
		when SchoolAtt14 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt14,0)))
		when SchoolAtt14 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt14))
		else convert(nvarchar(6),SchoolAtt14) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt14],
	PercSchoolAtt14 as [ClassField!4!SPercAtt14],
	case
		when SchoolAtt15 % 1 = 0 then convert(nvarchar(6),convert(int, SchoolAtt15))
		when SchoolAtt15 % 1 > .9 then convert(nvarchar(6),convert(int, round(SchoolAtt15,0)))
		when SchoolAtt15 % .1 = 0 then convert(nvarchar(6),convert(decimal(5,1), SchoolAtt15))
		else convert(nvarchar(6),SchoolAtt15) 
	end COLLATE DATABASE_DEFAULT as [ClassField!4!SAtt15],
	PercSchoolAtt15 as [ClassField!4!SPercAtt15],
	ChurchPresent as [ClassField!4!ChurchPresent],
	PercChurchPresent as [ClassField!4!PercChurchPresent],
	ChurchAbsent as [ClassField!4!ChurchAbsent],
	PercChurchAbsent as [ClassField!4!PercChurchAbsent],
	SSchoolPresent as [ClassField!4!SSchoolPresent],
	PercSSchoolPresent as [ClassField!4!PercSSchoolPresent],
	SSchoolAbsent as [ClassField!4!SSchoolAbsent],
	PercSSchoolAbsent as [ClassField!4!PercSSchoolAbsent],
	Att1 as [ClassField!4!Att1],
	Att2 as [ClassField!4!Att2],	
	Att3 as [ClassField!4!Att3],
	Att4 as [ClassField!4!Att4],
	Att5 as [ClassField!4!Att5],
	(
		Select sum(Att1)
		From #ReportCardData
		Where 	TermID = RD.TermID 
			and 
			StudentID = RD.StudentID 
			and
			GradeLevel is not null
			and 
			ClassTypeID in (1,8)
	) as [ClassField!4!TermAtt1Total],
	(
		Select sum(Att2)
		From #ReportCardData
		Where 	TermID = RD.TermID 
			and 
			StudentID = RD.StudentID 
			and
			GradeLevel is not null
			and 
			ClassTypeID in (1,8)
	) as [ClassField!4!TermAtt2Total],
	(
		Select sum(Att3)
		From #ReportCardData
		Where 	TermID = RD.TermID 
			and 
			StudentID = RD.StudentID 
			and
			GradeLevel is not null
			and 
			ClassTypeID in (1,8)
	) as [ClassField!4!TermAtt3Total],
	(
		Select sum(Att4)
		From #ReportCardData
		Where 	TermID = RD.TermID 
			and 
			StudentID = RD.StudentID 
			and
			GradeLevel is not null
			and 
			ClassTypeID in (1,8)
	) as [ClassField!4!TermAtt4Total],
	(
		Select sum(Att5)
		From #ReportCardData
		Where 	TermID = RD.TermID 
			and 
			StudentID = RD.StudentID 
			and
			GradeLevel is not null
			and 
			ClassTypeID in (1,8)
	) as [ClassField!4!TermAtt5Total],
	ClassShowPercentageGrade as [ClassField!4!ClassShowPercentageGrade],
	StandardsItemType as [ClassField!4!StandardsItemType]



From #ReportCardData RD
Where 
ClassTitle is not null
and
case 
	when ClassTypeID = 6 and @ShowWorshipAttendance = 'no' then 0
	else 1
end = 1

Order By [Student!2!SLname], [Student!2!SFname], [Student!2!SMname], [Student!2!StudentID], [ClassType!3!ClassTypeOrder], [ClassField!4!ReportOrder], [ClassField!4!ClassTitle], [ClassField!4!FieldOrder], [ClassField!4!FieldName], [ClassField!4!TermEnd], [ClassField!4!TermType], [ClassField!4!TermReportTitle]

FOR XML EXPLICIT




--Begin Audit Param Settings

DECLARE @EndTime datetime = (SELECT GETDATE())
DECLARE @TimeElapsed time = CONVERT(Time,(@EndTime - @StartTime))
DECLARE @ReportProfile nvarchar(10) 
	IF @ReportType = 'Individual'
	BEGIN
		SET @ReportProfile = 'Individual'
	END
	IF @RunByClassSetting = 'yes'
	BEGIN
		SET @ReportProfile = 'Class'
	END
	IF @RunByClassSetting != 'yes' and @ReportType = 'All'
	BEGIN
		SET @ReportProfile = 'Gradelevel'
	END
	
DECLARE @Source nvarchar(200) = 'ReportCard1'
DECLARE @Quantity int = (SELECT COUNT(DISTINCT StudentID) FROM #ReportCardData)
EXEC InsertAuditData @Source, @Quantity, @TimeElapsed, @DefaultName, @ReportProfile



--End Audit Param Settings

Drop Table #ReportCardData
Drop Table #tmpTeachers
Drop Table #Students2
Drop Table #AllCombinationsTSC
Drop Table #RDCombinationsTSC
Drop Table #RDCombinationsStudentClasses
Drop Table #AllCombinationsStudentClasses
Drop Table #AvgGrades
Drop table #CustomAvgGrades
Drop table #tmpTermIDs
Drop table #tmpYearlyGPA
Drop table #tmpTermComments
GO
