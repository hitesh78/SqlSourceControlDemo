SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/20/2016
-- Description:	Returns List of Non-School Dates
-- =============================================
CREATE FUNCTION [dbo].[getNonSchoolDates]()
RETURNS @NonSchoolDates TABLE (theDate date)
AS

Begin
	Insert into @NonSchoolDates
	Select
	TheDate
	From NonSchoolDays
	Where
	TheDate is not null

	Declare @NonSchoolDateRanges table (ID int identity(1,1), StartDate date, EndDate date)
	Insert into @NonSchoolDateRanges
	Select
	StartDate,
	EndDate
	From NonSchoolDays
	Where
	StartDate is not null 
	and
	EndDate is not null

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

		Insert into @NonSchoolDates
		SELECT DATEADD(DAY,number+1,@StartDate) [Date]
		FROM master..spt_values
		WHERE type = 'P'
		AND DATEADD(DAY,number+1,@StartDate) <= @EndDate

		Set @LineNumber = @LineNumber + 1
	End
	
	RETURN 	
End

GO
