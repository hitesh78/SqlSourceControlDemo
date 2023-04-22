CREATE TABLE [dbo].[StudentMiscFields]
(
[StudentID] [int] NOT NULL,
[BaptismDate] [date] NULL,
[CommunionDate] [date] NULL,
[ConfirmationDate] [date] NULL,
[WeddingDate] [date] NULL,
[BirthCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_BirthCity] DEFAULT (''),
[BirthState] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_BirthState] DEFAULT (''),
[BirthZip] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_BirthZip] DEFAULT (''),
[BirthCounty] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_BirthCounty] DEFAULT (''),
[StandTestID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_StandTestID] DEFAULT (''),
[BusOrCarpoolGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_BusOrCarpoolGroup] DEFAULT (''),
[Religion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_Religion] DEFAULT (''),
[ReligionChurch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_Church] DEFAULT (''),
[ReligionConversionDate] [date] NULL,
[ReligionUpdated] [date] NULL,
[FamStat] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_FamStat] DEFAULT (''),
[FamStatNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamStatUpdated] [date] NULL,
[MedAlert] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_MedAlert] DEFAULT (''),
[MedAlertNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedAlertUpdated] [date] NULL,
[IEPorDisabled] [bit] NOT NULL CONSTRAINT [DF_StudentMiscFields_DisabledOrIEP] DEFAULT ((0)),
[IEPCodes] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_IEPCodes] DEFAULT (''),
[IEPNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StudentMiscFields_IEPNotes] DEFAULT (''),
[PrimaryLanguage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_PrimaryLanguage] DEFAULT (''),
[EnglishFluency] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_EnglishFluency] DEFAULT (''),
[Forms] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_Forms] DEFAULT (''),
[FormsUpdated] [date] NULL,
[FinAid] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_FinAid] DEFAULT (''),
[FinAidNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinAidUpdated] [date] NULL,
[SchoolDistrict] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_SchoolDistrict] DEFAULT (''),
[FormerSchool] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StudentMiscFields_FormerSchool] DEFAULT (''),
[ReconciliationDate] [date] NULL,
[MedicalInsurance] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Campus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nationality] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GOVid_encrypted] [varbinary] (max) NULL,
[GOVid_plaintext] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACTS_Username] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACTS_CustomerID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACTS_Username2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACTS_CustomerID2] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondaryLanguage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CorpNumberIndiana_DOE_MV] [int] NULL,
[StudentCountyID] [int] NULL,
[Virtual_Due_To_Covid19] [bit] NULL CONSTRAINT [DF_Virtual_Due_To_Covid19] DEFAULT ((0)),
[USEntryDate] [smalldatetime] NULL,
[EdfiLanguageCodeValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdfiBirthCountryCodeValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryEdSchool] [bit] NOT NULL CONSTRAINT [DF_StudentMiscFields_PrimaryEdSchool] DEFAULT ((0)),
[ELLInstrument] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edfiRequestID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edfiRequestStatus] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edfiLastIdentityRequest] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 6/7/2021
-- Description:	Updates BirthCounty and Primary Language columns when a school updates corresponding edfi fields
-- =============================================
CREATE     TRIGGER [dbo].[SyncEdfiFields]
   ON  [dbo].[StudentMiscFields]
   After INSERT,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
Declare @EnableEdFi bit = (Select SS.Enabled From [LKG].dbo.glServices S left join [LKG].dbo.glSchoolServices SS on S.ServiceID = SS.ServiceID Where S.ServiceID = 31 and SS.SchoolID = DB_NAME())
IF(@EnableEdFi = 1) 
 Begin
	IF UPDATE(EdfiLanguageCodeValue)
	BEGIN
		
		Update StudentMiscFields 
		Set PrimaryLanguage = ED.ShortDescription
		From 
		StudentMiscFields SM
			inner join
		Inserted I 
			on SM.StudentID = I.StudentID
			inner join
		(
			Select 
			CodeValue,
			ShortDescription 
			From lkg.dbo.edfiDescriptorsAndTypes
			Where
			Name = 'LanguageDescriptor'
		) ED
			on I.EdfiLanguageCodeValue = ED.CodeValue

	End

	IF UPDATE(EdfiBirthCountryCodeValue)
	BEGIN

		Update StudentMiscFields 
		Set Birthcounty = isnull(ED.ShortDescription,'')
		From 
		StudentMiscFields SM
			inner join
		Inserted I 
			on SM.StudentID = I.StudentID
			left join
		(
			Select 
			CodeValue,
			ShortDescription 
			From lkg.dbo.edfiDescriptorsAndTypes
			Where
			Name = 'CountryDescriptor'
		) ED
			on I.EdfiBirthCountryCodeValue = ED.CodeValue
	End
  End
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[tStudentMiscFields_FACTS]
 on [dbo].[StudentMiscFields]
 After Update, Insert
