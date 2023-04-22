SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: December 5th, 2017 (edit 06/24/2021 JG)
-- Description:	Removes invalid SQLXML character from string to prevent the following error:
-- SQLXML: error loading XML result (An invalid character was found in text content.)
-- =============================================
CREATE FUNCTION [dbo].[RemoveInvalidSQLXMLCharacters]
(
	-- Add the parameters for the function here
	@stringToClean nvarchar(max)
)
RETURNS nvarchar(max)
AS
BEGIN
	---- Declare the return variable here
	--DECLARE <@ResultVar, sysname, @Result> <Function_Data_Type, ,int>

	---- Add the T-SQL statements to compute the return value here
	--SELECT <@ResultVar, sysname, @Result> = <@Param1, sysname, @p1>

	-- Return the result of the function
	RETURN 
	REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( 
	REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( 
	REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( 
	REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( 
	REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( 
	REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( 
	REPLACE(
		@stringToClean
	,char(0x0000),'') ,char(0x0001),'') ,char(0x0002),'') ,char(0x0003),'') ,char(0x0004),'') 
	,char(0x0005),'') ,char(0x0006),'') ,char(0x0007),'') ,char(0x0008),'') ,char(0x000B),'') 
	,char(0x000C),'') ,char(0x000E),'') ,char(0x000F),'') ,char(0x0010),'') ,char(0x0011),'') 
	,char(0x0012),'') ,char(0x0013),'') ,char(0x0014),'') ,char(0x0015),'') ,char(0x0016),'') 
	,char(0x0017),'') ,char(0x0018),'') ,char(0x0019),'') ,char(0x001A),'') ,char(0x001B),'') 
	,char(0x001C),'') ,char(0x001D),'') ,char(0x001E),'') ,char(0x001F),'') ,char(16),'') 
	,char(0x00A0),'')

END


/*
The following character was being stripped out and it resulted in the following support ticket: FD 350341
So I removed this filter.  I tested this on the Progress report and report card in the term comments section 
and this character didn't present any issues.  if we have issues with this character we should try and filter out 
of that specific area where there is a problem versus in the function. - dp 11/4/2020 

 ,char(0x00C2),'')



*/
GO
