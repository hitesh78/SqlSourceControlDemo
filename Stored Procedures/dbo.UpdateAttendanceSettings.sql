SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[UpdateAttendanceSettings] 
@INFO nvarchar(2000)

AS

Declare @StrLength int
Declare @StartPosition int
Declare @EndPosition int
Declare @ID nvarchar(10)
Declare @Title nvarchar(50)
Declare @AbbrTitle nvarchar(50)
Declare @ReportLegend nvarchar(10)
Declare @ReportTitle nvarchar(50)
Declare @ShowOnReportCard nvarchar(10)
Declare @MultiSelect nvarchar(10)
Declare @PresentValue decimal(3,2)
Declare @AbsentValue decimal(3,2)
Declare @ExcludedAttendance nvarchar(10)
Declare @LunchValue nvarchar(10)
Declare @edfiEventValue int


Declare @SchoolID nvarchar(20) = (Select SchoolID From Settings);
Declare @enableEdfiDataExchange bit = 
(
	Select [Enabled] From LKG.dbo.glSchoolServices
	Where
	SchoolID = @SchoolID
	and 
	ServiceID = 31
);	

While (LEN(@INFO) > 0)
Begin

	--Get ID
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Title
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Title = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Abbreviated Title
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @AbbrTitle = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Report Legend
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ReportLegend = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ReportTitle
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ReportTitle = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ShowOnReportCard
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ShowOnReportCard = SUBSTRING (@INFO, 1, @EndPosition)
	if @ShowOnReportCard = 'true'
	Begin
		Set @ShowOnReportCard = 1
	End
	Else
	Begin
		Set @ShowOnReportCard = 0
	End
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get MultiSelect
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @MultiSelect = SUBSTRING (@INFO, 1, @EndPosition)
	if @MultiSelect = 'true'
	Begin
		Set @MultiSelect = 1
	End
	Else
	Begin
		Set @MultiSelect = 0
	End
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get PresentValue
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @PresentValue = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get AbsentValue
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @AbsentValue = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Excluded Attendance
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ExcludedAttendance = SUBSTRING (@INFO, 1, @EndPosition)
	if @ExcludedAttendance = 'true'
	Begin
		Set @ExcludedAttendance = 1
	End
	Else
	Begin
		Set @ExcludedAttendance = 0
	End	
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Lunch Value
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @LunchValue = SUBSTRING (@INFO, 1, @EndPosition)
	if @LunchValue = 'true'
	Begin
		Set @LunchValue = 1;
	End
	Else
	Begin
		Set @LunchValue = 0;
	End;
	Set @StrLength = LEN(@INFO);
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength);

	if (@enableEdfiDataExchange = 1)
	Begin
		--Get edfiEventValue
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1;
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1;
		Set @edfiEventValue = SUBSTRING (@INFO, 1, @EndPosition);
		if @edfiEventValue = -1 
		begin
			set @edfiEventValue  = null;
		end;
		Set @StrLength = LEN(@INFO);
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength);
	End;



	Update AttendanceSettings
	Set 
		Title = rtrim(@Title),
		AbbrTitle = rtrim(@AbbrTitle),
		ReportLegend = rtrim(@ReportLegend),
		ReportTitle = rtrim(@ReportTitle),
		ShowOnReportCard = @ShowOnReportCard,
		MultiSelect = @MultiSelect,
		PresentValue = @PresentValue,
		AbsentValue = @AbsentValue,
		ExcludedAttendance = @ExcludedAttendance,
		LunchValue = @LunchValue,
		edfiAttendanceEventID = @edfiEventValue
	Where ID = @ID

END









--************************** File Seperator ****************************
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

GO
