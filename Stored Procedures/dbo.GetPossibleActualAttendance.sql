SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetPossibleActualAttendance] 
	@StudentID int
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
	CS.StudentID,
	CONVERT(DECIMAL(10,2),(COUNT(A.ClassDate))) as TotalPossibleAttendance,
	CONVERT(DECIMAL(10,2),(
	Sum(A.Att1) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att1')
	+
	Sum(A.Att2) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att2')
	+
	Sum(A.Att3) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att3')
	+
	Sum(A.Att4) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att4')
	+
	Sum(A.Att5) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att5')
	+
	Sum(A.Att6)* (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att6')
	+
	Sum(A.Att7) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att7')
	+
	Sum(A.Att8) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att8')
	+
	Sum(A.Att9) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att9')
	+
	Sum(A.Att10) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att10')
	+
	Sum(A.Att11) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att11')
	+
	Sum(A.Att12)* (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att12')
	+
	Sum(A.Att13) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att13')
	+
	Sum(A.Att14) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att14')
	+
	Sum(A.Att15)* (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att15')
	)) AS TotalPresentValue
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
	
	GROUP BY CS.StudentID
END
GO
