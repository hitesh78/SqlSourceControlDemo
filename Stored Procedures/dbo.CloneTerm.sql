SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE     Procedure [dbo].[CloneTerm] 
@CopyFromTermID int,
@NewTermID int,
@IncludeStudents bit, 
@IncludeAssignments bit

AS
-- Modified 1/18/2022 ~JG
-- fix for TeachersClasses.TeacherRole
BEGIN TRANSACTION;

-- Remove temporarily stored TypeID From TypeTitle
-- This code is added below but for some reason there are times when the code below doesn't work
-- Somehow the '@x@ is still left in the assingmentTypes which breaks this stored procedure when
-- it is ran to copy classes to the next term.  So we run this as a double check to make sure
-- there are no straggler '@x@' in the AssignmentTitle before continuing with this sp. - dp 1/16/2020
ALTER TABLE AssignmentType DISABLE TRIGGER ALL 
Update AssignmentType
Set TypeTitle = left(TypeTitle, (PATINDEX('%@x@%', TypeTitle)-1))
Where
TypeTitle like '%@x@%'
ALTER TABLE AssignmentType ENABLE TRIGGER ALL


-- Copy TeacherTerm Info
Insert into TeacherTerms
(
           [TeacherID]
           ,[TermID]
           ,[CalendarView]
           ,[Tab1Active]
           ,[Tab1Name]
           ,[Tab2Active]
           ,[Tab2Name]
           ,[Tab3Active]
           ,[Tab3Name]
           ,[Tab4Active]
           ,[Tab4Name]
           ,[Tab5Active]
           ,[Tab5Name]
           ,[Tab6Active]
           ,[Tab6Name]
           ,[Tab7Active]
           ,[Tab7Name]
           ,[Tab8Active]
           ,[Tab8Name]
           ,[Tab9Active]
           ,[Tab9Name]
           ,[Tab10Active]
           ,[Tab10Name]
           ,[Tab11Active]
           ,[Tab11Name]
           ,[MVDisplayTab1]
           ,[MVDisplayTab2]
           ,[MVDisplayTab3]
           ,[MVDisplayTab4]
           ,[MVDisplayTab5]
           ,[MVDisplayTab6]
           ,[MVDisplayTab7]
           ,[MVDisplayTab8]
           ,[MVDisplayTab9]
           ,[MVDisplayTab10]
           ,[MVDisplayTab11]
           ,[WVDisplayTab1]
           ,[WVDisplayTab2]
           ,[WVDisplayTab3]
           ,[WVDisplayTab4]
           ,[WVDisplayTab5]
           ,[WVDisplayTab6]
           ,[WVDisplayTab7]
           ,[WVDisplayTab8]
           ,[WVDisplayTab9]
           ,[WVDisplayTab10]
           ,[WVDisplayTab11]
           ,[DVDisplayTab1]
           ,[DVDisplayTab2]
           ,[DVDisplayTab3]
           ,[DVDisplayTab4]
           ,[DVDisplayTab5]
           ,[DVDisplayTab6]
           ,[DVDisplayTab7]
           ,[DVDisplayTab8]
           ,[DVDisplayTab9]
           ,[DVDisplayTab10]
           ,[DVDisplayTab11]
           ,[LVDisplayTab1]
           ,[LVDisplayTab2]
           ,[LVDisplayTab3]
           ,[LVDisplayTab4]
           ,[LVDisplayTab5]
           ,[LVDisplayTab6]
           ,[LVDisplayTab7]
           ,[LVDisplayTab8]
           ,[LVDisplayTab9]
           ,[LVDisplayTab10]
           ,[LVDisplayTab11]
           ,[CVDisplayTab1]
           ,[CVDisplayTab2]
           ,[CVDisplayTab3]
           ,[CVDisplayTab4]
           ,[CVDisplayTab5]
           ,[CVDisplayTab6]
           ,[CVDisplayTab7]
           ,[CVDisplayTab8]
           ,[CVDisplayTab9]
           ,[CVDisplayTab10]
           ,[CVDisplayTab11]
           ,[ShowWeekDaySunday]
           ,[ShowWeekDayMonday]
           ,[ShowWeekDayTuesday]
           ,[ShowWeekDayWednesday]
           ,[ShowWeekDayThursday]
           ,[ShowWeekDayFriday]
           ,[ShowWeekDaySaturday]
           ,[CalendarDisplayClasses]
           ,[AdminCalendarDisplayClasses]
)
SELECT 
	[TeacherID]
	,@NewTermID
	,[CalendarView]
	,[Tab1Active]
	,[Tab1Name]
	,[Tab2Active]
	,[Tab2Name]
	,[Tab3Active]
	,[Tab3Name]
	,[Tab4Active]
	,[Tab4Name]
	,[Tab5Active]
	,[Tab5Name]
	,[Tab6Active]
	,[Tab6Name]
	,[Tab7Active]
	,[Tab7Name]
	,[Tab8Active]
	,[Tab8Name]
	,[Tab9Active]
	,[Tab9Name]
	,[Tab10Active]
	,[Tab10Name]
	,[Tab11Active]
	,[Tab11Name]
	,[MVDisplayTab1]
	,[MVDisplayTab2]
	,[MVDisplayTab3]
	,[MVDisplayTab4]
	,[MVDisplayTab5]
	,[MVDisplayTab6]
	,[MVDisplayTab7]
	,[MVDisplayTab8]
	,[MVDisplayTab9]
	,[MVDisplayTab10]
	,[MVDisplayTab11]
	,[WVDisplayTab1]
	,[WVDisplayTab2]
	,[WVDisplayTab3]
	,[WVDisplayTab4]
	,[WVDisplayTab5]
	,[WVDisplayTab6]
	,[WVDisplayTab7]
	,[WVDisplayTab8]
	,[WVDisplayTab9]
	,[WVDisplayTab10]
	,[WVDisplayTab11]
	,[DVDisplayTab1]
	,[DVDisplayTab2]
	,[DVDisplayTab3]
	,[DVDisplayTab4]
	,[DVDisplayTab5]
	,[DVDisplayTab6]
	,[DVDisplayTab7]
	,[DVDisplayTab8]
	,[DVDisplayTab9]
	,[DVDisplayTab10]
	,[DVDisplayTab11]
	,[LVDisplayTab1]
	,[LVDisplayTab2]
	,[LVDisplayTab3]
	,[LVDisplayTab4]
	,[LVDisplayTab5]
	,[LVDisplayTab6]
	,[LVDisplayTab7]
	,[LVDisplayTab8]
	,[LVDisplayTab9]
	,[LVDisplayTab10]
	,[LVDisplayTab11]
	,[CVDisplayTab1]
	,[CVDisplayTab2]
	,[CVDisplayTab3]
	,[CVDisplayTab4]
	,[CVDisplayTab5]
	,[CVDisplayTab6]
	,[CVDisplayTab7]
	,[CVDisplayTab8]
	,[CVDisplayTab9]
	,[CVDisplayTab10]
	,[CVDisplayTab11]
	,[ShowWeekDaySunday]
	,[ShowWeekDayMonday]
	,[ShowWeekDayTuesday]
	,[ShowWeekDayWednesday]
	,[ShowWeekDayThursday]
	,[ShowWeekDayFriday]
	,[ShowWeekDaySaturday]
	,[CalendarDisplayClasses]
	,[AdminCalendarDisplayClasses]
