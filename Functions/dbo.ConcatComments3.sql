SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[ConcatComments3](@TermID int, @StudentID int, @ShowTeacherName bit)
RETURNS @Comments table
(
CommentOutput nVARCHAR(max)
)
AS
Begin

	Declare @CommentOutput nVARCHAR(max) = ''
	Declare @CommentsTable table (ClassTitle nvarchar(100), TermComment nvarchar(max))


	Insert into @CommentsTable
	Select 
	case
		when @ShowTeacherName = 1 then 
			case
				when rtrim(T.StaffTitle) = '' or T.StaffTitle is null 
				then isnull(@CommentOutput,'') + C.ReportTitle + ' ('+ (Select T.glname) + ')'
				else isnull(@CommentOutput,'') + C.ReportTitle + ' ('+ (Select T.StaffTitle + ' ' + T.Lname) + ')' 
			end
		else C.ReportTitle
	end,
	CS.TermComment
	From
	Classes C
		inner join
	ClassesStudents CS
		on C.ClassID = CS.ClassID
		inner join
	Teachers T
		on T.TeacherID = C.TeacherID
	Where
	C.TermID = @TermID
	and
	CS.StudentID = @StudentID
	and
	C.ClassTypeID = 3
	and
	CS.TermComment is not null
	and
	CS.TermComment != ''
	and
	CS.TermComment != '<P>&nbsp;</P>'
	and
	CS.TermComment != '<P><BR></P>'
	and
	CS.TermComment != '<p><br mce_bogus="1"></p>'
	and
	CS.TermComment != '<P> </P>'
	and
	TermComment != '<p style=''margin: 0px; padding: 0px;''></p>'	
	Order By C.ReportOrder, ClassTitle
	
	Select
	@CommentOutput =
	isnull(@CommentOutput,'') + '<div style="font-weight:bold">' + ClassTitle + '</div>' + '<div>' + TermComment + '</div><br style="line-height:.5"/>'
	From @CommentsTable	

	Insert into @Comments 
	Select REPLACE(REPLACE(REPLACE(Replace(@CommentOutput, '> </p>', '><br/></p>'), '''' , '\''' ) , CHAR(13) , '' ) , CHAR(10) , '' )

	Return 

End


GO
