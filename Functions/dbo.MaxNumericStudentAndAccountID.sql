SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[MaxNumericStudentAndAccountID]()
RETURNS bigint
AS
BEGIN
--  declare @theMax bigint
  declare @theMax2 bigint
  declare @uniqueMax bigint
  
--  select @theMax = cast((select MAX(cast(AccountID as bigint)) from Accounts 
--	where ltrim(rtrim(AccountID)) NOT LIKE '%[^0-9]%') as bigint)

  Select @theMax2 = MAX(xStudentID) from Students
  
	-- Find the first available gap within the next N consequetive numbers
	-- above the current maximum xStudentID.  Make sure the gap exists
	-- within both the Student table and the Accounts table as Account IDs
	-- are defaulted to xStudentIDs by default.  
	-- A choose N = the current size of the student table, as it would be 
	-- impossible to assign more unique numbers that fill every gap in the
	-- target range when there could only be the same N conflicts from
	-- existing records.  This logic is slightly flawed because xStudentID
	-- and AccountID represent separate potential "name spaces" so I'd need
	-- to check the next 2*N consequetive values to be 100% certain of no
	-- conflicts.  Oh well, I'll revisit this if it fails...
	--
	-- The benefit of this over the prior implementation is that any 
	-- very large, numeric Account ID that might have been introduced 
	-- caused all subsequent default xStudentIDs to start above that value
	-- which could blow the SIS or EnrollMe high value capacity for 
	-- xStudentIDs....
	--
	select @uniqueMax = MIN(n) from (
		SELECT TOP 100 percent 
			n = @theMax2 + CONVERT(BIGINT, ROW_NUMBER() OVER (ORDER BY s1.StudentID))
		FROM Students AS s1
	) x
	where n not in (select xStudentID from Students)
		and cast(n as nvarchar(20)) not in (select AccountID from Accounts)

	return @uniqueMax - 1
END

GO
