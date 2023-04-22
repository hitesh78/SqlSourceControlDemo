SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Skupen
-- Create date: 05/14/2013
-- Description:	This function will return a legend string for printing at the bottom of an attendance sheet.
-- =============================================
CREATE FUNCTION [dbo].[GetAttendanceLegend] 
(
	-- Add the parameters for the function here
	@ClassTypeID int
)
RETURNS NVarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ReportLegend NVarchar(MAX)

	-- Here are some other variables we will need.
	Declare @Att1Legend nvarchar(10)
	Declare @Att2Legend nvarchar(10)
	Declare @Att3Legend nvarchar(10)
	Declare @Att4Legend nvarchar(10)
	Declare @Att5Legend nvarchar(10)
	Declare @Att6Legend nvarchar(10)
	Declare @Att7Legend nvarchar(10)
	Declare @Att8Legend nvarchar(10)
	Declare @Att9Legend nvarchar(10)
	Declare @Att10Legend nvarchar(10)
	Declare @Att11Legend nvarchar(10)
	Declare @Att12Legend nvarchar(10)
	Declare @Att13Legend nvarchar(10)
	Declare @Att14Legend nvarchar(10)
	Declare @Att15Legend nvarchar(10)

	Declare @Att1FullTitle nvarchar(50)
	Declare @Att2FullTitle nvarchar(50)
	Declare @Att3FullTitle nvarchar(50)
	Declare @Att4FullTitle nvarchar(50)
	Declare @Att5FullTitle nvarchar(50)
	Declare @Att6FullTitle nvarchar(50)
	Declare @Att7FullTitle nvarchar(50)
	Declare @Att8FullTitle nvarchar(50)
	Declare @Att9FullTitle nvarchar(50)
	Declare @Att10FullTitle nvarchar(50)
	Declare @Att11FullTitle nvarchar(50)
	Declare @Att12FullTitle nvarchar(50)
	Declare @Att13FullTitle nvarchar(50)
	Declare @Att14FullTitle nvarchar(50)
	Declare @Att15FullTitle nvarchar(50)

	-- Now we want to start formatting the report legend.
	If @ClassTypeID = 5
	Begin
	Select @Att1Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att1'
	Select @Att2Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att2'
	Select @Att3Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att3'
	Select @Att4Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att4'
	Select @Att5Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att5'
	Select @Att6Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att6'
	Select @Att7Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att7'
	Select @Att8Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att8'
	Select @Att9Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att9'
	Select @Att10Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att10'
	Select @Att11Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att11'
	Select @Att12Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att12'
	Select @Att13Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att13'
	Select @Att14Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att14'
	Select @Att15Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att15'

	Select @Att1FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att1'
	Select @Att2FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att2'
	Select @Att3FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att3'
	Select @Att4FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att4'
	Select @Att5FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att5'
	Select @Att6FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att6'
	Select @Att7FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att7'
	Select @Att8FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att8'
	Select @Att9FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att9'
	Select @Att10FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att10'
	Select @Att11FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att11'
	Select @Att12FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att12'
	Select @Att13FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att13'
	Select @Att14FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att14'
	Select @Att15FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att15'	
	End
	Else
	Begin
		Select 
		@Att1FullTitle = rtrim(Attendance1),
		@Att1Legend = '(' + Attendance1Legend + ')',
		@Att2FullTitle = rtrim(Attendance2),
		@Att2Legend = '(' + Attendance2Legend + ')',
		@Att3FullTitle = rtrim(Attendance3),
		@Att3Legend = '(' + Attendance3Legend + ')',
		@Att4FullTitle = rtrim(Attendance4),
		@Att4Legend = '(' + Attendance4Legend + ')',
		@Att5FullTitle = rtrim(Attendance5),
		@Att5Legend = '(' + Attendance5Legend + ')'
		From Settings 
		Where SettingID = 1
	End



	-- Add the T-SQL statements to compute the return value here
	Set @ReportLegend = ''

	if @Att1FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att1FullTitle + '=' + @Att1Legend
	End
	if @Att2FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att2FullTitle + '=' + @Att2Legend
	End
	if @Att3FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att3FullTitle + '=' + @Att3Legend
	End
	if @Att4FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att4FullTitle + '=' + @Att4Legend
	End
	if @Att5FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att5FullTitle + '=' + @Att5Legend
	End
	if @Att6FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att6FullTitle + '=' + @Att6Legend
	End
	if @Att7FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att7FullTitle + '=' + @Att7Legend
	End
	if @Att8FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att8FullTitle + '=' + @Att8Legend
	End
	if @Att9FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att9FullTitle + '=' + @Att9Legend
	End
	if @Att10FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att10FullTitle + '=' + @Att10Legend
	End
	if @Att11FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att11FullTitle + '=' + @Att11Legend
	End
	if @Att12FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att12FullTitle + '=' + @Att12Legend
	End
	if @Att13FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att13FullTitle + '=' + @Att13Legend
	End
	if @Att14FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att14FullTitle + '=' + @Att14Legend
	End
	if @Att15FullTitle != ''
	Begin
		Set @ReportLegend = @ReportLegend + ' ' + @Att15FullTitle + '=' + @Att15Legend
	End


	-- Return the result of the function
	RETURN @ReportLegend

END

GO