FROM TeacherTerms
Where
TermID = @CopyFromTermID
and
TeacherID not in (Select TeacherID From TeacherTerms Where TermID = @NewTermID)



-- Creat temp table
Create table #newClassIDs
(
OldClassID int,
NewClassID int
)

Create table #newTypeIDs
(
OldTypeID int,
NewTypeID int
)

Declare @ExamTerm bit = (Select ExamTerm From Terms Where TermID = @NewTermID)

-- Get Term Date Differences
Declare @CopyFromTermStartDate date
Declare @NewTermStartDate date
Declare @NewTermEndDate date
Declare @DateDiff int

Set @CopyFromTermStartDate = (Select StartDate From Terms Where TermID = @CopyFromTermID)
Set @NewTermStartDate = (Select StartDate From Terms Where TermID = @NewTermID)
Set @NewTermEndDate = (Select EndDate From Terms Where TermID = @NewTermID)
Set @DateDiff = DATEDIFF ( Day , @CopyFromTermStartDate , @NewTermStartDate ) 



-- Copy All classes in the term
Insert into Classes
(
TeacherID,
ClassTitle,
ReportTitle,
SpanishTitle,
CourseCode,
PostSecondaryInstitution,
ReportOrder,
Units,
ClassTypeID,
CustomGradeScaleID,
StandardsGradeScaleID,
ParentClassID,
SubCommentClassTypeID,
CoachEmailAlert,
TermID,
AverageGrade,
Period,
Location,
Curve,
NonAcademic,
TermCode,
IgnoreTranscriptGradeLevelFilter,
PointsWeightedAssignmentTypes,
CategoryID,
AddAssignmentTypesAsReportCardSubgrades,
StandardsGroupID,
DefaultPresentValue,
PostCollectionID,
StdMinNumAssignmentsToMeet,
StdMinPercAvgToMeet,
StdMinNumStudentsMeetingAvg,
StdAverageAllAssignments,
StdRCShowOverallGrade,
StdRCShowCategoryGrade,
StdRCShowSubCategoryGrade,
StdRCShowStandardGrade,
ShowStandardsDataOnReportCards,
ShowStandardIDOnReportCards,
LPClassColor,
BiWeeklySchedule,
BiWeeklySchedStart2ndWeek,
PeriodOnSunday,
PeriodOnMonday,
PeriodOnTuesday,
PeriodOnWednesday,
PeriodOnThursday,
PeriodOnFriday,
PeriodOnSaturday,
BPeriodOnSunday,
BPeriodOnMonday,
BPeriodOnTuesday,
BPeriodOnWednesday,
BPeriodOnThursday,
BPeriodOnFriday,
BPeriodOnSaturday,
LocationOnSunday,
LocationOnMonday,
LocationOnTuesday,
LocationOnWednesday,
LocationOnThursday,
LocationOnFriday,
LocationOnSaturday,
BLocationOnSunday,
BLocationOnMonday,
BLocationOnTuesday,
BLocationOnWednesday,
BLocationOnThursday,
BLocationOnFriday,
BLocationOnSaturday,
EnablePSHourRounding,
PSRoundToNextHourPart,
PSRoundHourAfterXMinutes,
PSAutoCheckoutTime,
Rigor,
DualEnrollment,
ScheduleType,
ShowOnSchedule,
DisableClassAttendance,
gcCourseID,
gcAssignmentTypeID,
gcExcludeNoDueDate,
gcAutoSync,
gcSyncEnabled,
gcMarkingCodeGradeID,
MediumOfInstruction
)
Select
TeacherID,
ClassTitle,
ReportTitle,
SpanishTitle,
CourseCode,
PostSecondaryInstitution,
ReportOrder,
units,
ClassTypeID,
CustomGradeScaleID,
StandardsGradeScaleID,
ParentClassID,
SubCommentClassTypeID,
CoachEmailAlert,
@NewTermID,
ClassID,
Period,
Location,
0,
NonAcademic,
TermCode,
IgnoreTranscriptGradeLevelFilter,
PointsWeightedAssignmentTypes,
CategoryID,
AddAssignmentTypesAsReportCardSubgrades,
StandardsGroupID,
DefaultPresentValue,
PostCollectionID,
StdMinNumAssignmentsToMeet,
StdMinPercAvgToMeet,
StdMinNumStudentsMeetingAvg,
StdAverageAllAssignments,
StdRCShowOverallGrade,
StdRCShowCategoryGrade,
StdRCShowSubCategoryGrade,
StdRCShowStandardGrade,
ShowStandardsDataOnReportCards,
ShowStandardIDOnReportCards,
LPClassColor,
BiWeeklySchedule,
BiWeeklySchedStart2ndWeek,
PeriodOnSunday,
PeriodOnMonday,
PeriodOnTuesday,
PeriodOnWednesday,
PeriodOnThursday,
PeriodOnFriday,
PeriodOnSaturday,
BPeriodOnSunday,
BPeriodOnMonday,
BPeriodOnTuesday,
BPeriodOnWednesday,
BPeriodOnThursday,
BPeriodOnFriday,
BPeriodOnSaturday,
LocationOnSunday,
LocationOnMonday,
LocationOnTuesday,
LocationOnWednesday,
LocationOnThursday,
LocationOnFriday,
LocationOnSaturday,
BLocationOnSunday,
BLocationOnMonday,
BLocationOnTuesday,
BLocationOnWednesday,
BLocationOnThursday,
BLocationOnFriday,
BLocationOnSaturday,
EnablePSHourRounding,
PSRoundToNextHourPart,
PSRoundHourAfterXMinutes,
PSAutoCheckoutTime,
Rigor,
DualEnrollment,
ScheduleType,
ShowOnSchedule,
DisableClassAttendance,
case @IncludeStudents
	when 0 then null
	else gcCourseID
