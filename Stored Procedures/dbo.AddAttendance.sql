SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[AddAttendance] @ClassDate datetime, @ClassID int
AS

Declare @DefaultPresentValue decimal(5,2) = (Select DefaultPresentValue From Classes Where ClassID = @ClassID)

Declare @FetchCSID int

Declare CSIDCursor Cursor For
	Select CSID
	From 
	ClassesStudents CS
		inner join
	Students S
		on CS.StudentID = S.StudentID
	Where 
	CS.ClassID = @ClassID
	and
	S.Active = 1
	and
	CS.StudentConcludeDate is null	

Open CSIDCursor

FETCH NEXT FROM CSIDCursor INTO @FetchCSID
WHILE (@@FETCH_STATUS <> -1)
BEGIN

 Insert Into Attendance (ClassDate, CSID, Att1)
	Values( @ClassDate,
			@FetchCSID,
			@DefaultPresentValue)

 FETCH NEXT FROM CSIDCursor INTO @FetchCSID
End

Close CSIDCursor

Deallocate CSIDCursor



GO
