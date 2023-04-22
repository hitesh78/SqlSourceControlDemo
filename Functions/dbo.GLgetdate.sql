SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GLgetdate]()
RETURNS nchar(10)
AS
BEGIN

	-- Get TimeZone/DateFormat/DST Settings
	Declare 
	@TimeZone nvarchar(50),
	@TimeZoneOffset int,
	@DateFormat nvarchar(12),
	@EnableDaylightSavingsTime bit,
	@DSTStartDate date,
	@DSTEndDate date

	Select
	@TimeZone = TimeZone,
	@TimeZoneOffset = TimeZoneOffset,
	@DateFormat = DateFormat,
	@EnableDaylightSavingsTime = EnableDaylightSavingsTime,
	@DSTStartDate = DSTStartDate,
	@DSTEndDate = DSTEndDate
	From Settings Where SettingID = 1


	-- Get Time in specified TimeZone
	Declare @TimeInSpecifiedTimeZone datetime
	Set @TimeInSpecifiedTimeZone = (SELECT SWITCHOFFSET(TODATETIMEOFFSET(SYSUTCDATETIME(), '+00:00'), @TimeZoneOffset))


	-- Apply Daylight Savings Time if enabled
	If @EnableDaylightSavingsTime = 1
	Begin
		
		-- get month and day  
		Declare 
		@DSTStartMonth int = DATEPART(mm, @DSTStartDate),
		@DSTStartDay int = DATEPART(dd, @DSTStartDate),
		@DSTEndMonth int = DATEPART(mm, @DSTEndDate),
		@DSTEndDay int = DATEPART(dd, @DSTEndDate),
		@CurrentMonth int = DATEPART(mm, @TimeInSpecifiedTimeZone),
		@DSTStartYear int = DATEPART(yy, @TimeInSpecifiedTimeZone),	-- Set to current year
		@DSTEndYear int = DATEPART(yy, @TimeInSpecifiedTimeZone)	-- Set to current year
		
		
		If @DSTStartMonth > @DSTEndMonth	-- If DST date range spans multiple years
		Begin
		
			If @CurrentMonth < @DSTStartMonth
			Begin
				Set @DSTStartYear = @DSTStartYear - 1
			End
			Else
			Begin
				Set @DSTEndYear = @DSTEndYear + 1
			End

		End
		
		-- check for leap year and adjust day dates as needed
		If @DSTEndMonth = 2 and @DSTEndDay = 29 and ISDATE(CAST(@DSTEndYear AS nchar(4)) + '0229') != 1
		Begin
			Set @DSTEndDay = 28;
		End
		
		If @DSTStartMonth = 2 and @DSTStartDay = 29 and ISDATE(CAST(@DSTStartYear AS nchar(4)) + '0229') != 1
		Begin
			Set @DSTStartDay = 28;
		End	

		Declare @CurrentDSTStartDate date = convert(nchar(4), @DSTStartYear) + '-' + convert(nchar(2), @DSTStartMonth) + '-' + convert(nchar(2), @DSTStartDay)
		--Select @CurrentDSTStartDate as CurrentDSTStartDate
 		
		Declare @CurrentDSTEndDate date = convert(nchar(4), @DSTEndYear) + '-' + convert(nchar(2), @DSTEndMonth) + '-' + convert(nchar(2), @DSTEndDay)
		--Select @CurrentDSTEndDate as CurrentDSTEndDate
		
		
		
		if convert(date, @TimeInSpecifiedTimeZone) between @CurrentDSTStartDate and DATEADD(dd, 1, @CurrentDSTEndDate)
		Begin
			Set @TimeInSpecifiedTimeZone =  DATEADD(hh,1,@TimeInSpecifiedTimeZone)
		End
	End


  RETURN 
  	case
		when @DateFormat = 'mm/dd/yy' then CONVERT(nVARCHAR(10), @TimeInSpecifiedTimeZone, 101)
		when @DateFormat = 'dd/mm/yy' then CONVERT(nVARCHAR(10), @TimeInSpecifiedTimeZone, 103)
	end
  
END

GO
