CREATE TABLE [dbo].[Students]
(
[StudentID] [int] NOT NULL,
[xStudentID] [bigint] NOT NULL,
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_Students_Active] DEFAULT ((1)),
[Lname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Mname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fname] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GradeLevel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Father] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mother] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email1] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email2] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email3] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email4] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email5] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email6] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email7] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email8] [nvarchar] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthDate] [smalldatetime] NULL,
[Sex] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ethnicity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressDescription] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressDescription2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressName2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EntryDate] [smalldatetime] NULL,
[WithdrawalDate] [smalldatetime] NULL,
[GraduationDate] [smalldatetime] NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LockerNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LockerCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Students_Status] DEFAULT ('Active'),
[Affiliations] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Class] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Students_Class] DEFAULT (''),
[FamilyID] [int] NULL,
[CoachEmailAlertSent] [bit] NOT NULL CONSTRAINT [DF_Students_CoachEmailAlertSent] DEFAULT ((0)),
[IneligibleStudent] [bit] NOT NULL CONSTRAINT [DF_Students_IneligibleStudent] DEFAULT ((0)),
[Comments2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comments3] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldSystem_StudentID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isHispanicLatino] [bit] NULL,
[isCatholic] [bit] NULL,
[isTitle1Eligible] [bit] NULL,
[isTitle1Receiving] [bit] NULL,
[isNSLPBreakfast] [bit] NULL,
[isNSLPLunch] [bit] NULL,
[isSubsidizedTrans] [bit] NULL,
[isPromoteToCatholicHS] [bit] NULL,
[isSpecialEdReceiving] [bit] NULL,
[Family2ID] [int] NULL,
[Family2Name1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Family2Name2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Family2Phone1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Family2Phone2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentLivesWithFather] [bit] NULL,
[StudentLivesWithMother] [bit] NULL,
[StudentLivesWithStepfather] [bit] NULL,
[StudentLivesWithStepmother] [bit] NULL,
[StudentLivesWithGuardian1] [bit] NULL,
[StudentLivesWithGuardian2] [bit] NULL,
[StudentLivesWithOther] [bit] NULL,
[StudentLivesWithDesc] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Divorced] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Custody] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Major] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Degree] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WISEid] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldStudentID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone1OptIn] [bit] NULL CONSTRAINT [DF_Students_Phone1OptIn] DEFAULT ((1)),
[Phone2OptIn] [bit] NULL,
[Phone3OptIn] [bit] NULL,
[Family2Phone1OptIn] [bit] NULL,
[Family2Phone2OptIn] [bit] NULL,
[CountryRegion] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateProvince] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryRegion2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateProvince2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nickname] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glname] AS (case isnull(session_context(N'AdminLanguage'),'English') when 'Chinese' then [Lname]+[Fname] else ((([Lname]+', ')+[Fname])+case  when len(ltrim(rtrim([Mname])))>(0) then (' '+left([Mname],(1)))+'.' else '' end)+case  when len(ltrim(rtrim([Suffix])))>(0) then ', '+[Suffix] else '' end end+case  when len(ltrim(rtrim([NickName])))>(0) then (' ('+[NickName])+')' else '' end),
[isDiagnosedDisability] [bit] NULL,
[SchoolEmail] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateAbbr] AS ([dbo].[getStateAbbr]([State])),
[State2Abbr] AS ([dbo].[getStateAbbr]([State2])),
[WithdrawReason] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountyName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountyName2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isInternational] [bit] NULL,
[isChoiceProgram] [bit] NULL,
[isLunchEligible] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[Student_UpdateParentContacts]
 on [dbo].[Students]
 After /*Insert, SEE NOTE!*/ Update 
 -- 3/9/17 - Trigger fails if Insert is included; not sure why.
 -- This works for the use case of manually adding a student throught the Admin UI.
 -- I'm not sure if it also works when importing student records.  But if it does not
 -- we could kick off a reconversion by turning Comm2 off and back on again.
 --
 --
 -- 8/21/17 - Not sure why but tabs (char(9)) were causing replication of parents
 -- names to contacts to fail so I clean these out now...
 --
