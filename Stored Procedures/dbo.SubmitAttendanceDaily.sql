SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[SubmitAttendanceDaily] 
@INFO nvarchar(max)

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
Declare @Att6 tinyint
Declare @Att7 tinyint
Declare @Att8 tinyint
Declare @Att9 tinyint
Declare @Att10 tinyint
Declare @Att11 tinyint
Declare @Att12 tinyint
Declare @Att13 tinyint
Declare @Att14 tinyint
Declare @Att15 tinyint
Declare @Comment nvarchar(200)



While (LEN(@INFO) > 0)
Begin
	--Get CSID
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get ClassDate
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @ClassDate = dbo.toDBDate(SUBSTRING (@INFO, 1, @EndPosition))
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att1
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att1 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att2
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att2 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att3
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att3 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att4
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att4 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att5
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att5 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att6
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att6 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att7
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att7 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att8
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att8 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att9
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att9 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att10
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att10 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att11
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att11 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att12
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att12 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att13
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att13 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att14
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att14 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Att15
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Att15 = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Comment
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Comment = SUBSTRING (@INFO, 1, @EndPosition)
	Set @Comment = replace(@Comment, '=PercentageSymbol=', '%')  -- Translate =PercentageSymbol= back to %
	Set @Comment = replace(@Comment, '=AtSymbol=', '@')  -- Translate =AtSymbol= back to @
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)


	Update Attendance
	Set 	Att1 = @Att1,
			Att2 = @Att2,
			Att3 = @Att3,
			Att4 = @Att4,
			Att5 = @Att5,
			Att6 = @Att6,
			Att7 = @Att7,
			Att8 = @Att8,
			Att9 = @Att9,
			Att10 = @Att10,
			Att11 = @Att11,
			Att12 = @Att12,
			Att13 = @Att13,
			Att14 = @Att14,
			Att15 = @Att15,
			Comments = @Comment
	Where ClassDate = @ClassDate and CSID = @CSID


End  -- While
GO
