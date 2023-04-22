SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 11/27/2012
-- Description:	
/*
Used by Job that processes ClassGrade and Coash Alerts
Adds ClassGrade and Coach Alerts to the AlertLog table
and Updates alert status columns
*/
-- =============================================

CREATE Procedure [dbo].[Job_AddEmailsToAlertLog]
AS
BEGIN

	SET NOCOUNT ON;

-- *************************************************
-- Process Sports Eligibility Alerts
-- *************************************************
Declare @SportsEligibilityLetterGrade nvarchar(5) = (Select SportsEligibilityLetterGrade From Settings Where SettingID = 1)
Declare @SportEligibilityGPA decimal(3,2) = (Select SportEligibilityGPA From Settings where SettingID = 1)
Declare @AlertDate smalldatetime = dbo.GLgetdatetime()
Declare @LowStudentGPAs table (StudentID int, GPA decimal(3,2))
Declare @StudentAlertDescriptions table (StudentID int, AlertDescription nvarchar(4000))

Declare @SportsAlerts table	(	
	CSID int, 
	Subject nvarchar(100), 
	Coach nvarchar(100), 
	Email nvarchar(70), 
	AlertDescription nvarchar(1000),
	AlertDate smalldatetime,
	AccountID nvarchar(50)
)

Declare @ClassGradeAlerts table	(
	AAID int,	
	CSID int, 
	Subject nvarchar(100), 
	Student nvarchar(100), 
	Email nvarchar(70), 
	AlertDescription nvarchar(4000),
	AlertDate smalldatetime,
	AccountID nvarchar(50)
)

Declare @AssignmentGradeAlerts table	(	
	GradeID int,
	AAID int,
	CSID int, 
	AlertType nvarchar(50), 
	Student nvarchar(100), 
	Email nvarchar(70), 
	AlertDescription nvarchar(4000),
	AlertDate smalldatetime,
	AccountID nvarchar(50)
)

Declare @StudentsHaveParentAccess bit = (Select StudentAccountsHaveParentAccess From Settings Where SettingID = 1)

-- Get list of LowStudentGPAs where CoachAlert was not sent
Insert into @LowStudentGPAs(StudentID, GPA)
Select
CS.StudentID,
convert(decimal(6,2),round((sum(dbo.getUnitGPA(C.ClassID, CS.StudentGrade)) / sum(C.Units)),4)) as GPA
From 
Students S
	inner join
ClassesStudents CS
	on S.StudentID = CS.StudentID
	inner join
Classes C
	on CS.ClassID = C.ClassID
	inner join
CustomGradeScale CG
	on C.CustomGradeScaleID = CG.CustomGradeScaleID
	inner join
Terms T
	on C.TermID = T.TermID
Where
S.IneligibleStudent = 1
and
S.Active = 1
and
C.ClassTypeID = 1
and
C.Units > 0
and
CS.StudentGrade is not null
and
S.CoachEmailAlertSent = 0
and
CG.CalculateGPA = 1
and  
T.Status = 1
Group By CS.StudentID
Having (
convert(decimal(6,2),round((sum(dbo.getUnitGPA(C.ClassID, CS.StudentGrade)) / sum(C.Units)),4))
) < @SportEligibilityGPA

