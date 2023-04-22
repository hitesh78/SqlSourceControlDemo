SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Don Puls
-- Create date: 5/22/2017
-- Description:	Takes source_text, EK, and optional instance 
-- number as parameters and returns the translation
/*
@EK = 0.0 uses AdminDefaultLanguage
@EK = -0.1 uses TeacherDefaultLanguage
@EK = -0.2 uses StudentDefaultLanguage
Otherwise it will attempt to get the Users set language
*/
-- =============================================
CREATE FUNCTION [dbo].[T]
(
	-- Add the parameters for the function here
	@EK decimal(15,15),
	@source_text varchar(500)
)
RETURNS nvarchar(500)   
AS
BEGIN

declare @form_id int = 3931
--declare @ID nvarchar(50)

declare @AccountID nvarchar(50)
declare @Access nvarchar(10)
declare @LanguageType nvarchar(30)


-- get default languages 
Declare @StudentDefaultLanguage nvarchar(50) = (Select StudentDefaultLanguage From Settings);
Declare @TeacherDefaultLanguage nvarchar(50) = (Select TeacherDefaultLanguage From Settings);
Declare @AdminDefaultLanguage nvarchar(50) = (Select AdminDefaultLanguage From Settings);

if @EK = 0.0  set @LanguageType = @AdminDefaultLanguage;
else if @EK = -0.1  set @LanguageType = @TeacherDefaultLanguage;
else if @EK = -0.2  set @LanguageType = @StudentDefaultLanguage;
else
Begin
	--
	-- Determine target language based on user account or defaults settings...
	--
	; with Acct as (
		Select 
			isnull(AccountID,'') AccountID, 
			isnull(Access,'') Access, 
			isnull(LanguageType,'') LanguageType 
		From (values (1)) as dummy(a) left join Accounts 
		on (Cast(EncKey as float) = Cast(@EK as float) 
			AND Cast(@EK as float)<>-.1 ) -- EK of -.1 is flag to search ID instead of EK
	--    or (Cast(@EK as float)=-.1 AND Accounts.AccountID = @ID)
	)
	Select @AccountID = AccountID, @Access = Access,
		@LanguageType = CASE 
			WHEN isnull(LanguageType,'') = ''
				-- Flag to search ID instead of EK for ROLE default rather than user language setting
				OR Cast(@EK as float)=-.1
			THEN
				CASE
					WHEN Access = 'Student' OR Access = 'Family' OR Access = 'Family2' THEN @StudentDefaultLanguage
					WHEN Access = 'Teacher'	THEN @TeacherDefaultLanguage
					ELSE @AdminDefaultLanguage
				END
			ELSE
				LanguageType
		END 
	From Acct
End

--
-- Get translation based on @LanguageType, @Form_id, and @source_text
--
return ISNULL((
	SELECT tt.translated_text

	FROM LKG.dbo.i18n_source_text st 
	INNER JOIN LKG.dbo.i18n_translated_text tt 
	ON tt.source_text_id = st.source_text_id

	INNER JOIN LKG.dbo.i18n_form_text ft
	ON st.source_text_id = ft.source_text_id
	AND ( ft.instance_number = tt.instance_number or ft.instance_number = -1)
	AND ft.deprecated is null

	INNER JOIN LKG.dbo.i18n_forms f
	ON  -- all source text on current form
		f.form_id = ft.form_id
		AND f.form_id = @form_id

	INNER JOIN LKG.dbo.i18n_languages l
	ON l.language_id = tt.language_id

	WHERE 
	l.language = @LanguageType
	AND 
	tt.deprecated is null
	AND 
	st.source_text = @source_text)
,@source_text) 

END

GO