end as gcCourseID,
gcAssignmentTypeID,
gcExcludeNoDueDate,
gcAutoSync,
case
	when @IncludeStudents = 1 and gcSyncEnabled = 1 then 1
	else 0
end as gcSyncEnabled,  -- disabled sync if not including students
gcMarkingCodeGradeID,
MediumOfInstruction
from Classes
Where 
TermID = @CopyFromTermID
and
case 
	when @ExamTerm = 1 and ClassTypeID in (1,8)  then 1
	when @ExamTerm = 0 then 1
	else 0
end = 1
	

-- temporarely stored the old classID into the Average GradeField
Insert Into #newClassIDs (OldClassID, NewClassID)
Select AverageGrade, ClassID
From Classes
Where TermID = @NewTermID

-- clear out Average Grade column
Update Classes
Set AverageGrade = null
Where TermID = @NewTermID


-- Update ParentClassID
Update Classes
Set ParentClassID = tmp.NewClassID
From
Classes C
	inner join
#newClassIDs tmp
	on C.ParentClassID = tmp.OldClassID
Where C.ParentClassID > 0 and C.TermID = @NewTermID

-- Copy StaffAccess from Original Class and populate TeachersClasses table select * from TeachersClasses
Insert into TeachersClasses
Select
TC.TeacherID,
NC.NewClassID,
TC.TeacherRole
From 
TeachersClasses TC
	inner join
