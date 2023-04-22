SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 11/1/2018
-- Description:	Deletes all classes in a term
-- =============================================
CREATE PROCEDURE [dbo].[DeleteAllClassesFromTerm] (@TermID int)
AS
BEGIN

	SET NOCOUNT ON;


-- Remove Lesson Plans for that Term
Delete LessonPlans
From 
LessonPlans LP
	inner join
Classes C
	on LP.ClassID = C.ClassID
Where C.TermID = @TermID


-- Remove all Grades for that Term
--Print 'Deleting Grades'
Alter Table dbo.Grades disable Trigger all
Delete From dbo.Grades
From 
Grades G
	inner join
ClassesStudents CS
	on G.CSID = CS.CSID
	inner join
Classes C
	on C.ClassID = CS.ClassID
Where
C.TermID = @TermID
Alter Table dbo.Grades enable Trigger all


-- Delete Attachements
Declare @tmpFileIDs Table(FileID int)
Declare @tmpAssignmentIDs Table(AssignmentID int)

Insert into @tmpAssignmentIDs
Select AssignmentID
From 
Assignments A
	inner join
Classes C
	on C.ClassID = A.ClassID
Where
C.TermID = @TermID



Insert into @tmpFileIDs(FileID)
Select FileID
From AssignmentBinFiles
Where AssignmentID in (Select AssignmentID From @tmpAssignmentIDs)


Delete From AssignmentBinFiles
Where
AssignmentID in (Select AssignmentID From @tmpAssignmentIDs)


Delete From BinFiles
Where
FileID in (Select FileID From @tmpFileIDs)


-- Remove all Assignments for that Term
--Print 'Deleting Assignments'
Alter Table dbo.Assignments disable Trigger all
Delete From dbo.Assignments
From 
Assignments A
	inner join
Classes C
	on C.ClassID = A.ClassID
Where
C.TermID = @TermID
Alter Table dbo.Assignments enable Trigger all

-- Remove all ClassesStudents for that Term
--Print 'Deleting ClassesStudents'
Alter Table dbo.ClassesStudents disable Trigger all
Delete From dbo.ClassesStudents
From 
ClassesStudents CS
	inner join
Classes C
	on C.ClassID = CS.ClassID
Where
C.TermID = @TermID
Alter Table dbo.ClassesStudents enable Trigger all

-- Remove all Classes for that Term
--Print 'Deleting Classes'
Alter Table dbo.Classes disable Trigger all
Delete From dbo.Classes
From 
Classes
Where
TermID = @TermID
Alter Table dbo.Classes enable Trigger all




END
GO
