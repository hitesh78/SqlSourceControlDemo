SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[AddNonSchoolDaysAttendance]
	@DateID int,
	@ClassID int
as

Begin

	Declare @TheDate date
	Declare @StartDate date
	Declare @EndDate date
	Declare @AttendanceSymbol nvarchar(5)

	Select 
	@TheDate = TheDate,
	@StartDate = StartDate,
	@EndDate = EndDate,
	@AttendanceSymbol = AttendanceSymbol
	From dbo.NonSchoolDays
	Where
	DateID = @DateID
	
	-- Set Attendance Values
	Declare
	@Att1 int,
	@Att2 int,
	@Att3 int,
	@Att4 int,
	@Att5 int,
	@Att6 int,
	@Att7 int,
	@Att8 int,
	@Att9 int,
	@Att10 int,
	@Att11 int,
	@Att12 int,
	@Att13 int,
	@Att14 int,
	@Att15 int
	
	-- Initialize all values to zero 
	Select
	@Att1 = 0,
	@Att2 = 0,
	@Att3 = 0,
	@Att4 = 0,
	@Att5 = 0,
	@Att6 = 0,
	@Att7 = 0,
	@Att8 = 0,
	@Att9 = 0,
	@Att10 = 0,
	@Att11 = 0,
	@Att12 = 0,
	@Att13 = 0,
	@Att14 = 0,
	@Att15 = 0
	
	
	
	-- Figure out which attendance we are adding
	Declare @AttnID nvarchar(5)
	Set @AttnID = (Select top 1 ID From AttendanceSettings Where ReportLegend = @AttendanceSymbol)

	
	-- Set the attendance value to 1 for the attendance we are updating
	If @AttnID = 'Att1'
	Begin
		Set @Att1 = 1
	End
	If @AttnID = 'Att2'
	Begin
		Set @Att2 = 1
	End
	If @AttnID = 'Att3'
	Begin
		Set @Att3 = 1
	End
	If @AttnID = 'Att4'
	Begin
		Set @Att4 = 1
	End
	If @AttnID = 'Att5'
	Begin
		Set @Att5 = 1
	End
	If @AttnID = 'Att6'
	Begin
		Set @Att6 = 1
	End
	If @AttnID = 'Att7'
	Begin
		Set @Att7 = 1
	End
	If @AttnID = 'Att8'
	Begin
		Set @Att8 = 1
	End
	If @AttnID = 'Att9'
	Begin
		Set @Att9 = 1
	End
	If @AttnID = 'Att10'
	Begin
		Set @Att10 = 1
	End
	If @AttnID = 'Att11'
	Begin
		Set @Att11 = 1
	End
	If @AttnID = 'Att12'
	Begin
		Set @Att12 = 1
	End
	If @AttnID = 'Att13'
	Begin
		Set @Att13 = 1
	End
	If @AttnID = 'Att14'
	Begin
		Set @Att14 = 1
	End
	If @AttnID = 'Att15'
	Begin
		Set @Att15 = 1
	End
		 

	Declare @TheStartDateRange date
	Declare @TheEndDateRange date
	Declare @TheStartDateRangeDeleted date
	Declare @TheEndDateRangeDeleted date
	
	If @TheDate is null
	Begin
		Set @TheStartDateRange = @StartDate
		Set @TheEndDateRange = @EndDate
	End
	Else
	Begin
		Set @TheStartDateRange = @TheDate
		Set @TheEndDateRange = @TheDate	
	End
	
	
	Declare @CurrentDate date
	Declare @TheCSID int
	
	Set @CurrentDate = @TheStartDateRange
	
	
	-- Create temp table to hold dates
	Create table #tmpDates (TheDate date)

	-- Create temp table to hold CSIDs
	Create table #tmpCSIDs (CSID int)

	-- Go through each Date within the Date or DateRange 
	WHILE @CurrentDate <= @TheEndDateRange
	BEGIN 
		-- Only Add for valid School Weekdays
		if datename(weekday, @CurrentDate) in 
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
		Begin	

			-- Get all the CSIDs for the date into a temp table
			Insert into #tmpCSIDs(CSID)
			Select CS.CSID
			From 
			ClassesStudents CS
				inner join
			Classes C
				on C.ClassID = CS.ClassID
				inner join
			Terms T
				on C.TermID = T.TermID
			Where
			C.ClassTypeID = 5
			and
			T.ExamTerm = 0
			and
			@CurrentDate between T.StartDate and T.EndDate
			and
			CS.CSID not in (Select CSID From Attendance Where ClassDate between @CurrentDate and @TheEndDateRange)
			and
			(
			case	
				when @ClassID = -1 then 1
				when @ClassID = C.ClassID then 1
				else 0
			end) = 1

			While (Select count(*) From #tmpCSIDs) > 0
			Begin
				Set @TheCSID = (Select top 1 CSID From #tmpCSIDs)
				
				insert into Attendance
				(
				ClassDate, 
				CSID,
				Att1,
				Att2,
				Att3,
				Att4,
				Att5,
				Att6,
				Att7,
				Att8,
				Att9,
				Att10,
				Att11,
				Att12,
				Att13,
				Att14,
				Att15
				)
				values
				(
				@CurrentDate,
				@TheCSID,
				@Att1,
				@Att2,
				@Att3,
				@Att4,
				@Att5,
				@Att6,
				@Att7,
				@Att8,
				@Att9,
				@Att10,
				@Att11,
				@Att12,
				@Att13,
				@Att14,
				@Att15
				)					
			
				Delete From #tmpCSIDs Where CSID = @TheCSID
			
			End  -- While
			 

		End -- Exclude Weekends
		SET @CurrentDate = dateadd(day , 1, @CurrentDate )

	END	-- While


End


GO