#newClassIDs NC
	on TC.ClassID = NC.OldClassID


--Update AssignmentType
--Set TypeTitle = Left (A.TypeTitle, PATINDEX ( '%@x@%' , A.TypeTitle ) - 1)
--From 	AssignmentType A
--			inner join 
--		Classes C
--			on A.ClassID = C.ClassID
--Where C.TermID = @NewTermID




-- Copy Assignment Types
Insert Into AssignmentType
(
TypeTitle,
TypeWeight,
TypeEC,
DropLowestGrade,
RelativeWeighting,
ClassID
)
Select	TypeTitle + '@x@' + Convert(nvarchar(10), TypeID),  --Temporarily store old TypeID in TypeTile
		TypeWeight,
		TypeEC,
		DropLowestGrade,
		RelativeWeighting,
		NC.NewClassID
From 	AssignmentType A
			inner join
		Classes C 
			on  A.ClassID = C.ClassID
			inner join
		#newClassIDs NC
			on C.ClassID = NC.OldClassID
Where C.TermID = @CopyFromTermID


-- Extract temporarily stored TypeID From TypeTitle
Select  SUBSTRING ( TypeTitle , PATINDEX ( '%@x@%' , TypeTitle ) + 3 , LEN ( TypeTitle ) ) as CT,
		TypeID
into #tmpData
From 	AssignmentType A
			inner join 
		Classes C
			on A.ClassID = C.ClassID
Where C.TermID = @NewTermID


Insert into #newTypeIDs (OldTypeID, NewTypeID)
Select 	convert(int, CT),
		TypeID
From #tmpData

drop table #tmpData

-- Update the gcAssignmentTypeID column to the new AssignmentTypeID
Update Classes
Set gcAssignmentTypeID = NT.NewTypeID
From 
Classes C
	inner join
#newTypeIDs NT
	on C.gcAssignmentTypeID = NT.OldTypeID
Where
C.TermID = @NewTermID


-- Remove temporarily stored TypeID From TypeTitle
ALTER TABLE AssignmentType DISABLE TRIGGER ALL 
Update AssignmentType
Set TypeTitle = left(TypeTitle, (PATINDEX('%@x@%', TypeTitle)-1))
Where
TypeTitle like '%@x@%'
ALTER TABLE AssignmentType ENABLE TRIGGER ALL


-- Copy Students
IF @IncludeStudents = 1
Begin

ALTER TABLE ClassesStudents DISABLE TRIGGER ALL 

