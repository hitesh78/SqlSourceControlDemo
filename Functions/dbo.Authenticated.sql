SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Authenticated]
	(	@AuthID bigint,
		@EK decimal(15,15) )
RETURNS bit
AS
BEGIN
	Declare @IsAuthenticated bit
	Declare @EncKeys table (EncKey Decimal(15,15))
	Declare @Access nvarchar(15)
	Declare @ClassID int = abs(@AuthID%1000000000)
	Declare @LanguageType varchar(30)
	Declare @AdminDefaultLanguage varchar(30)
	
	Insert into @EncKeys
	Select EncKey
	From 
	Accounts A 
		inner join 
	Teachers T
		on T.AccountID = A.AccountID 
	Where
	TeacherID in 
	(
		Select TeacherID 
		From TeachersClasses 
		Where ClassID = @ClassID
		Union
		Select TeacherID 
		From Classes 
		Where ClassID = @ClassID
	)

	--
	-- Save user and admin default language settings into
	-- session scoped context name-value settings that may be
	-- extracted via, e.g. "SESSION_CONTEXT(N'AdminLanguage')"
	--
	Select @Access=Access, @LanguageType=isnull(LanguageType,'English') 
	from Accounts 
	where EncKey = @EK;
	EXEC sp_set_session_context N'UserLanguage', @LanguageType;
	--
	Select top 1 @AdminDefaultLanguage=isnull(AdminDefaultLanguage,'English') 
	From Settings
	EXEC sp_set_session_context N'AdminLanguage', @AdminDefaultLanguage;

	If (exists (Select EncKey From @EncKeys Where EncKey = @EK) and @EK != -.1) or (@Access = 'Principal' and @EK != -.1) or (@Access = 'Admin' and @EK != -.1)
	Begin
		set @IsAuthenticated = 1
	End
	Else
	Begin
		set @IsAuthenticated = 0
	End

	RETURN (@IsAuthenticated)
END
GO
