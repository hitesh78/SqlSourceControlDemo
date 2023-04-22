SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetTeacherAccessIDs]
(
@ClassID INT
)
RETURNS nVARCHAR(4000)
AS
BEGIN
DECLARE @TeacherIDs nVARCHAR(1000);

SELECT @TeacherIDs = COALESCE(@TeacherIDs + ', ', '') + '*' + convert(nvarchar(10),TeacherID) + ':' + convert(nvarchar(30),isnull(TeacherRole,'0')) 
FROM TeachersClasses
WHERE ClassID = @ClassID

RETURN 
(
SELECT @TeacherIDs
)
END

GO
