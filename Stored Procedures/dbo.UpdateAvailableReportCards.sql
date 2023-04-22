SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[UpdateAvailableReportCards] 

@INFO nvarchar(4000)
AS

Declare @StrLength int
Declare @StartPosition int
Declare @EndPosition int
Declare @ReportCardID int
Declare @ShowReportCard bit
Declare @TeachersCanRun bit
Declare @DisplayName nvarchar(150)


While (LEN(@INFO) > 0)
Begin

	--Get ReportCardID
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @ReportCardID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ShowReportCard
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @ShowReportCard = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get TeachersCanRun
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @TeachersCanRun = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get DisplayName
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @DisplayName = SUBSTRING (@INFO, 1, @EndPosition)
	--Set @DisplayName = replace(@DisplayName, '=PercentageSymbol=', '%')  -- Translate =PercentageSymbol= back to %
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)


	Update AvailableReportCards
	Set ShowReportCard = @ShowReportCard,
		TeachersCanRun = @TeachersCanRun,
		DisplayName = @DisplayName
	Where ReportCardID = @ReportCardID

END



Print 'File 18 completed'

GO