As
begin
	-- Replicate Student Phone # fields to PhoneNumbers table
	--
	-- Regarding the use of the serializable hint with merge,
	-- see http://michaeljswart.com/2011/09/mythbusting-concurrent-updateinsert-solutions/

	declare 
		@AdultSchool bit, 
		@Comm2 bit
	select 
		@AdultSchool=AdultSchool, 
		@Comm2=Comm2
		from Settings

	if -- @Comm2=1 and  -- Wrike 143843013 - We will maintain SIS parents in the StudentContacts and PhoneNumbers tables for all schools now
			@AdultSchool=0
	begin

		if update(phone1) or update(phone2)
			or update(Family2Phone1) or update(Family2Phone2)
			or update(mother) or update(father) or update(email1) or update(email2)  -- Wrike 143843013
			or update(Family2Name1) or update(Family2Name2) or update(email6) or update(email7) -- Wrike 143843013
		begin
			with parseParentPhones as (
				select 
					studentid, 
					ltrim(rtrim(REPLACE(lname,CHAR(9),''))) as StudentLastName,
					ltrim(rtrim(REPLACE(father,CHAR(9),''))) as name,
					email1 as email,
					phone1 origPhone,
					dbo.splitSISphonesALL(phone1) phones,
					'Father' as relationship,
					'(SIS Parent Contact)' as RolesAndPermissions
				from inserted --where update(phone1)
				union
				select 
					studentid, 
					ltrim(rtrim(REPLACE(lname,CHAR(9),''))) as StudentLastName,
					ltrim(rtrim(REPLACE(mother,CHAR(9),''))) as name,
					email2 as email,
					phone2 origPhone,
					dbo.splitSISphonesALL(phone2) phones,
					'Mother' as relationship,
					'(SIS Parent Contact)' as RolesAndPermissions
				from inserted --where update(phone2)
				union
				select 
					studentid, 
					ltrim(rtrim(REPLACE(lname,CHAR(9),''))) as StudentLastName,
					ltrim(rtrim(REPLACE(Family2Name1,CHAR(9),''))) as name,
					email6 as email,
					Family2Phone1 origPhone,
					dbo.splitSISphonesALL(Family2Phone1) phones,
					'Father 2' as relationship,
					'(SIS Parent Contact)' as RolesAndPermissions
				from inserted --where update(Family2Phone1)
				union
				select 
					studentid, 
					ltrim(rtrim(REPLACE(lname,CHAR(9),''))) as StudentLastName,
					ltrim(rtrim(REPLACE(Family2Name2,CHAR(9),''))) as name,
					email7 as email,
					Family2Phone2 origPhone,
					dbo.splitSISphonesALL(Family2Phone2) phones,
					'Mother 2' as relationship,
					'(SIS Parent Contact)' as RolesAndPermissions
				from inserted --where update(Family2Phone2)
			),
			demarkPhone1 as (
				select *,
					CHARINDEX('~',phones) pos1,
					CHARINDEX(',',name) as namePos1A, 
					CHARINDEX(' ',name) as namePos1B 
				from parseParentPhones
			),
			demarkPhones as (
				select *,
					CHARINDEX('~',phones,pos1+1) pos2, datalength(phones)/2 pos3,
					CHARINDEX(',',name,namePos1A+1) as namePos2A, datalength(name)/2 namePos3A, 
					CHARINDEX(' ',name,namePos1B+1) as namePos2B, datalength(name)/2 namePos3B 
				from demarkPhone1
			),
			Students as (
				select 
					StudentID,

					ltrim(rtrim(
					case when namePos1A>0 
					then
						-- comma delimiterd assumes LNAME, FNAME
						isnull(
							case 
								when namePos2A>0 then substring(name,namePos2A+1,namePos3A-namePos2A)
								else 
									case 
										when namePos1A>0 then substring(name,namePos1A+1,namePos3A-namePos1A) 
										else '' 
									end 
							end
						, '') 
					else
						-- space delimited assumes FNAME LNAME
						isnull(
							case 
								when PATINDEX('%' + StudentLastName + '%', name) > 0 then replace(name, StudentLastName, '')
								when namePos2B>0 then substring(name,1,namePos2B-1)
								else 
									case 
										when namePos1B>0 then substring(name,1,namePos1B-1) 
										else name 
									end 
								end
						,'')
					end))
						as fname,
					
					ltrim(rtrim(
					case when namePos1A>0 
					then
						-- comma delimiterd assumes LNAME, FNAME
						isnull(
							case 
								when namePos2A>0 then substring(name,1,namePos2A-1)
								else 
									case 
										when namePos1A>0 then substring(name,1,namePos1A-1) 
										else name 
									end 
							end
						,'')
					else
						-- space delimited assumes FNAME LNAME
						isnull(
							case 
								when PATINDEX('%' + StudentLastName + '%', name) > 0 then StudentLastName
								when namePos2B>0 then substring(name,namePos2B+1,namePos3B-namePos2B)
								else 
									case 
										when namePos1B>0 then substring(name,namePos1B+1,namePos3B-namePos1B) 
										else '' 
									end 
							end
						, '') 
					end))
						as lname,
					
					left(phones,pos1-1) phone1,
					substring(phones,pos1+1,pos2-pos1-1) phone2,
					right(phones,pos3-pos2) phone3,
					isnull(email,'') email,
					relationship,
					RolesAndPermissions
				from demarkPhones
				-- where isnull(origPhone,'')>''  -- Wrike 143843013 - commented out!
			)
			merge StudentContacts with (serializable)
			using Students s
			on s.StudentID = StudentContacts.StudentID
				and s.relationship = StudentContacts.relationship
				and s.RolesAndPermissions = StudentContacts.RolesAndPermissions
			when matched 
					and rtrim(s.fname+s.lname+s.email+s.phone1+s.phone2+s.phone3)='' then
				delete
			when matched then
				update set
					phone1num = left(s.phone1,50), 
					phone2num = left(s.phone2,50), 
					phone3num = left(s.phone3,50),
					email1 = s.email, 
					relationship = s.relationship,
					lname = s.lname, 
					fname = s.fname,
					RolesAndPermissions = s.RolesAndPermissions
			when not matched and rtrim(s.fname+s.lname+s.email+s.phone1+s.phone2+s.phone3)>'' then
				insert (
					StudentID,fname,lname,relationship,email1,
					phone1num,phone2num,phone3num,
					RolesAndPermissions)
				values (
					s.StudentID,
					s.fname,
					s.lname,
					s.relationship, 
					s.email,
					left(s.phone1,50), 
					left(s.phone2,50), 
					left(s.phone3,50),
					s.RolesAndPermissions
				);
		end

	end

end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[Student_UpdatePhoneNumbers]
 on [dbo].[Students]
 After Update
As
begin
	-- Replicate Student Phone # fields to PhoneNumbers table
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
					ON i.StudentID= d.StudentID
				WHERE NOT EXISTS( 
									SELECT 
										i.StudentID,
										i.phone1,
										i.phone2,
										i.phone3

									INTERSECT 
									
									SELECT 
										d.StudentID,
										d.phone1,
										d.phone2,
										d.phone3
								)

				Union 

				-- add new inserted records
				Select i.*
				From 
				inserted i
				Where
				i.StudentID not in (select StudentID from deleted)
			)
	Begin


		declare @AdultSchool bit = (select adultschool from settings)

		if update(phone3) 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Students
			on Students.StudentID = PhoneNumbers.StudentID	
				and case when @AdultSchool=0 then 'Phone' else 'Phone 3' end = PhoneNumbers.Type
			when matched and Students.phone3 != (Select phone3 From deleted where StudentID = Students.StudentID) then
				update set
					Phone = dbo.parsePhoneE164(Students.Phone3,'phone'),
					Extension = dbo.parsePhoneE164(Students.Phone3,'extension'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Students.phone3,'phone') is not null then
				insert (StudentID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Students.StudentID,
							case when @AdultSchool=0 then 'Phone' else 'Phone 3' end,
							dbo.parsePhoneE164(Students.Phone3,'phone'),
							dbo.parsePhoneE164(Students.Phone3,'extension'),
							null,
							null
						);
		end

		if update(phone1) and @AdultSchool=1 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Students
			on Students.StudentID = PhoneNumbers.StudentID
				and 'Phone 1' = PhoneNumbers.Type
			when matched and Students.phone1 != (Select phone1 From deleted where StudentID = Students.StudentID) then
				update set 
					Phone = dbo.parsePhoneE164(Students.Phone1,'phone'),
					Extension = dbo.parsePhoneE164(Students.Phone1,'extension'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Students.phone1,'phone') is not null then
				insert (StudentID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Students.StudentID, 
							'Phone 1', 
							dbo.parsePhoneE164(Students.Phone1,'phone'),
							dbo.parsePhoneE164(Students.Phone1,'extension'),
							null,
							null
						);
		end

		if update(phone2) and @AdultSchool=1 
		begin
			merge PhoneNumbers with (serializable)
			using inserted as Students
			on Students.StudentID = PhoneNumbers.StudentID
				and 'Phone 2' = PhoneNumbers.Type
			when matched and Students.phone2 != (Select phone2 From deleted where StudentID = Students.StudentID) then
				update set 
					Phone = dbo.parsePhoneE164(Students.Phone2,'phone'),
					Extension = dbo.parsePhoneE164(Students.Phone2,'extension'),
					PhoneNumberValid = null,
					VerifiedOn = null
			when not matched and dbo.parsePhoneE164(Students.phone2,'phone') is not null then
				insert (StudentID,Type,Phone,Extension,PhoneNumberValid,VerifiedOn)
				values (
							Students.StudentID, 
							'Phone 2', 
							dbo.parsePhoneE164(Students.Phone2,'phone'),
							dbo.parsePhoneE164(Students.Phone2,'extension'),
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
					Select dbo.parsePhoneE164(Phone1,'phone') from inserted union 
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
					Select dbo.parsePhoneE164(Phone1,'phone') from inserted union 
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
					Select dbo.parsePhoneE164(Phone1,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone2,'phone') from inserted union 
					Select dbo.parsePhoneE164(Phone3,'phone') from inserted
				);

	
	exec UpdatePhoneNumberExtensionColumn;

	End		-- if new or changed records exists

