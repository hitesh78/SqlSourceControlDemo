SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[DeleteAttendance] @ClassDate datetime, @ClassID int
AS
Delete from Attendance
where (ClassDate = @ClassDate) and (CSID IN (Select CSID 
					     from ClassesStudents
					     where ClassID = @ClassID))

GO
