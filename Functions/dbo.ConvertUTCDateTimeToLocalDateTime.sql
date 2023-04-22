SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls/Joey
-- Create date: 05/07/2020
-- Modified dt: 11/03/2022
-- Description:	Takes a given UTC datetime and converts it to a school's local datetime 
--   This was needed for the Google Classroom integration. APIGoogleClassroom.cs file
-- Rev. Notes:	change logic to handle when eval date is not the same DST type as now
-- =============================================
CREATE   FUNCTION [dbo].[ConvertUTCDateTimeToLocalDateTime]
(
	@UTCDateTimeToConvert datetime
)
RETURNS datetime
AS
BEGIN
/*declare @UTCDateTimeToConvert datetime = '11/17/2022 21:11:00' --'11/03/2022 20:11:00';*/
	Declare 
		@TimeZoneOffset int,
		@DSTStartDate date,
		@DSTEndDate date,
		@GlDate datetime,
		@result datetime;

	Select
		@TimeZoneOffset = TimeZoneOffset,
		@DSTStartDate = DSTStartDate,
		@DSTEndDate = DSTEndDate,
		@GlDate = dbo.GLgetdatetime()
	From Settings 
	Where SettingID = 1;

	IF @UTCDateTimeToConvert BETWEEN @DSTStartDate and @DSTEndDate AND @GlDate BETWEEN @DSTStartDate and @DSTEndDate
	BEGIN
		--PRINT '1';
		set @result = dateadd(n, datediff(n, GETUTCDATE(), @GlDate), @UTCDateTimeToConvert);
	END
	ELSE IF @UTCDateTimeToConvert NOT BETWEEN @DSTStartDate and @DSTEndDate AND @GlDate NOT BETWEEN @DSTStartDate and @DSTEndDate
	BEGIN
		--PRINT '2';
		set @result = dateadd(n, datediff(n, GETUTCDATE(), @GlDate), @UTCDateTimeToConvert);
	END
	ELSE IF @UTCDateTimeToConvert BETWEEN @DSTStartDate and @DSTEndDate AND @GlDate NOT BETWEEN @DSTStartDate and @DSTEndDate
	BEGIN
		--PRINT '3';
		set @result = DATEADD(HH, IIF(@TimeZoneOffset <= 0, 1, -1), dateadd(n, datediff(n, GETUTCDATE(), @GlDate), @UTCDateTimeToConvert));
	END
	ELSE IF @UTCDateTimeToConvert NOT BETWEEN @DSTStartDate and @DSTEndDate AND @GlDate BETWEEN @DSTStartDate and @DSTEndDate
	BEGIN
		--PRINT '4';
		set @result = DATEADD(HH, IIF(@TimeZoneOffset <= 0, -1, 1), dateadd(n, datediff(n, GETUTCDATE(), @GlDate), @UTCDateTimeToConvert));
	END

	return @result
END
GO