end


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateAccountsAfterStudentDelete]
 on [dbo].[Students]
 After Delete
As
	Delete from CalendarSelection
		Where AccountID in (Select AccountID From Deleted)
 
	Delete from Accounts
		Where AccountID in (Select AccountID From Deleted)
 
	Delete From Families
		Where
		FamilyID not in 
		(
			Select FamilyID From Students Where FamilyID is not null
			Union
			Select Family2ID From Students Where Family2ID is not null
		)

	Delete from Accounts
		where Access like 'Family%'
			and  AccountID not in (select AccountID from Families);

	-- The below code fixes a problem where a payment was assigned to a wron g student 
	-- when you delete a student and then a new student is added
	-- and the new student get the StudentID of the old student becuase it gets the new ID using max(StudentID)
	-- Becuase the payment was already assigned to the new studentID and it is not updated when you delete it
	-- The SQL code below will update the payment with the EnrollmentStudent StudentID column which was the original value
	-- in PSPayments before the student was imported.  Once the student is re-imported it will get the correct ID
	Update PSPayments
	set GLXrefID = ES.StudentID
	From
	PSPayments P
		inner join
	deleted d
		on P.GLXrefID = d.StudentID
		inner join
	EnrollStudentStatusDates ED
		on ED.ImportStudentID = d.StudentID
		inner join
	EnrollmentStudent ES
		on ED.EnrollmentStudentID = ES.EnrollmentStudentID;

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateFamiliesOnAddStudent]  
on [dbo].[Students]
INSTEAD OF INSERT
AS
BEGIN

-- 1. Put inserted records into a #tempInserted becuase you can't make changes 
-- to the Inserted table, this also allows us to avoid specifying columns
-- which will change over time
Select *
into #tempInserted
From Inserted
Where 
FamilyID is null
and 
Lname not like '-%' -- wrl


-- Creat table used to iterate all rows in #tempInserted via while loop
declare @temp table
(
ID int identity(1,1),
StudentID int
)
Insert into @temp 
Select StudentID From #tempInserted

Declare @NumLines int = @@RowCount
Declare @LineNumber int = 1
Declare @FamilyInfo FamilyTableType
Declare @FamilyID int


While @LineNumber <= @NumLines
Begin

	Update #tempInserted
	Set FamilyID = dbo.getFamilyID(I.Lname, I.Father, I.Mother, I.Street, I.Email1, I.Phone1)--,
	From 
	#tempInserted I
		inner join
	@temp t 
		on t.StudentID = I.StudentID
	Where
	t.ID = @LineNumber


	insert into @FamilyInfo
	Select
	Lname,
	Father,
	Mother,
	FamilyID
	From 
	#tempInserted I
		inner join
	@temp t 
		on t.StudentID = I.StudentID
	Where
	t.ID = @LineNumber
	
	Set @FamilyID = (Select FamilyID From @FamilyInfo)
	
	if not exists (Select FamilyID From Families Where FamilyID = @FamilyID)
	Begin
		EXEC PopulateAccountsAndFamilies @FamilyInfo
	End

	Insert into Students
	(StudentID,xStudentID,AccountID,Active,Lname,Mname,Fname,GradeLevel,Father,Mother,Phone1,Phone2,Phone3,Email1,Email2,Email3,Email4,Email5,Email6,Email7,Email8,BirthDate,Sex,Ethnicity,AddressDescription,AddressName,Street,City,State,Zip,AddressDescription2,AddressName2,Street2,City2,State2,Zip2,EntryDate,WithdrawalDate,GraduationDate,Comments,LockerNumber,LockerCode,Status,Affiliations,Class,FamilyID,CoachEmailAlertSent,IneligibleStudent,Comments2,Comments3,OldSystem_StudentID,isHispanicLatino,isCatholic,isTitle1Eligible,isTitle1Receiving,isNSLPBreakfast,isNSLPLunch,isSubsidizedTrans,isPromoteToCatholicHS,isSpecialEdReceiving,Family2ID,Family2Name1,Family2Name2,Family2Phone1,Family2Phone2,StudentLivesWithFather,StudentLivesWithMother,StudentLivesWithStepfather,StudentLivesWithStepmother,StudentLivesWithGuardian1,StudentLivesWithGuardian2,StudentLivesWithOther,StudentLivesWithDesc,Divorced,Custody,Major,Degree,WISEid,Suffix,OldStudentID,Phone1OptIn,Phone2OptIn,Phone3OptIn,Family2Phone1OptIn,Family2Phone2OptIn,CountryRegion,StateProvince,CountryRegion2,StateProvince2,Nickname,isDiagnosedDisability,SchoolEmail)
	Select I.StudentID,I.xStudentID,replace(I.AccountID, char(146), char(39)),I.Active,I.Lname,I.Mname,I.Fname,I.GradeLevel,I.Father,I.Mother,I.Phone1,I.Phone2,I.Phone3,I.Email1,I.Email2,I.Email3,I.Email4,I.Email5,I.Email6,I.Email7,I.Email8,I.BirthDate,I.Sex,I.Ethnicity,I.AddressDescription,I.AddressName,I.Street,I.City,I.State,I.Zip,I.AddressDescription2,I.AddressName2,I.Street2,I.City2,I.State2,I.Zip2,I.EntryDate,I.WithdrawalDate,I.GraduationDate,I.Comments,I.LockerNumber,I.LockerCode,I.Status,I.Affiliations,I.Class,I.FamilyID,I.CoachEmailAlertSent,I.IneligibleStudent,I.Comments2,I.Comments3,I.OldSystem_StudentID,I.isHispanicLatino,I.isCatholic,I.isTitle1Eligible,I.isTitle1Receiving,I.isNSLPBreakfast,I.isNSLPLunch,I.isSubsidizedTrans,I.isPromoteToCatholicHS,I.isSpecialEdReceiving,I.Family2ID,I.Family2Name1,I.Family2Name2,I.Family2Phone1,I.Family2Phone2,I.StudentLivesWithFather,I.StudentLivesWithMother,I.StudentLivesWithStepfather,I.StudentLivesWithStepmother,I.StudentLivesWithGuardian1,I.StudentLivesWithGuardian2,I.StudentLivesWithOther,I.StudentLivesWithDesc,I.Divorced,I.Custody,I.Major,I.Degree,I.WISEid,I.Suffix,I.OldStudentID,
	 I.Phone1OptIn,I.Phone2OptIn,I.Phone3OptIn,I.Family2Phone1OptIn,I.Family2Phone2OptIn,I.CountryRegion,I.StateProvince,I.CountryRegion2,I.StateProvince2,I.Nickname,I.isDiagnosedDisability, I.SchoolEmail
	From 
	#tempInserted I
		inner join
	@temp t 
		on t.StudentID = I.StudentID
	Where
	t.ID = @LineNumber
	
	Delete From @FamilyInfo
	
	Set @LineNumber = @LineNumber + 1

