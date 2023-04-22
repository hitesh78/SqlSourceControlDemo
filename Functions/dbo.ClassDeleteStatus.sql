SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ClassDeleteStatus]
(
@ClassID int
)
RETURNS nvarchar(20)
AS
BEGIN

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

	Declare 
	@ClassTypeID int,
	@AverageGrade decimal(10,4)
	
	
	Set @AverageGrade = (Select Avg(StudentGrade) From ClassesStudents Where ClassID = @ClassID)
	Set @ClassTypeID = (Select ClassTypeID From Classes Where ClassID = @ClassID)


	RETURN
	(
	Select
	case
		when @DisableDepopulateSafety = 1 then 'SafeToDelete'
		when exists	(Select * From LessonPlans Where ClassID = @ClassID)
			then 'NotSafeToDelete'
		when @ClassTypeID = 3 then
			case
				when exists
					(
					Select CSID
					From ClassesStudents
					Where 
					ClassID = @ClassID
					and
					(
					TermComment is not null 
					and
					TermComment != '' 
					)
					)
				then 'NotSafeToDelete'
				else 'SafeToDelete'
			end	
		when @ClassTypeID in (5,6) then
			case
				when exists
					(
					Select CSID
					From Attendance
					Where 
					CSID in (Select CSID From ClassesStudents Where ClassID = @ClassID)
					)
				then 'NotSafeToDelete'
				else 'SafeToDelete'
			end			
		when @ClassTypeID > 99 then
			case
				when exists
					(
					Select CSCFID
					From ClassesStudentsCF
					Where 
					CSID in (Select CSID From ClassesStudents Where ClassID = @ClassID)
					and
					CFGrade is not null
					)
				then 'NotSafeToDelete'
				else 'SafeToDelete'
			end
		when exists (Select * From Classes Where ParentClassID = @ClassID) then
			case
				when exists
					(
					Select CSCFID
					From ClassesStudentsCF
					Where 
					CSID in (Select CSID From ClassesStudents Where ClassID in (Select ClassID From Classes Where ParentClassID = @ClassID))
					and
					CFGrade is not null
					)
				then 'NotSafeToDelete'
				when @AverageGrade is not null then 'NotSafeToDelete'
				else 'SafeToDelete'
			end	
		else
			case
				when @AverageGrade is null then 'SafeToDelete'
				else 'NotSafeToDelete'
			end
	end
	)


END

GO