Insert Into ClassesStudents 
(
ClassID, 
StudentID
)
Select	
NC.NewClassID, 
CS.StudentID
From 	ClassesStudents CS
			inner join
		Students S
			on CS.StudentID = S.StudentID
			inner join
		Classes C 
			on  CS.ClassID = C.ClassID
			inner join
		#newClassIDs NC
			on C.ClassID = NC.OldClassID
Where 
C.TermID = @CopyFromTermID
and
S.Active = 1

ALTER TABLE ClassesStudents ENABLE TRIGGER ALL


-- Copy Non-SchoolDays
Declare @Dates table(theDates date);
WITH date_range (calc_date) AS 
(
SELECT @NewTermStartDate
UNION ALL 
SELECT DATEADD(DAY, 1, calc_date)
FROM date_range
WHERE DATEADD(DAY, 1, calc_date) <= @NewTermEndDate
)
Insert into @Dates
SELECT calc_date
FROM date_range
OPTION (MAXRECURSION 400);

Insert into Attendance
(
ClassDate, 
CSID,
Att1,
Att2,
Att3,
Att4,
Att5,
Att6,
Att7,
Att8,
Att9,
Att10,
Att11,
Att12,
Att13,
Att14,
Att15
)
Select 
D.theDates,
CS.CSID,
case when S.ID = 'Att1' then 1 else 0 end as Att1,
case when S.ID = 'Att2' then 1 else 0 end as Att2,
case when S.ID = 'Att3' then 1 else 0 end as Att3,
case when S.ID = 'Att4' then 1 else 0 end as Att4,
case when S.ID = 'Att5' then 1 else 0 end as Att5,
case when S.ID = 'Att6' then 1 else 0 end as Att6,
case when S.ID = 'Att7' then 1 else 0 end as Att7,
case when S.ID = 'Att8' then 1 else 0 end as Att8,
case when S.ID = 'Att9' then 1 else 0 end as Att9,
case when S.ID = 'Att10' then 1 else 0 end as Att10,
case when S.ID = 'Att11' then 1 else 0 end as Att11,
case when S.ID = 'Att12' then 1 else 0 end as Att12,
case when S.ID = 'Att13' then 1 else 0 end as Att13,
case when S.ID = 'Att14' then 1 else 0 end as Att14,
case when S.ID = 'Att15' then 1 else 0 end as Att15
From
NonSchoolDays ND
	inner join
AttendanceSettings S
	on S.ReportLegend = ND.AttendanceSymbol
	inner join
@Dates D
	on	D.theDates = ND.TheDate
		or
		D.theDates between ND.StartDate and ND.EndDate
cross join
(
Select CS2.CSID
From
ClassesStudents CS2
	inner join 
#newClassIDs NC
	on CS2.ClassID = NC.NewClassID
	inner join 
Classes C
	on CS2.ClassID = C.ClassID
Where 
C.ClassTypeID = 5	-- Only do for Daily Attendance Classes
) CS



-- Copy Alerts into AccountAlerts
INSERT INTO AccountAlerts
(
CSID,
AccountID,
LowClassGradeAlert,
LowClassGradeAlertSent,
HighClassGradeAlert,
HighClassGradeAlertSent,
HighGradeAlert,
LowGradeAlert,
HighConductAlert,
LowConductAlert,
Att2Alert,
Att3Alert,
Att4Alert,
Att5Alert,
Att6Alert,
Att7Alert,
Att8Alert,
Att9Alert,
Att10Alert,
Att11Alert,
Att12Alert,
Att13Alert,
Att14Alert,
Att15Alert
)
Select
CS.CSID,
OA.AccountID,
OA.LowClassGradeAlert,
OA.LowClassGradeAlertSent,
OA.HighClassGradeAlert,
OA.HighClassGradeAlertSent,
OA.HighGradeAlert,
OA.LowGradeAlert,
OA.HighConductAlert,
OA.LowConductAlert,
OA.Att2Alert,
OA.Att3Alert,
OA.Att4Alert,
OA.Att5Alert,
OA.Att6Alert,
OA.Att7Alert,
OA.Att8Alert,
OA.Att9Alert,
OA.Att10Alert,
OA.Att11Alert,
OA.Att12Alert,
OA.Att13Alert,
OA.Att14Alert,
OA.Att15Alert
From
ClassesStudents CS
	inner join 
