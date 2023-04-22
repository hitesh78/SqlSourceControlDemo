CREATE TABLE [dbo].[Teachers]
(
[TeacherID] [int] NOT NULL,
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StaffType] [tinyint] NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_Teachers_Active] DEFAULT ((1)),
[StaffTitle] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BCCteacherEmail] [bit] NOT NULL CONSTRAINT [DF_Teachers_BCCteacherEmail] DEFAULT ((0)),
[BCCemailACK] [bit] NOT NULL CONSTRAINT [DF_Teachers_BCCemailACK] DEFAULT ((0)),
[Permissions] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Teachers_Permissions] DEFAULT ('=Students=,=Grades Preview Pane=,=Counseling=,=Medical=,=Financial=,=Classes=,=Terms=,=Administrator Reports=,=Populate Classes=,=Attendance=,=Transcripts=,=Communicate='),
[BCCProspectiveEmail] [bit] NOT NULL CONSTRAINT [DF_Teachers_BCCProspectiveEmail] DEFAULT ((0)),
[NotifyEnrollmeStarted] [bit] NOT NULL CONSTRAINT [DF_Teachers_NotifyEnrollmeStarted] DEFAULT ((0)),
[NotifyEnrollmeSubmitted] [bit] NOT NULL CONSTRAINT [DF_Teachers_NotifyEnrollmeSubmitted] DEFAULT ((0)),
[NotifyEnrollmeInProcess] [bit] NOT NULL CONSTRAINT [DF_Teachers_NotifyEnrollmeInProcess] DEFAULT ((0)),
[NotifyEnrollmePending] [bit] NOT NULL CONSTRAINT [DF_Teachers_NotifyEnrollmePending] DEFAULT ((0)),
[NotifyEnrollmeCancelled] [bit] NOT NULL CONSTRAINT [DF_Teachers_NotifyEnrollmeCancelled] DEFAULT ((0)),
[NotifyEnrollmeApproved] [bit] NOT NULL CONSTRAINT [DF_Teachers_NotifyEnrollmeApproved] DEFAULT ((0)),
[NotifyEnrollmeNotApproved] [bit] NOT NULL CONSTRAINT [DF_Teachers_NotifyEnrollmeNotApproved] DEFAULT ((0)),
[CalendarId] [int] NULL,
[BirthDate] [date] NULL,
[Gender] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaritalStatus] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Education] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDateAtJob] [date] NULL,
[HireDate] [date] NULL,
[EmploymentType] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayGrade] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency1Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency1Relationship] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency1Phone1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency1Phone2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency1Email1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency1Email2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency2Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency2Relationship] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency2Phone1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency2Phone2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency2Email1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emergency2Email2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HispanicEthnicity] [bit] NULL,
[StaffTags] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StaffNotes] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostCollectionID] [int] NULL CONSTRAINT [DF_Teachers_PostCollectionID] DEFAULT (NULL),
[ReleaseDate] [date] NULL,
[ShareAssignmentCollection] [bit] NOT NULL CONSTRAINT [DF_Teachers_ShareAssignmentCollection] DEFAULT ((0)),
[ViewAssignmentCollectionsFrom] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShareLPCollection] [bit] NOT NULL CONSTRAINT [DF_Teachers_ShareLPCollection] DEFAULT ((0)),
[ViewLPCollectionsFrom] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowNongraded] [bit] NOT NULL CONSTRAINT [DF_Teachers_ShowNongraded] DEFAULT ((0)),
[DisciplineNotifications] [bit] NOT NULL CONSTRAINT [DF_Teachers_DisciplineNotifications] DEFAULT ((0)),
[glname] AS (case isnull(session_context(N'AdminLanguage'),'English') when 'Chinese' then [Lname]+[Fname] else (([Lname]+', ')+[Fname])+case  when len(ltrim(rtrim([Mname])))>(0) then (' '+left([Mname],(1)))+'.' else '' end end),
[NotifyAttendance] [bit] NOT NULL CONSTRAINT [DF__Teachers__Notify__5BCFFA5E] DEFAULT ((0)),
[ProfessionalLevel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCatholic] [bit] NULL,
[StatePersonnelNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StaffRoles] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Teachers_StaffRoles] DEFAULT ('0'),
[EdFiRole] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edfiRequestID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edfiRequestStatus] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edfiLastIdentityRequest] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[Teachers_UpdatePhoneNumbers]
 on [dbo].[Teachers]
 After Update, Insert