End

Insert into Students
(StudentID,xStudentID,AccountID,Active,Lname,Mname,Fname,GradeLevel,Father,Mother,Phone1,Phone2,Phone3,Email1,Email2,Email3,Email4,Email5,Email6,Email7,Email8,BirthDate,Sex,Ethnicity,AddressDescription,AddressName,Street,City,State,Zip,AddressDescription2,AddressName2,Street2,City2,State2,Zip2,EntryDate,WithdrawalDate,GraduationDate,Comments,LockerNumber,LockerCode,Status,Affiliations,Class,FamilyID,CoachEmailAlertSent,IneligibleStudent,Comments2,Comments3,OldSystem_StudentID,isHispanicLatino,isCatholic,isTitle1Eligible,isTitle1Receiving,isNSLPBreakfast,isNSLPLunch,isSubsidizedTrans,isPromoteToCatholicHS,isSpecialEdReceiving,Family2ID,Family2Name1,Family2Name2,Family2Phone1,Family2Phone2,StudentLivesWithFather,StudentLivesWithMother,StudentLivesWithStepfather,StudentLivesWithStepmother,StudentLivesWithGuardian1,StudentLivesWithGuardian2,StudentLivesWithOther,StudentLivesWithDesc,Divorced,Custody,Major,Degree,WISEid,Suffix,OldStudentID,Phone1OptIn,Phone2OptIn,Phone3OptIn,Family2Phone1OptIn,Family2Phone2OptIn,CountryRegion,StateProvince,CountryRegion2,StateProvince2,Nickname,isDiagnosedDisability,SchoolEmail)
Select StudentID,xStudentID,replace(AccountID, char(146), char(39)),Active,Lname,Mname,Fname,GradeLevel,Father,Mother,Phone1,Phone2,Phone3,Email1,Email2,Email3,Email4,Email5,Email6,Email7,Email8,BirthDate,Sex,Ethnicity,AddressDescription,AddressName,Street,City,State,Zip,AddressDescription2,AddressName2,Street2,City2,State2,Zip2,EntryDate,WithdrawalDate,GraduationDate,Comments,LockerNumber,LockerCode,Status,Affiliations,Class,FamilyID,CoachEmailAlertSent,IneligibleStudent,Comments2,Comments3,OldSystem_StudentID,isHispanicLatino,isCatholic,isTitle1Eligible,isTitle1Receiving,isNSLPBreakfast,isNSLPLunch,isSubsidizedTrans,isPromoteToCatholicHS,isSpecialEdReceiving,Family2ID,Family2Name1,Family2Name2,Family2Phone1,Family2Phone2,StudentLivesWithFather,StudentLivesWithMother,StudentLivesWithStepfather,StudentLivesWithStepmother,StudentLivesWithGuardian1,StudentLivesWithGuardian2,StudentLivesWithOther,StudentLivesWithDesc,Divorced,Custody,Major,Degree,WISEid,Suffix,OldStudentID,
	Phone1OptIn, Phone2OptIn, Phone3OptIn, Family2Phone1OptIn, Family2Phone2OptIn,CountryRegion,StateProvince,CountryRegion2,StateProvince2,Nickname,isDiagnosedDisability,SchoolEmail
From Inserted
Where 
FamilyID is null
and 
Lname like '-%' -- wrl


--
-- Make sure update trigger that replicates parents to contacts is called...
--

update students
set 
	mother = mother, 
	father = father, 
	Family2Name1 = Family2Name1,
	Family2Name2 = Family2Name2
where StudentID in (
	select StudentID from #tempInserted
)

drop table #tempInserted

END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Trigger [dbo].[UpdateFamilyAccounts]
 on [dbo].[Students]
 After Update
As
begin

	If	Update(Lname) or 
		Update(Father) or 
		Update(Mother) or 
		Update(FamilyID) or 
		Update(Family2ID) or
		Update(Family2Name1) or
		Update(Family2Name2)
	begin



		--********************Process Family 1 **************************
		-- 1. Populate table variable to be passed to sp PopulateAccountsAndFamilies
		Declare @FamilyInfo FamilyTableType
		insert into @FamilyInfo
			Select distinct
				I.Lname,
				I.Father,
				I.Mother,
				isnull(I.FamilyID, -- 8/15/2014 - wrl - allow specific family IDs to be entered
					dbo.getFamilyID(I.Lname, I.Father, I.Mother, I.Street, I.Email1, I.Phone1))
			From 
			inserted I
				inner join	-- Only insert Updated records not inserted
			deleted D
				on I.StudentID = D.StudentID
			where 
			I.FamilyID is null -- 8/15/2014 - wrl - following allows specific IDs to be entered...
				or I.FamilyID not in (select FamilyID from Families)  
			and
			I.Lname<>'-'

		IF @@rowcount > 0
		begin
			-- 2. Call sp PopulateAccountsAndFamilies 
			EXEC PopulateAccountsAndFamilies @FamilyInfo

			-- 3. Update Students table
			Update S
				Set 
					FamilyID = F.FamilyID
				From 
				Inserted I 
					inner join 
				Deleted D
					on I.StudentID = D.StudentID
					inner join
				Students S
					on I.StudentID = S.StudentID
					inner join
				@FamilyInfo F
					on	I.Lname = F.Lname
						and
						isnull(I.Father,'') = isnull(F.Father,'')
						and
						isnull(I.Mother,'') = isnull(F.Mother,'')
				where 
				I.Lname<>'-' 
				and 
				I.FamilyID is null			
		end
