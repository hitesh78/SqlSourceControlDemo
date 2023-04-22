CREATE TABLE [dbo].[Discipline]
(
[DisciplineID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[DateOfIncident] [smalldatetime] NOT NULL,
[DateReportClosed] [smalldatetime] NULL,
[ReferredBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Discipline_ReferredBy] DEFAULT (''),
[ReferredTo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Discipline_ReferredTo] DEFAULT (''),
[IncidentCodes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentHist] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GradeLevel] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Discipline_GradeLevel] DEFAULT (''),
[Location] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Discipline_Location] DEFAULT (''),
[TeacherID] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Modified dt: 11/10/2021 ~JG
--				09-16-2022 ~FA
-- =============================================
CREATE    Trigger [dbo].[SendDisciplineEmails]
on [dbo].[Discipline]
After Insert
As
Begin

	Declare 
	@DisciplineTabTitle nvarchar(30), 
	@ShowDisciplineDescription bit,
	@ShowDisciplineResult bit,
	@DisciplineAllowParentEmailAlerts bit,
	@ShowDisciplineToStudents bit

	Select 
	@DisciplineTabTitle = DisciplineTabTitle,
	@ShowDisciplineDescription = ShowDisciplineDescription,
	@ShowDisciplineResult = ShowDisciplineResult,
	@DisciplineAllowParentEmailAlerts = DisciplineAllowParentEmailAlerts,
	@ShowDisciplineToStudents = ShowDisciplineToStudents
	From Settings 
	Where SettingID = 1

		-- determine teacher id from selection
		Declare @StudentID int;
		Declare @TeacherID int;
		Declare @insertedID int;
		Declare @refereeName nvarchar(120);
		Declare @refereeId int = NULL;
		
		Select
			@insertedID = i.DisciplineID,
			@StudentID = i.StudentID,
			@TeacherID = i.TeacherID,
			@refereeName = Coalesce(nullif(i.ReferredTo, ''), nullif(i.ReferredBy, ''))
		From inserted i;

		-- only update TeacherID if it is NULL
		IF @TeacherID IS NULL
		BEGIN
			IF @refereeName IS NOT NULL
			BEGIN
				Select 
					@refereeId = t.TeacherID
				From Teachers t
				Where t.glname = @refereeName			
			END;
		
			IF @refereeId IS NULL
			BEGIN
				Select TOP 1 
					@refereeId = t.TeacherID
				From Accounts a
					inner join Teachers t
						on t.AccountID = a.AccountID
				Where a.Access = 'Principal'
					and t.Active = 1
				Order by convert(datetime, LastLoginTime) desc;
			END
			-- update record
			update Discipline
			set TeacherID = @refereeId
			where DisciplineID = @insertedID;
		END

		-- Get all unique emails that want discipline alerts for students
		Declare @AccessTypeToSendTo table(Access nvarchar(10))
		insert into @AccessTypeToSendTo
		Select
		Access
		From Accounts
		Where
		AccountID in
		(
		Select 
		F.AccountID
		From 
		Students S
			inner join
		Families F
			on S.FamilyID = F.FamilyID or S.Family2ID = F.FamilyID
		Where StudentID = @StudentID

		Union

		Select AccountID From Students Where StudentID = @StudentID
		)
		and
		SendDisciplineEmails = 1
		and
		@DisciplineAllowParentEmailAlerts = 1


		--Select * From @AccessTypeToSendTo

		Declare @StudentsHaveParentAccess bit = (Select StudentAccountsHaveParentAccess From Settings Where SettingID = 1)

		Declare @EmailsToSendTo table (EmailAddress nvarchar(50), SchoolAdmin bit, AccountID nvarchar(50) null, FamilyID int null)
		Insert into @EmailsToSendTo
		Select Email1, 0, null, FamilyID From Students 
		Where StudentID = @StudentID and (exists (Select * From @AccessTypeToSendTo Where Access = 'Family') or
			(exists (Select * From @AccessTypeToSendTo Where Access = 'Student') and @StudentsHaveParentAccess = 1))
		Union
		Select Email2, 0, null, FamilyID From Students 
		Where StudentID = @StudentID and (exists (Select * From @AccessTypeToSendTo Where Access = 'Family') or
			(exists (Select * From @AccessTypeToSendTo Where Access = 'Student') and @StudentsHaveParentAccess = 1))
		Union
		Select Email3, 0, null, FamilyID From Students 
		Where StudentID = @StudentID and (exists (Select * From @AccessTypeToSendTo Where Access = 'Family') or
			(exists (Select * From @AccessTypeToSendTo Where Access = 'Student') and @StudentsHaveParentAccess = 1))
		Union
		Select Email4, 0, null, FamilyID From Students 
		Where StudentID = @StudentID and (exists (Select * From @AccessTypeToSendTo Where Access = 'Family') or
			(exists (Select * From @AccessTypeToSendTo Where Access = 'Student') and @StudentsHaveParentAccess = 1))
		Union
		Select Email5, 0, null, FamilyID From Students 
		Where StudentID = @StudentID and (exists (Select * From @AccessTypeToSendTo Where Access = 'Family') or
			(exists (Select * From @AccessTypeToSendTo Where Access = 'Student') and @StudentsHaveParentAccess = 1))
		Union
		Select Email6, 0, null, Family2ID From Students Where StudentID = @StudentID and exists (Select * From @AccessTypeToSendTo Where Access = 'Family2')
		Union
		Select Email7, 0, null, Family2ID From Students Where StudentID = @StudentID and exists (Select * From @AccessTypeToSendTo Where Access = 'Family2')
		Union
		Select Email8, 0, AccountID, null From Students 
		Where 
		StudentID = @StudentID 
		and 
		exists (Select * From @AccessTypeToSendTo Where Access = 'Student')
		and 
		@StudentsHaveParentAccess = 0
		and
		@ShowDisciplineToStudents = 1
		Union
		Select Email, 1, AccountID, null 
		From Teachers 
		Where DisciplineNotifications = 1
		and Active = 1

		-- Convert any Family ID references to Account IDs 
		-- for easy i18n LanguageType determination in the final query...
		update sendto
		set AccountID = F.AccountID
		from @EmailsToSendTo sendto
		inner join Families f
		on f.FamilyID = sendto.FamilyID
		where sendto.AccountID is null 
			and sendto.FamilyID is not null

		Declare @EmailSubject nvarchar(50) = 'Gradelink - New ' + @DisciplineTabTitle + ' Entry'

		--Select * From @EmailsToSendTo
		--Where
		--isnull(ltrim(rtrim(EmailAddress)),'') != ''

		Declare @CRNL nvarchar(6) = '<br/>' 
		insert into AlertLog
			( CSID,AlertType,Student,Email,AlertDescription,AlertDate,LanguageType )
		Select
			@StudentID as CSID,
			@EmailSubject as AlertType,
			S.glname as Student,
			E.EmailAddress as Email,
			@CRNL + S.glname + N' received the following ' + isnull(@DisciplineTabTitle,'') + N' Entry:'
			+ @CRNL +
			+ @CRNL + N'Incident: ' + isnull(D.IncidentCodes,'') 			
			+ @CRNL + N'Date of Entry: ' + dbo.GLformatdate(isnull(DateOfIncident,'')) 
			+ @CRNL + N'Location: ' + isnull(D.Location,'') 
			+ @CRNL + @CRNL +
			case 
				when E.SchoolAdmin = 1 then N'Referred By: ' + isnull(D.ReferredBy,'') 
			+ @CRNL else '' end	+
			case 
				when E.SchoolAdmin = 1 then N'Referred To: ' + isnull(D.ReferredTo,'') 
			+ @CRNL else '' end +	
			case
				when @ShowDisciplineDescription = 1 then N'Description: ' + isnull(D.IncidentDesc,'')  
			+ @CRNL else '' end
			--+ case
			--	when @ShowDisciplineResult = 1 then
			--		'Result: ' + 
			--		isnull(rtrim(ltrim(
			--			(
			--				SELECT SUBSTRING(
			--				(
			--				Select ';' + 
			--				DA.Result
			--				From
			--				(
			--					Select
			--					table_pk_id,
			--					(
			--						SELECT
			--						isnull(doc.col.value('NumUnits[1]', 'nvarchar(10)') +  ' ','') + -- UnitAmount
			--						isnull(doc.col.value('Units[1]', 'nvarchar(20)') +  ' ','') + -- Unit
			--						isnull(doc.col.value('Type[1]', 'nvarchar(50)'),'') as Result
			--						FROM xml_fields.nodes('.') doc(col) 
			--					) as Result
			--					From 
			--					xml_records X
			--					Where
			--					X.entityName like '%DisciplineActionTaken%'
			--				) DA
			--				Where
			--				DA.table_pk_id = D.DisciplineID
			--				FOR XML PATH('')
			--				)
			--				,2,200000) AS CSV
			--			)
			--		)),'')
			--else '' 
			--end
			as AlertDescription,
			DateOfIncident as AlertDate,
			A.LanguageType
		From 
		Students S
			inner join
		inserted D
			on S.StudentID = D.StudentID
		cross join
			(
			Select EmailAddress, SchoolAdmin, AccountID From @EmailsToSendTo
			Where isnull(ltrim(rtrim(EmailAddress)),'') != ''
			) E	
		left join Accounts A -- left join used because we wouldn't want to skip an email just because of a problem with LanguageType (we cand default to English)
		on E.AccountID = A.AccountID
		Where
		case
			when @StudentID = -1 then 1
			when D.StudentID = @StudentID then 1
			else 0
		end = 1

End

GO
ALTER TABLE [dbo].[Discipline] ADD CONSTRAINT [PK_Discipline] PRIMARY KEY CLUSTERED ([DisciplineID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[Discipline] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TeacherID] ON [dbo].[Discipline] ([TeacherID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Discipline] ADD CONSTRAINT [FK_Discipline_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Discipline] ADD CONSTRAINT [FK_Discipline_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID])
GO
