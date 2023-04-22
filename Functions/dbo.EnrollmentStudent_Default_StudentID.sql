SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[EnrollmentStudent_Default_StudentID] 
(
)
RETURNS bigint
AS
BEGIN

declare @i bigint;
set @i = (SELECT ISNULL(MAX(StudentID),999999999) + 1 FROM EnrollmentStudent)
if @i<1000000000
begin
   set @i=1000000000
end
RETURN @i

END

GO