/*
-- DS-479:
-- Now we handle this in a batch job now because we run into 
-- problems when the family contacts sync feature
-- replicates Family2 names to sibling records and
-- this trigger gets called repeatedly for multiple rows.
-- We can exceed trigger/sproc call depth limits, etc...
--
-- The Family 1 ID code continues to work because every new
-- student requires that ID so it is created on every record
-- and we cannot get a backlog of null IDs to updates all at once
-- as we can here because we only created family 2 IDs by
-- default once some family 2 contact information is entered
-- (and potentially replicated to siblings in one set of trigger operations)...
--
		--********************Process Family 2 **************************
		-- 1. Populate table variable to be passed to sp PopulateAccountsAndFamilies
		Delete From @FamilyInfo;

		insert into @FamilyInfo
		Select distinct		-- Add Family2ID if Family2 names are entered.
			I.Lname,
			I.Family2Name1,
			I.Family2Name2,
			isnull(I.Family2ID,
				dbo.getFamily2ID(I.Lname, I.Family2Name1, I.Family2Name2, I.Street2, I.Email6, I.Email7, I.Family2Phone1, I.Family2Phone2))
		From 
		inserted I
			inner join	-- Only insert Updated records not inserted
		deleted D
			on I.StudentID = D.StudentID
		where 
		isnull(I.Family2ID,-1) not in (select FamilyID from Families) 
		and
		(
			ltrim(rtrim(isnull(I.Family2Name1,''))) != '' 
			or
			ltrim(rtrim(isnull(I.Family2Name2,''))) != ''
		)
		and
		I.Lname<>'-'



		IF (Select count(*) From @FamilyInfo) > 0
		begin

			-- 2. Call sp PopulateAccountsAndFamilies 
			EXEC PopulateAccountsAndFamilies @FamilyInfo

			-- 3. Update Students table
			Update S
				Set 
					Family2ID = F.FamilyID
				From 
				Inserted I 
					inner join 
				Deleted D
					on I.StudentID = D.StudentID
					inner join
				Students S
					on I.StudentID = S.StudentID
					inner join
				@FamilyInfo F
					on	I.Lname = F.Lname
						and
						isnull(I.Family2Name1,'') = isnull(F.Father,'')
						and
						isnull(I.Family2Name2,'') = isnull(F.Mother,'')
				where 
				I.Lname<>'-' 
				and 
				I.Family2ID is null			
			
		end
*/

		if UPDATE(FamilyID) or UPDATE(Family2ID)
		BEGIN
			-- Remove Families that are no longer being used...

            -- (GLCOR-220) Move service hours to new account IDs
            --   for any account IDs being deprecated for old Family IDs
            ; with FamilyIDchanges as (
                select 
                    (select AccountID as newAccountID 
                        from Families 
                        where FamilyID = I.FamilyID) as newAccountID,
                    (select AccountID as newAccountID 
                        from Families 
                        where FamilyID = D.FamilyID) as oldAccountID
                from inserted I
                inner join deleted D
                    on I.StudentID = D.StudentID
                    and isnull(I.FamilyID,'')<>isnull(D.FamilyID,'')
                    and D.FamilyID 
                        not in (Select FamilyID From Students Where FamilyID is not null)
                union
                select 
                    (select AccountID as newAccountID 
                        from Families 
                        where FamilyID = I.Family2ID) as newAccountID,
                    (select AccountID as newAccountID 
                        from Families 
                        where FamilyID = D.Family2ID) as oldAccountID
                from inserted I
                inner join deleted D
                    on I.StudentID = D.StudentID
                    and isnull(I.Family2ID,'')<>isnull(D.Family2ID,'')
                    and D.Family2ID 
                        not in (Select Family2ID From Students Where Family2ID is not null)
            )
            update S
                set AccountID = C.newAccountID
            from ServiceHours S
            inner join FamilyIDchanges C
                on S.AccountID = C.oldAccountID

			-- Check FamilyID records
			Delete Families 
			From 
			Families f
				inner join 
			deleted d
				on f.FamilyID = d.FamilyID
			Where 
			f.FamilyID not in (Select FamilyID From Students Where FamilyID is not null)	

			-- Check Family2ID records
			Delete Families 
			From 
			Families f
				inner join 
			deleted d
				on f.FamilyID = d.Family2ID
			Where 
			f.FamilyID not in (Select Family2ID From Students Where Family2ID is not null)

			-- Remove orphaned family accounts (could be made more efficient)
			Delete from accounts
			Where 
			AccountID not in (Select distinct AccountID From Families)
			and 
			(Access='Family' or Access = 'Family2')
			
			-- Remove AccountAlerts records that are no longer valid
			Delete AccountAlerts
			From 
			AccountAlerts AA
				inner join
			ClassesStudents CS
				on AA.CSID = CS.CSID
				inner join
			Accounts A
				on AA.AccountID = A.AccountID
			Where
			CS.StudentID  in (Select StudentID From Deleted)
			and
			A.Access = 'Family'
			and
			AA.AccountID not in
			(
				Select
				F.AccountID 
				From 
				Families F
					inner join
				Students S
					on S.FamilyID = F.FamilyID or S.Family2ID = F.FamilyID
				Where
				S.StudentID = CS.StudentID
			)			

		END

	end

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateFamilyFields]
 on [dbo].[Students]
 After Update
As
begin

-- Allow shut off of this default/sync logic via settings...
IF (select SyncFamilyFields from Settings)=0
BEGIN
	RETURN
END

-- PSEUDO CODE:

--get current INSERT row values -> x....

--find best existing record for defaults -> @...

--if any of 3 sets of x fields are all blanks

--  if all fields are blank
--  else
--    if name,phone,email blank..
--    if address block 1 blank...
--    if address block 2 blank...

--get old (deleted) values -> @

--if there was an old student ID (i.e. changed record)...

--  if name,phone,email is not blank..
--    broadcast mother/father name changes...
--    broadcast phone # changes...
--    broadcast email changes...
--  endif

--  if address block 1 is not blank...
--    broadcast address block 1 changes...
--  endif

--  if address block 2 is not blank...
--    broadcast address block 2 changes...
--  endif


-- SUPPORT CODE:
--drop table messages
--create table messages (
--message nvarchar(2000),
--xAddressDescription nvarchar(50),
--deleteAddr int,
--xStreet nvarchar(50),
--xCity nvarchar(50),
--xState nvarchar(50),
--xZip nvarchar(50),
--xFamilyID int,
--xStudentID int,
--AddressDescription  nvarchar(50),
--Street nvarchar(50),
--City nvarchar(50),
--State nvarchar(50),
--Zip nvarchar(50) )
--delete messages
--select * from messages


	declare @importStudentID int = null;
	declare @father nvarchar(50);
	declare @mother nvarchar(50);
	declare @phone1 nvarchar(50);
	declare @phone2 nvarchar(50);
--	declare @phone3 nvarchar(50); -- stop syncing what is typically used on "student email"
	declare @email1 nvarchar(50);
	declare @email2 nvarchar(50);
--	declare @email3 nvarchar(50); -- stop syncing what is typically used on "student email"
	declare @AddressDescription nvarchar(50);
	declare @Street nvarchar(50);
	declare @City nvarchar(50);
	declare @State nvarchar(50);
	declare @Zip nvarchar(50);
	declare @AddressDescription2 nvarchar(50);
	declare @Street2 nvarchar(50);
	declare @City2 nvarchar(50);
	declare @State2 nvarchar(50);
	declare @Zip2 nvarchar(50);
	declare @xfather nvarchar(50);
	declare @xmother nvarchar(50);
	declare @xphone1 nvarchar(50);
	declare @xphone2 nvarchar(50);
--	declare @xphone3 nvarchar(50);
	declare @xemail1 nvarchar(50);
	declare @xemail2 nvarchar(50);
