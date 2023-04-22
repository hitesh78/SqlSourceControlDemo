CREATE TABLE [dbo].[StudentContacts]
(
[ContactID] [int] NOT NULL IDENTITY(1, 1),
[xContactID] [int] NOT NULL CONSTRAINT [DF_StudentContacts_xContactID] DEFAULT ((0)),
[StudentID] [int] NOT NULL,
[Title] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RolesAndPermissions] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Relationship] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone1Num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone1Desc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2Num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2Desc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone3Num] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone3Desc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email1Desc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2Desc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email3Desc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Occupation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Employer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone1OptIn] [bit] NULL,
[Phone2OptIn] [bit] NULL,
[Phone3OptIn] [bit] NULL,
[StateProvince] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryRegion] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nickname] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullName] AS (case isnull(session_context(N'AdminLanguage'),'English') when 'Chinese' then ([Lname]+[Fname])+case  when len(ltrim(rtrim([NickName])))>(0) then (' ('+[NickName])+')' else '' end else (case  when isnull([Lname],'')>'' AND isnull([Fname],'')>'' then ([Lname]+', ')+[Fname] else isnull([Lname],'')+isnull([Fname],'') end+case  when len(ltrim(rtrim([Mname])))>(0) then (' '+left([Mname],(1)))+'.' else '' end)+case  when len(ltrim(rtrim([NickName])))>(0) then (' ('+[NickName])+')' else '' end end)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[Contacts_UpdatePhoneNumbers]
 on [dbo].[StudentContacts]
 After Insert,Update
