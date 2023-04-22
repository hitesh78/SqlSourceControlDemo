SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 5/22/2018
-- Description:	Returns a translation given source_text and @LanguageType
-- This is needed for a SQL trigger on Settings table OnUpdateDefaultStudentLanguage
--
-- 10/19/2018 - Scope of application may expand now as I've added the 'User' and 'Admin'
--              LanguageType parameter options.... - Duke
/*
@LanguageType = 0.0 uses AdminDefaultLanguage
*/

/*
--
-- TEST CASES:
--

-- Set ID to a logged in StudentID for these tests...
declare @ID bigint = 1004;
declare @EK decimal(15,15) = (select EncKey from Accounts where AccountID = '1004')
select @EK

SELECT	
		SESSION_CONTEXT(N'UserLanguage'),
		SESSION_CONTEXT(N'AdminLanguage')

select dbo.SAuthenticated(@ID,@EK) 

SELECT	
		SESSION_CONTEXT(N'UserLanguage'),
		SESSION_CONTEXT(N'AdminLanguage')

select dbo.T2(N'Spanish','Hours')

select dbo.T2(N'Chinese','Hours')

select dbo.T2(N'User','Hours')

select dbo.T2(N'Admin','Hours')

*/

-- =============================================
CREATE FUNCTION [dbo].[T2]
(
	-- Add the parameters for the function here
	@LanguageType nvarchar(30),
	@source_text varchar(500)
)
RETURNS nvarchar(500)   
AS
BEGIN

declare @form_id int = 3931

declare @Language nvarchar(30) = 
	CASE @LanguageType
		WHEN N'User' THEN CAST(SESSION_CONTEXT(N'UserLanguage') as nvarchar(30))
		WHEN N'Admin' THEN CAST(SESSION_CONTEXT(N'AdminLanguage') as nvarchar(30))
		ELSE @LanguageType 
	END;
	
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
	l.language = @Language
	AND 
	tt.deprecated is null
	AND 
	st.source_text = @source_text)
,@source_text) 

END
GO