--	declare @xemail3 nvarchar(50);
	declare @xAddressDescription nvarchar(50);
	declare @xStreet nvarchar(50);
	declare @xCity nvarchar(50);
	declare @xState nvarchar(50);
	declare @xZip nvarchar(50);
	declare @xAddressDescription2 nvarchar(50);
	declare @xStreet2 nvarchar(50);
	declare @xCity2 nvarchar(50);
	declare @xState2 nvarchar(50);
	declare @xZip2 nvarchar(50);
	declare @xFamilyID int = null;
	declare @xStudentID int = null;
	declare @StudentID int = null;
	declare @deleteAddr int;

	-- select values in current row
	select  @xfather = isnull(s.father,''), @xmother = isnull(s.mother,''),
			@xphone1 = isnull(s.phone1,''), @xphone2 = isnull(s.phone2,''), 
--			@xphone3 = isnull(s.phone3,''),
			@xemail1 = isnull(s.email1,''), @xemail2 = isnull(s.email2,''), 
--			@xemail3 = isnull(s.email3,''),
			@xAddressDescription = isnull(s.AddressDescription,''), 
			@xStreet = isnull(s.Street,''), 
			@xCity = isnull(s.City,''), 
			@xState = isnull(s.State,''), 
			@xZip = isnull(s.Zip,''),
			@xAddressDescription2 = isnull(s.AddressDescription2,''), 
			@xStreet2 = isnull(s.Street2,''), 
			@xCity2 = isnull(s.City2,''), 
			@xState2 = isnull(s.State2,''), 
			@xZip2 = isnull(s.Zip2,''),
			@xFamilyID = s.FamilyID, 
			@xStudentID = s.StudentID
	from inserted s

	-- Find the best existing record for defaults
	set @importStudentID = null
	select top 1 @importStudentID = s.StudentID, @father = s.father, @mother = s.mother,
			@phone1 = s.phone1, @phone2 = s.phone2, -- @phone3 = s.phone3,
			@email1 = s.email1, @email2 = s.email2, -- @email3 = s.email3,
			@AddressDescription = s.AddressDescription,
			@Street = s.Street, @City = s.City, @State = s.State, @Zip = s.Zip,
			@AddressDescription2 = s.AddressDescription2,
			@Street2 = s.Street2, @City2 = s.City2, @State2 = s.State2, @Zip2 = s.Zip2
	from Students s
	where s.FamilyID is not null 
		and s.FamilyID = @xFamilyID
		and s.StudentID <> @xStudentID
	order by isnull(father,'')+isnull(phone1,'')+isnull(email1,'')+isnull(street,'') desc, StudentID

	if ( ( @xFamilyID is not null AND @importStudentID is not null ) AND
		 ( @xfather+@xmother+@xphone1+@xphone2 /*+@xphone3*/ +@xemail1+@xemail2 /*+@xemail3*/ = ''
		or @xAddressDescription+@xStreet+@xCity+@xState+@xZip = ''
		or @xAddressDescription2+@xStreet2+@xCity2+@xState2+@xZip2 = '' ) )
	begin

--insert into messages (message) values ('default fields flagged...');

		-- If all family fields are blank, try to default from other sibling records...
		if ( @xfather+@xmother+@xphone1+@xphone2 /*+@xphone3*/ +@xemail1+@xemail2 /*+@xemail3*/ 
				+@xAddressDescription+@xStreet+@xCity+@xState+@xZip 
				+@xAddressDescription2+@xStreet2+@xCity2+@xState2+@xZip2 = '' ) 
		begin
			-- Update fields in current row from another student in same family (if found)
			if (@importStudentID is not null)
			begin

--insert into messages (message) values ('default fields from studentID='+cast(@importStudentID as nvarchar(20)));
--insert into messages (message) values ('default all family fields to studentID='+cast(@xStudentID as nvarchar(20)));
			
				update Students 
				set father = @father, mother = @mother,
					phone1 = @phone1, phone2 = @phone2, -- phone3 = @phone3,
					email1 = @email1, email2 = @email2, -- email3 = @email3,
					AddressDescription = @AddressDescription, 
					Street = @Street, City = @City, State = @State, Zip = @Zip,
					AddressDescription2 = @AddressDescription2,
					Street2 = @Street2, City2 = @City2, State2 = @State2, Zip2 = @Zip2
				from Students s
				where s.StudentID = @xStudentID
			end
		end
		else 
		begin
			-- Default name, phone and email block if all emtpy...
			if ( @xfather+@xmother+@xphone1+@xphone2 /*+@xphone3*/ +@xemail1+@xemail2/*+@xemail3*/ = '' ) 
			begin
				update Students 
				set father = @father, mother = @mother,
					phone1 = @phone1, phone2 = @phone2, -- phone3 = @phone3,
					email1 = @email1, email2 = @email2 --, email3 = @email3
				from Students s
				where s.StudentID = @xStudentID
--if @@ROWCOUNT>0			
--insert into messages (message) values ('default parents, phone and email fields to studentID='+cast(@xStudentID as nvarchar(20)));
			end
		
			-- Default address block #1 if all emtpy...
			if ( @xAddressDescription+@xStreet+@xCity+@xState+@xZip = '' ) 
			begin
			
				-- Find the best existing record for defaults
				select top 1 @importStudentID = s.StudentID,
						@AddressDescription = s.AddressDescription,
						@Street = s.Street, @City = s.City, @State = s.State, @Zip = s.Zip
				from Students s
				where s.FamilyID is not null 
					and s.FamilyID = @xFamilyID
					and s.StudentID <> @xStudentID
				order by isnull(Street,'')+isnull(City,'')+isnull(Zip,'') desc, StudentID

--insert into messages (message,AddressDescription,Street,City,State,Zip)
--values ('default address 1 from studentID='+cast(@importStudentID as nvarchar(20)),
--@AddressDescription,@Street,@City,@State,@Zip);

				update Students 
				set AddressDescription = @AddressDescription, 
					Street = @Street, City = @City, State = @State, Zip = @Zip
				from Students s
				where s.StudentID = @xStudentID
--if @@ROWCOUNT>0			
--insert into messages (message) values ('default address 1 fields to studentID='+cast(@xStudentID as nvarchar(20)));
			end
		
			-- Default address block #2 if all emtpy...
			if ( @xAddressDescription2+@xStreet2+@xCity2+@xState2+@xZip2 = '' ) 
			begin
				-- Find the best existing record for defaults
				select top 1 @importStudentID = s.StudentID,
						@AddressDescription2 = s.AddressDescription2,
						@Street2 = s.Street2, @City2 = s.City2, @State2 = s.State2, @Zip2 = s.Zip2
				from Students s
				where s.FamilyID is not null 
					and s.FamilyID = @xFamilyID
					and s.StudentID <> @xStudentID
				order by isnull(Street2,'')+isnull(City2,'')+isnull(Zip2,'') desc, StudentID

				update Students 
				set	AddressDescription2 = @AddressDescription2, 
					Street2 = @Street2, City2 = @City2, State2 = @State2, Zip2 = @Zip2
				from Students s
				where s.StudentID = @xStudentID
