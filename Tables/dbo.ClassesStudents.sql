CREATE TABLE [dbo].[ClassesStudents]
(
[CSID] [int] NOT NULL IDENTITY(1, 1),
[ClassID] [int] NOT NULL,
[StudentID] [int] NOT NULL,
[StudentGrade] [decimal] (5, 1) NULL,
[AlternativeGrade] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassLevel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassComments] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exceptional] [tinyint] NULL CONSTRAINT [DF_ClassesStudents_Exceptional] DEFAULT ((0)),
[Good] [tinyint] NULL CONSTRAINT [DF_ClassesStudents_Good] DEFAULT ((1)),
[Poor] [tinyint] NULL CONSTRAINT [DF_ClassesStudents_Poor] DEFAULT ((0)),
[Unacceptable] [tinyint] NULL CONSTRAINT [DF_ClassesStudents_Unacceptable] DEFAULT ((0)),
[DeficiencyComment] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TermComment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InUseBy] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassGradeOnConclude] [decimal] (5, 1) NULL,
[StudentConcludeDate] [date] NULL,
[OldCSID] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[AddStudent]
 on [dbo].[ClassesStudents]
 After Insert
As
Begin

	-- Populate Grades Records
	Insert into Grades (CSID, AssignmentID)
	Select I.CSID, A.AssignmentID
	From 
	Inserted I 
		inner join 
	Assignments A
		on A.ClassID = I.ClassID
		
	-- Populate AccountAlerts Records
	Insert into AccountAlerts (CSID, AccountID, HighClassGradeAlert, HighGradeAlert, LowClassGradeAlert, LowGradeAlert)
	Select
	I.CSID,
	S.AccountID,
	case
		when cgs.PositiveAvgToggle = 1 and cgs.PositiveAvgDefault is not null then cgs.PositiveAvgDefault
		else 0
	end as HighClassGradeAlert,
	case
		when cgs.PositiveAssignToggle = 1 and cgs.PositiveAssignDefault is not null then cgs.PositiveAssignDefault
		else 0
	end as HighGradeAlert,
	case
		when cgs.NegativeAvgToggle = 1 and cgs.NegativeAvgDefault is not null then cgs.NegativeAvgDefault
		else 0
	end as LowClassGradeAlert,
	case
		when cgs.NegativeAssignToggle = 1 and cgs.NegativeAssignDefault is not null then cgs.NegativeAssignDefault
		else 0
	end as LowGradeAlert
	From
	Inserted I 
		inner join 
	Students S
		on I.StudentID = S.StudentID
		inner join
	Classes C
		on I.ClassID = C.ClassID
		inner join
	CustomGradeScale cgs
		on C.CustomGradeScaleID = cgs.CustomGradeScaleID
	Where
	C.ClassTypeID in (1,5,6,8)
	and
	Not Exists (Select * From AccountAlerts Where CSID = I.CSID and AccountID = S.AccountID)

	Union

	Select 
	I.CSID,
	F.AccountID,
	case
		when cgs.PositiveAvgToggle = 1 and cgs.PositiveAvgDefault is not null then cgs.PositiveAvgDefault
		else 0
	end as HighClassGradeAlert,
	case
		when cgs.PositiveAssignToggle = 1 and cgs.PositiveAssignDefault is not null then cgs.PositiveAssignDefault
		else 0
	end as HighGradeAlert,
	case
		when cgs.NegativeAvgToggle = 1 and cgs.NegativeAvgDefault is not null then cgs.NegativeAvgDefault
		else 0
	end as LowClassGradeAlert,
	case
		when cgs.NegativeAssignToggle = 1 and cgs.NegativeAssignDefault is not null then cgs.NegativeAssignDefault
		else 0
	end as LowGradeAlert
	From
	Inserted I 
		inner join 
	Students S
		on I.StudentID = S.StudentID
		inner join
	Families F
		on S.FamilyID = F.FamilyID
		inner join
	Classes C
		on I.ClassID = C.ClassID
		inner join
	CustomGradeScale cgs
		on C.CustomGradeScaleID = cgs.CustomGradeScaleID
	Where
	C.ClassTypeID in (1,5,6,8)
	and
	Not Exists (Select * From AccountAlerts Where CSID = I.CSID and AccountID = F.AccountID)		
		
	Union

	Select 
	I.CSID,
	F.AccountID,
	case
		when cgs.PositiveAvgToggle = 1 and cgs.PositiveAvgDefault is not null then cgs.PositiveAvgDefault
		else 0
	end as HighClassGradeAlert,
	case
		when cgs.PositiveAssignToggle = 1 and cgs.PositiveAssignDefault is not null then cgs.PositiveAssignDefault
		else 0
	end as HighGradeAlert,
	case
		when cgs.NegativeAvgToggle = 1 and cgs.NegativeAvgDefault is not null then cgs.NegativeAvgDefault
		else 0
	end as LowClassGradeAlert,
	case
		when cgs.NegativeAssignToggle = 1 and cgs.NegativeAssignDefault is not null then cgs.NegativeAssignDefault
		else 0
	end as LowGradeAlert
	From
	Inserted I 
		inner join 
	Students S
		on I.StudentID = S.StudentID
		inner join
	Families F
		on S.Family2ID = F.FamilyID
		inner join
	Classes C
		on I.ClassID = C.ClassID
		inner join
	CustomGradeScale cgs
		on C.CustomGradeScaleID = cgs.CustomGradeScaleID
	Where
	C.ClassTypeID in (1,5,6,8)
	and
	S.Family2ID is not null
	and
	Not Exists (Select * From AccountAlerts Where CSID = I.CSID and AccountID = F.AccountID)		


	-- Add NonSchoolDays for Attendance Classes
	Select I.ClassID
	into #InsertedAttendanceClasses
	From 
	Inserted I
		inner join
	Classes C
		on I.ClassID = C.ClassID
	Where
	C.ClassTypeID = 5
	
	Declare @TermID int
	Declare @TermStart date
	Declare @TermEnd date
	Declare @ClassID int			
	Declare @DateID int	
	
	Create table #NonSchoolDateItems (DateID int)
		
	Alter table dbo.Attendance Disable trigger All
		
	While (Select count(*) From #InsertedAttendanceClasses) > 0
	Begin
		
		Set @ClassID = (Select top 1 ClassID From #InsertedAttendanceClasses)
		Set @TermID = (Select TermID From Classes Where ClassID = @ClassID)
		Set @TermStart = (Select StartDate From Terms Where TermID = @TermID)
		Set @TermEnd = (Select EndDate From Terms Where TermID = @TermID)

		Insert into #NonSchoolDateItems
		Select DateID
		From dbo.NonSchoolDays
		Where
		TheDate between @TermStart and @TermEnd
		or
		StartDate  between @TermStart and @TermEnd
		or
		EndDate  between @TermStart and @TermEnd	
		
			
		-- Add NonSchoolDays Attendance
		While (Select count(*) From #NonSchoolDateItems) > 0
		Begin	
			Set @DateID = (Select top 1 DateID From #NonSchoolDateItems)
			Execute dbo.AddNonSchoolDaysAttendance @DateID, @ClassID
			Delete From #NonSchoolDateItems Where DateID = @DateID
		End

		Delete From #InsertedAttendanceClasses Where ClassID = @ClassID	
	End
			
	Alter table dbo.Attendance Enable trigger All
	drop table #NonSchoolDateItems		
			
End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Trigger [dbo].[LogClassGradeAlerts]
On [dbo].[ClassesStudents]
For Update
As
Begin

If Update(StudentGrade)
Begin

	Declare @ClassID int = (Select top 1 ClassID From Inserted)
	Declare @HiddenClass bit = (Select NonAcademic From Classes Where ClassID = @ClassID)

	If @HiddenClass = 0
	Begin

		-- *******************************************************************
		-- Update ClassesStudents Alert Columns
		-- *******************************************************************
		Update AccountAlerts
		Set
		NeedToSendClassGradeAlert = AA2.NeedToSendClassGradeAlert,
		HighClassGradeAlertSent = AA2.SetHighClassGradeAlertSent,
		LowClassGradeAlertSent = AA2.SetLowClassGradeAlertSent
		From 
		AccountAlerts AA1
			inner join
		(
			Select
			AA.AAID,
			case
				when
					CGG.GradeOrder <= AA.HighClassGradeAlert  -- when InsertedClassGradeLevel <= HighClassGradeAlert
					and 
					AA.HighClassGradeAlert > 0 
					and 
					AA.HighClassGradeAlertSent = 0
				then 1
				when
					CGG.GradeOrder >= AA.LowClassGradeAlert	-- InsertedClassGradeLevel >= LowClassGradeAlert
					and 
					AA.LowClassGradeAlert > 0
					and 
					AA.LowClassGradeAlertSent = 0
				then 1
				else 0
			end as NeedToSendClassGradeAlert,
			case
				when CS1.StudentGrade is null then 0
				when CGG.GradeOrder > AA.HighClassGradeAlert then 0
				else AA.HighClassGradeAlertSent
			end as SetHighClassGradeAlertSent,
			case 
				when CS1.StudentGrade is null then 0
				when CGG.GradeOrder < AA.LowClassGradeAlert then 0
				else AA.LowClassGradeAlertSent
			end as SetLowClassGradeAlertSent
			From 
			Inserted CS1
				inner join
			Deleted CS2
				on CS1.CSID = CS2.CSID
				inner join
			AccountAlerts AA
				on CS1.CSID = AA.CSID
				inner join
			Classes C
				on CS1.ClassID = C.ClassID
				left join
			CustomGradeScaleGrades CGG
				on	C.CustomGradeScaleID = CGG.CustomGradeScaleID
					and
					CGG.GradeSymbol = dbo.GetLetterGrade(CS1.ClassID, CS1.StudentGrade)
			Where
			CS1.StudentGrade is null	-- For clearing out a grade and resetting High/LowClassGradeSent to 0
			or
			(
				CS1.StudentGrade != isnull(CS2.StudentGrade,-1)
				and 
				C.NonAcademic = 0
				and
				(
				AA.HighClassGradeAlert > 0
				or
				AA.LowClassGradeAlert > 0
				)
			)
		)AA2
			on AA1.AAID = AA2.AAID	
			
		
		-- *******************************************************************
		-- Update Students and ClassesStudents CoachAlert Columns
		-- *******************************************************************
		Declare @SportsEligibilityLetterGrade nvarchar(5) = (Select SportsEligibilityLetterGrade From Settings Where SettingID = 1)
		Declare @SportEligibilityGPA decimal(3,2) = (Select SportEligibilityGPA From Settings where SettingID = 1)
		Declare @IneligibleStudents table (StudentID int)
		Declare @SportsEligibilityStudents table (StudentID int)



		-- get SportsEligibilityStudents
		Insert into @SportsEligibilityStudents
		Select distinct StudentID
		From
		Classes C
			inner join 
		ClassesStudents CS
			on C.ClassID = CS.ClassID and C.ClassTypeID = 7
			inner join
		Terms T
			on C.TermID = T.TermID and T.Status = 1
		Where 
		CS.StudentID in (Select StudentID From Inserted)			


		-- get IneligibleStudents
		Insert into @IneligibleStudents
		Select
		CS.StudentID
		From
		@SportsEligibilityStudents SE
			 inner join 
		ClassesStudents CS
			on SE.StudentID = CS.StudentID
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
		C.ClassTypeID = 1
		and
		C.Units > 0
		and
		CS.StudentGrade is not null
		and
		CG.CalculateGPA = 1
		and  
		T.Status = (Select TermID From Classes Where ClassID = @ClassID)
		Group By CS.StudentID
		Having (
		convert(decimal(6,2),round((sum(dbo.getUnitGPA(C.ClassID, CS.StudentGrade)) / sum(C.Units)),4))
		) < @SportEligibilityGPA

		Union

		Select
		CS.StudentID
		From
		@SportsEligibilityStudents SE
			 inner join 
		ClassesStudents CS
			on SE.StudentID = CS.StudentID
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
		T.TermID = (Select TermID From Classes Where ClassID = @ClassID)
		and
		C.ClassTypeID in (1,8)
		and
		CS.StudentGrade is not null
		Group By CS.StudentID
			
		ALTER TABLE Students DISABLE TRIGGER ALL; 

		-- Update IneligibleStudent column on Students table
		Update Students
		Set IneligibleStudent = 
		case
			when StudentID in (Select StudentID From @IneligibleStudents) then 1
			else 0
		end
		Where
		StudentID in (Select StudentID From @SportsEligibilityStudents)
		

		-- Reset CoachEmailAlertSent column once they are eligible again
		Update Students
		Set CoachEmailAlertSent = 0
		Where
		StudentID in (Select StudentID From @SportsEligibilityStudents)
		and
		StudentID not in (Select StudentID From @IneligibleStudents)

		ALTER TABLE Students ENABLE TRIGGER ALL; 

	End -- If Hidden Class

End  -- If Update(StudentGrade)

End  -- Trigger Body
GO
ALTER TABLE [dbo].[ClassesStudents] ADD CONSTRAINT [PK_Classes-Students] PRIMARY KEY CLUSTERED ([CSID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassID] ON [dbo].[ClassesStudents] ([ClassID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClassesStudents] ADD CONSTRAINT [IX_ClassesStudents] UNIQUE NONCLUSTERED ([ClassID], [StudentID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[ClassesStudents] ([StudentID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClassesStudents] ADD CONSTRAINT [FK_ClassesStudents_Classes] FOREIGN KEY ([ClassID]) REFERENCES [dbo].[Classes] ([ClassID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ClassesStudents] ADD CONSTRAINT [FK_ClassesStudents_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID])
GO
