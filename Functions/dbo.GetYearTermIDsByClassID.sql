SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--The following funciton returns the TermIDs for the schoolyear that the passed ClassID is in 

CREATE FUNCTION [dbo].[GetYearTermIDsByClassID]
(
	@ClassID int
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
	Declare @MidDate date
	Declare @YearStartDate date
	Declare @YearEndDate date


	Select
	@SchoolStartMonth = SchoolStartMonth,
	@SchoolEndMonth = SchoolEndMonth
	From Settings 
	Where SettingID = 1


	-- Get Mid-Date of the ClassTerm - this should be a safe date 
	-- encase the configured dates are slightly off
	Select 
	@MidDate = (DateAdd(day, (DATEDIFF(day, StartDate, EndDate)/2), StartDate))
	From Terms
	Where TermID = (Select TermID From Classes Where ClassID = @ClassID)


	-- Get StartMonth - going back from the Mid-Date till we reach the Start Month
	If MONTH(@MidDate) >= @SchoolStartMonth
	Begin
		Set @YearStartDate = convert(nchar(4),YEAR(@MidDate)) + '-' + convert(nvarchar(2),@SchoolStartMonth) + '-1'
	End
	Else
	Begin
		Set @YearStartDate = convert(nchar(4),YEAR(@MidDate)-1) + '-' + convert(nvarchar(2),@SchoolStartMonth) + '-1'
	End


	-- Get EndMoth - going forward from the Mid-Date till we reach the End Month
	-- Adds 1 to the end month to get the next month since the day value will always be 1
	-- and then later we just filter terms that are < then this date rather than <= the actual last day of the 
	-- last day of the real end month.
	If MONTH(@MidDate) <= @SchoolEndMonth
	Begin
		if @SchoolEndMonth = 12 set @SchoolEndMonth = 11	-- add so month doesn't go to 13 is SchoolEndMonth is December
		Set @YearEndDate = convert(nchar(4),YEAR(@MidDate)) + '-' + convert(nvarchar(2),@SchoolEndMonth+1) + '-1'
	End
	Else
	Begin
		if @SchoolEndMonth = 12 set @SchoolEndMonth = 11	-- add so month doesn't go to 13 is SchoolEndMonth is December
		Set @YearEndDate = convert(nchar(4),YEAR(@MidDate)+1) + '-' + convert(nvarchar(2),@SchoolEndMonth+1) + '-1'
	End

	Insert into @TermIDs
	Select TermID 
	From Terms
	Where 
	StartDate >= @YearStartDate
	and
	EndDate < @YearEndDate
	and
	ExamTerm = 0
	and
	TermID not in (Select ParentTermID From Terms)
	and
	TermTitle not like '%Sum%'	

	RETURN
	
END





GO
