SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ConcatComments2](@TermID int, @StudentID int, @ShowTeacherName bit)
RETURNS @Comments table
(
CommentOutput nVARCHAR(max)
)
AS
Begin

	Declare @CommentOutput nVARCHAR(max)
	
	
	Declare @CommentsTable table (ClassTitle nvarchar(100), TermComment nvarchar(max))

	Insert into @CommentsTable
	Select 
	case
		when @ShowTeacherName = 1 then ClassTitle
		else left(ClassTitle, charIndex(' (', ClassTitle))
	end,
	TermComment
	FROM Transcript
	Where
	TermID = @TermID
	and
	StudentID = @StudentID
	and
	ClassTypeID = 3
	and
	TermComment is not null
	and
	TermComment != ''
	and
	TermComment != '<P>&nbsp;</P>'
	and
	TermComment != '<P><BR></P>'
	and
	TermComment != '<p><br mce_bogus="1"></p>'
	and
	TermComment != '<P> </P>'
	and
	TermComment != '<p style=''margin: 0px; padding: 0px;''></p>'	
	Order By ReportOrder, ClassTitle
	

	SELECT
	@CommentOutput =
	isnull(@CommentOutput,'') + '<div style="font-weight:bold">' + ClassTitle + '</div>' + '<div>' + TermComment + '</div><br style="line-height:.5"/>'
	FROM @CommentsTable
	Order By ClassTitle;

	Insert into @Comments 
	Select REPLACE(REPLACE(REPLACE(Replace(@CommentOutput, '> </p>', '><br/></p>'), '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )

	Return 

End

GO