as
begin
	-- Replicate Contact Phone # fields to PhoneNumbers table
	--
	-- Regarding the use of the serializable hint with merge,
	-- see http://michaeljswart.com/2011/09/mythbusting-concurrent-updateinsert-solutions/



	-- UPDATE  - 8/3/2021 dp
	-- This Trigger was updated to improve performace when editing Students table
	-- Changes inclued:
	-- Removed/disabled [PhoneNumbers_format_sis_phones] trigger on PhoneNumbers table
	-- Added business logic from [PhoneNumbers_format_sis_phones] trigger to this trigger





	-- https://stackoverflow.com/questions/2164282/if-update-in-sql-server-trigger
	-- Only run trigger if there are actual changes to the data values as update will run even if data not changed but still updated
	-- Include union to add new inserted records
    
	-- get changed records from updating
	if exists(
				SELECT  d.*
				FROM    
				deleted d
					INNER JOIN 
				inserted i
					ON i.TeacherID = d.TeacherID
				WHERE NOT EXISTS( 
									SELECT 
										i.TeacherID,
										i.phone,
										i.phone2,
										i.phone3

									INTERSECT 
									
									SELECT 
										d.TeacherID,
										d.phone,
										d.phone2,
										d.phone3
								)

				Union 

				-- add new inserted records
				Select i.*
				From 
				inserted i
				Where
				i.TeacherID not in (select TeacherID from deleted)
			)
	Begin


		if update(phone) 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Teachers
			on Teachers.TeacherID = PhoneNumbers.TeacherID
				and 'Work' = PhoneNumbers.Type
			when matched and Teachers.phone != (Select phone From deleted where TeacherID = Teachers.TeacherID) then
				update set 
					Phone = dbo.parsePhoneE164(Teachers.Phone,'phone'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Teachers.phone,'phone') is not null then
				insert (TeacherID,Type,Phone,PhoneNumberValid,VerifiedOn)
				values (
							Teachers.TeacherID,
							'Work',
							dbo.parsePhoneE164(Teachers.Phone,'phone'),
							null,
							null
						);
		end

		if update(phone2) 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Teachers
			on Teachers.TeacherID = PhoneNumbers.TeacherID
				and 'Cell' = PhoneNumbers.Type
			when matched and Teachers.phone2 != (Select phone2 From deleted where TeacherID = Teachers.TeacherID) then
				update set 
					Phone = dbo.parsePhoneE164(Teachers.Phone2,'phone'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Teachers.phone2,'phone') is not null then
				insert (TeacherID,Type,Phone,PhoneNumberValid,VerifiedOn)
				values (
							Teachers.TeacherID,
							'Cell',
							dbo.parsePhoneE164(Teachers.Phone2,'phone'),
							null,
							null
						);
		end

		if update(phone3) 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Teachers
			on Teachers.TeacherID = PhoneNumbers.TeacherID
				and 'Home' = PhoneNumbers.Type
			when matched and Teachers.phone3 != (Select phone3 From deleted where TeacherID = Teachers.TeacherID) then
				update set 
					Phone = dbo.parsePhoneE164(Teachers.Phone3,'phone'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Teachers.phone3,'phone') is not null then
				insert (TeacherID,Type,Phone,PhoneNumberValid,VerifiedOn)
				values (
							Teachers.TeacherID,
							'Home',
							dbo.parsePhoneE164(Teachers.Phone3,'phone'),
							null,
							null
						);
		end



		-- Delete blank or null phone numbers...
		delete from PhoneNumbers
		Where
		isnull(phone,'') = '';



		-- Set PhoneNumberValid Column
		Update PhoneNumbers
		set PhoneNumberValid = x.MaxPhoneNumberValid
		From
		PhoneNumbers P
			inner join
		(
						Select
						Phone,
						max(convert(tinyint,PhoneNumberValid)) as MaxPhoneNumberValid
						From PhoneNumbers
						Where
						PhoneNumberValid is not null
						Group By Phone
		) x
			on x.Phone = P.Phone
		Where
		P.Phone in (
					Select dbo.parsePhoneE164(Phone,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone2,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone3,'phone') from inserted
				);



		-- Update VerifiedOn
		Update PhoneNumbers
		set VerifiedOn = x.MaxVerifiedOn
		From
		PhoneNumbers P
			inner join
		(
						Select
						Phone,
						max(VerifiedOn) as MaxVerifiedOn
						From PhoneNumbers
						Where
						LineType is not null
						and
						VerifiedOn is not null
						Group By Phone
		) x
			on x.Phone = P.Phone
		Where
		P.Phone in (
					Select dbo.parsePhoneE164(Phone,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone2,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone3,'phone') from inserted
				)


		-- Update LineType
		Update PhoneNumbers
		set LineType = x.MaxLineType
		From
		PhoneNumbers P
			inner join
		(
						Select
						Phone,
						max(LineType) as MaxLineType
						From PhoneNumbers
						Where
						LineType is not null
						and
						VerifiedOn is not null
						Group By Phone
		) x
			on x.Phone = P.Phone
		Where
		P.Phone in (
					Select dbo.parsePhoneE164(Phone,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone2,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone3,'phone') from inserted
				)


	End		-- if new or changed records exists

end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateAccountsAfterDelete]
 on [dbo].[Teachers]
 After Delete
As
 Delete from CalendarSelection
 Where AccountID in (Select AccountID From Deleted)
 Delete from Accounts
 Where AccountID in (Select AccountID From Deleted)
GO
ALTER TABLE [dbo].[Teachers] ADD CONSTRAINT [PK_Teachers] PRIMARY KEY CLUSTERED ([TeacherID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountID] ON [dbo].[Teachers] ([AccountID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Teachers] ADD CONSTRAINT [UNQ_Teachers_AccountID] UNIQUE NONCLUSTERED ([AccountID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CalendarId] ON [dbo].[Teachers] ([CalendarId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET ARITHABORT ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_PostCollectionID_notnull] ON [dbo].[Teachers] ([PostCollectionID]) WHERE ([PostCollectionID] IS NOT NULL) ON [PRIMARY]
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET ARITHABORT ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_Teachers_SPN] ON [dbo].[Teachers] ([StatePersonnelNumber]) WHERE ([StatePersonnelNumber] IS NOT NULL) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Teachers] ADD CONSTRAINT [FK_Teachers_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Accounts] ([AccountID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Teachers] ADD CONSTRAINT [FK_Teachers_Calendar] FOREIGN KEY ([CalendarId]) REFERENCES [dbo].[Calendar] ([CalendarId])
GO
