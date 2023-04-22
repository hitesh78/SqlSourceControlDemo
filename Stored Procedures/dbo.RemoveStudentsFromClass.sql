SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[RemoveStudentsFromClass] 
@INFO nvarchar(4000),
@ClassID int,
@ApplyToAllClasses nvarchar(10)

AS

Declare @EndPosition int
Declare @StrLength int
Declare @StartPosition int
Declare @CSID int
Declare @CSID2 int
Declare @ClassID2 int
Declare @StudentID int
Declare @SubCommentClassTypeID int
Declare @SubCommentClassID int
Declare @TermID int
Declare @GradesAttendanceExists bit
Declare @TheClassID int
Declare @TheCSID int  
Declare @DisableDepopulateSafety bit  


Set @DisableDepopulateSafety =
(
Select 
	case
		when DisableDepopulateSafety < dbo.GLgetdatetime() then 0
		else 1
	end as DisableDepopulateSafety		
From Settings Where SettingID = 1
)


Set @TermID = (Select TermID From Classes Where ClassID = @ClassID) 

create table #Classes (ClassID int)



While (LEN(@INFO) > 0)
Begin

	--Get CSID
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)

	Set @StudentID = (Select StudentID From ClassesStudents Where CSID = @CSID)


	Declare @TeacherID int
	Set @TeacherID = (Select TeacherID From Classes Where ClassID = @ClassID)


	If @ApplyToAllClasses = 'yes'
	Begin
		Insert into #Classes (ClassID)
		Select ClassID
		From Classes
		Where 
		TeacherID = @TeacherID
		and
		TermID = @TermID
	End
	Else
	Begin
		Insert into #Classes (ClassID)
		values(@ClassID)
	End



	While (Select count(*) From #Classes) > 0
	Begin

		
		Set @TheClassID = (Select top 1 ClassID From #Classes)
		Delete From #Classes Where ClassID = @TheClassID
		Set @TheCSID = (Select CSID From ClassesStudents Where ClassID = @TheClassID and StudentID = @StudentID)
		
		
		-- Check to see if Student has any Grades or Attendance
		If	(not exists(Select CSID From Grades Where CSID = @TheCSID and Grade is not null) 
			and 
			not exists(Select CSID From Attendance Where CSID = @TheCSID)
			) 
			or
			@DisableDepopulateSafety = 1
		Begin

			Set @SubCommentClassTypeID = (Select SubCommentClassTypeID From Classes Where ClassID = @TheClassID)
			If (@SubCommentClassTypeID > 0)
			Begin
			  Set @SubCommentClassID = (Select ClassID From Classes Where ParentClassID = @TheClassID)
			End


			Delete from ClassesStudents
			Where 
			StudentID = @StudentID
			and
			ClassID = @TheClassID
			
		
			-- Remove Transcript Records
			Delete from Transcript
			Where 
			StudentID = @StudentID
			and
			ClassID = @TheClassID			


			-- Check to see if we need to remove students from SubComment Class
			If (@SubCommentClassTypeID > 0)
			Begin
				Set @CSID2 = (Select CSID From ClassesStudents Where ClassID = @SubCommentClassID and StudentID = @StudentID)
				Set @ClassID2 = (Select ClassID From ClassesStudents Where ClassID = @SubCommentClassID and StudentID = @StudentID)
				
				Delete from ClassesStudents
				Where CSID = @CSID2
				
				-- Remove Transcript Records
				Delete from Transcript
				Where 
				StudentID = @StudentID
				and
				ClassID = @ClassID2						

			End

		End

	End	-- (Select count(*) From #Classes) > 0

End -- (LEN(@INFO) > 0)




GO
