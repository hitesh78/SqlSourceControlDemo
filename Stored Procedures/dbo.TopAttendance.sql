SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[TopAttendance] 
@GradeLevel nvarchar(20),
@ReportType nvarchar(20),
@TheCount int,
@ClassID int,
@EK Decimal(15,15)

AS
Declare @TheCount2 int
Set @TheCount2 = @TheCount + 1



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
	Declare @CAttendance1 nvarchar(50)
	Declare @CAttendance2 nvarchar(50)
	Declare @CAttendance3 nvarchar(50)
	Declare @CAttendance4 nvarchar(50)
	Declare @CAttendance5 nvarchar(50)	
	Declare @DailyAttendance nvarchar(10)
	Declare @ClassAttendance nvarchar(10)



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
		@ClassAttendance = ClassAttendance,
		@DailyAttendance = DailyAttendance,
		@CAttendance1 = Attendance1,
		@CAttendance2 = Attendance2,
		@CAttendance3 = Attendance3,
		@CAttendance4 = Attendance4,
		@CAttendance5 = Attendance5
		From Settings 
		Where SettingID = 1




SET ROWCOUNT @TheCount2
Select 	1 as tag,
		Null as parent,
		@DailyAttendance as [One!1!DailyAttendance],
		@ClassAttendance as [One!1!ClassAttendance],
		@ClassID as [One!1!ClassID],
		@EK as [One!1!EK],
		@ReportType as [One!1!ReportType],
		@GradeLevel as [One!1!GradeLevel],
		@TheCount as [One!1!TheCount],
		datename(month,dbo.GLgetdatetime()) + ' ' + datename(day,dbo.GLgetdatetime()) + ', ' + datename(year,dbo.GLgetdatetime()) As [One!1!TheDate],
		@Attendance1 as [One!1!Attendance1],
		@Attendance2 as [One!1!Attendance2],
		@Attendance3 as [One!1!Attendance3],
		@Attendance4 as [One!1!Attendance4],
		@Attendance5 as [One!1!Attendance5],
		@Attendance6 as [One!1!Attendance6],
		@Attendance7 as [One!1!Attendance7],
		@Attendance8 as [One!1!Attendance8],
		@Attendance9 as [One!1!Attendance9],
		@Attendance10 as [One!1!Attendance10],
		@Attendance11 as [One!1!Attendance11],
		@Attendance12 as [One!1!Attendance12],
		@Attendance13 as [One!1!Attendance13],
		@Attendance14 as [One!1!Attendance14],
		@Attendance15 as [One!1!Attendance15],
		@CAttendance1 as [One!1!CAttendance1],
		@CAttendance2 as [One!1!CAttendance2],
		@CAttendance3 as [One!1!CAttendance3],
		@CAttendance4 as [One!1!CAttendance4],
		@CAttendance5 as [One!1!CAttendance5],
		Null as [Two!2!StudentID],
		Null as [Two!2!Fname],
		Null as [Two!2!Lname],
		Null as [Two!2!Sname],
		Null as [Two!2!AttenCnt]

Union All

Select  2 as tag,
		1 as parent,
		Null as [One!1!DailyAttendance],
		Null as [One!1!ClassAttendance],
		Null as [One!1!ClassID],
		Null as [One!1!EK],
		Null as [One!1!ReportType],
		Null as [One!1!GradeLevel],
		Null as [One!1!TheCount],
		Null as [One!1!TheDate],
		Null as [One!1!Attendance1],
		Null as [One!1!Attendance2],
		Null as [One!1!Attendance3],
		Null as [One!1!Attendance4],
		Null as [One!1!Attendance5],
		Null as [One!1!Attendance6],
		Null as [One!1!Attendance7],
		Null as [One!1!Attendance8],
		Null as [One!1!Attendance9],
		Null as [One!1!Attendance10],
		Null as [One!1!Attendance11],
		Null as [One!1!Attendance12],
		Null as [One!1!Attendance13],
		Null as [One!1!Attendance14],
		Null as [One!1!Attendance15],
		Null as [One!1!CAttendance1],
		Null as [One!1!CAttendance2],
		Null as [One!1!CAttendance3],
		Null as [One!1!CAttendance4],
		Null as [One!1!CAttendance5],
		S.StudentID as [Two!2!StudentID],
		S.Fname as [Two!2!Fname],
		S.Lname as [Two!2!Lname],
		S.glname as [Two!2!Sname],
		case @ReportType
			when 'Att1' then sum(A.Att1)
			when 'Att2' then sum(A.Att2)
			when 'Att3' then sum(A.Att3)
			when 'Att4' then sum(A.Att4)
			when 'Att5' then sum(A.Att5)
			when 'Att6' then sum(A.Att6)
			when 'Att7' then sum(A.Att7)
			when 'Att8' then sum(A.Att8)
			when 'Att9' then sum(A.Att9)
			when 'Att10' then sum(A.Att10)
			when 'Att11' then sum(A.Att11)
			when 'Att12' then sum(A.Att12)
			when 'Att13' then sum(A.Att13)
			when 'Att14' then sum(A.Att14)
			when 'Att15' then sum(A.Att15)
			when 'ChurchPresents' then sum(A.ChurchPresent)
			when 'ChurchAbsents' then sum(A.ChurchAbsent)
			when 'SSchoolPresents' then sum(A.SSchoolPresent)
			when 'SSchoolAbsents' then sum(A.SSchoolAbsent)
		end as [Two!2!AttenCnt]
from 
	Students S 
		inner join 
	ClassesStudents CS
		on S.StudentID = CS.StudentID 
		inner join 
	Attendance A
		on CS.CSID = A.CSID
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	Terms T
		on C.TermID = T.TermID
Where 
	(
	case
		when @DailyAttendance = 1 and C.ClassTypeID = 5 then 1
		when @DailyAttendance = 0 and C.ClassTypeID in (1,2,8) then 1
		else 0
	end) = 1
	and
	T.Status = 1
	and
	case @GradeLevel
		when '0' then 1
		when S.GradeLevel then 1
	end = 1
Group By S.StudentID, S.Lname, S.Fname, S.glname
Order By tag, [Two!2!AttenCnt] desc
FOR XML EXPLICIT




GO
