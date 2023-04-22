SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/18/2022
-- Description:	Returns List of Non-School Dates plus the Non-School Date Description
-- =============================================
Create   FUNCTION [dbo].[getNonSchoolDates2]()
RETURNS @NonSchoolDates TABLE (theDate date, theDescription nvarchar(100))
AS

Begin
	Insert into @NonSchoolDates
	Select
	TheDate,
	[Description]
	From NonSchoolDays
	Where
	TheDate is not null

	Declare @NonSchoolDateRanges table (ID int identity(1,1), StartDate date, EndDate date, theDescription nvarchar(100))
	Insert into @NonSchoolDateRanges
	Select
	StartDate,
	EndDate,
	[Description]
	From NonSchoolDays
	Where
	StartDate is not null 
	and
	EndDate is not null

	Declare @NumLines int = @@RowCount
	Declare @LineNumber int = 1
	Declare @StartDate date
	Declare @EndDate date
	Declare @Description nvarchar(100)

	While @LineNumber <= @NumLines
	Begin
		Select
		@StartDate =  DATEADD(DAY,-1,StartDate),
		@EndDate = EndDate,
		@Description = theDescription
		From @NonSchoolDateRanges
		Where ID = @LineNumber

		Insert into @NonSchoolDates
		SELECT 
		DATEADD(DAY,number+1,@StartDate) as [Date],
		@Description 
		FROM master..spt_values
		WHERE type = 'P'
		AND DATEADD(DAY,number+1,@StartDate) <= @EndDate

		Set @LineNumber = @LineNumber + 1
	End
	
	RETURN 	
End

GO
