SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--
-- This allows for consistent formatting and, soon, for 
-- i18n specific formatting.  We make limited use of time
-- in GL so use of this scalar UDF will probably not
-- present performance problems.
--
-- THe SQL Convert with last parameter of zero presents
-- a format of, e.g. "3:00PM"...
--
-- Create 2/15/2019 Duke
--
create function [dbo].[formatTime]
(
	@t time(0)
)
returns nvarchar(7)
as 
begin
-- The following article indicates that these scalar udfs are not inlined yet and may be called
-- for every usage in every row, incurring performance penalties.  So use cautiously...
-- https://www.red-gate.com/simple-talk/sql/t-sql-programming/sql-server-user-defined-functions/
--
	return CONVERT(nvarchar(7), @t, 0)
end

GO