--if @@ROWCOUNT>0			
--insert into messages (message) values ('default address 2 fields to studentID='+cast(@xStudentID as nvarchar(20)));
			end

		end
	end

	set @StudentID = null;
	select  @StudentID = s.StudentID, @father = s.father, @mother = s.mother,
			@phone1 = s.phone1, @phone2 = s.phone2, -- @phone3 = s.phone3,
			@email1 = s.email1, @email2 = s.email2, -- @email3 = s.email3,
			@AddressDescription = s.AddressDescription,
			@Street = s.Street, @City = s.City, @State = s.State, @Zip = s.Zip,
			@AddressDescription2 = s.AddressDescription2,
			@Street2 = s.Street2, @City2 = s.City2, @State2 = s.State2, @Zip2 = s.Zip2
	from deleted s

	if ( @StudentID is not null )
	-- if this record is changed and matched other records, then update those other records
	begin
	
		if ( @xfather+@xmother+@xphone1+@xphone2 /*+@xphone3*/ +@xemail1+@xemail2/*+@xemail3*/ <> '' ) 
		begin
	
			update Students 
			set father = @xfather, mother = @xmother
			from Students
			where FamilyID is not null 
				and FamilyID = @xFamilyID
				and StudentID <> @xStudentID
				and isnull(father,'') = isnull(@father,'') 
				and isnull(mother,'') = isnull(@mother,'')

-- 		if @@ROWCOUNT <> 0
-- 			insert into messages (message) values ('publish mother/father updates from studentID='+cast(@xStudentID as nvarchar(20)));
		
			update Students 
			set phone1 = @xphone1, phone2 = @xphone2 --, phone3 = @xphone3
			from Students
			where FamilyID is not null 
				and FamilyID = @xFamilyID
				and isnull(phone1,'') = isnull(@phone1,'')
				and isnull(phone2,'') = isnull(@phone2,'')
--				and isnull(phone3,'') = isnull(@phone3,'')

-- 		if @@ROWCOUNT <> 0
-- 			insert into messages (message) values ('publish phone updates from studentID='+cast(@xStudentID as nvarchar(20)));
			
			update Students 
			set email1 = @xemail1, email2 = @xemail2 --, email3 = @xemail3
			from Students
			where FamilyID is not null 
				and FamilyID = @xFamilyID
				and StudentID <> @xStudentID
				and isnull(email1,'') = isnull(@email1,'')
				and isnull(email2,'') = isnull(@email2,'')
--				and isnull(email3,'') = isnull(@email3,'')
-- 		if @@ROWCOUNT <> 0
-- 			insert into messages (message) values ('publish email updates from studentID='+cast(@xStudentID as nvarchar(20)));
		end
		
		if ( @xAddressDescription+@xStreet+@xCity+@xState+@xZip <> '' ) 
		begin
			-- But if only the state is filled in then allow clearing all copies of address
			set @deleteAddr = case when @xAddressDescription+@xStreet+@xCity+@xZip='' then 1 else 0 end;
			if (@deleteAddr = 1)
			begin
				set @xState = '';
			end
/*
insert into messages (
	message,
xAddressDescription,
deleteAddr,
xStreet,
xCity,
xState,
xZip,
xFamilyID,
xStudentID,
AddressDescription ,
Street,
City,
State,
Zip
) values (
case when @deleteAddr=0 then
	'publish to addr 1='+cast(@xStudentID as nvarchar(20))
else
	'delete addr 1='+cast(@xStudentID as nvarchar(20)) end,
@xAddressDescription,
@deleteAddr,
@xStreet,
@xCity,
@xState,
@xZip,
@xFamilyID,
@xStudentID,
@AddressDescription ,
@Street,
@City,
@State,
@Zip 
	);
*/	
			update Students 
			set AddressDescription = @xAddressDescription, 
				Street = @xStreet, City = @xCity, State = @xState, Zip = @xZip
			from Students s
			where FamilyID is not null 
			  and (( FamilyID = @xFamilyID
				and (StudentID <> @xStudentID or @deleteAddr=1)
				and isnull(AddressDescription,'') = isnull(@AddressDescription,'') 
				and isnull(Street,'') = isnull(@Street,'') 
				and isnull(City,'') = isnull(@City,'') 
				--and (isnull(State,'') = isnull(@State,'') or @deleteAddr=1)
				and isnull(Zip,'') = isnull(@Zip,''))
				or (StudentID = @xStudentID and @deleteAddr=1))
				
		--if @@ROWCOUNT <> 0
		--	insert into messages (message) values ('publish address 1 updates from studentID='+cast(@xStudentID as nvarchar(20)));
--	insert into messages (message) values ('row count = '+cast(@@rowcount as nvarchar(20)))

		end

		if ( @xAddressDescription2+@xStreet2+@xCity2+@xState2+@xZip2 <> '' ) 
		begin
			-- But if only the state is filled in then allow clearing all copies of address
			set @deleteAddr = case when @xAddressDescription2+@xStreet2+@xCity2+@xZip2='' then 1 else 0 end;
			if (@deleteAddr = 1)
			begin
				set @xState2 = '';
			end

--if @deleteAddr = 1
--	insert into messages (message) values ('delete addr 2='+cast(@xStudentID as nvarchar(20)));

			update Students 
			set AddressDescription2 = @xAddressDescription2, 
				Street2 = @xStreet2, City2 = @xCity2, State2 = @xState2, Zip2 = @xZip2
			from Students s
			where FamilyID is not null 
			  and (( FamilyID = @xFamilyID
				and (StudentID <> @xStudentID or @deleteAddr=1)
				and isnull(AddressDescription2,'') = isnull(@AddressDescription2,'') 
				and isnull(Street2,'') = isnull(@Street2,'') 
				and isnull(City2,'') = isnull(@City2,'') 
				--and (isnull(State,'') = isnull(@State,'') or @deleteAddr=1)
				and isnull(Zip2,'') = isnull(@Zip2,''))
				or (StudentID = @xStudentID and @deleteAddr=1))

			--if @@ROWCOUNT <> 0
			--	insert into messages (message) values ('publish address 2 updates from studentID='+cast(@xStudentID as nvarchar(20)));
		end
	end
	
	-----------------------------------------------------------
	--  Add Records to AccountAlerts if FamilyID change and 
	--  the student is already populated in Classes
	--
	--  Removal of orphaned records is handeled elsware and 
	--  doesn't need to be here
	--
	--  It is not needed to do this for Family2ID only FamilyID
	--	Don Puls 6/5/2015
	-----------------------------------------------------------
	
	-- Add missing records for Family1 Account
	Insert into AccountAlerts (CSID, AccountID)
	Select
	CS.CSID,
	F.AccountID
	From 
	Students S
		inner join
	Families F
		on S.FamilyID = F.FamilyID
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
		inner join
	Classes C
		on C.ClassID = CS.ClassID
	Where
	S.StudentID = @xStudentID
	and
	C.ClassTypeID in (1,5,6,8)
	and
	not exists 
	(Select * From AccountAlerts Where CSID = CS.CSID and AccountID = F.AccountID)
	
	
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateRaceCodesFromDpiEthnicity]
 on [dbo].[Students]
 After Update, Insert
