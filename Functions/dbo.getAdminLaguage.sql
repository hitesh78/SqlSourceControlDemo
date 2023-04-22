SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 9-11-2018
-- Description:	Just retrieves Admin Laguage - used for SQL Computed column glName in Students table
-- =============================================
CREATE FUNCTION [dbo].[getAdminLaguage] ()
RETURNS nvarchar(30)
AS
Begin
	RETURN (select AdminDefaultLanguage From Settings);
End

GO
