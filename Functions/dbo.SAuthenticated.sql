SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[SAuthenticated]
(	@StudentID int,
	@EK decimal(15,15) )
RETURNS bit
AS
BEGIN

	Declare @IsAuthenticated bit
	Declare @FamilyID int = (Select FamilyID From Students Where StudentID = @StudentID)
	Declare @Family2ID int = (Select Family2ID From Students Where StudentID = @StudentID)
	Declare @StudentAccountsHaveParentAccess bit = (Select StudentAccountsHaveParentAccess From Settings Where SettingID = 1)
	Declare @LanguageType varchar(30)
	Declare @AdminDefaultLanguage varchar(30)

    Select @LanguageType = isnull(LanguageType,'English')
    From 
    Accounts
    Where
    EncKey = @EK 
    and 
    EncKey != -.1
    and
    EncKey is not null
    and
    AccountID in 
    (
        Select AccountID 
        From Students 
        Where 
        case 
            when @StudentAccountsHaveParentAccess = 0 and StudentID = @StudentID then 1
            when @StudentAccountsHaveParentAccess = 1 and FamilyID = @FamilyID then 1
            else 0
        end = 1
        Union
        Select AccountID
        From Families
        Where
        FamilyID = @FamilyID
        or
        FamilyID = @Family2ID
    )

	IF @LanguageType IS NOT NULL -- i.e. If NULLL then no user found by ID & EK
	Begin
		set @IsAuthenticated = 1
	End
	Else
	Begin
		set @IsAuthenticated = 0 
	End

    --
    -- Save user and admin default language settings into
    -- session scoped context name-value settings that may be
    -- extracted via, e.g. "SESSION_CONTEXT(N'AdminLanguage')"
    --
    EXEC sp_set_session_context N'UserLanguage', @LanguageType;
    --
    Select top 1 @AdminDefaultLanguage=isnull(AdminDefaultLanguage,'English') 
    From Settings
    EXEC sp_set_session_context N'AdminLanguage', @AdminDefaultLanguage;

    RETURN (@IsAuthenticated)
END



GO
