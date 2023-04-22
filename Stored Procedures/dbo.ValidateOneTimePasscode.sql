SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 09/14/2021
-- Modified dt: 11/01/2021
-- Description:	Validate One Time Passcode
-- =============================================
CREATE     PROCEDURE [dbo].[ValidateOneTimePasscode]
@AccountId nvarchar(100),
@Otp nvarchar(10)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @MinsActive int;
	Declare @HoursAuth int;
	Declare @OtpCount int;
	Declare @Match bit;
	Declare @Active bit;
	--
	Select 
		@MinsActive = isnull(OtpActiveMins, 10),
		@HoursAuth = isnull(MfaValidHours, 240)
	From Settings
	Where SettingID = 1;
	--
	Select 
		@OtpCount = isnull(OtpCount, 0) + 1, -- include this try
		@Match = 
			Case 
				When isnull(Otp, '') = @Otp
				Then 1
				Else 0
			End,
		@Active = 
			Case 
				When OtpUtc IS NULL 
				Then 0
				When (SYSUTCDATETIME() >= OtpUtc) AND (SYSUTCDATETIME() <= DATEADD(MI, @MinsActive, OtpUtc))
				Then 1
				Else 0
			End
	From Accounts 
	Where AccountID = @AccountID;
	--
	IF @Match = 1 AND @Active = 1 AND @OtpCount <= 5
	BEGIN
		-- success log
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
		Select 
			AccountID,
			Access,
			'MFA',
			'SUCCESS',
			CONVERT(nvarchar(30), dbo.GLgetdatetime(), 9),
			LastLoginIPaddress,
			LastClientDeviceType,
			EncKey,
			LoginSessionCount,
			LastClientUserAgent,
			LastClientDNSname
		from Accounts
		Where AccountID = @AccountID;
		-- set valid until
		Update Accounts
		Set OtpCount = null,
			Otp = null,
			OtpUtc = null,
			MfaValidUntilUtc = DATEADD(HH, @HoursAuth, SYSUTCDATETIME())
		Where AccountID = @AccountID;
		-- return true
		select CAST(1 as bit);
	END
	ELSE IF @OtpCount >= 5
	BEGIN
		-- lock out log
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
		Select 
			AccountID,
			Access,
			'MFA',
			'LOCK',
			CONVERT(nvarchar(30), dbo.GLgetdatetime(), 9),
			LastLoginIPaddress,
			LastClientDeviceType,
			EncKey,
			LoginSessionCount,
			LastClientUserAgent,
			LastClientDNSname
		from Accounts
		Where AccountID = @AccountID;
		-- Lock Account
		Update Accounts
		Set OtpCount = @OtpCount,
			MfaValidUntilUtc = null,
			Lockout = 1
		Where AccountID = @AccountID;
		-- return null
		select null;
	END
	ELSE
	BEGIN
		-- fail log
		INSERT INTO AccountsActivityLog (AccountID, AccessType, Activity, Response, DateTime, IPaddress, DeviceType, EncKey, LoginSessionCount, ClientUserAgent, ClientDNSname)
		Select 
			AccountID,
			Access,
			'MFA',
			'FAIL',
			CONVERT(nvarchar(30), dbo.GLgetdatetime(), 9),
			LastLoginIPaddress,
			LastClientDeviceType,
			EncKey,
			LoginSessionCount,
			LastClientUserAgent,
			LastClientDNSname
		from Accounts
		Where AccountID = @AccountID;
		-- increment otp count
		Update Accounts
		Set OtpCount = @OtpCount
		Where AccountID = @AccountID;
		-- return false
		Select CAST(0 as bit);
	END
END
GO
