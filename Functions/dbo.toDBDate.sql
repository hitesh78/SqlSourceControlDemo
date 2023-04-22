SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[toDBDate]
(
@StringDate nvarchar(12)
)
RETURNS datetime
AS
BEGIN

	-- Get TimeZone/DateFormat/DST Settings
	Declare @DateFormat nvarchar(12) = (Select DateFormat From Settings Where SettingID = 1)
	Declare @DBDate datetime
	
	Set @DBDate = 
	case
		when @StringDate = 'mm/dd/yy' or @StringDate = 'dd/mm/yy' or LEN(@StringDate)<8 then null
		when isnumeric(substring(@StringDate,1,4))=1 then CAST(@StringDate as datetime) -- SQL interprets yyyy-mm-dd by default
		when @DateFormat = 'dd/mm/yy' then CONVERT(datetime, @StringDate, 103)
		else CONVERT(datetime, @StringDate, 101)	-- 'mm/dd/yy' format
	end
	
	RETURN @DBDate
  
END
GO
