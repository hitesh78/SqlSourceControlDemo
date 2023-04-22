SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ============================================= 
-- Author:		Don Puls
-- Create date: 6/21/2021
-- Modified dt: 6/28/2021
-- Description:	Returns List of edfi Instructional day Dates
-- =============================================
Create    FUNCTION [dbo].[getEdFiInstructionalDayDates]
(
	@CalendarStartDate date,
	@CalendarEndDate date
)
RETURNS @InstructionalDayDates TABLE (theDate date)
AS

Begin
	Insert into @InstructionalDayDates
	Select
	N.TheDate
	From 
	NonSchoolDays N
		left join 
	EdFiCalendarEvents CE
		on N.EventID = CE.EventID
		left join
	EdFiEventTypes	ET
		on CE.EventTypeID = ET.EventTypeID
	Where
	ET.EventType = 'Instructional day'
	and
	TheDate is not null
	and
	TheDate between @CalendarStartDate and @CalendarEndDate

	Declare @NonSchoolDateRanges table (ID int identity(1,1), StartDate date, EndDate date)
	Insert into @NonSchoolDateRanges
	Select
	StartDate,
	EndDate
	From 
	NonSchoolDays N
		left join 
	EdFiCalendarEvents CE
		on N.EventID = CE.EventID
		left join
	EdFiEventTypes	ET
		on CE.EventTypeID = ET.EventTypeID
	Where
	ET.EventType = 'Instructional day'
	and
	StartDate >= @CalendarStartDate
	and
	EndDate <= @CalendarEndDate;


	Declare @NumLines int = @@RowCount
	Declare @LineNumber int = 1
	Declare @StartDate date
	Declare @EndDate date

	While @LineNumber <= @NumLines
	Begin
		Select
		@StartDate =  DATEADD(DAY,-1,StartDate),
		@EndDate = EndDate
		From @NonSchoolDateRanges
		Where ID = @LineNumber

		Insert into @InstructionalDayDates
		SELECT DATEADD(DAY,number+1,@StartDate) [Date]
		FROM master..spt_values
		WHERE type = 'P'
		AND DATEADD(DAY,number+1,@StartDate) <= @EndDate

		Set @LineNumber = @LineNumber + 1
	End
	
	RETURN 	
End

GO
