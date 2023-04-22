SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[AddStudentsToClass] 
@ClassID int, 
@INFO nvarchar(4000),
@ApplyToAllClasses nvarchar(10)

AS


Declare @EndPosition int
Declare @StrLength int
Declare @StartPosition int
Declare @StudentID int
Declare @SubCommentClassTypeID int
Declare @SubCommentClassID int
Declare @TermID int

Set @TermID = (Select TermID From Classes Where ClassID = @ClassID) 

create table #Classes (ClassID int)

While (LEN(@INFO) > 0)
Begin

	--Get StudentID
	Set @EndPosition = PATINDEX ('%@%', @INFO) - 1
	Set @StartPosition = PATINDEX ('%@%', @INFO) + 1
	Set @StudentID = SUBSTRING (@INFO, 1, @EndPosition)
	Set @StrLength = LEN(@INFO)
	Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)

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

		Declare @TheClassID int
		Set @TheClassID = (Select top 1 ClassID From #Classes)
		Delete From #Classes Where ClassID = @TheClassID

		IF @StudentID not in (Select StudentID From ClassesStudents Where ClassID = @TheClassID)
		Begin

			-- Add Student to Primary Class
			Insert into ClassesStudents(ClassID, StudentID)
			Values(@TheClassID, @StudentID)
			


			-- Check to see if we need to add students to SubComment Class

			Set @SubCommentClassTypeID = (Select SubCommentClassTypeID From Classes Where ClassID = @TheClassID)
			If (@SubCommentClassTypeID > 0)
			Begin
			  Set @SubCommentClassID = (Select ClassID From Classes Where ParentClassID = @TheClassID)
			End


			If (@SubCommentClassTypeID > 0)
			Begin

				Declare @ParentClassID int
				Set @ParentClassID = (Select IDENT_CURRENT('Classes'))
			
				IF @StudentID not in (Select StudentID From ClassesStudents Where ClassID = @SubCommentClassID)
				Begin
					-- Add Student to SubComment Class
					Insert into ClassesStudents(ClassID, StudentID)
					Values(@SubCommentClassID, @StudentID)
				
					-- Add CSID for Custom Fields for SubComment Class
					Declare @ClassTypeID2 int
					Set @ClassTypeID2 = (Select ClassTypeID From Classes Where ClassID = @SubCommentClassID)
				
					Declare @CSID2 int
					Set @CSID2 = (Select CSID From ClassesStudents Where ClassID = @SubCommentClassID and StudentID = @StudentID)
					
					Insert into ClassesStudentsCF (CSID, CustomFieldID)
					Select 	@CSID2 as CSID, 
							CustomFieldID
					From CustomFields
					Where ClassTypeID = @ClassTypeID2
				End

			End


			-- Add CSID for Custom Fields for Primary class
			Declare @ClassTypeID int
			Set @ClassTypeID = (Select ClassTypeID From Classes Where ClassID = @TheClassID)
			
			If @ClassTypeID >= 100
			Begin
			
				Declare @CSID int
				Set @CSID = (Select CSID From ClassesStudents Where ClassID = @TheClassID and StudentID = @StudentID)
				
				Insert into ClassesStudentsCF (CSID, CustomFieldID)
				Select 	@CSID as CSID, 
						CustomFieldID
				From CustomFields
				Where ClassTypeID = @ClassTypeID
			
			End

		End		-- IF @StudentID not in (Select StudentID From ClassesStudents Where ClassID = @TheClassID)

	End -- While (Select count(*) From #Classes > 0

END





GO
