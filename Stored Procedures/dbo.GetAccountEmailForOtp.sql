SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 9/16/2021
-- Modified dt: 10/4/2021
-- Description:	Get Account Email For Otp
-- =============================================
CREATE     PROCEDURE [dbo].[GetAccountEmailForOtp]
@AccountId nvarchar(100),
@Otp nvarchar(10)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @Email nvarchar(100);
    Declare @Access nvarchar(10);
	Declare @Otp_Orig nvarchar(10);
	Declare @OtpCount int;
	Declare @OtpUtc datetime2;
	Declare @MinsActive int;
	Declare @AdultSchool bit;
	--
	Select 
		@MinsActive = isnull(OtpActiveMins, 10),
		@AdultSchool = AdultSchool
	From Settings 
	Where SettingID = 1;
	--
	Select 
		@Access = Access,
		@OtpCount = OtpCount,
		@OtpUtc = OtpUtc,
		@Otp_Orig = Otp
	From Accounts 
	Where AccountID = @AccountID;
	--
    If @Access = 'Student'
    Begin
		If @AdultSchool = 1
		Begin
			Select
				@Email = isnull(ltrim(rtrim(Coalesce(S.Email1, S.Email2, S.Email3))),'')
			From Students S
			Where AccountID = @AccountID
				and (isnull(ltrim(rtrim(S.Email1)),'') LIKE '%_@%_.__%' 
					or isnull(ltrim(rtrim(S.Email2)),'') LIKE '%_@%_.__%'
					or isnull(ltrim(rtrim(S.Email3)),'') LIKE '%_@%_.__%');
		End
		Else
		Begin
			Select
				@Email = isnull(ltrim(rtrim(Coalesce(S.Email8, S.SchoolEmail))),'')
			From Students S
			Where AccountID = @AccountID
				and (isnull(ltrim(rtrim(S.Email8)),'') LIKE '%_@%_.__%' 
					or isnull(ltrim(rtrim(S.SchoolEmail)),'') LIKE '%_@%_.__%');
		End
	End
    Else If @Access = 'Family'
    Begin
	    Select top 1
		    @Email = isnull(ltrim(rtrim(Coalesce(S.Email1, S.Email2))),'')
	    From Students S
		    inner join Families F
		    on F.FamilyID = S.FamilyID
	    Where F.AccountID = @AccountID
		    and (isnull(ltrim(rtrim(S.Email1)),'') LIKE '%_@%_.__%' 
		        or isnull(ltrim(rtrim(S.Email2)),'') LIKE '%_@%_.__%');
    End
    Else If @Access = 'Family2'
    Begin
	    Select top 1
		    @Email = isnull(ltrim(rtrim(Coalesce(S.Email6, S.Email7))),'')
	    From Students S
		    inner join Families F
		    on F.FamilyID = S.Family2ID
	    Where F.AccountID = @AccountID
		    and (isnull(ltrim(rtrim(S.Email6)),'') LIKE '%_@%_.__%' 
		        or isnull(ltrim(rtrim(S.Email7)),'') LIKE '%_@%_.__%');
    End
    Else
    Begin
        Select
		    @Email = isnull(ltrim(rtrim(Coalesce(Email, Email2, Email3))),'')
        From Teachers
        Where AccountID = @AccountID
		    and (isnull(ltrim(rtrim(Email)),'') LIKE '%_@%_.__%'
		        or isnull(ltrim(rtrim(Email2)),'') LIKE '%_@%_.__%'
		        or isnull(ltrim(rtrim(Email3)),'') LIKE '%_@%_.__%');
    End
	--
	IF isnull(@Email, '') <> ''
	BEGIN
		IF @OtpUtc IS NULL OR DATEADD(MI, @MinsActive, @OtpUtc) < SYSUTCDATETIME()
		BEGIN -- set new otp			
			Update Accounts
			Set Otp = @Otp,
				OtpCount = 0,
				OtpUtc = SYSUTCDATETIME(),
				MfaValidUntilUtc = null
			Where AccountID = @AccountID;
		END
		ELSE -- use orig otp
		BEGIN
			SET @Otp = @Otp_Orig;
		END
	END
	--
	Select @Email as Email, @Otp as Otp, @MinsActive as MinsActive;
	--
END
GO
