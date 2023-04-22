SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		GL Legacy
-- Modified by: Eugene L.
-- Modified dt: 9/30/2022 
-- Mod Desc: Add UpdLock hint
-- =============================================

-- =============================================
-- Author:		GL Legacy
-- Modified by: Eugene L.
-- Modified dt: 9/7/2022 
-- Mod Desc: Add UpdLock hint
-- =============================================

-- =============================================
-- Author:		GL Legacy
-- Modified by: Joey
-- Modified dt: 9/20/2021 >> 12/28/2021
-- Mod Desc:	MFA
-- =============================================
CREATE    Procedure [dbo].[Authenticate]
@ID nvarchar(50),
@Password nvarchar(80),
@ClientIPaddress nvarchar(20),
@ClientDeviceType nvarchar(20),
@ClientUserAgent nvarchar(500),
@ClientDNSname nvarchar(300)
--@OAuth nvarchar(50)
as


Set @ID = isnull(replace(@ID, char(146), char(39)), @ID) -- Swap Right Apostrophe with stright : GMA-1571

--Determine Access
Declare @Access nvarchar(15)
Set @Access = (Select Access from Accounts WITH(UPDLOCK) where AccountID = @ID);

Declare @RequireOTP bit = 0;
DECLARE @FailedLogin bit = 0

DECLARE @AuthID int
SET @AuthID =
CASE
	WHEN @Access = 'Student' THEN (SELECT StudentID FROM Students WITH(UPDLOCK) WHERE AccountID = @ID)
	WHEN @Access = 'Teacher' THEN (SELECT TeacherID FROM Teachers WITH(UPDLOCK) WHERE AccountID = @ID)
	WHEN @Access = 'No Access' THEN (SELECT TeacherID FROM Teachers WITH(UPDLOCK) WHERE AccountID = @ID)
	WHEN @Access = 'Principal' THEN (SELECT TeacherID FROM Teachers WITH(UPDLOCK) WHERE AccountID = @ID)
	WHEN @Access = 'Admin' THEN (SELECT TeacherID FROM Teachers WITH(UPDLOCK) WHERE AccountID = @ID)
	WHEN @Access = 'Family' THEN (SELECT FamilyID FROM Families WITH(UPDLOCK) WHERE AccountID = @ID)
	WHEN @Access = 'Family2' THEN (SELECT FamilyID FROM Families WITH(UPDLOCK) WHERE AccountID = @ID)
	ELSE -1
END

 DECLARE @sessionCount int 
 SET @sessionCount = ISNULL((SELECT LoginSessionCount FROM Accounts WITH(UPDLOCK) WHERE AccountID = @ID), 0) + 1
 
 DECLARE @ExistingEK decimal(15,15) 
 SET @ExistingEK = ISNULL((SELECT EncKey FROM Accounts WITH(UPDLOCK) WHERE AccountID = @ID), -.1)
 

 DECLARE @currentGLdatetime nvarchar(30)
 SET @currentGLdatetime = CONVERT(nvarchar(30), dbo.GLgetdatetime(), 9)
 Declare @AdminID nvarchar(15) = CONVERT(nvarchar(15),SESSION_CONTEXT(N'AdminID'))
