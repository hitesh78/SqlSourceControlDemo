SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- =============================================
-- Author:		Don Puls
-- Create date: 4/21/2021
-- Description:	returns all the school dates within a specified Start and End Date 
--				Excludes NonSchool Days and Weekdays that the school does not meet on  
-- =============================================
Create FUNCTION [dbo].[getSchoolDates]
(
	@StartDate date,
	@EndDate date
)
RETURNS TABLE AS
 RETURN


	Select
	theDate
	From
	dbo.GetDates(@StartDate, @EndDate)
	Where
	datename(weekday, theDate) in 
		(
			Select * From dbo.SplitCSVStrings
			(
					(
					Select
					case when AttSunday = 1 then 'Sunday,' else '' end + 
					case when AttMonday = 1 then 'Monday,' else '' end +
					case when AttTuesday = 1 then 'Tuesday,' else '' end +
					case when AttWednesday = 1 then 'Wednesday,' else '' end +
					case when AttThursday = 1 then 'Thursday,' else '' end +
					case when AttFriday = 1 then 'Friday,' else '' end +
					case when AttSaturday = 1 then 'Saturday' else '' end as weekdays
					From Settings
					Where SettingID = 1
					)			
			)
		
		)	
	and
	theDate not in (Select * From dbo.getNonSchoolDates())
GO
