SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[GLformatdate]
(
@Date date
)
RETURNS nchar(10)
AS
BEGIN

	-- Get TimeZone/DateFormat/DST Settings
	Declare @DateFormat nvarchar(12) = (Select DateFormat From Settings Where SettingID = 1)
	
	RETURN
	case @DateFormat
		when 'dd/mm/yy' then CONVERT(nvarchar(10), @Date, 103)
		else CONVERT(nvarchar(10), @Date, 101)	-- 'mm/dd/yy' format
	end
  
END



GO