as
begin
	-- Replicate Contact Phone # fields to PhoneNumbers table
	--
	-- Regarding the use of the serializable hint with merge,
	-- see http://michaeljswart.com/2011/09/mythbusting-concurrent-updateinsert-solutions/

	--
	-- The following are pairs of scenarios for updating contacts phone 
	-- fields 1-3 to the new PhoneNumbers table.  Each 1-3 set of fields
	-- has a scenario when a description (e.g. like an extension for instance)
	-- is updated that writes that field to the phone numbers extension field.
	-- But if the description field is not specified, we do not want to 
	-- update the extension field because the PhoneNumbers table
	-- trigger "PhoneNumbers_format_sis_phones" will look for are parse out
	-- extra annotative characters that are not part of the phone number in an
	-- effort to compute and set the exension field in the PhoneNumbers table....
	--


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
					ON i.ContactID = d.ContactID
				WHERE NOT EXISTS( 
									SELECT 
										i.ContactID,
										i.Phone1Desc,
										i.phone1num,
										i.Phone2Desc,
										i.phone2num,
										i.Phone3Desc,
										i.phone3num

									INTERSECT 
									
									SELECT 
										d.ContactID,
										d.Phone1Desc,
										d.phone1num,
										d.Phone2Desc,
										d.phone2num,
										d.Phone3Desc,
										d.phone3num
								)

				Union 

				-- add new inserted records
				Select i.*
				From 
				inserted i
				Where
				i.ContactID not in (select ContactID from deleted)
			)
	Begin

		if update(Phone1Desc)
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Contacts
			on	Contacts.ContactID = PhoneNumbers.ContactID
				and 
				'Phone 1' = PhoneNumbers.Type
			when matched and Contacts.Phone1Desc != (Select Phone1Desc From deleted where ContactID = Contacts.ContactID) then
				update set 
					Phone = dbo.parsePhoneE164(Contacts.Phone1Num,'phone'),
					Extension = dbo.parsePhoneE164(Contacts.Phone1Num,'extension'),
					PhoneNumberValid =		-- only set to null if number changed
										case
											when Contacts.Phone1Num != (Select Phone1Num From deleted where ContactID = Contacts.ContactID) then null
											else PhoneNumberValid
										end,
					VerifiedOn =		-- only set to null if number changed
										case
											when Contacts.Phone1Num != (Select Phone1Num From deleted where ContactID = Contacts.ContactID) then null
											else PhoneNumberValid
										end
			when not matched and dbo.parsePhoneE164(Contacts.Phone1Num,'phone') is not null then
				insert (ContactID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Contacts.ContactID,
							'Phone 1',
							dbo.parsePhoneE164(Contacts.Phone1Num,'phone'),
							dbo.parsePhoneE164(Contacts.Phone1Num,'extension'),
							null,
							null
						);
		end
		else if update(phone1num) 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Contacts
			on	Contacts.ContactID = PhoneNumbers.ContactID
				and 
				'Phone 1' = PhoneNumbers.Type
			when matched and Contacts.phone1num != (Select phone1num From deleted where ContactID = Contacts.ContactID) then
				update set 
					Phone = dbo.parsePhoneE164(Contacts.Phone1Num,'phone'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Contacts.Phone1Num,'phone') is not null then
				insert (ContactID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Contacts.ContactID,
							'Phone 1',
							dbo.parsePhoneE164(Contacts.Phone1Num,'phone'),
							dbo.parsePhoneE164(Contacts.Phone1Num,'extension'),
							null,
							null
						);
		end

		if update(Phone2Desc)
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Contacts
			on	Contacts.ContactID = PhoneNumbers.ContactID
				and 
				'Phone 2' = PhoneNumbers.Type
			when matched and Contacts.Phone2Desc != (Select Phone2Desc From deleted where ContactID = Contacts.ContactID) then
				update set 
					Phone = dbo.parsePhoneE164(Contacts.Phone2Num,'phone'),
					Extension = dbo.parsePhoneE164(Contacts.Phone2Num,'extension'),
					PhoneNumberValid =		-- only set to null if number changed
										case
											when Contacts.Phone2Num != (Select Phone2Num From deleted where ContactID = Contacts.ContactID) then null
											else PhoneNumberValid
										end,
					VerifiedOn =		-- only set to null if number changed
										case
											when Contacts.Phone2Num != (Select Phone2Num From deleted where ContactID = Contacts.ContactID) then null
											else PhoneNumberValid
										end
			when not matched and dbo.parsePhoneE164(Contacts.Phone2Num,'phone') is not null then
				insert (ContactID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Contacts.ContactID,
							'Phone 2',
							dbo.parsePhoneE164(Contacts.Phone2Num,'phone'),
							dbo.parsePhoneE164(Contacts.Phone2Num,'extension'),
							null,
							null
						);
		end
		else if update(phone2num) 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Contacts
			on	Contacts.ContactID = PhoneNumbers.ContactID
				and 
				'Phone 2' = PhoneNumbers.Type
			when matched and Contacts.phone2num != (Select phone2num From deleted where ContactID = Contacts.ContactID) then
				update set 
					Phone = dbo.parsePhoneE164(Contacts.Phone2Num,'phone'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Contacts.Phone2Num,'phone') is not null then
				insert (ContactID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Contacts.ContactID,
							'Phone 2',
							dbo.parsePhoneE164(Contacts.Phone2Num,'phone'),
							dbo.parsePhoneE164(Contacts.Phone2Num,'extension'),
							null,
							null
						);
		end

		if update(Phone3Desc)
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Contacts
			on	Contacts.ContactID = PhoneNumbers.ContactID
				and 
				'Phone 3' = PhoneNumbers.Type
			when matched and Contacts.Phone3Desc != (Select Phone3Desc From deleted where ContactID = Contacts.ContactID) then
				update set 
					Phone = dbo.parsePhoneE164(Contacts.Phone3Num,'phone'),
					Extension = dbo.parsePhoneE164(Contacts.Phone3Num,'extension'),
					PhoneNumberValid =		-- only set to null if number changed
										case
											when Contacts.Phone3Num != (Select Phone3Num From deleted where ContactID = Contacts.ContactID) then null
											else PhoneNumberValid
										end,
					VerifiedOn =		-- only set to null if number changed
										case
											when Contacts.Phone3Num != (Select Phone3Num From deleted where ContactID = Contacts.ContactID) then null
											else PhoneNumberValid
										end
			when not matched and dbo.parsePhoneE164(Contacts.Phone3Num,'phone') is not null then
				insert (ContactID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Contacts.ContactID,
							'Phone 3',
							dbo.parsePhoneE164(Contacts.Phone3Num,'phone'),
							dbo.parsePhoneE164(Contacts.Phone3Num,'extension'),
							null,
							null
						);
		end
		else if update(phone3num) 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Contacts
			on	Contacts.ContactID = PhoneNumbers.ContactID
				and 
				'Phone 3' = PhoneNumbers.Type
			when matched and Contacts.phone3num != (Select phone3num From deleted where ContactID = Contacts.ContactID) then
				update set 
					Phone = dbo.parsePhoneE164(Contacts.Phone3Num,'phone'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Contacts.Phone3Num,'phone') is not null then
				insert (ContactID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Contacts.ContactID,
							'Phone 3',
							dbo.parsePhoneE164(Contacts.Phone3Num,'phone'),
							dbo.parsePhoneE164(Contacts.Phone3Num,'extension'),
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
					Select dbo.parsePhoneE164(Phone1Num,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone2Num,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone3Num,'phone') from inserted
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
					Select dbo.parsePhoneE164(Phone1Num,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone2Num,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone3Num,'phone') from inserted
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
					Select dbo.parsePhoneE164(Phone1Num,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone2Num,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone3Num,'phone') from inserted
				);

	exec UpdatePhoneNumberExtensionColumn;


	End		-- if new or changed records exists

end

GO
ALTER TABLE [dbo].[StudentContacts] ADD CONSTRAINT [PK_Contacts2] PRIMARY KEY CLUSTERED ([ContactID]) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[StudentContacts] ([StudentID]) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentContacts] ADD CONSTRAINT [FK_StudentContacts_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