--check if account exists
If @ID not in (Select AccountID From Accounts WITH(UPDLOCK))
Begin
	if isnull(@AdminID,'') != '' -- IS NOT NULL   
	Begin
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)  
		VALUES (@AdminID + ' As ' + @ID, 'Admin', 'LOGIN', 'FAIL: Account Does Not Exist', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)  
	End
	Else
	Begin
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)  
		VALUES (@ID, @Access, 'LOGIN', 'FAIL: Account Does Not Exist', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
	End

	Select 
		1 as EncKey, 
		SchoolName,
		SchoolPhone,
		SchoolContact,
		SchoolEmailAddress,
		SchoolWebSite,
		@ClientIPaddress as ClientIPaddress,
		@ClientDNSname as ClientDNSname,
		CAST(0 as bit) as OneTimePass
	From Settings where SettingID = 1 
	FOR XML RAW
	SET @FailedLogin = 1
	RETURN
End

--Check for Lockout
Declare @Lockout bit
Set @Lockout = (Select Lockout from Accounts WITH(UPDLOCK) where AccountID = @ID)
Declare @MissedPasswords tinyint
Set @MissedPasswords = (Select MissedPasswords from Accounts WITH(UPDLOCK) where AccountID = @ID)
Declare @LockAllStudents bit
Set @LockAllStudents = (Select LockAllStudents From Settings Where SettingID = 1)

if @LockAllStudents = 1 and (@Access = 'Student' or @Access = 'Family' or @Access = 'Family2')
Begin
	
	if isnull(@AdminID,'') != '' -- IS NOT NULL    
	Begin
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
		VALUES (@AdminID + ' As ' + @ID,'Admin', 'LOGIN', 'FAIL: All Accounts Locked', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
	End
	Else
	Begin
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
		VALUES (@ID, @Access, 'LOGIN', 'FAIL: All Accounts Locked', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
	End

	Select 
		4 as EncKey,
		SchoolName,
		SchoolPhone,
		SchoolContact,
		SchoolEmailAddress,
		SchoolWebSite,
		LockoutReason,
		@ClientIPaddress as ClientIPaddress,
		@ClientDNSname as ClientDNSname,
		CAST(0 as bit) as OneTimePass
	From Settings where SettingID = 1 
	FOR XML RAW	
	SET @FailedLogin = 1
End

If @Lockout = 1
Begin
	IF @MissedPasswords < 5
	BEGIN
		if isnull(@AdminID,'') != '' -- IS NOT NULL    
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@AdminID + ' As ' + @ID, 'Admin', 'LOGIN', 'FAIL: Account is Locked', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End
		Else
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@ID, @Access, 'LOGIN', 'FAIL: Account is Locked', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End

		Select 
			3 as EncKey,
			SchoolName,
			SchoolPhone,
			SchoolContact,
			SchoolEmailAddress,
			SchoolWebSite,
			@ClientIPaddress as ClientIPaddress,
			@ClientDNSname as ClientDNSname,
			CAST(0 as bit) as OneTimePass
		From Settings where SettingID = 1 
		FOR XML RAW
		SET @FailedLogin = 1
	END
	ELSE
	BEGIN
  		if isnull(@AdminID,'') != '' -- IS NOT NULL    
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@AdminID + ' As ' + @ID, 'Admin', 'LOGIN', 'Fail: Missed Password - Temporarily Locked', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End
		Else
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@ID, @Access, 'LOGIN', 'Fail: Missed Password - Temporarily Locked', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End
		--
		Select 
			3 as EncKey,
			SchoolName,
			SchoolPhone,
			SchoolContact,
			SchoolEmailAddress,
			SchoolWebSite,
			@ClientIPaddress as ClientIPaddress,
			@ClientDNSname as ClientDNSname,
			CAST(0 as bit) as OneTimePass
		From Settings where SettingID = 1 
		FOR XML RAW
		SET @FailedLogin = 1
	END
End
Else
Begin
	If (@Access = 'No Access')
	Begin
  		if isnull(@AdminID,'') != '' -- IS NOT NULL    
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@AdminID + ' As ' + @ID, 'Admin', 'LOGIN', 'Fail: This Staff Account does not have Access to Gradelink', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End
		Else
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@ID, @Access, 'LOGIN', 'Fail: This Staff Account does not have Access to Gradelink', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End
		--
		Select 
			5 as EncKey,
			SchoolName,
			SchoolPhone,
			SchoolContact,
			SchoolEmailAddress,
			SchoolWebSite,
			@ClientIPaddress as ClientIPaddress,
			@ClientDNSname as ClientDNSname,
			CAST(0 as bit) as OneTimePass
		From Settings where SettingID = 1 
		FOR XML RAW
		SET @FailedLogin = 1
		RETURN		
	End
	--
	If (@Access = 'Principal' or @Access = 'Teacher' or @Access = 'Admin') and ((Select Active From Teachers Where AccountID = @ID) = 0)
	Begin
		if isnull(@AdminID,'') != '' -- IS NOT NULL  
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@ID, 'Admin', 'LOGIN', 'Fail: Account no longer Active', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End
		Else
		Begin
			INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
			VALUES (@ID, @Access, 'LOGIN', 'Fail: Account no longer Active', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @ExistingEK, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
		End
		--
		Select 
			5 as EncKey,
			SchoolName,
			SchoolPhone,
			SchoolContact,
			SchoolEmailAddress,
			SchoolWebSite,
			@ClientIPaddress as ClientIPaddress,
			@ClientDNSname as ClientDNSname,
			CAST(0 as bit) as OneTimePass
		From Settings where SettingID = 1 
		FOR XML RAW
		SET @FailedLogin = 1
		RETURN
	End
	--
	Declare @StrPassword nvarchar(20)
	Declare @BackupPswd nvarchar(20)
	Declare @PasswordLength tinyint
	Declare @Count tinyint
	Declare @CurrentChar char(1)
	Declare @TheNum tinyint
	Declare @TheStrNum nvarchar(2)
	Declare @CalcNum1 bigint
	Declare @CalcNum2 bigint
	Declare @CalcPassword1 nvarchar(80)
	Declare @CalcPassword2 nvarchar(80)
	Declare @LoginKey1 int
	Declare @LoginKey2 int
	Declare @ActiveClassCount int
	Declare @StudentClassCount int
	Declare @AllowParentsToViewPastGrades bit = (Select AllowParentsToViewPastGrades From Settings Where SettingID = 1)
  
	Declare @ClassCount int -- Find out if we need to use the Hidden Init class
	Set @ClassCount = (Select count(ClassID) From Classes)
  
	Set @LoginKey1 = (Select Code From LKG.dbo.LoginKey where CodeID = 1)
	Set @LoginKey2 = (Select Code From LKG.dbo.LoginKey where CodeID = 2)

	--retrieve the password from database
	Set @StrPassword = (Select ThePassword from Accounts where AccountID = @ID)
	SET @BackupPswd = (Select BackupPswd from Accounts where AccountID = @ID)
    
  	--retrieve the password salt from database
	DECLARE @Salt uniqueidentifier = (Select PasswordSalt from Accounts where AccountID = @ID);
  
	--Password IN = Account Pswd (8 character Hash from login form OR legacy PlainText pswd)
	--(legacy 3/8/2018)Account Pswd (8 character Hash) = Hash(password IN + AccountID)
	--(legacy 3/8/2018)Password IN (Hash) = Hash(Account Password[legacy accounts with plain text passwords] + AccountID)
	--Account Pswd (8 character Hash) = Hash(Password IN + StudentID/TeacherID/FamilyID)
	--Password IN = Hash(Password (in table) + StudentID/TeacherID/FamilyID)
	If @Password = @StrPassword COLLATE Latin1_General_CS_AS
	OR @Password = @BackupPswd COLLATE Latin1_General_CS_AS
	OR @StrPassword = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5', CONCAT(@Password,LOWER(@ID)))), 3, 8)
	OR @Password = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5', CONCAT(@StrPassword,LOWER(@ID)))), 3, 8)
	OR @Password = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5', CONCAT(@BackupPswd,LOWER(@ID)))), 3, 8)
	OR @StrPassword = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5', CONCAT(@Password,@AuthID))), 3, 8)
	OR @Password = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5', CONCAT(@StrPassword,@AuthID))), 3, 8)
	OR @Password = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5', CONCAT(@BackupPswd,@AuthID))), 3, 8)
	OR @StrPassword = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('SHA2_256', CONCAT(@Password,@Salt))), 3, 8)
	OR @Password = SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('SHA2_256', CONCAT(@StrPassword,@Salt))), 3, 8)
	Begin

	--Reset Lockout
	IF  @MissedPasswords >= 5 and @Lockout = 1		
	BEGIN
		Set @MissedPasswords = @MissedPasswords + 1
		Update Accounts WITH(UPDLOCK)
		Set MissedPasswords = @MissedPasswords
		Where AccountID = @ID
	END
	ELSE
	BEGIN
		Update Accounts WITH(UPDLOCK)
		Set MissedPasswords = 0
		Where AccountID = @ID
	END

	DECLARE @EncKey Decimal(15,15)
	IF (@ExistingEK < 0)
		SET @EncKey = Convert(dec(15,15),Rand())
	ELSE
		SET @EncKey = @ExistingEK

    Update Accounts WITH(UPDLOCK)
    Set 
		EncKey = @EncKey,
		LastLoginTime = @currentGLdatetime,
		LastClickTime = @currentGLdatetime,
		LoginSessionCount = @sessionCount,
		LastClientDeviceType = @ClientDeviceType,
		LastClientDNSname = @ClientDNSname,
		LastClientUserAgent = @ClientUserAgent
    Where AccountID = @ID

	--IF (@OAuth = @ID)
	--BEGIN
	--	UPDATE Accounts
	--	SET GoogleOauthValidated = 1
	--	Where AccountID = @ID
	--END
    
    DECLARE @currentGLdate nvarchar(30)
	SET @currentGLdate = convert(nvarchar(30), dbo.GLgetdate())
	
	DECLARE @currentGLhour nvarchar(5)
	SET @currentGLhour = (SELECT DATEPART(HOUR, dbo.GLgetdatetime()))
	
	DECLARE @currentHour nvarchar(5)
	SET @currentHour = (SELECT DATEPART(HOUR, GETDATE()))
	
	DECLARE @currentDate nvarchar(15)
	SET @currentDate = (SELECT CONVERT(nvarchar,getdate(),1))
	
	IF NOT EXISTS (SELECT Date, Hour FROM [LKG].dbo.UserAnalytics WHERE Date = @currentDate and Hour = @currentHour)
	BEGIN
		INSERT INTO [LKG].dbo.UserAnalytics ( Date, Hour ) VALUES ( @currentDate, @currentHour )		
	END
	
	IF NOT EXISTS (SELECT Date, Hour FROM UserAnalytics WHERE Date = @currentGLdate and Hour = @currentGLhour)
	BEGIN
		INSERT INTO UserAnalytics ( Date, Hour ) VALUES ( @currentGLdate, @currentGLhour )		
	END
    
    IF @ID != 'glinit'
    BEGIN
		UPDATE [LKG].dbo.UserAnalytics  WITH(UPDLOCK) 
		SET TotalCustomerLoginCount = ISNULL((SELECT TotalCustomerLoginCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
		WHERE Date = @currentDate and Hour = @currentHour
		
		UPDATE UserAnalytics WITH(UPDLOCK)
		SET TotalCustomerLoginCount = ISNULL((SELECT TotalCustomerLoginCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
		WHERE Date = @currentGLdate and Hour = @currentGLhour
	END

    If @Access = 'Principal' 
    Begin
    
		IF @ID = 'glinit'
		BEGIN
			UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK)
			SET GradelinkLoginCount = ISNULL((SELECT GradelinkLoginCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
			WHERE Date = @currentDate and Hour = @currentHour
			
			UPDATE UserAnalytics WITH(UPDLOCK)
			SET GradelinkLoginCount = ISNULL((SELECT GradelinkLoginCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
			WHERE Date = @currentGLdate and Hour = @currentGLhour
		END
		ELSE
		BEGIN
			UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK)
			SET AdministratorLoginCount = ISNULL((SELECT AdministratorLoginCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
			WHERE Date = @currentDate and Hour = @currentHour
			
			UPDATE UserAnalytics WITH(UPDLOCK)
			SET AdministratorLoginCount = ISNULL((SELECT AdministratorLoginCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
			WHERE Date = @currentGLdate and Hour = @currentGLhour
		END
    
		-- Clear InUseBy Column
		Update ClassesStudents WITH(UPDLOCK)
		Set InUseBy = null
		Where
		InUseBy =
		(
			Select top 1
			glname as TeacherName
			From
			Teachers T WITH(UPDLOCK) 
			Where AccountID = @ID
		)
		-- mfa		
		IF (Select cast(isnull(StaffMfa, 0) as bit) from Settings where SettingID = 1) = 1
		BEGIN
			Select @RequireOTP =
				Case
					When MfaValidUntilUtc IS NULL
					Then 1
					When MfaValidUntilUtc <= SYSUTCDATETIME()
					Then 1
					Else 0 -- Still Valid, no need for new OTP
				End
			from Accounts 
			where AccountID = @ID;
		END

		If @ClassCount = 1
		Begin  -- Use Hidden Init Class
		-- Send encKey to browser
			Select top 1 
				@EncKey as EncKey,
	   			ClassID,
				@ID as AccountID,
				@Access as Access,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				@RequireOTP as OneTimePass
			From Classes C inner join Terms T
			on C.TermID = T.TermID
			Order By ClassTitle
			FOR XML RAW
		End
		Else
		Begin  -- Don't Use Hidden Init Class
		-- Send encKey to browser
			Select top 1 @EncKey as EncKey,
	   			ClassID,
				@ID as AccountID,
				@Access as Access,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				@RequireOTP as OneTimePass
			From Classes C inner join Terms T
			on C.TermID = T.TermID
			Where ClassTitle != 'InitClass'
			Order By ClassTitle
			FOR XML RAW
		End

	End

    Else If @Access = 'Teacher'
    Begin
    
		UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK) 
		SET TeacherLoginCount = ISNULL((SELECT TeacherLoginCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
		WHERE Date = @currentDate and Hour = @currentHour
		
		UPDATE UserAnalytics WITH(UPDLOCK) 
		SET TeacherLoginCount = ISNULL((SELECT TeacherLoginCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
		WHERE Date = @currentGLdate and Hour = @currentGLhour

		-- Clear InUseBy Column
		Update ClassesStudents WITH(UPDLOCK) 
		Set InUseBy = null
		Where
		InUseBy =
		(
			Select top 1
			glname as TeacherName
			From
			Teachers T WITH(UPDLOCK) 
			Where AccountID = @ID
		)
		-- mfa		
		IF (Select cast(isnull(StaffMfa, 0) as bit) from Settings where SettingID = 1) = 1
		BEGIN
			Select @RequireOTP =
				Case
					When MfaValidUntilUtc IS NULL
					Then 1
					When MfaValidUntilUtc <= SYSUTCDATETIME()
					Then 1
					Else 0 -- Still Valid, no need for new OTP
				End
			from Accounts 
			where AccountID = @ID;
		END

		Declare @TeacherID int
		Set @TeacherID = (Select TeacherID From Teachers Where AccountID = @ID)

		Set @ActiveClassCount = 
		(
			Select Count(*) 
			From 
			Classes C
				inner join
			Terms TR
				on C.TermID = TR.TermID
			Where 	
			TR.Status = 1
			and
			C.Concluded = 0
			and
			C.ClassID in 
			(
				Select ClassID 
				From Classes
				Where 
				TeacherID = @TeacherID

				Union

				Select 
				ClassID 
				From TeachersClasses
				Where
				TeacherID = @TeacherID
			)		
		)
		
		if @ActiveClassCount = 0
		Begin
			-- Send encKey to browser
			Select top 1 
			@EncKey as EncKey,
			@ID as AccountID,
			@Access as Access,
			1 as ShowConcludedClasses,
			ClassID,
			@RequireOTP as OneTimePass
			From 
			Classes C 
				inner join
			[Periods] P
				on P.PeriodID = C.Period			
				inner join 
			Terms TR
				on C.TermID = TR.TermID
			Where 
			C.Concluded = 1
			and
			C.ClassID in
			(
				Select ClassID 
				From Classes
				Where 
				TeacherID = @TeacherID

				Union

				Select 
				ClassID 
				From TeachersClasses
				Where
				TeacherID = @TeacherID
			)
			Order By TR.EndDate, P.PeriodStartTime, C.ClassTitle
			FOR XML RAW
			
			--no classes found for this teacher.  The XSLT presents a message and we will log this account out
			IF @@ROWCOUNT = 0
			BEGIN
				SET @sessionCount = ISNULL((SELECT TOP(1) LoginSessionCount FROM Accounts WHERE EncKey = @EncKey), 1) - 1
				DECLARE @NewEK Decimal(19,19) = -.1

				UPDATE Accounts WITH(UPDLOCK) 
				SET 
					EncKey = @NewEK,
					LastLogOutTime = @currentGLdatetime,
					LoginSessionCount = @sessionCount
				WHERE EncKey = @EncKey
				
				UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK) 
				SET TotalCustomerLogoutCount = ISNULL((SELECT TotalCustomerLogoutCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
				WHERE Date = @currentDate and Hour = @currentHour
				
				UPDATE UserAnalytics WITH(UPDLOCK) 
				SET TotalCustomerLogoutCount = ISNULL((SELECT TotalCustomerLogoutCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
				WHERE Date = @currentGLdate and Hour = @currentGLhour
				
				UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK) 
				SET TeacherLogoutCount = ISNULL((SELECT TeacherLogoutCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
				WHERE Date = @currentDate and Hour = @currentHour
				
				UPDATE UserAnalytics WITH(UPDLOCK) 
				SET TeacherLogoutCount = ISNULL((SELECT TeacherLogoutCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
				WHERE Date = @currentGLdate and Hour = @currentGLhour
				
				if isnull(@AdminID,'') != '' -- IS NOT NULL  
				Begin
					INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
					VALUES (@AdminID + ' As ' + @ID, 'Admin', 'LOGOUT', 'ERROR: No Classes Assigned to this Teacher', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
				End
				Else
				Begin
					INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
					VALUES (@ID, @Access, 'LOGOUT', 'ERROR: No Classes Assigned to this Teacher', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
				End
				SET @FailedLogin = 1
			END

		End
		Else
		Begin
		    -- Send encKey to browser
			Select top 1 
			@EncKey as EncKey,
			@ID as AccountID,
			@Access as Access,
			0 as ShowConcludedClasses,
			ClassID,
			@RequireOTP as OneTimePass
			From 
			Classes C 
				inner join
			[Periods] P
				on P.PeriodID = C.Period			
				inner join 
			Terms TR
				on C.TermID = TR.TermID
			Where 
			C.Concluded = 0
			and
			TR.Status = 1
			and
			C.ClassID in
			(
				Select ClassID 
				From Classes
				Where 
				TeacherID = @TeacherID

				Union

				Select 
				ClassID 
				From TeachersClasses
				Where
				TeacherID = @TeacherID
			)
			Order By P.PeriodStartTime, C.ClassTitle, ExamTerm
			FOR XML RAW		    
	
		End

    End

    Else If @Access = 'Student'
    Begin
    
		UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK) SET StudentLoginCount = ISNULL((SELECT StudentLoginCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
		WHERE Date = @currentDate and Hour = @currentHour
		
		UPDATE UserAnalytics WITH(UPDLOCK) SET StudentLoginCount = ISNULL((SELECT StudentLoginCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
		WHERE Date = @currentGLdate and Hour = @currentGLhour
				
		-- mfa		
		IF (Select cast(isnull(StudentMfa, 0) as bit) from Settings where SettingID = 1) = 1
		BEGIN
			Select @RequireOTP =
				Case
					When MfaValidUntilUtc IS NULL
					Then 1
					When MfaValidUntilUtc <= SYSUTCDATETIME()
					Then 1
					Else 0 -- Still Valid, no need for new OTP
				End
			from Accounts 
			where AccountID = @ID;
		END


		Set @ActiveClassCount = 
		(	
			Select Count(*) 
			From 
			Classes C
				inner join
			Terms TR
				on C.TermID = TR.TermID
				inner join 
			ClassesStudents CS
				on CS.ClassID = C.ClassID
				inner join
			Students S
				on S.StudentID = CS.StudentID
			Where 	
				S.AccountID = @ID
				and 
				TR.Status = 1
				and
				C.Concluded = 0
		)


		if @ActiveClassCount = 0
		Begin
			
			Set @StudentClassCount =
			(
				Select COUNT(*)
				From 
				Students S
					inner join 
				ClassesStudents CS
					on S.StudentID = CS.StudentID
				Where
				S.AccountID =  @ID
			)
			
			If @StudentClassCount > 0 and @AllowParentsToViewPastGrades = 1
			Begin
			
				-- Send encKey to browser
				Select top 1 
					@EncKey as EncKey,
					C.ClassID,
					@ID as AccountID,
					S.StudentID as StudentID,
					@Access as Access,
					@ClientIPaddress as ClientIPaddress,
					@ClientDNSname as ClientDNSname,
					case
						when @AllowParentsToViewPastGrades = 0 
						then 0
						else 1
					end as ShowConcludedClasses,
					@RequireOTP as OneTimePass
				From 
				Classes C 
					inner join
				[Periods] P
					on P.PeriodID = C.Period
					inner join 
				ClassesStudents CS
				on CS.ClassID = C.ClassID inner join Students S
				on S.StudentID = CS.StudentID inner join Accounts A
				on S.AccountID = A.AccountID inner join Terms TR
				on C.TermID = TR.TermID
				where S.AccountID = @ID 
				--and C.Concluded = 1 Commented out 1/12/2017 
				--prevented a student from logging in. remove in a year if no issues MF DP
				Order By P.PeriodStartTime
				FOR XML RAW
			
			End
			Else
			Begin
		
				-- Send encKey to browser
				Select top 1 
					@EncKey as EncKey,
					@ID as AccountID,
					StudentID as StudentID,
					@Access as Access,
					@ClientIPaddress as ClientIPaddress,
					@ClientDNSname as ClientDNSname,
					@RequireOTP as OneTimePass
				From Students
				where AccountID = @ID
				FOR XML RAW				
				
			End

		End
		Else
		Begin
	
	    -- Send encKey to browser
	    Select top 1 
			@EncKey as EncKey,
		   	 C.ClassID,
			 @ID as AccountID,
			 S.StudentID as StudentID,
			 @Access as Access,
			 0 as ShowConcludedClasses,
			 @ClientIPaddress as ClientIPaddress,
			 @ClientDNSname as ClientDNSname,
			@RequireOTP as OneTimePass
	    From 
	    Classes C 
			inner join
		[Periods] P
			on P.PeriodID = C.Period	    
			inner join 
		ClassesStudents CS
		on CS.ClassID = C.ClassID inner join Students S
		on S.StudentID = CS.StudentID inner join Accounts A
		on S.AccountID = A.AccountID inner join Terms TR
	    on C.TermID = TR.TermID
	    where S.AccountID = @ID and TR.Status = 1 and C.Concluded = 0
	    Order By P.PeriodStartTime
	    FOR XML RAW
	
		End

    End

    Else if @Access = 'Family' or @Access = 'Family2'
    Begin

		UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK) 
		SET StudentLoginCount = ISNULL((SELECT StudentLoginCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
		WHERE Date = @currentDate and Hour = @currentHour
		
		UPDATE UserAnalytics WITH(UPDLOCK) 
		SET StudentLoginCount = ISNULL((SELECT StudentLoginCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
		WHERE Date = @currentGLdate and Hour = @currentGLhour
							
							
		Set @ActiveClassCount =
		(					
			Select COUNT(*)
			From 
			Classes C 
				inner join 
			ClassesStudents CS
				on CS.ClassID = C.ClassID 
				inner join 
			Students S
				on S.StudentID = CS.StudentID 
				inner join 
			Terms TR
				on C.TermID = TR.TermID
				inner join
			Families F
				on	F.FamilyID = S.FamilyID
					or
					F.FamilyID = S.Family2ID
			Where 
			F.AccountID = @ID 
			and 
			TR.Status = 1 
			and 
			C.Concluded = 0	
		)						
					
		-- mfa		
		IF (Select cast(isnull(StudentMfa, 0) as bit) from Settings where SettingID = 1) = 1
		BEGIN
			Select @RequireOTP =
				Case
					When MfaValidUntilUtc IS NULL
					Then 1
					When MfaValidUntilUtc <= SYSUTCDATETIME()
					Then 1
					Else 0 -- Still Valid, no need for new OTP
				End
			from Accounts 
			where AccountID = @ID;
		END

		if @ActiveClassCount = 0
		Begin

			
			Set @StudentClassCount =
			(
				Select COUNT(*)
				From 
				Students S
					inner join 
				ClassesStudents CS
					on S.StudentID = CS.StudentID
					inner join
				Families F
					on	F.FamilyID = S.FamilyID
						or
						F.FamilyID = S.Family2ID					
				Where
				F.AccountID = @ID 
			)
			
			If @StudentClassCount > 0 and @AllowParentsToViewPastGrades = 1
			Begin
				-- Send encKey to browser
				Select top 1 
				@EncKey as EncKey,
				C.ClassID,
				@ID as AccountID,
				S.StudentID as StudentID,
				@Access as Access,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				@RequireOTP as OneTimePass,
				case 
					when @AllowParentsToViewPastGrades = 0 
					then 0
					else 1
				end as ShowConcludedClasses
				From 
				Classes C 
					inner join
				[Periods] P
					on P.PeriodID = C.Period				
					inner join 
				ClassesStudents CS
					on CS.ClassID = C.ClassID 
					inner join 
				Students S
					on S.StudentID = CS.StudentID 
					inner join 
				Terms TR
					on C.TermID = TR.TermID
					inner join
				Families F
					on	F.FamilyID = S.FamilyID
						or
						F.FamilyID = S.Family2ID
				Where 
				F.AccountID = @ID 
				and 
				C.Concluded = 1
				Order By S.Fname, P.PeriodStartTime
				FOR XML RAW			
				
			End
			-- else -- Replaced with negation of 'if' condition plus
			--         @@ROWCOUNT test to allow less restrictive login query to
			--         return a valid @EncKey even if query above produces no results.
			-- Fresh Desk #59488. 6/23/17 Duke
			If (@StudentClassCount <= 0 or @AllowParentsToViewPastGrades <> 1)
				or @@ROWCOUNT = 0
			Begin
				
				-- Send encKey to browser
				Select top 1 
					@EncKey as EncKey,
					@ID as AccountID,
					S.StudentID as StudentID,
					@Access as Access,
					@ClientIPaddress as ClientIPaddress,
					@ClientDNSname as ClientDNSname,
					@RequireOTP as OneTimePass
				From 
				Students S
					inner join
				Families F
					on	F.FamilyID = S.FamilyID
						or
						F.FamilyID = S.Family2ID
				Where 
				F.AccountID = @ID 
				Order By S.Fname
				FOR XML RAW							
				
			End

		End
		Else
		Begin

			-- Send encKey to browser
			Select top 1 
				@EncKey as EncKey,
				C.ClassID,
				@ID as AccountID,
				S.StudentID as StudentID,
				@Access as Access,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				0 as ShowConcludedClasses,
				@RequireOTP as OneTimePass
			From 
			Classes C 
				inner join
			[Periods] P
				on P.PeriodID = C.Period			
				inner join 
			ClassesStudents CS
				on CS.ClassID = C.ClassID 
				inner join 
			Students S
				on S.StudentID = CS.StudentID 
				inner join 
			Terms TR
				on C.TermID = TR.TermID
				inner join
			Families F
				on	F.FamilyID = S.FamilyID
					or
					F.FamilyID = S.Family2ID
			Where 
			F.AccountID = @ID 
			and 
			TR.Status = 1 
			and 
			C.Concluded = 0
			Order By S.Fname, P.PeriodStartTime
			FOR XML RAW
			
		End
		
	End

    Else if @Access = 'Admin'
    Begin
    
		UPDATE [LKG].dbo.UserAnalytics WITH(UPDLOCK) 
		SET AdminLimitedLoginCount = ISNULL((SELECT AdminLimitedLoginCount FROM [LKG].dbo.UserAnalytics WITH(UPDLOCK) WHERE Date = @currentDate and Hour = @currentHour), 0) + 1
		WHERE Date = @currentDate and Hour = @currentHour
	
		UPDATE UserAnalytics WITH(UPDLOCK) 
		SET AdminLimitedLoginCount = ISNULL((SELECT AdminLimitedLoginCount FROM UserAnalytics WITH(UPDLOCK) WHERE Date = @currentGLdate and Hour = @currentGLhour), 0) + 1
		WHERE Date = @currentGLdate and Hour = @currentGLhour

		-- Clear InUseBy Column
		Update ClassesStudents WITH(UPDLOCK) 
		Set InUseBy = null
		Where
		InUseBy =
		(
			Select top 1
			glname as TeacherName
			From
			Teachers T WITH(UPDLOCK) 
			Where AccountID = @ID
		)

		-- mfa		
		IF (Select cast(isnull(StaffMfa, 0) as bit) from Settings where SettingID = 1) = 1
		BEGIN
			Select @RequireOTP =
				Case
					When MfaValidUntilUtc IS NULL
					Then 1
					When MfaValidUntilUtc <= SYSUTCDATETIME()
					Then 1
					Else 0 -- Still Valid, no need for new OTP
				End
			from Accounts 
			where AccountID = @ID;
		END

		If @ClassCount = 1
		Begin  -- Use Hidden Init Class
			-- Send encKey to browser
			Select top 1 @EncKey as EncKey,
	   			ClassID,
				@ID as AccountID,
				@Access as Access,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				@RequireOTP as OneTimePass
			From Classes C inner join Terms T
			on C.TermID = T.TermID
			Order By ClassTitle
			FOR XML RAW
		End
		Else
		Begin  -- Don't Use Hidden Init Class
			-- Send encKey to browser
			Select top 1 @EncKey as EncKey,
	   			ClassID,
				@ID as AccountID,
				@Access as Access,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				@RequireOTP as OneTimePass
			From Classes C inner join Terms T
			on C.TermID = T.TermID
			Where ClassTitle != 'InitClass'
			Order By ClassTitle
			FOR XML RAW
		End

	End

	End
	Else
	Begin
		--
		Set @MissedPasswords = @MissedPasswords + 1

		Update Accounts WITH(UPDLOCK) 
		Set MissedPasswords = @MissedPasswords
		Where AccountID = @ID

		If @MissedPasswords > 4    	-- Lockout Threshhold
		Begin
			Update Accounts WITH(UPDLOCK) 
			Set Lockout = 1
			Where AccountID = @ID

			if isnull(@AdminID,'') != '' -- IS NOT NULL  
			Begin
				INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
				VALUES (@AdminID + ' As ' + @ID, 'Admin', 'LOGIN', 'FAIL: Exceeded Password Lockout Threshold', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
			End
			Else
			Begin
				INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
				VALUES (@ID, @Access, 'LOGIN', 'FAIL: Exceeded Password Lockout Threshold', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
			End

			Select 
				6 as EncKey,
	  			SchoolName,
				SchoolPhone,
				SchoolContact,
				SchoolEmailAddress,
				SchoolWebSite,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				CAST(0 as bit) as OneTimePass
			From Settings where SettingID = 1 
			FOR XML RAW
			SET @FailedLogin = 1
		End
		else
		Begin
			--password does not match
			if isnull(@AdminID,'') != '' -- IS NOT NULL  
			Begin
				INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
				VALUES (@AdminID + ' As ' + @ID, 'Admin', 'LOGIN', 'FAIL: Wrong Password', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
			End
			Else
			Begin
				INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
				VALUES (@ID, @Access, 'LOGIN', 'FAIL: Wrong Password', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount-1, @ClientUserAgent, @ClientDNSname)
			End
			--
			Select 
				2 as EncKey,
	  			SchoolName,
				SchoolPhone,
				SchoolContact,
				SchoolEmailAddress,
				SchoolWebSite,
				@ClientIPaddress as ClientIPaddress,
				@ClientDNSname as ClientDNSname,
				CAST(0 as bit) as OneTimePass
			From Settings where SettingID = 1 
			FOR XML RAW
			SET @FailedLogin = 1
		End
	
	End
End

if @FailedLogin = 0
BEGIN
	if isnull(@AdminID,'') != ''  -- IS NOT NULL  
	Begin
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
		VALUES (@AdminID + ' As ' + @ID,'Admin', 'LOGIN', 'SUCCESS', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount, @ClientUserAgent, @ClientDNSname)					End
	Else
	Begin
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
		VALUES (@ID, @Access, 'LOGIN', 'SUCCESS', @currentGLdatetime, @ClientIPaddress, @ClientDeviceType, @EncKey, @sessionCount, @ClientUserAgent, @ClientDNSname)
	End
END
GO
