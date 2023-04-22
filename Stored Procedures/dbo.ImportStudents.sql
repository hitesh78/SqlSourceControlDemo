SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   Procedure [dbo].[ImportStudents]
@ClassID int,
@EK decimal(15,15),
@UpdateStudents nvarchar(5),
@Data nvarchar(max)
as

Begin Try

	CREATE TABLE #TextPtrTable (c1 ntext)
	--EXEC sp_tableoption '#TextPtrTable', 'text in row', 'on'

	INSERT #TextPtrTable VALUES (@Data COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare @DataSegment nvarchar(1000)
	Declare @EndPosition int
	Declare @StrLength int
	Declare @StartPosition int
	Declare @StudentID bigint
	Declare @Username nvarchar(20)
	Declare @Password nvarchar(40)
	Declare @LastName nvarchar(40)
	Declare @FirstName nvarchar(40)
	Declare @MiddleName nvarchar(40)
	Declare @NickName nvarchar(40)
	Declare @GradeLevel nvarchar(20)
	Declare @Division nvarchar(20)
	Declare @Father nvarchar(50)
	Declare @Mother nvarchar(50)
	Declare @Phone1 nvarchar(50)
	Declare @Phone2 nvarchar(50)
	Declare @Phone3 nvarchar(50)
	Declare @Email1 nvarchar(50)
	Declare @Email2 nvarchar(50)
	Declare @Email6 nvarchar(50)
	Declare @Email7 nvarchar(50)
	Declare @Email8 nvarchar(50)
	Declare @SchoolEmail nvarchar(100)
	Declare @Birthdate smalldatetime
	Declare @Sex nvarchar(12)
	Declare @Ethnicity nvarchar(50)
	Declare @AddressDescription1  nvarchar(100)
	Declare @Street1  nvarchar(100)
	Declare @City1  nvarchar(100)
	Declare @State1  nvarchar(50)
	Declare @Zip1  nvarchar(12)
	Declare @AddressDescription2  nvarchar(100)
	Declare @Street2  nvarchar(100)
	Declare @City2  nvarchar(100)
	Declare @State2  nvarchar(50)
	Declare @Zip2  nvarchar(12)
	Declare @AddressName1 nvarchar(100)
	Declare @AddressName2 nvarchar(100)
	Declare @LockerNumber nvarchar(20)
	Declare @LockerCode nvarchar(20)
	Declare @StudentIDExists bit
	Declare @UpdateStudentExists bit
	Declare @DuplicateStudentIDs table (StudentID bigint, Lname nvarchar(128), Fname nvarchar(128))



	Create Table #tmpAccounts
	(
	AccountID nvarchar(50),
	ThePassword nvarchar(50) Collate DATABASE_DEFAULT,
	Access nvarchar(10),
	EncKey decimal(15,15),
	MissedPasswords tinyint,
	Lockout bit,
	LastName nvarchar(128),
	FirstName nvarchar(128),
	StudentID bigint,
	UpdateThisRecord bit
	)


	Create Table #tmpStudents
	(
	StudentID bigint,
	xStudentID bigint,
	AccountID nvarchar(50),
	Lname nvarchar(30),
	Mname nvarchar(30),
	Fname nvarchar(30),
	NickName nvarchar(40),
	GradeLevel nvarchar(20),
	Division nvarchar(20),
	Father nvarchar(50),
	Mother nvarchar(50),
	Phone1 nvarchar(50),
	Phone2 nvarchar(50),
	Phone3 nvarchar(50),
	Email1 nvarchar(70),
	Email2 nvarchar(70),
	Email6 nvarchar(70),
	Email7 nvarchar(70),
	Email8 nvarchar(70),
	SchoolEmail nvarchar(100),
	BirthDate smalldatetime, 
	Sex nvarchar(12), 
	Ethnicity nvarchar(50),
	AddressDescription nvarchar(100),
	AddressName nvarchar(100),
	Street nvarchar(100),
	City nvarchar(50),
	State nvarchar(50),
	Zip nvarchar(50),
	AddressDescription2 nvarchar(100),
	AddressName2 nvarchar(100),
	Street2 nvarchar(100),
	City2 nvarchar(50),
	State2 nvarchar(50),
	Zip2 nvarchar(50),
	LockerNumber nvarchar(20),
	LockerCode nvarchar(20),
	UpdateThisRecord bit
	)




	Declare @DataStartPosition int
	Declare @DataEndPosition int
	Declare @CharacterCount int
	Declare @LastCharacterCount int
	Declare @CommaCount int
	Declare @EndOfData bit
	Declare @StudentData nvarchar(4000)
	DECLARE @ptrval VARBINARY(16)
	Declare @DataLength int


	Set @DataStartPosition = 1
	Set @CharacterCount = 1
	Set @LastCharacterCount = 0
	Set @EndOfData = 1

	SELECT @ptrval = TEXTPTR(c1)
	FROM #TextPtrTable


	While (@EndOfData != 0)
	Begin

	SELECT @StudentData = c1
	FROM #TextPtrTable


	Set @CommaCount = 0


	While (@CharacterCount != 0 and @CommaCount != 36)
	Begin
	  Set @LastCharacterCount = @CharacterCount
	  Set @CharacterCount = CHARINDEX (',', @StudentData, @CharacterCount + 1)
	  Set @CommaCount = @CommaCount + 1
	End

	If @CharacterCount = 0
	Begin
	  Set @EndOfData = 0
	End


	Set @DataEndPosition = @LastCharacterCount
	Set @CharacterCount = 1
	Set @DataSegment = SUBSTRING (@StudentData, @DataStartPosition, @DataEndPosition)

	Set @DataSegment = REPLACE (@DataSegment, CHAR(10), N'')
	Set @DataSegment = REPLACE (@DataSegment, CHAR(13), N'')
	Set @DataSegment = REPLACE (@DataSegment, '""', N'''')
	Set @DataSegment = REPLACE (@DataSegment, '"', N'')


	UPDATETEXT #TextPtrTable.c1 @ptrval 0 @DataEndPosition


			While (LEN(@DataSegment) > 0)
			Begin

			--Get StudentID
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @StudentID = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Username
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Username = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Password
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Password = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			if isnull(@Password,'') = '' and @UpdateStudents = 'no'
			Begin
				Set @Password = dbo.GeneratePassword()
			End

			--Get LastName
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @LastName = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			Set @LastName = dbo.udf_CorrectCasing(@LastName)

			--Get FirstName
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @FirstName = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			Set @FirstName = dbo.udf_CorrectCasing(@FirstName)

			--Get MiddleName
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @MiddleName = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			Set @MiddleName = dbo.udf_CorrectCasing(@MiddleName)

			--Get NickName
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @NickName = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			Set @NickName = dbo.udf_CorrectCasing(@NickName)

			--Get GradeLevel
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @GradeLevel = ltrim(rtrim(SUBSTRING (@DataSegment, 1, @EndPosition)))
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Division
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Division = ltrim(rtrim(SUBSTRING (@DataSegment, 1, @EndPosition)))
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Birthdate
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Birthdate = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Sex
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Sex = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
		
			--Get Ethnicity
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Ethnicity = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)	
		
			--Get Locker #
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @LockerNumber = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
		
			--Get Locker Code
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @LockerCode = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)	

			--Get Father
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Father = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			--Set @Father = dbo.udf_CorrectCasing(@Father) -- this was causing issues on sch186 missing last charater

			--Get Mother
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Mother = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			--Set @Mother = dbo.udf_CorrectCasing(@Mother) -- this was causing issues on sch186 missing last charater

			--Get Address1 Description
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @AddressDescription1 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
		
			--Get Street1
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Street1 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get City1
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @City1 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get State1
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @State1 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Zip1
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Zip1 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Address2 Description
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @AddressDescription2 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
				
			--Get Street2
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Street2 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get City2
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @City2 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get State2
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @State2 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Zip2
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Zip2 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)		

			--Get Phone1
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Phone1 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Phone2
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Phone2 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Phone3
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Phone3 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Family1 Parent1 Email
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Email1 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Family1 Parent2 Email
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Email2 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Family2 Parent1 Email
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Email6 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Family2 Parent2 Email
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Email7 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)

			--Get Student Email
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
			Set @Email8 = SUBSTRING (@DataSegment, 1, @EndPosition)
			Set @StrLength = LEN(@DataSegment)
			Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)


			--Get Student School Email
			Set @EndPosition = PATINDEX ('%,%', @DataSegment) - 1
			If @EndPosition >= 0
			Begin
				Set @StartPosition = PATINDEX ('%,%', @DataSegment) + 1
				Set @SchoolEmail = SUBSTRING (@DataSegment, 1, @EndPosition)
				Set @StrLength = LEN(@DataSegment)
				Set @DataSegment = SUBSTRING (@DataSegment, @StartPosition, @StrLength)
			End
		
			Set @UpdateStudentExists = (Select count(*) Where Exists (Select * From Students Where xStudentID = @StudentID and Lname = @LastName and Fname = @FirstName))
		
			Set @StudentIDExists = (Select count(*) Where Exists (Select * From Students Where xStudentID = @StudentID or StudentID = @StudentID))
		


			If @UpdateStudents = 'yes' and @UpdateStudentExists = 1
				Begin
			
					Insert into #tmpAccounts(AccountID, ThePassword, Access, EncKey, MissedPasswords, Lockout, LastName, FirstName, StudentID, UpdateThisRecord)
					Values	(
							@Username,
							@Password,
							'Student',
							-0.1,
							0,
							0,
							@LastName,
							@FirstName,
							@StudentID,
							1
							)

					Insert into #tmpStudents(StudentID, xStudentID, AccountID, LName, MName, FName, NickName, GradeLevel, Division, Father, Mother, Phone1, Phone2, Phone3, Email1, Email2, Email6, Email7, Email8, SchoolEmail, BirthDate, Sex, Ethnicity, AddressDescription, AddressName, Street, City, State, Zip, AddressDescription2, AddressName2, Street2, City2, State2, Zip2, LockerNumber, LockerCode, UpdateThisRecord)
					Values	(
							@StudentID,
							@StudentID,
							@Username,
							@LastName,
							@MiddleName,
							@FirstName,
							@NickName,
							case @GradeLevel
								when '1st' then '1'
								when '2nd' then '2'
								when '3rd' then '3'
								when '4th' then '4'
								when '5th' then '5' 					
								when '6th' then '6' 					
								when '7th' then '7' 					
								when '8th' then '8' 					
								when '9th' then '9' 					
								when '10th' then '10' 					
								when '11th' then '11' 					
								when '12th' then '12'
								when 'k' then 'K'
								when 'kg' then 'K'
								when 'KG' then 'K'
								when 'pk' then 'PK'
								when 'ps' then 'PS'					
								else @GradeLevel
							end,
							@Division,
							@Father,
							@Mother,
							@Phone1,
							@Phone2,
							@Phone3,
							@Email1,
							@Email2,
							@Email6,
							@Email7,
							@Email8,
							@SchoolEmail,
							@BirthDate, 
							case lower(@Sex)
								when 'm' then 'Male'
								when 'f' then 'Female'
								when 'male' then 'Male'
								when 'female' then 'Female'
								else @Sex
							end,
							@Ethnicity, 
							@AddressDescription1, 
							@AddressName1,
							@Street1, 
							@City1, 
							@State1, 
							@Zip1,
							@AddressDescription2, 
							@AddressName2,
							@Street2, 
							@City2, 
							@State2, 
							@Zip2,
							@LockerNumber,
							@LockerCode,
							1				
							)

				End
			
				Else

				Begin
			
					If @StudentIDExists = 1
					Begin
						insert into @DuplicateStudentIDs(StudentID, Lname, Fname)
						values (@StudentID, @LastName, @FirstName) 
					End
				
					Else
				
					Begin
		
						Insert into #tmpAccounts(AccountID, ThePassword, Access, EncKey, MissedPasswords, Lockout, LastName, FirstName, StudentID, UpdateThisRecord)
						Values	(
								@Username,
								case when isnull(@Password,'') = '' then dbo.GeneratePassword() else @Password end,
								'Student',
								-0.1,
								0,
								0,
								@LastName,
								@FirstName,
								@StudentID,
								0
								)
					
						Insert into #tmpStudents(StudentID, xStudentID, AccountID, LName, MName, FName, NickName, GradeLevel,  Division, Father, Mother, Phone1, Phone2, Phone3, Email1, Email2, Email6, Email7, Email8, SchoolEmail, BirthDate, Sex, Ethnicity, AddressDescription, AddressName, Street, City, State, Zip, AddressDescription2, AddressName2, Street2, City2, State2, Zip2, LockerNumber, LockerCode, UpdateThisRecord)
						Values	(
								@StudentID,
								@StudentID,
								@Username,
								@LastName,
								@MiddleName,
								@FirstName,
								@NickName,
								case @GradeLevel
									when '1st' then '1'
									when '2nd' then '2'
									when '3rd' then '3'
									when '4th' then '4'
									when '5th' then '5' 					
									when '6th' then '6' 					
									when '7th' then '7' 					
									when '8th' then '8' 					
									when '9th' then '9' 					
									when '10th' then '10' 					
									when '11th' then '11' 					
									when '12th' then '12'
									when 'k' then 'K'
									when 'kg' then 'K'
									when 'KG' then 'K'
									when 'pk' then 'PK'
									when 'ps' then 'PS'					
									else @GradeLevel
								end,
								@Division,
								@Father,
								@Mother,
								@Phone1,
								@Phone2,
								@Phone3,
								@Email1,
								@Email2,
								@Email6,
								@Email7,
								@Email8,
								@SchoolEmail,
								@BirthDate, 
								case lower(@Sex)
									when 'm' then 'Male'
									when 'f' then 'Female'
									when 'male' then 'Male'
									when 'female' then 'Female'
									else @Sex
								end,
								@Ethnicity, 
								@AddressDescription1, 
								@AddressName1,
								@Street1, 
								@City1, 
								@State1, 
								@Zip1,
								@AddressDescription2, 
								@AddressName2,
								@Street2, 
								@City2, 
								@State2, 
								@Zip2,
								@LockerNumber,
								@LockerCode,
								0				
								)
				
					End	-- If not duplicate Students
					
				End -- IF Update Students		
	
			End		--While
	


	End		--WHILE


	If Exists(Select * From @DuplicateStudentIDs)
	Begin

		Select 	
		@ClassID as ClassID,
		@EK as EK,
		'Duplicates Detected' as Saved,
		StudentID,
		Lname, 
		Fname
		From @DuplicateStudentIDs
		FOR XML RAW

	End

	Else If Exists(Select * From #tmpAccounts) And Exists(Select * From #tmpStudents) 
	Begin



		CREATE TABLE #Accounts_Updated
		(
			ThePassword nvarchar(30) NOT NULL,
			AccountID nvarchar(50) NOT NULL,
		)
				
		If Exists(Select * From #tmpAccounts Where UpdateThisRecord = 1) And Exists(Select * From #tmpStudents Where UpdateThisRecord = 1) And @UpdateStudents = 'yes'
		Begin
					
			ALTER TABLE Students NOCHECK CONSTRAINT FK_Students_Accounts
				
			Begin Transaction

			Update A
			Set 
			AccountID = case when Isnull(x.AccountID, '') = '' then A.AccountID else x.AccountID end,
			ThePassword = case when ltrim(rtrim(Isnull(x.ThePassword, ''))) = '' then A.ThePassword else x.ThePassword end
			OUTPUT Inserted.ThePassword, Inserted.AccountID INTO #Accounts_Updated
			From 
			Accounts A 
				inner join 
			(
				Select 
				S.AccountID, 
				tA.ThePassword,
				tA.UpdateThisRecord
				From
				#tmpAccounts tA 
					inner join 
				Students S 
					on	tA.StudentID = S.xStudentID 
						and 
						tA.LastName = S.Lname 
						and 
						tA.FirstName = S.Fname
			) x
				on A.AccountID = x.AccountID
			Where x.UpdateThisRecord = 1
		
			Update S
			Set
			AccountID = case when Isnull(tS.AccountID, '') = '' then S.AccountID else tS.AccountID end,
			Mname = case when Isnull(tS.Mname, '') = '' then S.Mname else tS.Mname end,
			Nickname = case when Isnull(tS.Nickname, '') = '' then S.Nickname else tS.Nickname end,
			Class = case when Isnull(tS.Division, '') = '' then S.Class else tS.Division end, 
			Father = case when Isnull(tS.Father, '') = '' then S.Father else tS.Father end,
			Mother = case when Isnull(tS.Mother, '') = '' then S.Mother else tS.Mother end,
			Phone1 = case when Isnull(tS.Phone1, '') = '' then S.Phone1 else tS.Phone1 end,
			Phone2 = case when Isnull(tS.Phone2, '') = '' then S.Phone2 else tS.Phone2 end,
			Phone3 = case when Isnull(tS.Phone3, '') = '' then S.Phone3 else tS.Phone3 end,
			Email1 = case when Isnull(tS.Email1, '') = '' then S.Email1 else tS.Email1 end,
			Email2 = case when Isnull(tS.Email2, '') = '' then S.Email2 else tS.Email2 end,
			Email6 = case when Isnull(tS.Email6, '') = '' then S.Email6 else tS.Email6 end,
			Email7 = case when Isnull(tS.Email7, '') = '' then S.Email7 else tS.Email7 end,
			Email8 = case when Isnull(tS.Email8, '') = '' then S.Email8 else tS.Email8 end,
			SchoolEmail = case when Isnull(tS.SchoolEmail, '') = '' then S.SchoolEmail else tS.SchoolEmail end,
			BirthDate = case when Isnull(tS.BirthDate, '') = '' then S.BirthDate else tS.BirthDate end,
			Sex = case when Isnull(tS.Sex, '') = '' then S.Sex else 
					case lower(tS.Sex)
						when 'm' then 'Male'
						when 'f' then 'Female'
						when 'male' then 'Male'
						when 'female' then 'Female'
						else tS.Sex
					end				
			end,
			Ethnicity = case when Isnull(tS.Ethnicity, '') = '' then S.Ethnicity else tS.Ethnicity end,
			AddressDescription = case when Isnull(tS.AddressDescription, '') = '' then S.AddressDescription else tS.AddressDescription end,
			AddressName = case when Isnull(tS.AddressName, '') = '' then S.AddressName else tS.AddressName end,
			Street = case when Isnull(tS.Street, '') = '' then S.Street else tS.Street end,
			City = case when Isnull(tS.City, '') = '' then S.City else tS.City end,
			State = case when Isnull(tS.State, '') = '' then S.State else tS.State end,
			Zip = case when Isnull(tS.Zip, '') = '' then S.Zip else tS.Zip end,
			AddressDescription2 = case when Isnull(tS.AddressDescription2, '') = '' then S.AddressDescription2 else tS.AddressDescription2 end,
			AddressName2 = case when Isnull(tS.AddressName2, '') = '' then S.AddressName2 else tS.AddressName2 end,
			Street2 = case when Isnull(tS.Street2, '') = '' then S.Street2 else tS.Street2 end,
			City2 = case when Isnull(tS.City2, '') = '' then S.City2 else tS.City2 end,
			State2 = case when Isnull(tS.State2, '') = '' then S.State2 else tS.State2 end,
			Zip2 = case when Isnull(tS.Zip2, '') = '' then S.Zip2 else tS.Zip2 end,
			LockerNumber = case when Isnull(tS.LockerNumber, '') = '' then S.LockerNumber else tS.LockerNumber end,
			LockerCode = case when Isnull(tS.LockerCode, '') = '' then S.LockerCode else tS.LockerCode end
			From Students As S Inner Join #tmpStudents As tS On S.xStudentID = tS.StudentID And S.Lname = tS.Lname And S.Fname = tS.Fname
			Where tS.UpdateThisRecord = 1

			Commit Transaction
		
			ALTER TABLE Students CHECK CONSTRAINT FK_Students_Accounts

		End

		--select * from #Accounts_Updated

		--This CURSOR is used to Audit the Change Password operation for UPDATE statements.  The INSERT process is handled by Triggers
		DECLARE @AccountID nvarchar(50)
		DECLARE @ThePassword nvarchar(50)
		DECLARE @dbname nvarchar(20) = (SELECT DB_NAME())
		DECLARE @AuthID int

		DECLARE cur CURSOR FOR SELECT AccountID, ThePassword FROM #Accounts_Updated
		OPEN cur

		FETCH NEXT FROM cur INTO @AccountID, @ThePassword

		WHILE @@FETCH_STATUS = 0 BEGIN
			SET @AuthID = (SELECT StudentID FROM Students WHERE AccountID = @AccountID)

			UPDATE Accounts
			SET ThePassword = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5', CONCAT(@ThePassword,@AuthID))), 3, 8)
			WHERE AccountID = @AccountID

			EXEC [LKG].dbo.sp_AuditChangePassword @ThePassword, @AuthID, @AccountID, @dbname
			FETCH NEXT FROM cur INTO @AccountID, @ThePassword
		END

		CLOSE cur    
		DEALLOCATE cur
	
		/* Now write the Insert statements */

		Begin Transaction

		Insert into Accounts(AccountID, ThePassword, Access, EncKey, MissedPasswords, Lockout)
		Select 
		tA.AccountID, 
		case when ltrim(rtrim(isnull(tA.ThePassword,''))) = '' then dbo.GeneratePassword() else ta.ThePassword end,
		tA.Access, 
		tA.EncKey, 
		tA.MissedPasswords, 
		tA.Lockout 
		From #tmpAccounts As tA 
		Where UpdateThisRecord = 0

		Insert into Students(StudentID, xStudentID, AccountID, LName, MName, FName, Nickname, GradeLevel, Class, Father, Mother, Phone1, Phone2, Phone3, Email1, Email2, Email6, Email7, Email8, SchoolEmail, BirthDate, Sex, Ethnicity, AddressDescription, AddressName, Street, City, State, Zip, AddressDescription2, AddressName2, Street2, City2, State2, Zip2, LockerNumber, LockerCode)
		Select 
		case 
			when tS.StudentID < 2147483647 then tS.StudentID
			else (Select Max(StudentID) + 1 From Students)
		end, 
		tS.xStudentID, 
		tS.AccountID, tS.Lname, tS.Mname, tS.Fname, ts.Nickname, tS.GradeLevel, ts.Division, tS.Father, tS.Mother, tS.Phone1, tS.Phone2, tS.Phone3, tS.Email1, tS.Email2, tS.Email6, tS.Email7, tS.Email8, tS.SchoolEmail, tS.BirthDate, tS.Sex, tS.Ethnicity, tS.AddressDescription, tS.AddressName, tS.Street, tS.City, tS.State, tS.Zip, tS.AddressDescription2, tS.AddressName2, tS.Street2, tS.City2, tS.State2, tS.Zip2, tS.LockerNumber, tS.LockerCode From #tmpStudents As tS Where UpdateThisRecord = 0


		/********* Import Race *********/
		-- First Add any new Race values in the import that is not in the Race table
		INSERT INTO Race ([Name], [Description], [Deprecated], [RaceOrder])
		Select distinct
		ltrim(rtrim(tS.Ethnicity)) COLLATE DATABASE_DEFAULT,
		'New race value from imported students on ' + dbo.GLgetdate() COLLATE DATABASE_DEFAULT,
		0,
		12
		From
		#tmpStudents tS
		Where
		Isnull(ltrim(rtrim(tS.Ethnicity)), '') COLLATE DATABASE_DEFAULT != ''
		and
		ltrim(rtrim(tS.Ethnicity)) COLLATE DATABASE_DEFAULT 
			not in (Select [Name] COLLATE DATABASE_DEFAULT from Race)	
			
		--Next import Race records..
		-- First remove any existing Race records
		Delete StudentRace
		From 
		StudentRace SR
			inner join
		Students S 
			on SR.StudentID = S.StudentID
			inner join 
		#tmpStudents tS 
			on S.xStudentID = tS.StudentID
		Where
		Isnull(ltrim(rtrim(tS.Ethnicity)), '') != ''

		-- Second add race records
		Insert into StudentRace(StudentID, RaceID)
		Select
		S.StudentID,
		(Select RaceID 
			From Race 
			Where [Name] COLLATE DATABASE_DEFAULT = 
			ltrim(rtrim(tS.Ethnicity)) COLLATE DATABASE_DEFAULT
			)
		From 
		Students S 
			inner join 
		#tmpStudents tS 
			on S.xStudentID = tS.StudentID
		Where
		Isnull(ltrim(rtrim(tS.Ethnicity)), '') != ''
			
		/********* Import Race *********/
			
			
		Commit Transaction
			
		drop table #tmpAccounts
		drop table #tmpStudents
		drop table #TextPtrTable
		drop table #Accounts_Updated


		Select 	
		@ClassID as ClassID,
		@EK as EK,
		'Student Data Imported/Updated' as Saved
		FOR XML RAW

	End


End Try
Begin Catch

	If ERROR_NUMBER() = 2627
		Select 	
		@ClassID as ClassID,
		@EK as EK,
		'Error: Duplicate StudentIDs submitted. No changes saved.' as Saved
		FOR XML RAW
	Else
		Select 	
		@ClassID as ClassID,
		@EK as EK,
		'Error ' + CAST(ERROR_NUMBER() AS nvarchar(16)) + ': ' + ERROR_MESSAGE() as Saved
		FOR XML RAW

	If XACT_STATE() != 0
		Rollback Transaction


End Catch

GO
