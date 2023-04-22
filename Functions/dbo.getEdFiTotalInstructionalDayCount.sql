SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ============================================= 
-- Author:		Joey
-- Create date: 7/01/2021
-- Modified dt: 7/01/2021
-- Description:	Returns count of edfi Instructional days
-- =============================================
Create    FUNCTION [dbo].[getEdFiTotalInstructionalDayCount]
(
	@CalendarStartDate date,
	@CalendarEndDate date
)
RETURNS int
AS
Begin
	
	Declare @InstructionalDayDateCount int;
	
	Declare @InstructionalDayDates table (theDate date);
	
	Insert into @InstructionalDayDates	
	SELECT 
		theDate
	From dbo.getSchoolDates(@CalendarStartDate, @CalendarEndDate)

	-- add Instructional Day dates added to Non-school Days
	insert into @InstructionalDayDates
	SELECT 
		theDate
	From dbo.getEdFiInstructionalDayDates(@CalendarStartDate, @CalendarEndDate);
	
	Select @InstructionalDayDateCount = COUNT(theDate) From @InstructionalDayDates;

	RETURN @InstructionalDayDateCount;
End

GO
