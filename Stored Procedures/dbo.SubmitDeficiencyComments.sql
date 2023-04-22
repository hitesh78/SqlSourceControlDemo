SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[SubmitDeficiencyComments] 
@INFO nvarchar(max), 
@ClassID int, 
@EK decimal(15,15), 
@Admin tinyint

AS

Declare @CSID int
Declare @Comments nvarchar(1000)
Declare @StrLength int
Declare @StartPosition int
Declare @EndPosition int

While (LEN(@INFO) > 0)
Begin

	--Get CSID
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	--Get Comments
	Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
	Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
	Set @Comments = SUBSTRING (@INFO, 1, @EndPosition)
	Set @Comments = replace(@Comments, '=PercentageSymbol=', '%')  -- Translate =PercentageSymbol= back to %
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
	
	Update ClassesStudents
	Set DeficiencyComment = @Comments
	Where CSID = @CSID

End

Declare @ClassTypeID int
Set @ClassTypeID = (Select ClassTypeID From Classes Where ClassID = @ClassID) 

Select 	@Admin as Admin,
		@ClassID as ClassID,
		@EK as EK,
		@ClassTypeID as ClassTypeID,
		'yes' as Saved

FOR XML RAW




GO
