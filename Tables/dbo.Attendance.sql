CREATE TABLE [dbo].[Attendance]
(
[ClassDate] [datetime] NOT NULL,
[CSID] [int] NOT NULL,
[Att1] [decimal] (3, 2) NOT NULL CONSTRAINT [DF_Attendence_Attendence] DEFAULT ((1)),
[Att2] [decimal] (3, 2) NOT NULL CONSTRAINT [DF_Attendence_Conduct] DEFAULT ((0)),
[Att3] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Absent] DEFAULT ((0)),
[Att4] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_UTardy] DEFAULT ((0)),
[Att5] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_UAbsent] DEFAULT ((0)),
[Att6] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att6] DEFAULT ((0)),
[Att7] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att7] DEFAULT ((0)),
[Att8] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att8] DEFAULT ((0)),
[Att9] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att9] DEFAULT ((0)),
[Att10] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att10] DEFAULT ((0)),
[Att11] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att11] DEFAULT ((0)),
[Att12] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att12] DEFAULT ((0)),
[Att13] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att13] DEFAULT ((0)),
[Att14] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att14] DEFAULT ((0)),
[Att15] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Att15] DEFAULT ((0)),
[Comments] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exceptional] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Exceptional] DEFAULT ((0)),
[Good] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Good] DEFAULT ((1)),
[Poor] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Poor] DEFAULT ((0)),
[Unacceptable] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_Unacceptable] DEFAULT ((0)),
[ChurchPresent] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_ChurchPresent] DEFAULT ((1)),
[ChurchAbsent] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_ChurchAbsent] DEFAULT ((0)),
[SSchoolPresent] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_SSchoolPresent] DEFAULT ((1)),
[SSchoolAbsent] [tinyint] NOT NULL CONSTRAINT [DF_Attendance_SSchoolAbsent] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[LogAttendanceAlerts]
on [dbo].[Attendance]
After Update
As
Begin

	-- Note: @TurnOffAttendanceAlerts only affects ClassAttendance
	Declare @TurnOffAttendanceAlerts bit = (Select TurnOffAttendanceAlerts From Settings Where SettingID = 1)
	Declare @HideAcademicTabsForLowGrades int = (Select isnull(HideAcademicTabsForLowGrades,-100) From Settings Where SettingID = 1)
	Declare @CSID int = (Select CSID from Inserted)
	Declare @OKToSendAttendanceAlerts bit = 0
	Declare @GradeLevel nvarchar(5)= 
	(
	Select GradeLevel
	From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
	Where
	CS.CSID = @CSID
	)
	
	Declare @ClassTypeID int = 
	(
		Select ClassTypeID
		From 
		Classes C
			inner join
		ClassesStudents CS
			on C.ClassID = CS.ClassID
		Where
		CS.CSID = @CSID
	)

	if 
		case @GradeLevel
		  when 'PS' then -2
		  when 'PK' then -1
		  when 'K' then 0
		  when '1' then 1
		  when '2' then 2
		  when '3' then 3
		  when '4' then 4
		  when '5' then 5
		  when '6' then 6
		  when '7' then 7
		  when '8' then 8
		  when '9' then 9
		  when '10' then 10
		  when '11' then 11
		  when '12' then 12
		  else 13
		end	>= @HideAcademicTabsForLowGrades
	Begin
		Set @OKToSendAttendanceAlerts = 1
	End

	If (@TurnOffAttendanceAlerts = 0 or @ClassTypeID = 5) and @OKToSendAttendanceAlerts = 1
	Begin

		

		Declare @InsertedAtt1 tinyint = (Select Att1 from Inserted)
		Declare @DeletedAtt1 tinyint = (Select Att1 from Deleted) 
		Declare @InsertedAtt2 tinyint = (Select Att2 from Inserted)
		Declare @DeletedAtt2 tinyint = (Select Att2 from Deleted) 
		Declare @InsertedAtt3 tinyint = (Select Att3 from Inserted) 
		Declare @DeletedAtt3 tinyint = (Select Att3 from Deleted) 
		Declare @InsertedAtt4 tinyint = (Select Att4 from Inserted) 
		Declare @DeletedAtt4 tinyint = (Select Att4 from Deleted)
		Declare @InsertedAtt5 tinyint = (Select Att5 from Inserted) 
		Declare @DeletedAtt5 tinyint = (Select Att5 from Deleted) 
		Declare @InsertedAtt6 tinyint = (Select Att6 from Inserted)
		Declare @DeletedAtt6 tinyint = (Select Att6 from Deleted)
		Declare @InsertedAtt7 tinyint = (Select Att7 from Inserted) 
		Declare @DeletedAtt7 tinyint = (Select Att7 from Deleted)
		Declare @InsertedAtt8 tinyint = (Select Att8 from Inserted)
		Declare @DeletedAtt8 tinyint = (Select Att8 from Deleted)
		Declare @InsertedAtt9 tinyint = (Select Att9 from Inserted) 
		Declare @DeletedAtt9 tinyint = (Select Att9 from Deleted) 
		Declare @InsertedAtt10 tinyint = (Select Att10 from Inserted)
		Declare @DeletedAtt10 tinyint = (Select Att10 from Deleted)
		Declare @InsertedAtt11 tinyint = (Select Att11 from Inserted)
		Declare @DeletedAtt11 tinyint = (Select Att11 from Deleted) 
		Declare @InsertedAtt12 tinyint = (Select Att12 from Inserted)
		Declare @DeletedAtt12 tinyint = (Select Att12 from Deleted)
		Declare @InsertedAtt13 tinyint = (Select Att13 from Inserted)
		Declare @DeletedAtt13 tinyint = (Select Att13 from Deleted)
		Declare @InsertedAtt14 tinyint = (Select Att14 from Inserted) 
		Declare @DeletedAtt14 tinyint = (Select Att14 from Deleted)
		Declare @InsertedAtt15 tinyint = (Select Att15 from Inserted)
		Declare @DeletedAtt15 tinyint = (Select Att15 from Deleted)

		Declare @InsertedExceptional tinyint = (Select Exceptional from Inserted) 
		Declare @DeletedExceptional tinyint = (Select Exceptional from Deleted)
		Declare @InsertedGood tinyint = (Select Good from Inserted) 
		Declare @DeletedGood tinyint = (Select Good from Deleted) 
		Declare @InsertedPoor tinyint = (Select Poor from Inserted) 
		Declare @DeletedPoor tinyint = (Select Poor from Deleted)
		Declare @InsertedUnacceptable tinyint = (Select Unacceptable from Inserted) 
		Declare @DeletedUnacceptable tinyint = (Select Unacceptable from Deleted) 
		Declare @DateInserted datetime = (Select ClassDate from Inserted)



		 If (@InsertedAtt1 != @DeletedAtt1)
			or (@InsertedAtt2 != @DeletedAtt2)
			or (@InsertedAtt3 != @DeletedAtt3)
			or (@InsertedAtt4 != @DeletedAtt4)
			or (@InsertedAtt5 != @DeletedAtt5)
			or (@InsertedAtt6 != @DeletedAtt6)
			or (@InsertedAtt7 != @DeletedAtt7)
			or (@InsertedAtt8 != @DeletedAtt8)
			or (@InsertedAtt9 != @DeletedAtt9)
			or (@InsertedAtt10 != @DeletedAtt10)
			or (@InsertedAtt11 != @DeletedAtt11)
			or (@InsertedAtt12 != @DeletedAtt12)
			or (@InsertedAtt13 != @DeletedAtt13)
			or (@InsertedAtt14 != @DeletedAtt14)
			or (@InsertedAtt15 != @DeletedAtt15)
			or (@InsertedExceptional != @DeletedExceptional)
			or (@InsertedGood != @DeletedGood)
			or (@InsertedPoor != @DeletedPoor)
			or (@InsertedUnacceptable != @DeletedUnacceptable)
			or ((@DeletedAtt1 is null) and (@InsertedAtt1 is not null))

		 Begin

			   Declare @Att1Changed bit
			   Declare @Att2Changed bit
			   Declare @Att3Changed bit
			   Declare @Att4Changed bit
			   Declare @Att5Changed bit
			   Declare @Att6Changed bit
			   Declare @Att7Changed bit
			   Declare @Att8Changed bit
			   Declare @Att9Changed bit
			   Declare @Att10Changed bit
			   Declare @Att11Changed bit
			   Declare @Att12Changed bit
			   Declare @Att13Changed bit
			   Declare @Att14Changed bit
			   Declare @Att15Changed bit

			   Declare @ExceptionalChanged bit
			   Declare @GoodChanged bit
			   Declare @PoorChanged bit
			   Declare @UnacceptableChanged bit

			  If (@InsertedAtt1 != @DeletedAtt1)
			  Begin
				Set @Att1Changed = 1
			  End
			  If (@InsertedAtt2 != @DeletedAtt2)
			  Begin
				Set @Att2Changed = 1
			  End
			  If (@InsertedAtt3 != @DeletedAtt3)
			  Begin
				Set @Att3Changed = 1
			  End
			  If (@InsertedAtt4 != @DeletedAtt4)
			  Begin
				Set @Att4Changed = 1
			  End
			  If (@InsertedAtt5 != @DeletedAtt5)
			  Begin
				Set @Att5Changed = 1
			  End
			  If (@InsertedAtt6 != @DeletedAtt6)
			  Begin
				Set @Att6Changed = 1
			  End
			  If (@InsertedAtt7 != @DeletedAtt7)
			  Begin
				Set @Att7Changed = 1
			  End
			  If (@InsertedAtt8 != @DeletedAtt8)
			  Begin
				Set @Att8Changed = 1
			  End
			  If (@InsertedAtt9 != @DeletedAtt9)
			  Begin
				Set @Att9Changed = 1
			  End
			  If (@InsertedAtt10 != @DeletedAtt10)
			  Begin
				Set @Att10Changed = 1
			  End
			  If (@InsertedAtt11 != @DeletedAtt11)
			  Begin
				Set @Att11Changed = 1
			  End
			  If (@InsertedAtt12 != @DeletedAtt12)
			  Begin
				Set @Att12Changed = 1
			  End
			  If (@InsertedAtt13 != @DeletedAtt13)
			  Begin
				Set @Att13Changed = 1
			  End
			  If (@InsertedAtt14 != @DeletedAtt14)
			  Begin
				Set @Att14Changed = 1
			  End
			  If (@InsertedAtt15 != @DeletedAtt15)
			  Begin
				Set @Att15Changed = 1
			  End

			  If (@InsertedExceptional != @DeletedExceptional)
			  Begin
				Set @ExceptionalChanged = 1
			  End
			  If (@InsertedGood != @DeletedGood)
			  Begin
				Set @GoodChanged = 1
			  End
			  If (@InsertedPoor != @DeletedPoor)
			  Begin
				Set @PoorChanged = 1
			  End
			  If (@InsertedUnacceptable != @DeletedUnacceptable)
			  Begin
				Set @UnacceptableChanged = 1
			  End










			Declare @AccountAlerts table
			(
			[CSID] int,
			[AccountID] [nvarchar](50),
			[HighConductAlert] [tinyint],
			[LowConductAlert] [tinyint],
			[Att2Alert] [bit],
			[Att3Alert] [bit],
			[Att4Alert] [bit],
			[Att5Alert] [bit],
			[Att6Alert] [bit],
			[Att7Alert] [bit],
			[Att8Alert] [bit],
			[Att9Alert] [bit],
			[Att10Alert] [bit],
			[Att11Alert] [bit],
			[Att12Alert] [bit],
			[Att13Alert] [bit],
			[Att14Alert] [bit],
			[Att15Alert] [bit]
			)


			Insert into @AccountAlerts
			Select 
			CSID,
			AccountID,
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
			From 
			AccountAlerts
			Where
			CSID = @CSID


			Declare @AlertDate nchar(30) =  (Select convert(nchar(30),ClassDate) from Inserted)
			Declare @StudentsHaveParentAccess bit = (Select StudentAccountsHaveParentAccess From Settings Where SettingID = 1)

			Declare @AccountAlertsToSend table (CSID int, AccountID nvarchar(50), Subject nvarchar(30), AttendanceTitle nvarchar(50))


			-- Get alerts to send to each account
			insert into @AccountAlertsToSend
			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			case 
				when @ClassTypeID = 5 then (Select Title From AttendanceSettings Where ID = 'Att2') 
				else (Select Attendance2 From Settings Where SettingID = 1)
			end as AttendanceTitle
			From @AccountAlerts
			Where
			Att2Alert = 1
			and
			@Att2Changed = 1
			and
			@InsertedAtt2 = 1

			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			case 
				when @ClassTypeID = 5 then (Select Title From AttendanceSettings Where ID = 'Att3') 
				else (Select Attendance3 From Settings Where SettingID = 1)
			end as AttendanceTitle
			From @AccountAlerts
			Where
			Att3Alert = 1
			and
			@Att3Changed = 1
			and
			@InsertedAtt3 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			case 
				when @ClassTypeID = 5 then (Select Title From AttendanceSettings Where ID = 'Att4') 
				else (Select Attendance4 From Settings Where SettingID = 1)
			end as AttendanceTitle
			From @AccountAlerts
			Where
			Att4Alert = 1
			and
			@Att4Changed = 1
			and
			@InsertedAtt4 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			case 
				when @ClassTypeID = 5 then (Select Title From AttendanceSettings Where ID = 'Att5') 
				else (Select Attendance5 From Settings Where SettingID = 1)
			end as AttendanceTitle
			From @AccountAlerts
			Where
			Att5Alert = 1
			and
			@Att5Changed = 1
			and
			@InsertedAtt5 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att6') as AttendanceTitle
			From @AccountAlerts
			Where
			Att6Alert = 1
			and
			@Att6Changed = 1
			and
			@InsertedAtt6 = 1

			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att7') as AttendanceTitle
			From @AccountAlerts
			Where
			Att7Alert = 1
			and
			@Att7Changed = 1
			and
			@InsertedAtt7 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att8') as AttendanceTitle
			From @AccountAlerts
			Where
			Att8Alert = 1
			and
			@Att8Changed = 1
			and
			@InsertedAtt8 = 1

			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att9') as AttendanceTitle
			From @AccountAlerts
			Where
			Att9Alert = 1
			and
			@Att9Changed = 1
			and
			@InsertedAtt9 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att10') as AttendanceTitle
			From @AccountAlerts
			Where
			Att10Alert = 1
			and
			@Att10Changed = 1
			and
			@InsertedAtt10 = 1

			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att11') as AttendanceTitle
			From @AccountAlerts
			Where
			Att11Alert = 1
			and
			@Att11Changed = 1
			and
			@InsertedAtt11 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att12') as AttendanceTitle
			From @AccountAlerts
			Where
			Att12Alert = 1
			and
			@Att12Changed = 1
			and
			@InsertedAtt12 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att13') as AttendanceTitle
			From @AccountAlerts
			Where
			Att13Alert = 1
			and
			@Att13Changed = 1
			and
			@InsertedAtt13 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att14') as AttendanceTitle
			From @AccountAlerts
			Where
			Att14Alert = 1
			and
			@Att14Changed = 1
			and
			@InsertedAtt14 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'Attendance Alert' as Subject,
			(Select Title From AttendanceSettings Where ID = 'Att15') as AttendanceTitle
			From @AccountAlerts
			Where
			Att15Alert = 1
			and
			@Att15Changed = 1
			and
			@InsertedAtt15 = 1


			Union

			Select 
			CSID, 
			AccountID,
			'High Conduct Alert' as Subject,
			(case 
				When @InsertedExceptional = 1 Then 'Exceptional'
				When @InsertedGood = 1 Then 'Satisfactory'
				When @InsertedPoor = 1 Then 'Needs Improvement'
				When @InsertedUnacceptable = 1 Then 'Unacceptable'
			 end) as AttendanceTitle
			From @AccountAlerts
			Where
			HighConductAlert >=
				(case 
					When @InsertedExceptional = 1 Then 1
					When @InsertedGood = 1 Then 2
					When @InsertedPoor = 1 Then 3
					When @InsertedUnacceptable = 1 Then 4
				 end)
			and 
			HighConductAlert != 0 
			and 
			((@ExceptionalChanged = 1) or (@GoodChanged = 1) or (@PoorChanged = 1) or (@UnacceptableChanged = 1))

			Union

			Select 
			CSID, 
			AccountID,
			'Low Conduct Alert' as Subject,
			(case 
				When @InsertedExceptional = 1 Then 'Exceptional'
				When @InsertedGood = 1 Then 'Satisfactory'
				When @InsertedPoor = 1 Then 'Needs Improvement'
				When @InsertedUnacceptable = 1 Then 'Unacceptable'
			 end) as AttendanceTitle
			From @AccountAlerts
			Where
			LowConductAlert <=
				(case 
					When @InsertedExceptional = 1 Then 1
					When @InsertedGood = 1 Then 2
					When @InsertedPoor = 1 Then 3
					When @InsertedUnacceptable = 1 Then 4
				 end)
			and 
			LowConductAlert != 0 
			and 
			((@ExceptionalChanged = 1) or (@GoodChanged = 1) or (@PoorChanged = 1) or (@UnacceptableChanged = 1))






			--Select * From @AccountAlertsToSend
			Declare @DateTimeOfAlert nchar(30) = (Select convert(nchar(30),dbo.GLgetdatetime()))

			Insert Into AlertLog(CSID, AlertType, Student, Email, AlertDescription, AlertDate,LanguageType)
			Select distinct
			AA.CSID,
			AA.Subject,
			S.glname as Student,
			AE.EmailAddress,
			case
				when AA.Subject = 'Attendance Alert' then
					'An Attendance mark of (' + AA.AttendanceTitle + ') as entered in ' + 
					C.ClassTitle + ' for ' + glname + ' on ' + 
					datename(weekday,@AlertDate) + ', ' + datename(month,@AlertDate) + ' ' + datename(day,@AlertDate) +  '.'
				else
					'A conduct mark of (' + AA.AttendanceTitle + ') was entered in ' + 
					C.ClassTitle + ' for ' + glname + ' on ' + 
					datename(weekday,@AlertDate) + ', ' + datename(month,@AlertDate) + ' ' + datename(day,@AlertDate) +  '.'
			end as AlertDescription,
			@DateTimeOfAlert as AlertDate,
			(Select LanguageType from Accounts where AccountID = AA.AccountID) as LanguageType
			From
			@AccountAlertsToSend AA
				inner join
			ClassesStudents CS
				on AA.CSID = CS.CSID
				inner join
			Students S
				on S.StudentID = CS.StudentID
				inner join
			Classes C
				on C.ClassID = CS.ClassID
				inner join
			(
				Select F.AccountID, S.Email1 as EmailAddress 
				From Students S	inner join Families F on S.FamilyID = F.FamilyID
				Where CHARINDEX('@', S.Email1) != 0
				Union
				Select F.AccountID, S.Email2 as EmailAddress 
				From Students S	inner join Families F on S.FamilyID = F.FamilyID
				Where CHARINDEX('@', S.Email2) != 0
				Union
				Select F.AccountID, S.Email3 as EmailAddress 
				From Students S	inner join Families F on S.FamilyID = F.FamilyID
				Where CHARINDEX('@', S.Email3) != 0
				Union
				Select F.AccountID, S.Email4 as EmailAddress 
				From Students S	inner join Families F on S.FamilyID = F.FamilyID
				Where CHARINDEX('@', S.Email4) != 0
				Union
				Select F.AccountID, S.Email5 as EmailAddress 
				From Students S	inner join Families F on S.FamilyID = F.FamilyID
				Where CHARINDEX('@', S.Email5) != 0
				Union
				Select F.AccountID, S.Email6 as EmailAddress 
				From Students S	inner join Families F on S.Family2ID = F.FamilyID
				Where CHARINDEX('@', S.Email6) != 0
				Union
				Select F.AccountID, S.Email7 as EmailAddress 
				From Students S	inner join Families F on S.Family2ID = F.FamilyID
				Where CHARINDEX('@', S.Email7) != 0
				Union
				Select AccountID, Email8 as EmailAddress From Students 
				Where CHARINDEX('@', Email8) != 0 and @StudentsHaveParentAccess = 0
				Union
				Select AccountID, Email1 as EmailAddress From Students 
				Where CHARINDEX('@', Email1) != 0 and @StudentsHaveParentAccess = 1
				Union
				Select AccountID, Email2 as EmailAddress From Students 
				Where CHARINDEX('@', Email2) != 0 and @StudentsHaveParentAccess = 1
				Union
				Select AccountID, Email3 as EmailAddress From Students 
				Where CHARINDEX('@', Email3) != 0 and @StudentsHaveParentAccess = 1
				Union
				Select AccountID, Email4 as EmailAddress From Students 
				Where CHARINDEX('@', Email4) != 0 and @StudentsHaveParentAccess = 1
				Union
				Select AccountID, Email5 as EmailAddress From Students 
				Where CHARINDEX('@', Email5) != 0 and @StudentsHaveParentAccess = 1
			) AE
				on AA.AccountID = AE.AccountID	



		End

	End -- if statement
End


GO
ALTER TABLE [dbo].[Attendance] ADD CONSTRAINT [PK_Attendence] PRIMARY KEY CLUSTERED ([ClassDate], [CSID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CSID] ON [dbo].[Attendance] ([CSID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Attendance] ADD CONSTRAINT [FK_Attendance_ClassesStudents] FOREIGN KEY ([CSID]) REFERENCES [dbo].[ClassesStudents] ([CSID]) ON DELETE CASCADE
GO