#newClassIDs NC
	on CS.ClassID = NC.NewClassID
	inner join
(
Select
AA.CSID,
CS2.ClassID,
CS2.StudentID,
AA.AccountID,
AA.LowClassGradeAlert,
AA.LowClassGradeAlertSent,
AA.HighClassGradeAlert,
AA.HighClassGradeAlertSent,
AA.HighGradeAlert,
AA.LowGradeAlert,
AA.HighConductAlert,
AA.LowConductAlert,
AA.Att2Alert,
AA.Att3Alert,
AA.Att4Alert,
AA.Att5Alert,
AA.Att6Alert,
AA.Att7Alert,
AA.Att8Alert,
AA.Att9Alert,
AA.Att10Alert,
AA.Att11Alert,
AA.Att12Alert,
AA.Att13Alert,
AA.Att14Alert,
AA.Att15Alert,
AA.NeedToSendClassGradeAlert
From 
ClassesStudents CS2
	inner join
AccountAlerts AA
	on CS2.CSID = AA.CSID
Where
CS2.ClassID in (Select OldClassID From #newClassIDs)
) OA
	on	NC.OldClassID = OA.ClassID
		and
		CS.StudentID = OA.StudentID

-- Add Records to ClassesStudentsCF table for any custom classes
Declare @FetchCustomClassID int
Declare @FetchCustomClassTypeID int
Declare CustomClassCursor Cursor For
Select ClassID, ClassTypeID
From Classes
Where ClassTypeID >= 100 and TermID = @NewTermID

Open CustomClassCursor

FETCH NEXT FROM CustomClassCursor INTO @FetchCustomClassID, @FetchCustomClassTypeID

WHILE (@@FETCH_STATUS <> -1)
BEGIN

 	Insert into ClassesStudentsCF (CSID, CustomFieldID)
 	Select CS.CSID, CF.CustomFieldID
	From 	
	CustomFields CF 
		cross join 
	ClassesStudents CS
	Where 
	CF.ClassTypeID = @FetchCustomClassTypeID 
	and 
	CS.ClassID = @FetchCustomClassID
	and
	CS.StudentID in (Select StudentID From Students Where Active = 1)

	FETCH NEXT FROM CustomClassCursor INTO @FetchCustomClassID, @FetchCustomClassTypeID
End

Close CustomClassCursor
Deallocate CustomClassCursor



End  -- if IncludeStudents



-- Update NewsTeacherPages to use the latest ClassID and TeacherID
Update NewsTeacherPages
Set 
ClassID = PC.ClassID,
TeacherID = PC.TeacherID
From
NewsTeacherPages N
	inner join
(
	Select
	N2.PostCollectionID,
	(Select top 1 ClassID From Classes Where PostCollectionID = N2.PostCollectionID order by classid desc) as ClassID,
	(
	Select TeacherID From Classes
	Where 
	ClassID = (Select top 1 ClassID From Classes Where PostCollectionID = N2.PostCollectionID order by classid desc)
	) as TeacherID  
	From
	NewsTeacherPages N2
	Where
	subPostType = 'Standard' or subPostType = 'Homeroom'
) PC
	on N.PostCollectionID = PC.PostCollectionID




-- Include Assignments
IF @IncludeAssignments = 1
Begin

Insert Into Assignments 
(
ClassID,
AssignmentTitle,
DueDate,
DateAssigned,
Weight,
Curve,
ADescription,
EC,
GradeStyle,
OutOf,
TypeID
)
Select
NC.NewClassID,
A.AssignmentTitle,
DATEADD(day, @DateDiff, A.DueDate),
DATEADD(day, @DateDiff, A.DateAssigned),
A.Weight,
0,
A.ADescription,
A.EC,
A.GradeStyle,
A.OutOf,
NT.NewTypeID
From 	Assignments A
			inner join
		Classes C 
			on  A.ClassID = C.ClassID
			inner join
		#newClassIDs NC
			on C.ClassID = NC.OldClassID
			inner join
		#newTypeIDs NT
			on A.TypeID = NT.OldTypeID
Where C.TermID = @CopyFromTermID  and C.ClassTypeID < 3

End  -- if IncludeAssignments

drop table #newClassIDs
drop table #newTypeIDs

COMMIT;
GO
