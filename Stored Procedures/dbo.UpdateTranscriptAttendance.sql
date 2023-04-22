SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[UpdateTranscriptAttendance] 
@INFO nvarchar(4000), 
@ClassTypeID int

AS


Declare @EndPosition int
Declare @StrLength int
Declare @StartPosition int
Declare @TranscriptID int
Declare @Att1 decimal(5,2)
Declare @Att2 decimal(5,2)
Declare @Att3 decimal(5,2)
Declare @Att4 decimal(5,2)
Declare @Att5 decimal(5,2)
Declare @Att6 decimal(5,2)
Declare @Att7 decimal(5,2)
Declare @Att8 decimal(5,2)
Declare @Att9 decimal(5,2)
Declare @Att10 decimal(5,2)
Declare @Att11 decimal(5,2)
Declare @Att12 decimal(5,2)
Declare @Att13 decimal(5,2)
Declare @Att14 decimal(5,2)
Declare @Att15 decimal(5,2)
Declare @ChurchPresent decimal(5,2)
Declare @ChurchAbsent decimal(5,2)
Declare @SSchoolPresent decimal(5,2)
Declare @SSchoolAbsent decimal(5,2)
Declare @SchoolTotalDays decimal(5,2)
Declare @ChurchTotalDays decimal(5,2)
Declare @SSchoolTotalDays decimal(5,2)


Set @Att1 = 0
Set @Att2 = 0
Set @Att3 = 0
Set @Att4 = 0
Set @Att5 = 0
Set @Att6 = 0
Set @Att7 = 0
Set @Att8 = 0
Set @Att9 = 0
Set @Att10 = 0
Set @Att11 = 0
Set @Att12 = 0
Set @Att13 = 0
Set @Att14 = 0
Set @Att15 = 0



If @ClassTypeID = 6
Begin


	While (LEN(@INFO) > 0)
	Begin
	
	--Get TranscriptID
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @TranscriptID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ChurchPresent
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ChurchPresent = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ChurchAbsent
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ChurchAbsent = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get SSchoolPresent
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @SSchoolPresent = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get SSchoolAbsent
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @SSchoolAbsent = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)

	Set @ChurchTotalDays = @ChurchPresent + @ChurchAbsent
	Set @SSchoolTotalDays = @SSchoolPresent + @SSchoolAbsent

	Update Transcript
	Set 	ChurchPresent = @ChurchPresent,
			PercChurchPresent = 
			case
				when @ChurchTotalDays = 0 then 0
				else ( Convert(Dec(5,2), @ChurchPresent) / Convert(Dec(5,2), @ChurchTotalDays) ) * 100
			end,
			ChurchAbsent = @ChurchAbsent,
			PercChurchAbsent =
			case
				when @ChurchTotalDays = 0 then 0
				else ( Convert(Dec(5,2), @ChurchAbsent) / Convert(Dec(5,2), @ChurchTotalDays) ) * 100
			end,
			SSchoolPresent = @SSchoolPresent,
			PercSSchoolPresent = 
			case 
				when @SSchoolTotalDays = 0 then 0
				else ( Convert(Dec(5,2), @SSchoolPresent) / Convert(Dec(5,2), @SSchoolTotalDays) ) * 100
			end,
			SSchoolAbsent = @SSchoolAbsent,
			PercSSchoolAbsent = 
			case
				when @SSchoolTotalDays = 0 then 0
				else ( Convert(Dec(5,2), @SSchoolAbsent) / Convert(Dec(5,2), @SSchoolTotalDays) ) * 100
			end
	Where TranscriptID = @TranscriptID
	
	END


