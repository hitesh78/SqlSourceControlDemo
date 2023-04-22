SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetEntryAttendanceDate] 
	@StudentID int
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
	TOP (1) ClassDate as EntryDate 
	FROM
	Attendance A
		inner join
	ClassesStudents CS
		ON A.CSID = CS.CSID
		inner join
	Classes C
		ON C.ClassID = CS.ClassID
		inner join
	Terms T
		ON T.TermID = C.TermID
		inner join
	Students S
		ON S.StudentID = CS.StudentID
	WHERE
		T.TermID in(SELECT * FROM dbo.GetYearTermIDsByDate(GETDATE()))
	and
		T.TermID not in (SELECT ParentTermID FROM Terms)
	and
	CASE
		WHEN Att3 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att3' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att4 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att4' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att5 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att5' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att6 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att6' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att7 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att7' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att8 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att8' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att9 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att9' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att10 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att10' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att11 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att11' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att12 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att12' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att13 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att13' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att14 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att14' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		WHEN Att15 = 1 and exists(SELECT * FROM AttendanceSettings WHERE ID = 'Att15' and ExcludedAttendance = 1 and MultiSELECT = 0) THEN 0
		ELSE 1
	END = 1 
	and
		S.Active = 1
	and
		C.ClassTypeID = 5
	and
		C.NONAcademic = 0
	and
		S.StudentID = @StudentID
END
GO
