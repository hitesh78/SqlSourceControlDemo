SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



-- =============================================
-- Author:		Don Puls
-- Create date: 6/16/2015
-- Description:	Given a year and weeknumber it will return the days of that week 
-- =============================================
CREATE FUNCTION [dbo].[GetWeekDates]
(
	@YearNum nchar(4),
	@WeekNum int
)
RETURNS 
@WeekDates table
(
	theDate date,
	theWeekDay nvarchar(12)
)
AS
BEGIN
Declare @StartDate date = (Select DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNum-1), 6));
Declare @EndDate date = (Select DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNum-1), 5));


WITH WeekDates AS (
  SELECT 
  @StartDate  AS theDate,
  DATENAME(dw,@StartDate) as theWeekDay
  UNION ALL
  SELECT 
  DATEADD(dd, 1, theDate),
  DATENAME(dw,DATEADD(dd, 1, theDate))
  FROM WeekDates s
  WHERE DATEADD(dd, 1, theDate) <= @EndDate)
insert into @WeekDates
SELECT * 
FROM WeekDates
Return
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
