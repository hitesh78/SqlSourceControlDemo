SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Skupen
-- Create date: 10/07/2013
-- Description:	A function similar to ClassDeleteStatus for determining whether or not a class is safe to edit.
-- =============================================
CREATE FUNCTION [dbo].[ClassEditStatus] 
(
	-- Add the parameters for the function here
	@ClassID int
)
RETURNS nvarchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(20) = 'SafeToEdit';
	
	-- Declare other stuff we will need here.
	Declare @ClassStartDate datetime, @ClassEndDate datetime;

	-- Ok, now we know this class has been defined in other terms this year.
	-- If they have their AllowChangesToClassesAfter1stTerm setting set, 
	-- then they will be able to edit this class.
	If (Select Settings.AllowChangesToClassesAfter1stTerm From Settings) = 1
		Return @Result

	-- Add the T-SQL statements to compute the return value here
	-- Ok, grab the start date and end date of the class.
	Select
		@ClassStartDate = StartDate,
		@ClassEndDate = EndDate
	From
		Terms
	Where
		TermID = (Select TermID From Classes Where ClassID = @ClassID);

	-- Ok, if the class hasn't started yet, then they are allowed to edit it.
	If @ClassStartDate > GETDATE()
		Return @Result;

		
	-- If the class is from a term from a past year, then they may NOT edit it.
	If (@ClassEndDate < GETDATE()) And ((Select TermID From Classes Where ClassID = @ClassID) Not In (Select TermID From dbo.GetYearTermIDsByDate(GETDATE())))
	Begin
		Set @Result = 'NotSafeToEdit';
		Return @Result;
	End
	

	-- Now, at this point we know that the class is in progress.
	-- First we will want to check how many terms are defined for this year.
	-- If they only have one term defined, and this class is in it, then we are safe.
	If ((Select Count(*) From dbo.GetYearTermIDsByDate(GETDATE())) = 1) And ((Select TermID From Classes Where ClassID = @ClassID) In (Select TermID From dbo.GetYearTermIDsByDate(GETDATE())))
		Return @Result;

	-- Now let's see if this class has been defined in previous terms this year.
	-- If it has, then we CANNOT let them edit this class. 
	If (Select Count(*) From Classes As C1 Where C1.ClassTitle = (Select ClassTitle From Classes As C2 Where C2.ClassID = @ClassID) And C1.TermID In (Select TermID From dbo.GetYearTermIDsByDate(GETDATE())) And C1.TermID != (Select TermID From Classes As C3 Where C3.ClassID = @ClassID)) >= 1
		Set @Result = 'NotSafeToEdit';

	-- Return the result of the function
	RETURN @Result

END

GO
