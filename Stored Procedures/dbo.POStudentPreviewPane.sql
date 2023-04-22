SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 4/30/2013
-- Description:	ShowsStudentInfo From POStudentSearchPage
-- =============================================
CREATE Procedure [dbo].[POStudentPreviewPane] 
@StudentID int
AS
BEGIN
	SET NOCOUNT ON;


	Declare @AccountID nvarchar(100) = (Select AccountID From Students Where StudentID = @StudentID)
	Declare @LastLoginTime nvarchar(100) = (Select LastLoginTime From Accounts Where AccountID = @AccountID)

	Declare @DailyAttendance bit
	Set @DailyAttendance = (Select DailyAttendance From Settings Where SettingID = 1)

	Declare @Attendance1 nvarchar(50)
	Declare @Attendance2 nvarchar(50)
	Declare @Attendance3 nvarchar(50)
	Declare @Attendance4 nvarchar(50)
	Declare @Attendance5 nvarchar(50)
	Declare @Attendance6 nvarchar(50)
	Declare @Attendance7 nvarchar(50)
	Declare @Attendance8 nvarchar(50)
	Declare @Attendance9 nvarchar(50)
	Declare @Attendance10 nvarchar(50)
	Declare @Attendance11 nvarchar(50)
	Declare @Attendance12 nvarchar(50)
	Declare @Attendance13 nvarchar(50)
	Declare @Attendance14 nvarchar(50)
	Declare @Attendance15 nvarchar(50)


	Set @Attendance1 = (Select Title From AttendanceSettings Where ID = 'Att1')
	Set @Attendance2 = (Select Title From AttendanceSettings Where ID = 'Att2')
	Set @Attendance3 = (Select Title From AttendanceSettings Where ID = 'Att3')
	Set @Attendance4 = (Select Title From AttendanceSettings Where ID = 'Att4')
	Set @Attendance5 = (Select Title From AttendanceSettings Where ID = 'Att5')
	Set @Attendance6 = (Select Title From AttendanceSettings Where ID = 'Att6')
	Set @Attendance7 = (Select Title From AttendanceSettings Where ID = 'Att7')
	Set @Attendance8 = (Select Title From AttendanceSettings Where ID = 'Att8')
	Set @Attendance9 = (Select Title From AttendanceSettings Where ID = 'Att9')
	Set @Attendance10 = (Select Title From AttendanceSettings Where ID = 'Att10')
	Set @Attendance11 = (Select Title From AttendanceSettings Where ID = 'Att11')
	Set @Attendance12 = (Select Title From AttendanceSettings Where ID = 'Att12')
	Set @Attendance13 = (Select Title From AttendanceSettings Where ID = 'Att13')
	Set @Attendance14 = (Select Title From AttendanceSettings Where ID = 'Att14')
	Set @Attendance15 = (Select Title From AttendanceSettings Where ID = 'Att15')	



	Select
	1 as tag,
	null as parent,
	@LastLoginTime as [Term!1!LastLoginTime],
	@DailyAttendance as [Term!1!DailyAttendance],
	T.TermID as [Term!1!TermID], 
	TermTitle as [Term!1!TermTitle], 
	EndDate as [Term!1!EndDate],
	(
		Select top 1 dbo.GetStudentAttendance(CS.CSID)
		From 
		Classes C
			inner join
		ClassesStudents CS
			on C.ClassID = CS.ClassID
		Where
		C.TermID =  T.TermID
		and
		C.ClassTypeID = 5
		and
		CS.StudentID = @StudentID
	) as [Term!1!Attendance],
	(
		Select 
		replace(
		(case A.Att1 when 1 then @Attendance1 + ', ' else '' end) +
		(case A.Att2 when 1 then @Attendance2 + ', ' else '' end) +
		(case A.Att3 when 1 then @Attendance3 + ', ' else '' end) +
		(case A.Att4 when 1 then @Attendance4 + ', ' else '' end) +
		(case A.Att5 when 1 then @Attendance5 + ', ' else '' end) +
		(case A.Att6 when 1 then @Attendance6 + ', ' else '' end) +
		(case A.Att7 when 1 then @Attendance7 + ', ' else '' end) +
		(case A.Att8 when 1 then @Attendance8 + ', ' else '' end) +
		(case A.Att9 when 1 then @Attendance9 + ', ' else '' end) +
		(case A.Att10 when 1 then @Attendance10 + ', ' else '' end) +
		(case A.Att11 when 1 then @Attendance11 + ', ' else '' end) +
		(case A.Att12 when 1 then @Attendance12 + ', ' else '' end) +
		(case A.Att13 when 1 then @Attendance13 + ', ' else '' end) +
		(case A.Att14 when 1 then @Attendance14 + ', ' else '' end) +
		(case A.Att15 when 1 then @Attendance15 + ', ' else '' end) + '@@'
		,
		', @@','') + 
		(case when isnull(A.Comments,'') = '' then '' else '&lt;br/&gt;' + A.Comments end)
		From 
		Classes C
			inner join
		ClassesStudents CS
			on C.ClassID = CS.ClassID
			inner join
		Attendance A
			on A.CSID = CS.CSID
		Where
		C.TermID = T.TermID
		and
		C.ClassTypeID = 5
		and
		CS.StudentID = @StudentID
		and
		convert(date, A.ClassDate) = convert(date, dbo.GLgetdatetime())
	) as [Term!1!TodaysAttendance],				
	null as [Class!2!ClassTitle],
	null as [Class!2!ClassPeriod],
	null as [Class!2!Concluded],
	null as [Class!2!AvgClassGrade],
	null as [Class!2!AlternativeGradeUsed],
	null as [Class!2!LowStudentGrade]
	From 
	Terms T
	Where
	T.TermID =
	(	 
		Select top 1
		T.TermID
		From 
		Classes C 
			inner join 
		ClassesStudents CS 
			on C.ClassID = CS.ClassID
			inner join
		Terms T
			on C.TermID = T.TermID
		Where 
		CS.StudentID = @StudentID
		and
		T.Status = 1
		Order By
		case
			when GETDATE() between T.StartDate and T.EndDate then 0
			else 1
		end
	)
	
	Union All

	Select
	2 as tag,
	1 as parent,
	null as [Term!1!LastLoginTime],
	null as [Term!1!DailyAttendance],
	T.TermID as [Term!1!TermID], 
	T.TermTitle as [Term!1!TermTitle], 
	T.EndDate as [Term!1!EndDate],
	null as [Term!1!Attendance],
	null as [Term!1!TodaysAttendance],
	C.ReportTitle as [Class!2!ClassTitle],
	C.Period as [Class!2!ClassPeriod],
	C.Concluded as [Class!2!Concluded],
	case 
		when isnull(CS.AlternativeGrade,'') != '' then CS.AlternativeGrade 
		when CG.ShowPercentageGrade = 1 then
			dbo.GetLetterGrade(C.ClassID, CS.StudentGrade) + ' (' + convert(nvarchar(10),convert(decimal(5,1),CS.StudentGrade)) + ')'
		when CG.ShowPercentageGrade = 0 then
			dbo.GetLetterGrade(C.ClassID, CS.StudentGrade)
		else ''
	end as [Class!2!AvgClassGrade],
	case 
		when isnull(CS.AlternativeGrade,'') != '' then 1
		else 0
	end as [Class!2!AlternativeGradeUsed],
	case 
		when isnull(CS.AlternativeGrade,'') != '' then 0
		when CS.StudentGrade < 69 then 1
		else 0
	end as [Class!2!LowStudentGrade]	
	From 
	Classes C
		inner join
	Terms T
		on C.TermID = T.TermID
		inner join
	ClassesStudents CS
		on CS.ClassID = C.ClassID
		left join
	CustomGradeScale CG
		on C.CustomGradeScaleID = CG.CustomGradeScaleID
	Where
	T.TermID =
	(	 
		Select top 1
		T.TermID
		From 
		Classes C 
			inner join 
		ClassesStudents CS 
			on C.ClassID = CS.ClassID
			inner join
		Terms T
			on C.TermID = T.TermID
		Where 
		CS.StudentID = @StudentID
		and
		T.Status = 1
		Order By
		case
			when GETDATE() between T.StartDate and T.EndDate then 0
			else 1
		end
	)
	and
	CS.StudentID = @StudentID
	and
	ParentClassID = 0
	and
	C.ClassTypeID = 1

	Order By [Term!1!EndDate], [Term!1!TermID], [Class!2!ClassPeriod], [Class!2!ClassTitle]

	FOR XML EXPLICIT			
					



END

GO
