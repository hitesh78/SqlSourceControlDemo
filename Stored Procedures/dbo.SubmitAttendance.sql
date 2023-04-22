SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   Procedure [dbo].[SubmitAttendance] 
@INFO nvarchar(max), 
@ClassTypeID int

AS

Declare @EndPosition int
Declare @StrLength int
Declare @StartPosition int
Declare @CSID int
Declare @ClassDate datetime
Declare @Att1 tinyint
Declare @Att2 tinyint
Declare @Att3 tinyint
Declare @Att4 tinyint
Declare @Att5 tinyint
Declare @Exceptional tinyint
Declare @Good tinyint
Declare @Poor tinyint
Declare @Unacceptable tinyint
Declare @ChurchPresent tinyint
Declare @ChurchAbsent tinyint
Declare @SSchoolPresent tinyint
Declare @SSchoolAbsent tinyint
Declare @Comments nvarchar(300)


Declare @ShowOnlyChurchAttendance bit
Set @ShowOnlyChurchAttendance = (Select ShowOnlyChurchAttendance From Settings Where SettingID = 1)
Declare @ShowConductForClassAttendance bit
Set @ShowConductForClassAttendance = (Select ShowConductForClassAttendance From Settings Where SettingID = 1)

If @ClassTypeID = 6
Begin


	While (LEN(@INFO) > 0)
	Begin
	
	--Get CSID
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ClassDate
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ClassDate = dbo.toDBDate(SUBSTRING (@INFO, 1, @EndPosition))
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

	If @ShowOnlyChurchAttendance = 0
	Begin
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

		Update Attendance
		Set 	ChurchPresent = @ChurchPresent,
				ChurchAbsent = @ChurchAbsent,
				SSchoolPresent = @SSchoolPresent,
				SSchoolAbsent = @SSchoolAbsent
		Where ClassDate = @ClassDate and CSID = @CSID

	End
	Else
	Begin
		Update Attendance
		Set 	ChurchPresent = @ChurchPresent,
				ChurchAbsent = @ChurchAbsent,
				SSchoolPresent = 0,
				SSchoolAbsent = 0
		Where ClassDate = @ClassDate and CSID = @CSID
	End
	
	END


End
Else
Begin
	While (LEN(@INFO) > 0)
	Begin
	--Get CSID
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ClassDate
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @ClassDate = dbo.toDBDate(SUBSTRING (@INFO, 1, @EndPosition))
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att1
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Att1 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att2
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Att2 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att3
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Att3 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att4
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Att4 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)

	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att5
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Att5 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
If @ClassTypeID != 5 AND @ShowConductForClassAttendance = 1
Begin
	--Get Exceptional
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Exceptional = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Good
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Good = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Poor
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Poor = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Unacceptable
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Unacceptable = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)	

	Update Attendance
	Set 	Att1 = @Att1,
			Att2 = @Att2,
			Att3 = @Att3,
			Att4 = @Att4,
			Att5 = @Att5,
			Exceptional = @Exceptional,
			Good = @Good,
			Poor = @Poor,
			Unacceptable = @Unacceptable
	Where ClassDate = @ClassDate and CSID = @CSID
	
END -- if
Else
Begin
	Update Attendance
	Set 	Att1 = @Att1,
			Att2 = @Att2,
			Att3 = @Att3,
			Att4 = @Att4,
			Att5 = @Att5
	Where ClassDate = @ClassDate and CSID = @CSID
End

    --Get Comments
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @Comments = SUBSTRING (@INFO, 1, @EndPosition)
	Set @Comments = replace(@Comments, '=PercentageSymbol=', '%')  -- Translate =PercentageSymbol= back to %
	Set @Comments = replace(@Comments, '=AtSymbol=', '@')  -- Translate =AtSymbol= back to @	
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	
	Update Attendance
	Set Comments = @Comments
	Where ClassDate = @ClassDate and CSID = @CSID

	End  -- While

End  -- if




set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

GO