As
BEGIN
	IF (UPDATE(Ethnicity))
	BEGIN
		WITH StudentsWithDpiRaceKeyUpdates(StudentID,FederalRaceCodes) AS (
			-- Only evaluate students that are updated with a numeric DPI code in 
			-- the (previously) deprecated Student Ethnicity field.
			SELECT i.StudentID, dpi.FederalRaceCodes 
				FROM inserted i
				INNER JOIN vDPI_Crosswalk_Race_Table dpi
					ON right('0000'+cast(i.Ethnicity as nvarchar(10)),4) = dpi.Individual_Race_Key 
				WHERE ISNULL(right('0000'+cast(i.Ethnicity as nvarchar(10)),4),'')
					<> ISNULL((select RaceKey from vDPI_Export2 where StudentID=i.StudentID),'')
		),
		NewStudentRaces(StudentID,RaceID) AS (
			SELECT s.StudentID, r.RaceID
				FROM StudentsWithDpiRaceKeyUpdates s
				INNER JOIN (
					SELECT FederalRaceMapping, max(RaceID) as RaceID
						FROM RACE 
						WHERE FederalRaceMapping IS NOT NULL
						GROUP BY FederalRaceMapping
					) r
				ON CHARINDEX(r.FederalRaceMapping+';', s.FederalRaceCodes) > 0
		)
		MERGE StudentRace AS t
			USING NewStudentRaces AS s
				ON t.RaceID = s.RaceID AND t.StudentID = s.StudentID
			WHEN NOT MATCHED BY TARGET
					AND s.StudentID IN (SELECT StudentID FROM StudentsWithDpiRaceKeyUpdates)
				THEN
					INSERT (StudentID, RaceID)
					VALUES (s.StudentID, RaceID)
			WHEN NOT MATCHED BY SOURCE
					AND t.StudentID IN (SELECT StudentID FROM StudentsWithDpiRaceKeyUpdates)
				THEN 
					DELETE;
	END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateStatusField]
 on [dbo].[Students]
 After Update
As
begin

	-- Keep classic 'Active' field in sync with SIS 'Status' field

    -- When classic asserts an 'active' field value then replicate to SIS 'status' field
    -- if SIS field is not an agreement with overall active/inactive state...
	If Update(Active) and not Update(Status) 
	begin
		Update Students 
			set Status 
				= (case when i.Active=1 then 'Active' else 'Inactive' end)
			from Students s
			inner join Inserted i on s.StudentID = i.StudentID
			where i.Active <>
				(case	when (i.Status='Inactive' or i.Status= 'Alumnus' or i.Status='New Enrollment')
						then 0 else 1 end)
	end

	-- When SIS asserts a 'status' value then replicate to classic 'active' field
    -- if SIS field is not an agreement with overall active/inactive state...
	If not Update(Active) and Update(Status)
	begin
		Update Students 
			set Active
				= (case when (i.Status='Inactive' or i.Status= 'Alumnus' or i.Status='New Enrollment')
					then 0 else 1 end)
			from Students s
			inner join Inserted i on s.StudentID = i.StudentID
			where i.Active <>
				(case	when (i.Status='Inactive' or i.Status= 'Alumnus' or i.Status='New Enrollment')
						then 0 else 1 end)
	end

	-- I18N-252: nullify if AddressName/addressname2 = dbo.getStudentAddressTitle()
	If Update(AddressName) or Update(AddressName2)
	begin
		Update s
		set AddressName = case when s.AddressName = sa.AddressTitle then null else s.AddressName end,
			AddressName2 = case when s.AddressName2 = sa.AddressTitle then null else s.AddressName2 end
		from Students s
		--
		-- join to inserted reduces scope of rows to check/update...
		-- NOTE could comment out to make self-healing if there are occasional failures of this nullification...
		inner join Inserted i 
		on s.StudentID = i.StudentID
		--
		inner join dbo.getStudentAddressTitle() Sa
		on S. StudentID = Sa.StudentID
		--
		where s.AddressName = sa.AddressTitle or s.AddressName2 = sa.AddressTitle
	end

end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateStudentNameOnTranscript]
 on [dbo].[Students]
 After Update
As
begin

	If Update(Lname) or Update(Mname) or Update(Fname) or Update(Suffix) or Update(Nickname)
	begin
		update transcript set 
			Lname=i.Lname,  
			Fname=i.Fname,
			Mname=i.Mname,
            Suffix=i.Suffix,
			Nickname=i.Nickname
			from transcript t
			inner join Inserted i on t.StudentID = i.StudentID

	end
end

GO
ALTER TABLE [dbo].[Students] ADD CONSTRAINT [CHK_GradeLevel] CHECK (([GradeLevel]='30' OR [GradeLevel]='29' OR [GradeLevel]='28' OR [GradeLevel]='27' OR [GradeLevel]='26' OR [GradeLevel]='25' OR [GradeLevel]='24' OR [GradeLevel]='23' OR [GradeLevel]='22' OR [GradeLevel]='21' OR [GradeLevel]='20' OR [GradeLevel]='19' OR [GradeLevel]='18' OR [GradeLevel]='17' OR [GradeLevel]='16' OR [GradeLevel]='15' OR [GradeLevel]='14' OR [GradeLevel]='13' OR [GradeLevel]='12' OR [GradeLevel]='11' OR [GradeLevel]='10' OR [GradeLevel]='9' OR [GradeLevel]='8' OR [GradeLevel]='7' OR [GradeLevel]='6' OR [GradeLevel]='5' OR [GradeLevel]='4' OR [GradeLevel]='3' OR [GradeLevel]='2' OR [GradeLevel]='1' OR [GradeLevel]='K' OR [GradeLevel]='PK' OR [GradeLevel]='PS'))
GO
ALTER TABLE [dbo].[Students] ADD CONSTRAINT [CK_Lname_Students] CHECK (([Lname]<>N''))
GO
ALTER TABLE [dbo].[Students] ADD CONSTRAINT [PK_Students] PRIMARY KEY CLUSTERED ([StudentID]) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountID] ON [dbo].[Students] ([AccountID]) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Students] ADD CONSTRAINT [UNQ_Students_AccountID] UNIQUE NONCLUSTERED ([AccountID]) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Students_StudentID_AccountID] ON [dbo].[Students] ([StudentID], [AccountID]) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
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
CREATE UNIQUE NONCLUSTERED INDEX [idx_wiseid_notnull] ON [dbo].[Students] ([WISEid]) WHERE ([wiseid] IS NOT NULL) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [Unique_xStudentID] ON [dbo].[Students] ([xStudentID]) WITH (FILLFACTOR=95, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Students] WITH NOCHECK ADD CONSTRAINT [FK_Students_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Accounts] ([AccountID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
