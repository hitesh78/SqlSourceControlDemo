SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[SubmitComments] @INFO nvarchar(4000)
AS

Declare @EndPosition int
Declare @StrLength int
Declare @StartPosition int
Declare @CSID int
Declare @Comments nvarchar(50)

While (LEN(@INFO) > 0)
Begin

--Get CSID
Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
--Get Comments
Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
Set @Comments = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)


Update ClassesStudents
Set 	ClassComments = dbo.RemoveInvalidSQLXMLCharacters(@Comments)
Where CSID = @CSID

END





GO
