SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- =============================================
-- Author:		Don Puls
-- Create date: 6/16/2015
-- Description:	Given a date for the first of the month it will return the days of that 
-- including the overlapping days for the previous and next month.  The main use for 
-- this is to creat a month calendar view.   
-- =============================================
CREATE FUNCTION [dbo].[GetMonthDates]
(
	@SelectedDate date
)
RETURNS 
@MonthDates table
(
	monthOrder tinyint,
	theDate date,
	theDay tinyint,
	theWeekday nvarchar(10)
)
AS
BEGIN
	Declare @PreviousMonth date = dateadd(month, -1, @SelectedDate)
	Declare @NextMonth date = dateadd(month, 1, @SelectedDate)
	Declare @ThisMonthFirstWeekDayDiff int = datepart(weekday, @SelectedDate) - 1
	Declare @CurrentDate int = 0
	Declare @NextMonthCurrentDate int = 1
	Declare @DateIncrement int = 0
	Declare @NumberDaysThisMonth int = datediff(day, dateadd(day, 1-day(@SelectedDate), @SelectedDate), dateadd(month, 1, dateadd(day, 1-day(@SelectedDate), @SelectedDate)))
	Declare @NumberDaysPreviousMonth int = datediff(day, dateadd(day, 1-day(@PreviousMonth), @PreviousMonth), dateadd(month, 1, dateadd(day, 1-day(@PreviousMonth), @PreviousMonth)))
	Declare @PreviousMonthStartDateNumber int = @NumberDaysPreviousMonth + 1 - @ThisMonthFirstWeekDayDiff
	Declare @PreviousMonthStartDate date = dateadd(day, (@PreviousMonthStartDateNumber -1), @PreviousMonth)
	Declare @PreviousMonthCurrentDate int = @PreviousMonthStartDateNumber
	Declare @LastDateofThisMonth date = dateadd(day, (@NumberDaysThisMonth -1), @SelectedDate)
	Declare @ThisMonthLastWeekDayDiff int = 7 - datepart(weekday, @LastDateofThisMonth)
	Declare @DaysThisMonth table (theDay tinyint identity(1,1), theWeekday nvarchar(10), theDate date)
	Declare @DaysPreviousMonth table (theDay tinyint, theWeekday nvarchar(10), theDate date)
	Declare @DaysNextMonth table (theDay tinyint, theWeekday nvarchar(10), theDate date)

	While @CurrentDate < @NumberDaysThisMonth
	Begin
		insert into @DaysThisMonth
		Select 
		DATENAME(weekday, DATEADD(day, @DateIncrement, @SelectedDate)),
		DATEADD(day, @DateIncrement, @SelectedDate)
		Set @CurrentDate = SCOPE_IDENTITY()
		Set @DateIncrement = @DateIncrement + 1
	End

	if @ThisMonthFirstWeekDayDiff > 0
	Set @DateIncrement = 0
	While @PreviousMonthCurrentDate <= @NumberDaysPreviousMonth
	Begin
		insert into @DaysPreviousMonth
		Select 
		@PreviousMonthCurrentDate,
		DATENAME(weekday, DATEADD(day, @DateIncrement, @PreviousMonthStartDate)),
		DATEADD(day, @DateIncrement, @PreviousMonthStartDate)
		Set @PreviousMonthCurrentDate = @PreviousMonthCurrentDate + 1
		Set @DateIncrement = @DateIncrement + 1
	End

	if @ThisMonthLastWeekDayDiff > 0
	Set @DateIncrement = 0
	While @NextMonthCurrentDate <= @ThisMonthLastWeekDayDiff
	Begin
		insert into @DaysNextMonth
		Select 
		@NextMonthCurrentDate,
		DATENAME(weekday, DATEADD(day, @DateIncrement, @NextMonth)),
		DATEADD(day, @DateIncrement, @NextMonth)
		Set @NextMonthCurrentDate = @NextMonthCurrentDate + 1
		Set @DateIncrement = @DateIncrement + 1
	End
	
	insert into @MonthDates
	Select 1 as monthOrder, theDate, theDay, theWeekday From @DaysPreviousMonth
	Union
	Select 2 as monthOrder, theDate, theDay, theWeekday From @DaysThisMonth
	Union
	Select 3 as monthOrder, theDate, theDay, theWeekday From @DaysNextMonth
	RETURN
END


/*
--Example 1
Select *
From 
dbo.GetMonthDates('2015-06-01')


--Example 2 using with data from another table where the other table has only one record per date
Select M.*, A.AssignmentTitle, A.ClassID
From 
dbo.GetMonthDates('2015-06-01') M
	left join
Assignments A
	on M.theDate = A.DueDate
and
ClassID = 2098


--Example 2 using with data from another table where the other table has multiple records per date so 
--we separate the data by 
Select M.*,
(
SELECT Stuff(
  (SELECT N', ' + AssignmentTitle From Assignments Where DueDate = M.theDate FOR XML PATH(''),TYPE)
  .value('text()[1]','nvarchar(max)'),1,2,N'')
)
From 
dbo.GetMonthDates('2015-06-01') M



*/



GO
