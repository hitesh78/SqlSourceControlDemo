SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SubmitEffort] @INFO nvarchar(4000)
AS

Declare @EndPosition int
Declare @StrLength int
Declare @StartPosition int
Declare @CSID int
Declare @Exceptional tinyint
Declare @Good tinyint
Declare @Poor tinyint
Declare @Unacceptable tinyint

While (LEN(@INFO) > 0)
Begin

--Get CSID
Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
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


Update ClassesStudents
Set 	Exceptional = @Exceptional,
		Good = @Good,
		Poor = @Poor,
		Unacceptable = @Unacceptable
Where CSID = @CSID

END



GO
