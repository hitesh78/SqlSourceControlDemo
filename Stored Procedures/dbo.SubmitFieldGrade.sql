SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[SubmitFieldGrade] @INFO nvarchar(4000), @ClassID int, @EK decimal(15,15)
AS

Declare @EndPosition int
Declare @CSCFID int
Declare @CFGrade nvarchar(7)
Declare @NG nvarchar(7)
Declare @CFComments nvarchar(300)
Declare @StrLength int
Declare @StartPosition int

While (LEN(@INFO) > 0)
Begin

--Get CSCFID
Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
Set @CSCFID = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
--Get CFGrade
Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
Set @CFGrade = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
--Get NG
Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
Set @NG = SUBSTRING (@INFO, 1, @EndPosition)
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
--Get CFComments
Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
Set @CFComments = SUBSTRING (@INFO, 1, @EndPosition)
Set @CFComments = replace(@CFComments, '=PercentageSymbol=', '%')  -- Translate =PercentageSymbol= back to %
Set @StrLength = LEN(@INFO)
Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)


If (@NG = 'false')
Begin
	Update ClassesStudentsCF
	Set CFGrade = @CFGrade,
		CFComments = @CFComments
	Where CSCFID = @CSCFID
End
Else If(@NG = 'true')
Begin
	Update ClassesStudentsCF
	Set CFGrade = null,
		CFComments = null
	Where CSCFID = @CSCFID
End

END

	Declare @StudentCount int
	Declare @FieldCount int

	Set @StudentCount = (	select	count(CSID)
				From ClassesStudents
				Where ClassID = @ClassID)


	Set @FieldCount = (	
				Select count(*)
				From 	CustomFields CF
						inner join
					Classes C
						on C.ClassTypeID = CF.ClassTypeID
				Where C.ClassID = @ClassID
			)




	select 	@ClassID as ClassID,
		@StudentCount as StudentCount,
		@FieldCount as FieldCount,
		@EK as EK

	For XML RAW












GO
