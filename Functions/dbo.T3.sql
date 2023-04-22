SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Don Puls
-- Create date: 8/16/2018
-- Description:	Temporary dummy function that just returns passed in value
-- This will go away or be replaced eventually it will be used by a few 
-- outstanding SQL scripts that may be performanced impacted the t() function
-- number as parameters and returns the translation
/*
@EK = 0.0 uses AdminDefaultLanguage
@EK = -0.1 uses TeacherDefaultLanguage
@EK = -0.2 uses StudentDefaultLanguage
Otherwise it will attempt to get the Users set language
*/
-- =============================================
Create FUNCTION [dbo].[T3]
(
	-- Add the parameters for the function here
	@EK decimal(15,15),
	@source_text varchar(500)
)
RETURNS nvarchar(500)   
AS
BEGIN

return @source_text

END

GO
