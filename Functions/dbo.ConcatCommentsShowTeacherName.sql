SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ConcatCommentsShowTeacherName](@TermID int, @StudentID int)
RETURNS nVARCHAR(max)
AS
BEGIN

DECLARE @Output nVARCHAR(max)
Declare @CommentCount int

Set @CommentCount = 
(
Select count(*) 
From Transcript 
Where
TermID = @TermID
and
StudentID = @StudentID
and
ClassTypeID = 3
and
(
	TermComment != '<P>&nbsp;</P>'
	and
	TermComment != '<P><BR></P>'
	and
	TermComment != '<p><br mce_bogus="1"></p>'
	and
	TermComment != '<P> </P>'	
	and
	TermComment != ''
	and
	TermComment is not null		
)
)

SET @Output = ''


If @CommentCount > 1
Begin
	SELECT 
	@Output =
	case
		when rtrim(StaffTitle) = '' or StaffTitle is null 
		then @Output + '<div style="margin-bottom:-20; font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select Tglname) + ')</div>' + '<div style="margin-bottom:-15">' + TermComment + '</div>'
		else @Output + '<div style="margin-bottom:-20; font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select StaffTitle + ' ' + TLname) + ')</div>' + '<div style="margin-bottom:-15">' + TermComment + '</div>'
	end
	FROM Transcript
	Where
	TermID = @TermID
	and
	StudentID = @StudentID
	and
	ClassTypeID = 3
	and
	(
		TermComment != '<P>&nbsp;</P>'
		and
		TermComment != '<P><BR></P>'
		and
		TermComment != '<p><br mce_bogus="1"></p>'
		and
		TermComment != '<P> </P>'		
		and
		TermComment != ''
		and
		TermComment is not null		
	)
End
Else
Begin
	SELECT top 1
	--@Output = TermComment
	@Output = 
	--(Select ClassTitle) + ' ('+ (Select TFname + ' ' + TLname) + ')</div>' + TermComment + '<br/>' +
	'<div style="margin-bottom:-20; font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select Tglname) + ')</div>' + '<div style="margin-bottom:-15">' + TermComment + '</div>'
	FROM Transcript
	Where
	TermID = @TermID
	and
	StudentID = @StudentID
	and
	ClassTypeID = 3
	and
	(
		TermComment != '<P>&nbsp;</P>'
		and
		TermComment != '<P><BR></P>'
		and
		TermComment != '<p><br mce_bogus="1"></p>'
		and
		TermComment != '<P> </P>'		
		and
		TermComment != ''
		and
		TermComment is not null		
	)
End

Return @Output

End







GO
