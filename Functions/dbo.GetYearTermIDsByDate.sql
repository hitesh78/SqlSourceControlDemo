SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--The following funciton returns the TermIDs for the schoolyear that the passed ClassID is in 

CREATE FUNCTION [dbo].[GetYearTermIDsByDate]
(
	@TheDate date
)
RETURNS 
@TermIDs table
(
	TermID int
)
AS
BEGIN

	Declare @SchoolStartMonth int
	Declare @SchoolEndMonth int
	Declare @YearStartDate date
	Declare @YearEndDate date


	Select
	@SchoolStartMonth = SchoolStartMonth,
	@SchoolEndMonth = SchoolEndMonth
	From Settings 
	Where SettingID = 1



	-- Get StartMonth - going back from the @TheDate till we reach the Start Month
	If MONTH(@TheDate) >= @SchoolStartMonth or MONTH(@TheDate) > @SchoolEndMonth -- Added or statement to fix schools running in summer time and showing previous year terms
	Begin
		Set @YearStartDate = convert(nchar(4),YEAR(@TheDate)) + '-' + convert(nvarchar(2),@SchoolStartMonth) + '-1'
	End
	Else
	Begin
		Set @YearStartDate = convert(nchar(4),YEAR(@TheDate)-1) + '-' + convert(nvarchar(2),@SchoolStartMonth) + '-1'
	End


	-- Get EndMoth - going forward from the @TheDate till we reach the End Month
	-- Adds 1 to the end month to get the next month since the day value will always be 1
	-- and then later we just filter terms that are < then this date rather than <= the actual last day of the 
	-- last day of the real end month.
	If MONTH(@TheDate) <= @SchoolEndMonth
	Begin

		/*
		* Additions on 10/21/2013 by Andy Skupen.
		* When a school sets their school year's end month to December,
		* the first branch of the following if statement returns a month of 13.
		* So, the other branch was added to advance the school year's end date
		* to January 1 of the following year.
		*/

		If @SchoolEndMonth < 12
			Set @YearEndDate = convert(nchar(4),YEAR(@TheDate)) + '-' + convert(nvarchar(2),@SchoolEndMonth+1) + '-1';
		Else
			Set @YearEndDate = convert(char(4), Year(@TheDate) + 1) + '-1-1';

		/* 
		* End of Additions on 10/21/2013 by Andy Skupen.
		*/

	End
	Else
	Begin
		Set @YearEndDate = convert(nchar(4),YEAR(@TheDate)+1) + '-' + convert(nvarchar(2),@SchoolEndMonth+1) + '-1'
	End

	Insert into @TermIDs
	Select TermID 
	From Terms
	Where 
	StartDate >= @YearStartDate
	and
	EndDate < @YearEndDate
	and
	TermTitle not like '%Sum%'
	

	RETURN
	
END


GO
