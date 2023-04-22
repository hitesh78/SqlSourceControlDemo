SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[DeleteAttendanceForAllClasses] @ClassDate datetime
AS
Delete from Attendance
where (ClassDate = @ClassDate) and (CSID IN (Select CS.CSID 
					     from 
							ClassesStudents CS
								inner join
							Classes C
								on C.ClassID = CS.ClassID
					     where C.ClassTypeID in (1,2,5,8)))



GO