-- Get List of StudentAlertDescriptions for Both Low GPA and Low LetterGrades where CoachAlert was not sent
Insert into @StudentAlertDescriptions(StudentID, AlertDescription)
Select
S.StudentID,
S.glname + ' is currently Ineligible to play sports.  ' + S.glname + '''s current GPA is ' + convert(nvarchar(8),SG.GPA) + 
'.  A GPA of ' + convert(nvarchar(8),@SportEligibilityGPA) + ' or higher is required to be eligible to play sports.'	
as AlertDescription
From 
Students S
	inner join
@LowStudentGPAs SG
	on SG.StudentID = S.StudentID
	inner join
ClassesStudents CS
	on CS.StudentID = S.StudentID
	inner join
Classes C
	on C.ClassID = CS.ClassID
	inner join
Terms T
	on T.TermID = C.TermID
Where
T.Status = 1

Union

Select
S.StudentID,
S.glname + ' is currently Ineligible to play sports.  ' + S.glname + ' has low grades in the following classes:' 
+ 
reverse(stuff(reverse((
	Select
	C2.ReportTitle + ',' as 'data()' 
	From 
	ClassesStudents CS2
		inner join
	Classes C2
		on CS2.ClassID = C2.ClassID
		inner join
	Terms T2
		on T2.TermID = C2.TermID
		inner join
	CustomGradeScaleGrades CGG2
		on	C2.CustomGradeScaleID = CGG2.CustomGradeScaleID
			and
			CGG2.GradeSymbol = dbo.GetLetterGrade(CS2.ClassID, CS2.StudentGrade)
			and
			CGG2.GradeOrder >= dbo.GetLowGradeOrder(C2.CustomGradeScaleID, @SportsEligibilityLetterGrade)	
	Where
	CS2.StudentID = S.StudentID
	and
	CS2.StudentGrade is not null
	and
	T2.Status = 1
	for xml path('')
)), 1, 1, ''))
+ 
'.  A student cannot be averaging a ' + @SportsEligibilityLetterGrade + ' or lower in any classes to be eligible to play sports.'
as AlertDescription
From
Students S
	inner join 
ClassesStudents CS
	on S.StudentID = CS.StudentID
	inner join
Classes C
	on CS.ClassID = C.ClassID
	inner join
Terms T
	on C.TermID = T.TermID
	inner join
CustomGradeScaleGrades CGG
	on	C.CustomGradeScaleID = CGG.CustomGradeScaleID
		and
		CGG.GradeSymbol = dbo.GetLetterGrade(CS.ClassID, CS.StudentGrade)
		and
		CGG.GradeOrder >= dbo.GetLowGradeOrder(C.CustomGradeScaleID, @SportsEligibilityLetterGrade)	
Where
T.Status = 1
and
S.IneligibleStudent = 1
and
S.Active = 1
and
C.ClassTypeID in (1,8)
and
CS.StudentGrade is not null
and
S.CoachEmailAlertSent = 0
and
CS.CSID = CS.CSID
and
CS.StudentID not in (Select StudentID From @LowStudentGPAs)
Group By S.StudentID, S.Fname, S.Lname, S.glname
Order by 1


-- Insert Both Sports Eligibility alerts and Student ClassGrade Alerts
--Insert Into AlertLog(CSID, AlertType, Student, Email, AlertDescription, AlertDate)

-- Sports Eligibility Alerts
Insert into @SportsAlerts
Select
	CS.CSID,
	'Player Ineligibility Alert' as Subject,
	T.glname as Coach,
	T.Email,
	AD.AlertDescription as AlertDescription,
	@AlertDate as AlertDate,
	T.AccountID
From 
Teachers T
	inner join 
Classes C
	on T.TeacherID = C.TeacherID
	inner join
ClassesStudents CS
	on CS.ClassID = C.ClassID
	inner join
Terms Tm
	on Tm.TermID = C.TermID
	inner join
@StudentAlertDescriptions AD
	on CS.StudentID = AD.StudentID
Where
		C.ClassTypeID = 7
		and
		C.CoachEmailAlert = 1
		and
		C.Concluded = 0
		and
		Tm.Status = 1
		and
		(SELECT CHARINDEX('@', T.Email)) != 0


-- Add Code to Update CoachEmail Alert Sent column		
Update Students
Set CoachEmailAlertSent = 1
Where
StudentID in (Select StudentID From @StudentAlertDescriptions)


-- *************************************************	
-- Process ClassGrade Alerts
-- *************************************************
Insert into @ClassGradeAlerts
Select
	AA.AAID,
	AA.CSID,
	case 
		when CGG.GradeOrder <= AA.HighClassGradeAlert then 'High Class Grade Alert'
		when CGG.GradeOrder >= AA.LowClassGradeAlert then 'Low Class Grade Alert'
	end as Subject,
	S.glname as Student,
	AE.EmailAddress as Email,
	S.glname + ' is currently averaging a grade of (' + dbo.GetLetterGrade(CS.ClassID, CS.StudentGrade) + ') in ' + C.ReportTitle + '.' 
	as AlertDescription,
	@AlertDate as AlertDate,
	AA.AccountID
From 
AccountAlerts AA
	inner join
ClassesStudents CS
	on AA.CSID = CS.CSID
	inner join
Classes C
	on CS.ClassID = C.ClassID
	inner join
Students S
	on S.StudentID = CS.StudentID
	inner join
CustomGradeScaleGrades CGG
	on	C.CustomGradeScaleID = CGG.CustomGradeScaleID
		and
		CGG.GradeSymbol = dbo.GetLetterGrade(CS.ClassID, CS.StudentGrade)
	inner join
	(
		Select F.AccountID, S.Email1 as EmailAddress 
		From Students S	inner join Families F on S.FamilyID = F.FamilyID
		Where CHARINDEX('@', S.Email1) != 0 and S.Active = 1
		Union
		Select F.AccountID, S.Email2 as EmailAddress 
		From Students S	inner join Families F on S.FamilyID = F.FamilyID
		Where CHARINDEX('@', S.Email2) != 0 and S.Active = 1
		Union
		Select F.AccountID, S.Email3 as EmailAddress 
		From Students S	inner join Families F on S.FamilyID = F.FamilyID
		Where CHARINDEX('@', S.Email3) != 0 and S.Active = 1
		Union
		Select F.AccountID, S.Email4 as EmailAddress 
		From Students S	inner join Families F on S.FamilyID = F.FamilyID
		Where CHARINDEX('@', S.Email4) != 0 and S.Active = 1
		Union
		Select F.AccountID, S.Email5 as EmailAddress 
		From Students S	inner join Families F on S.FamilyID = F.FamilyID
		Where CHARINDEX('@', S.Email5) != 0 and S.Active = 1
		Union
		Select F.AccountID, S.Email6 as EmailAddress 
		From Students S	inner join Families F on S.Family2ID = F.FamilyID
		Where CHARINDEX('@', S.Email6) != 0 and S.Active = 1
		Union
		Select F.AccountID, S.Email7 as EmailAddress 
		From Students S	inner join Families F on S.Family2ID = F.FamilyID
		Where CHARINDEX('@', S.Email7) != 0 and S.Active = 1
		Union
		Select AccountID, Email8 as EmailAddress From Students 
		Where CHARINDEX('@', Email8) != 0 and @StudentsHaveParentAccess = 0 and Active = 1
		Union
		Select AccountID, Email1 as EmailAddress From Students 
		Where CHARINDEX('@', Email1) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
		Union
		Select AccountID, Email2 as EmailAddress From Students 
		Where CHARINDEX('@', Email2) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
		Union
		Select AccountID, Email3 as EmailAddress From Students 
		Where CHARINDEX('@', Email3) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
		Union
		Select AccountID, Email4 as EmailAddress From Students 
		Where CHARINDEX('@', Email4) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
		Union
		Select AccountID, Email5 as EmailAddress From Students 
		Where CHARINDEX('@', Email5) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
	) AE
	on AA.AccountID = AE.AccountID
Where
AA.NeedToSendClassGradeAlert = 1
and
(	-- include this encase the parents change the alerts but the CS record is flagged to be sent and is no longer valid 
CGG.GradeOrder <= AA.HighClassGradeAlert and AA.HighClassGradeAlert > 0
or
CGG.GradeOrder >= AA.LowClassGradeAlert and AA.LowClassGradeAlert > 0
)
and
S.Active = 1


-- Update HighClassGradeAlertSent
Update AccountAlerts
Set 
HighClassGradeAlertSent = 1,
NeedToSendClassGradeAlert = 0
Where
AAID in (Select AAID From @ClassGradeAlerts Where Subject = 'High Class Grade Alert')

-- Update LowClassGradeAlertSent
Update AccountAlerts
Set 
LowClassGradeAlertSent = 1,
NeedToSendClassGradeAlert = 0
Where
AAID in (Select AAID From @ClassGradeAlerts Where Subject = 'Low Class Grade Alert')

-- Reset Class Alert flag for any other records not in @ClassGrade Alerts due to invalid Email Addresses
-- So the parents don't get bombarded with emials once they put a valid email address in
Update AccountAlerts
Set 
NeedToSendClassGradeAlert = 0
Where
NeedToSendClassGradeAlert = 1


-- *************************************************	
-- Process Assignment Grades Alerts
-- *************************************************

Declare @CRNL nvarchar(10) = CHAR(13) + CHAR(10)

Insert into @AssignmentGradeAlerts
Select
	G.GradeID,
	AA.AAID,
	AA.CSID,
	case 
		when CGG.GradeOrder <= AA.HighGradeAlert then 'High Grade Alert'
		when CGG.GradeOrder >= AA.LowGradeAlert then 'Low Grade Alert'
	end as Subject,
	S.glname as Student,
	AE.EmailAddress as Email, 
	S.glname
	+ ' received a grade of ' + 
	case
		when isnull(G.GradeCode,'') != ''
		then	(
					Select
					GradeSymbol + ' (' + GradeDescription + ')'
					From 
					CustomGradeScaleGrades
					Where
					CustomGradeScaleID = (Select CustomGradeScaleID From CustomGradeScale Where GradeScaleName = '**Assignment Grade Codes')
					and
					GradeSymbol = G.GradeCode
				)
		else dbo.GetLetterGrade(C.ClassID, G.Grade)
	end
	+ ' in ' + 
	C.ReportTitle 
	+ ' for assignment ' + 
	A.AssignmentTitle 
	+  '.' +
	case 
		when isnull(A.ADescription, '') != ''
		then + @CRNL + @CRNL + 'Assignment Description:' + @CRNL + replace(A.ADescription, '&nbsp;', @CRNL + @CRNL)
		else ''
	end
	+
	case
		when isnull(G.Comments, '') != ''
		then + @CRNL + @CRNL + 'Teacher Comments:' + @CRNL + G.Comments
		else ''
	end
	as AlertDescription,
	@AlertDate as AlertDate,
	AA.AccountID
From 
Grades G
	inner join
Assignments A
	on G.AssignmentID = A.AssignmentID
	inner join
ClassesStudents CS
	on G.CSID = CS.CSID
	inner join
AccountAlerts AA
	on AA.CSID = CS.CSID
	inner join
Classes C 
	on CS.ClassID = C.ClassID
	inner join
Students S
	on CS.StudentID = S.StudentID
	inner join
CustomGradeScaleGrades CGG
	on	C.CustomGradeScaleID = CGG.CustomGradeScaleID
		and
		CGG.GradeSymbol = dbo.GetLetterGrade(CS.ClassID, G.Grade)
	inner join
(
	Select F.AccountID, S.Email1 as EmailAddress 
	From Students S	inner join Families F on S.FamilyID = F.FamilyID
	Where CHARINDEX('@', S.Email1) != 0 and S.Active = 1
	Union
	Select F.AccountID, S.Email2 as EmailAddress 
	From Students S	inner join Families F on S.FamilyID = F.FamilyID
	Where CHARINDEX('@', S.Email2) != 0 and S.Active = 1
	Union
	Select F.AccountID, S.Email3 as EmailAddress 
	From Students S	inner join Families F on S.FamilyID = F.FamilyID
	Where CHARINDEX('@', S.Email3) != 0 and S.Active = 1
	Union
	Select F.AccountID, S.Email4 as EmailAddress 
	From Students S	inner join Families F on S.FamilyID = F.FamilyID
	Where CHARINDEX('@', S.Email4) != 0 and S.Active = 1
	Union
	Select F.AccountID, S.Email5 as EmailAddress 
	From Students S	inner join Families F on S.FamilyID = F.FamilyID
	Where CHARINDEX('@', S.Email5) != 0 and S.Active = 1
	Union
	Select F.AccountID, S.Email6 as EmailAddress 
	From Students S	inner join Families F on S.Family2ID = F.FamilyID
	Where CHARINDEX('@', S.Email6) != 0 and S.Active = 1
	Union
	Select F.AccountID, S.Email7 as EmailAddress 
	From Students S	inner join Families F on S.Family2ID = F.FamilyID
	Where CHARINDEX('@', S.Email7) != 0 and S.Active = 1
	Union
	Select AccountID, Email8 as EmailAddress From Students 
	Where CHARINDEX('@', Email8) != 0 and @StudentsHaveParentAccess = 0 and Active = 1
	Union
	Select AccountID, Email1 as EmailAddress From Students 
	Where CHARINDEX('@', Email1) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
	Union
	Select AccountID, Email2 as EmailAddress From Students 
	Where CHARINDEX('@', Email2) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
	Union
	Select AccountID, Email3 as EmailAddress From Students 
	Where CHARINDEX('@', Email3) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
	Union
	Select AccountID, Email4 as EmailAddress From Students 
	Where CHARINDEX('@', Email4) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
	Union
	Select AccountID, Email5 as EmailAddress From Students 
	Where CHARINDEX('@', Email5) != 0 and @StudentsHaveParentAccess = 1 and Active = 1
) AE
	on AA.AccountID = AE.AccountID	
Where
G.NeedToSendGradeAlert = 1
and
(	-- include this encase the parents change the alerts but the CS record is flagged to be sent and is no longer valid 
CGG.GradeOrder <= AA.HighGradeAlert and AA.HighGradeAlert > 0
or
CGG.GradeOrder >= AA.LowGradeAlert and AA.LowGradeAlert > 0
)
and
S.Active = 1


-- Reset NeedToSendGradeAlert Flag to 0 (updated Code to reset all Grade records that are flagged)
Update Grades 
Set NeedToSendGradeAlert = 0 
Where NeedToSendGradeAlert = 1
--Where GradeID in (Select GradeID From @AssignmentGradeAlerts)


-- *************************************************
-- Insert Class Grade and Sports Alerts into AlertLog table
-- *************************************************
Declare @BlockAcademicAlerts bit = (Select case when LockAllStudents=1 or ShowAcademicAlertsOnParentInterface=0 then 1 else 0 end From Settings Where SettingID = 1)

If @BlockAcademicAlerts != 1
Begin
	Insert Into AlertLog(
		CSID, 
		AlertType, 
		Student, 
		Email, 
		AlertDescription, 
		AlertDate,
		LanguageType
	)
	Select distinct 
		ca.CSID, 
		ca.Subject, 
		ca.Student, 
		ca.Email, 
		ca.AlertDescription, 
		ca.AlertDate, 
		isnull(a.LanguageType,'English') as  LanguageType 
	From @ClassGradeAlerts ca
	left join Accounts a -- Account should always be present, but left join to prevent stopping the show if not matched since this is just to get a language preference
	on ca.AccountID = a.AccountID	
	
	Insert Into AlertLog(
		CSID, 
		AlertType, 
		Student, 
		Email, 
		AlertDescription, 
		AlertDate,
		LanguageType
	)
	Select distinct 
		aa.CSID, 
		aa.AlertType, 
		aa.Student, 
		aa.Email, 
		aa.AlertDescription, 
		aa.AlertDate,
		isnull(a.LanguageType,'English') as  LanguageType 
	From @AssignmentGradeAlerts aa
	left join Accounts a -- Account should always be present, but left join to prevent stopping the show if not matched since this is just to get a language preference
	on aa.AccountID = a.AccountID		
End

Insert Into AlertLog(
	CSID, 
	AlertType, 
	Student, -- a misnomer in this case where we store 'coach'
	Email, 
	AlertDescription, 
	AlertDate, 
	LanguageType
)
Select 
	sa.CSID, 
	sa.Subject, 
	sa.Coach, 
	sa.Email, 
	sa.AlertDescription,
	sa.AlertDate,
	isnull(a.LanguageType,'English') as  LanguageType
From @SportsAlerts sa
left join Accounts a -- Account should always be present, but left join to prevent stopping the show if not matched since this is just to get a language preference
on sa.AccountID = a.AccountID
							
END	-- Procedure Body



GO