As
BEGIN
	IF (UPDATE(FACTS_CustomerID) or UPDATE(FACTS_Username)
		or UPDATE(FACTS_CustomerID2) or UPDATE(FACTS_Username2))
	BEGIN
		with EditedRows as (
			select s.FamilyID, 
				i.FACTS_CustomerID, 
				i.FACTS_Username
			from inserted i
			left join deleted d
			on i.StudentID = d.StudentID
			inner join Students s
			on i.StudentID = s.StudentID
			union
			select s.Family2ID FamilyID, 
				i.FACTS_CustomerID2 FACTS_CustomerID, 
				i.FACTS_Username2 FACTS_Username
			from inserted i
			left join deleted d
			on i.StudentID = d.StudentID
			inner join Students s
			on i.StudentID = s.StudentID
			where s.Family2ID is not null
		)
		merge FACTSCustomers with (serializable)
		using EditedRows er
		on er.FamilyID = FACTSCustomers.FamilyID 
		when matched and (er.FACTS_CustomerID is null 
					and er.FACTS_Username is null) then
			delete
		when matched then				
			update set
				CustomerID = er.FACTS_CustomerID, 
				Username = er.FACTS_Username
		when not matched 
				and (er.FACTS_CustomerID is not null 
					or er.FACTS_Username is not null) then
			insert (FamilyID, CustomerID, Username)
			values (er.FamilyID, er.FACTS_CustomerID, er.FACTS_Username);

		IF UPDATE(FACTS_CustomerID) or UPDATE(FACTS_Username)
		BEGIN
			--
			-- Replicate FACTS fields on primary family ID since these
			-- may be shared with multiple students.  No need to do this
			-- for Family ID 2 since these are not shared...
			--
			with EditedRows as (
				select s.FamilyID, s.StudentID, i.FACTS_CustomerID, i.FACTS_Username
				from inserted i
				left join deleted d
				on i.StudentID = d.StudentID
				inner join Students s
				on i.StudentID = s.StudentID
			)
			update smf with (serializable)
				set FACTS_CustomerID = er.FACTS_CustomerID, 
					FACTS_Username = er.FACTS_Username
			from StudentMiscFields smf
			inner join EditedRows er 
			on 
				smf.StudentID in (select StudentID from Students where FamilyID = er.FamilyID) 
				and smf.StudentID <> er.StudentID
		END
	END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[tStudentMiscFields_GovId]
 on [dbo].[StudentMiscFields]
 After Update, Insert
As
BEGIN
	IF (UPDATE(GOVid_plaintext))
	BEGIN
		if (select EncryptByKey (Key_GUID('SymmetricKey1'),'test')) is null
		begin
			if isnull((select distinct 1 from inserted where isnull(GOVid_plaintext,'')<>''),0)=1
			begin
				RAISERROR ('You do not have permission to update the Government ID field.',15,1);
				rollback;
				return;
			end
		end
		else
		begin
			update StudentMiscFields
				set GOVid_encrypted = case when isnull(GOVid_plaintext,'')='' 
					then null else EncryptByKey (Key_GUID('SymmetricKey1'),GOVid_plaintext) end
				where StudentID in (select StudentID from inserted union select StudentID from deleted)
				and isnull(GOVid_plaintext,'')<>'**encrypted**' -- prevent recursion 
		end
		-- hide actual Gov IDs after storing
		update StudentMiscFields
			set GOVid_plaintext = '**encrypted**' -- informative and prevents recursion
			where StudentID in (select StudentID from inserted union select StudentID from deleted)
			and GOVid_encrypted is not null
	END
END

GO
ALTER TABLE [dbo].[StudentMiscFields] ADD CONSTRAINT [PK_StudentMiscFields] PRIMARY KEY CLUSTERED ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[StudentMiscFields] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentMiscFields] WITH NOCHECK ADD CONSTRAINT [FK_StudentMiscFields_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
