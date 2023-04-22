SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ConcatComments](@TermID int, @StudentID int)
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
	and
	TermComment != '<p style=''margin: 0px; padding: 0px;''></p>'	
)
)

SET @Output = ''


If @CommentCount > 1
Begin
	SELECT 
	@Output =
	case
		when (rtrim(StaffTitle) = '' or StaffTitle is null) and patindex('%<p>%', TermComment) = 0 -- no <p> tags
		then @Output + '<div style="margin-bottom:-20; font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select Tglname) + ')</div>' + '<div style="margin-bottom:-15"><p>' + TermComment + '</p></div>'
		when rtrim(StaffTitle) = '' or StaffTitle is null
		then @Output + '<div style="margin-bottom:-20; font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select Tglname) + ')</div>' + '<div style="margin-bottom:-15">' + TermComment + '</div>'
		when patindex('%<p>%', TermComment) = 0
		then @Output + '<div style="margin-bottom:-20; font-weight:bold">' + (Select ClassTitle) + ' ('+ (Select StaffTitle + ' ' + TLname) + ')</div>' + '<div style="margin-bottom:-15"><p>' + TermComment + '</p></div>'
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
		and
		TermComment != '<p style=''margin: 0px; padding: 0px;''></p>'		
	)
End
Else
Begin
	SELECT 
	--@Output = TermComment
	@Output = replace (replace (TermComment, '<P>', ''), '</P>', '') -- remove
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
		and
		TermComment != '<p style=''margin: 0px; padding: 0px;''></p>'			
	)
End



Return @Output

End







GO