End
Else
Begin


	Declare @Att1SOR bit
	Declare @Att2SOR bit
	Declare @Att3SOR bit
	Declare @Att4SOR bit
	Declare @Att5SOR bit
	Declare @Att6SOR bit
	Declare @Att7SOR bit
	Declare @Att8SOR bit
	Declare @Att9SOR bit
	Declare @Att10SOR bit
	Declare @Att11SOR bit
	Declare @Att12SOR bit
	Declare @Att13SOR bit
	Declare @Att14SOR bit
	Declare @Att15SOR bit
	
	Set @Att1SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att1')	
	Set @Att2SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att2')	
	Set @Att3SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att3')	
	Set @Att4SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att4')	
	Set @Att5SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att5')	
	Set @Att6SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att6')	
	Set @Att7SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att7')	
	Set @Att8SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att8')	
	Set @Att9SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att9')	
	Set @Att10SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att10')	
	Set @Att11SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att11')	
	Set @Att12SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att12')	
	Set @Att13SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att13')	
	Set @Att14SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att14')	
	Set @Att15SOR = (Select ShowOnReportCard From AttendanceSettings Where ID = 'Att15')


	While (LEN(@INFO) > 0)
	Begin
	--Get TranscriptID
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @TranscriptID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)

	if @Att1SOR = 1
	Begin
		--Get Att1
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att1 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att2SOR = 1
	Begin
		--Get Att2
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att2 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att3SOR = 1
	Begin
		--Get Att3
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att3 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att4SOR = 1
	Begin
		--Get Att4
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att4 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att5SOR = 1
	Begin
		--Get Att5
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att5 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att6SOR = 1
	Begin
		--Get Att6
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att6 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att7SOR = 1
	Begin
		--Get Att7
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att7 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att8SOR = 1
	Begin
		--Get Att8
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att8 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att9SOR = 1
	Begin
		--Get Att9
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att9 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att10SOR = 1
	Begin
		--Get Att10
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att10 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att11SOR = 1
	Begin
		--Get Att11
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att11 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att12SOR = 1
	Begin
		--Get Att12
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att12 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att13SOR = 1
	Begin
		--Get Att13
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att13 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att14SOR = 1
	Begin
		--Get Att14
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att14 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End
	if @Att15SOR = 1
	Begin
		--Get Att15
		Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
		Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
		Set @Att15 = SUBSTRING (@INFO, 1, @EndPosition)
		Set @StrLength = LEN(@INFO)
		Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	End


	Set @SchoolTotalDays = @Att1 + @Att2 + @Att3 + @Att4 + @Att5 + @Att6 + @Att7 + @Att8 + @Att9 + @Att10 + @Att11 + @Att12 + @Att13 + @Att14 + @Att15 

	If @SchoolTotalDays = 0
	Begin
		Set @SchoolTotalDays = 1
	End

	Update Transcript
	Set 	SchoolAtt1 = @Att1,
			PercSchoolAtt1 = ( Convert(Dec(5,2), @Att1) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt2 = @Att2,
			PercSchoolAtt2 = ( Convert(Dec(5,2), @Att2) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt3 = @Att3,
			PercSchoolAtt3 = ( Convert(Dec(5,2), @Att3) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt4 = @Att4,
			PercSchoolAtt4 = ( Convert(Dec(5,2), @Att4) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt5 = @Att5,
			PercSchoolAtt5 = ( Convert(Dec(5,2), @Att5) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt6 = @Att6,
			PercSchoolAtt6 = ( Convert(Dec(5,2), @Att6) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt7 = @Att7,
			PercSchoolAtt7 = ( Convert(Dec(5,2), @Att7) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt8 = @Att8,
			PercSchoolAtt8 = ( Convert(Dec(5,2), @Att8) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt9 = @Att9,
			PercSchoolAtt9 = ( Convert(Dec(5,2), @Att9) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt10 = @Att10,
			PercSchoolAtt10 = ( Convert(Dec(5,2), @Att10) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt11 = @Att11,
			PercSchoolAtt11 = ( Convert(Dec(5,2), @Att11) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt12 = @Att12,
			PercSchoolAtt12 = ( Convert(Dec(5,2), @Att12) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt13 = @Att13,
			PercSchoolAtt13 = ( Convert(Dec(5,2), @Att13) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt14 = @Att14,
			PercSchoolAtt14 = ( Convert(Dec(5,2), @Att14) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100,
			SchoolAtt15 = @Att15,
			PercSchoolAtt15 = ( Convert(Dec(5,2), @Att15) / Convert(Dec(5,2), @SchoolTotalDays) ) * 100
	Where TranscriptID = @TranscriptID


	End  -- While

End  -- if





GO
