SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[AttendanceSheet]
(
@ClassID int,
@EK Decimal(15,15),
@StartDate smalldatetime,
@EndDate smalldatetime,
@ProfileID int
)
as


--Declare @EndDate smalldatetime
--Declare @StartDate smalldatetime
--DECLARE @ClassID int
--DECLARE @EK decimal(15,15)
--
---- TODO: Set parameter values here.
--
--Set @EK = .345456
--Set @ClassID = 2043
--Set @StartDate = '11/22/2007'
--Set @EndDate = '01/31/2008'

Declare @ClassTypeID int	
Set @ClassTypeID = (Select ClassTypeID From Classes Where ClassID = @ClassID)


-- Compile Dates Table
Declare @FirstDayofWeek smalldatetime
Declare @FirstDayNumber int
Declare @LastDayNumber int
Declare @LastDayofWeek smalldatetime

Set @FirstDayNumber = datepart(weekday, @StartDate)
Set @FirstDayofWeek = dateadd(day, (2 - @FirstDayNumber), @StartDate)
Set @LastDayNumber = datepart(weekday, @EndDate)
Set @LastDayofWeek = dateadd(day, (6 - @LastDayNumber), @EndDate)



Declare @CurrentDate smalldatetime

Create Table #SchoolDates
(
DateID int identity,
MonthNumber int,
TheDayMonth nvarchar(20),
MonthYear int,
TheDayName nchar(3),
TheDayNumber tinyint
)

Set @CurrentDate = @FirstDayofWeek

While @CurrentDate < @LastDayofWeek + 1
Begin


	if datepart(weekday, @CurrentDate) != 1 and datepart(weekday, @CurrentDate) != 7
	Begin

		Insert into #SchoolDates
		(
		MonthNumber,
		TheDayMonth,
		MonthYear,
		TheDayName,
		TheDayNumber
		)
		values
		(
		datepart(month, @CurrentDate),
		case datepart(month, @CurrentDate)
			when 1 then 'January'
			when 2 then 'February'
			when 3 then 'March'
			when 4 then 'April'
			when 5 then 'May'
			when 6 then 'June'
			when 7 then 'July'
			when 8 then 'August'
			when 9 then 'September'
			when 10 then 'October'
			when 11 then 'November'
			when 12 then 'December'
		end,
		datepart(year, @CurrentDate),
		case datepart(weekday, @CurrentDate)
			when 1 then 'Sun'
			when 2 then 'Mon'
			when 3 then 'Tue'
			when 4 then 'Wed'
			when 5 then 'Thu'
			when 6 then 'Fri'
			when 7 then 'Sat'
		end,
		datepart(day, @CurrentDate)
		)

	End

	Set @CurrentDate = dateadd(day, 1, @CurrentDate)

End





Declare @NumberOfWeeks int
Set @NumberofWeeks = (Select ceiling(convert(decimal(4,1),count(*))/5) From #SchoolDates)


--Select * From #SchoolDates



-- Student Data
Create Table #StudentNames
(
StudentID int,
StudentName nvarchar(50)
)

Create Table #StudentNames2
(
StudentID int,
StudentName nvarchar(50)
)

Insert Into #StudentNames
Select
	S.StudentID, 
	Lname + ', ' + Fname as StudentName
From 
	Students S
		inner join
	ClassesStudents CS
		on S.StudentID = CS.StudentID
Where CS.ClassID = @ClassID
Order By S.Lname, S.Fname



-- Student's Attendance Data
Create Table #TheAttendance
(
AttendanceID int identity,
StudentID int,
Lname nvarchar(50),
Fname nvarchar(50),
Attendance nvarchar(50),
ClassDate datetime
)


-- Get Student Attendance Totals

Declare 
@Att2AV decimal(5,2),
@Att3AV decimal(5,2),
@Att4AV decimal(5,2),
@Att5AV decimal(5,2),
@Att6AV decimal(5,2),
@Att7AV decimal(5,2),
@Att8AV decimal(5,2),
@Att9AV decimal(5,2),
@Att10AV decimal(5,2),
@Att11AV decimal(5,2),
@Att12AV decimal(5,2),
@Att13AV decimal(5,2),
@Att14AV decimal(5,2),
@Att15AV decimal(5,2),
@Att3PV decimal(5,2),
@Att4PV decimal(5,2),
@Att5PV decimal(5,2),
@Att6PV decimal(5,2),
@Att7PV decimal(5,2),
@Att8PV decimal(5,2),
@Att9PV decimal(5,2),
@Att10PV decimal(5,2),
@Att11PV decimal(5,2),
@Att12PV decimal(5,2),
@Att13PV decimal(5,2),
@Att14PV decimal(5,2),
@Att15PV decimal(5,2),
@Att2TV decimal(5,2),
@Att3TV decimal(5,2),
@Att4TV decimal(5,2),
@Att5TV decimal(5,2),
@Att6TV decimal(5,2),
@Att7TV decimal(5,2),
@Att8TV decimal(5,2),
@Att9TV decimal(5,2),
@Att10TV decimal(5,2),
@Att11TV decimal(5,2),
@Att12TV decimal(5,2),
@Att13TV decimal(5,2),
@Att14TV decimal(5,2),
@Att15TV decimal(5,2),
@Att3Title nvarchar(50),
@Att4Title nvarchar(50),
@Att5Title nvarchar(50),
@Att6Title nvarchar(50),
@Att7Title nvarchar(50),
@Att8Title nvarchar(50),
@Att9Title nvarchar(50),
@Att10Title nvarchar(50),
@Att11Title nvarchar(50),
@Att12Title nvarchar(50),
@Att13Title nvarchar(50),
@Att14Title nvarchar(50),
@Att15Title nvarchar(50),
@TotalAbsences decimal(5,2),
@TotalPresents decimal(5,2)


Create Table #StudentTotals
(
StudentID int,
PresentTotal decimal(5,2),
AbsentTotal decimal(5,2),
TardyTotal int
)

If @ClassTypeID = 5
Begin

	Set @Att3AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att3')
	Set @Att4AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att4')
	Set @Att5AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att5')
	Set @Att6AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att6')
	Set @Att7AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att7')
	Set @Att8AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att8')
	Set @Att9AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att9')
	Set @Att10AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att10')
	Set @Att11AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att11')
	Set @Att12AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att12')
	Set @Att13AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att13')
	Set @Att14AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att14')
	Set @Att15AV = (Select AbsentValue From AttendanceSettings Where ID = 'Att15')

	Set @Att3PV = (Select PresentValue From AttendanceSettings Where ID = 'Att3')
	Set @Att4PV = (Select PresentValue From AttendanceSettings Where ID = 'Att4')
	Set @Att5PV = (Select PresentValue From AttendanceSettings Where ID = 'Att5')
	Set @Att6PV = (Select PresentValue From AttendanceSettings Where ID = 'Att6')
	Set @Att7PV = (Select PresentValue From AttendanceSettings Where ID = 'Att7')
	Set @Att8PV = (Select PresentValue From AttendanceSettings Where ID = 'Att8')
	Set @Att9PV = (Select PresentValue From AttendanceSettings Where ID = 'Att9')
	Set @Att10PV = (Select PresentValue From AttendanceSettings Where ID = 'Att10')
	Set @Att11PV = (Select PresentValue From AttendanceSettings Where ID = 'Att11')
	Set @Att12PV = (Select PresentValue From AttendanceSettings Where ID = 'Att12')
	Set @Att13PV = (Select PresentValue From AttendanceSettings Where ID = 'Att13')
	Set @Att14PV = (Select PresentValue From AttendanceSettings Where ID = 'Att14')
	Set @Att15PV = (Select PresentValue From AttendanceSettings Where ID = 'Att15')

	Set @Att3Title = (Select Title From AttendanceSettings Where ID = 'Att3')
	Set @Att4Title = (Select Title From AttendanceSettings Where ID = 'Att4')
	Set @Att5Title = (Select Title From AttendanceSettings Where ID = 'Att5')
	Set @Att6Title = (Select Title From AttendanceSettings Where ID = 'Att6')
	Set @Att7Title = (Select Title From AttendanceSettings Where ID = 'Att7')
	Set @Att8Title = (Select Title From AttendanceSettings Where ID = 'Att8')
	Set @Att9Title = (Select Title From AttendanceSettings Where ID = 'Att9')
	Set @Att10Title = (Select Title From AttendanceSettings Where ID = 'Att10')
	Set @Att11Title = (Select Title From AttendanceSettings Where ID = 'Att11')
	Set @Att12Title = (Select Title From AttendanceSettings Where ID = 'Att12')
	Set @Att13Title = (Select Title From AttendanceSettings Where ID = 'Att13')
	Set @Att14Title = (Select Title From AttendanceSettings Where ID = 'Att14')
	Set @Att15Title = (Select Title From AttendanceSettings Where ID = 'Att15')


	Set @Att3TV = (case
					when @Att3Title like '%Tard%' or @Att3Title like '%Late%' then 1
					else 0
					end)
	Set @Att4TV = (case
					when @Att4Title like '%Tard%' or @Att4Title like '%Late%' then 1
					else 0
					end)
	Set @Att5TV = (case
					when @Att5Title like '%Tard%' or @Att5Title like '%Late%' then 1
					else 0
					end)
	Set @Att6TV = (case
					when @Att6Title like '%Tard%' or @Att6Title like '%Late%' then 1
					else 0
					end)
	Set @Att7TV = (case
					when @Att7Title like '%Tard%' or @Att7Title like '%Late%' then 1
					else 0
					end)
	Set @Att8TV = (case
					when @Att8Title like '%Tard%' or @Att8Title like '%Late%' then 1
					else 0
					end)
	Set @Att9TV = (case
					when @Att9Title like '%Tard%' or @Att9Title like '%Late%' then 1
					else 0
					end)
	Set @Att10TV = (case
					when @Att10Title like '%Tard%' or @Att10Title like '%Late%' then 1
					else 0
					end)
	Set @Att11TV = (case
					when @Att11Title like '%Tard%' or @Att11Title like '%Late%' then 1
					else 0
					end)
	Set @Att12TV = (case
					when @Att12Title like '%Tard%' or @Att12Title like '%Late%' then 1
					else 0
					end)
	Set @Att13TV = (case
					when @Att13Title like '%Tard%' or @Att13Title like '%Late%' then 1
					else 0
					end)
	Set @Att14TV = (case
					when @Att14Title like '%Tard%' or @Att14Title like '%Late%' then 1
					else 0
					end)
	Set @Att15TV = (case
					when @Att15Title like '%Tard%' or @Att15Title like '%Late%' then 1
					else 0
					end)







	Insert Into #StudentTotals
	Select distinct
		CS.StudentID, 
		(
			Select sum(Att1) + sum(Att3)*@Att3PV + sum(Att4)*@Att4PV + sum(Att5)*@Att5PV + sum(Att6)*@Att6PV + sum(Att7)*@Att7PV + sum(Att8)*@Att8PV + sum(Att9)*@Att9PV + sum(Att10)*@Att10PV + sum(Att11)*@Att11PV + sum(Att12)*@Att12PV + sum(Att13)*@Att13PV + sum(Att14)*@Att14PV + sum(Att15)*@Att15PV
			From Attendance
			Where 
			CSID = CS.CSID
			and
			ClassDate between @StartDate and @EndDate
			and
			datepart(weekday, ClassDate) != 1 and datepart(weekday, ClassDate) != 7
		) as PresentTotal,
		(
			Select sum(Att2) + sum(Att3)*@Att3AV + sum(Att4)*@Att4AV + sum(Att5)*@Att5AV + sum(Att6)*@Att6AV + sum(Att7)*@Att7AV + sum(Att8)*@Att8AV + sum(Att9)*@Att9AV + sum(Att10)*@Att10AV + sum(Att11)*@Att11AV + sum(Att12)*@Att12AV + sum(Att13)*@Att13AV + sum(Att14)*@Att14AV + sum(Att15)*@Att15AV
			From Attendance
			Where 
			CSID = CS.CSID
			and
			ClassDate between @StartDate and @EndDate
			and
			datepart(weekday, ClassDate) != 1 and datepart(weekday, ClassDate) != 7
		) as AbsentTotal,
		(
			Select sum(Att3)*@Att3TV + sum(Att4)*@Att4TV + sum(Att5)*@Att5TV + sum(Att6)*@Att6TV + sum(Att7)*@Att7TV + sum(Att8)*@Att8TV + sum(Att9)*@Att9TV + sum(Att10)*@Att10TV + sum(Att11)*@Att11TV + sum(Att12)*@Att12TV + sum(Att13)*@Att13TV + sum(Att14)*@Att14TV + sum(Att15)*@Att15TV
			From Attendance
			Where 
			CSID = CS.CSID
			and
			ClassDate between @StartDate and @EndDate
			and
			datepart(weekday, ClassDate) != 1 and datepart(weekday, ClassDate) != 7
		) as TardyTotal
	From 
		ClassesStudents CS
			inner join
		Attendance A
			on CS.CSID = A.CSID
	Where CS.ClassID = @ClassID

End
Else
Begin


	Select 
	@Att2TV = 
	case
	  when Attendance2 like '%Tard%' or Attendance2 like '%Late%' then 1
	  else 0
	end,		
	@Att3TV = 
	case
	  when Attendance3 like '%Tard%' or Attendance3 like '%Late%' then 1
	  else 0
	end,	
	@Att4TV = 
	case
	  when Attendance4 like '%Tard%' or Attendance4 like '%Late%' then 1
	  else 0
	end,	
	@Att5TV = 
	case
	  when Attendance5 like '%Tard%' or Attendance5 like '%Late%' then 1
	  else 0
	end	
	From Settings 
	Where SettingID = 1
	
	
	Select 
	@Att2AV = 
	case 
	  when Attendance2 like '%Absent%' or Attendance2 like '%Absence%' then 1
	  else 0
	end,		
	@Att3AV = 
	case
	  when Attendance3 like '%Absent%' or Attendance3 like '%Absence%' then 1
	  else 0
	end,	
	@Att4AV = 
	case
	  when Attendance4 like '%Absent%' or Attendance4 like '%Absence%' then 1
	  else 0
	end,	
	@Att5AV = 
	case
	  when Attendance5 like '%Absent%' or Attendance5 like '%Absence%' then 1
	  else 0
	end	
	From Settings 
	Where SettingID = 1	



	Insert Into #StudentTotals
	Select distinct
		CS.StudentID, 
		(
			Select sum(Att1)
			From Attendance
			Where 
			CSID = CS.CSID
			and
			ClassDate between @StartDate and @EndDate
			and
			datepart(weekday, ClassDate) != 1 and datepart(weekday, ClassDate) != 7
		) as PresentTotal,
		(
			Select sum(Att2)*@Att2AV + sum(Att3)*@Att3AV + sum(Att4)*@Att4AV + sum(Att5)*@Att5AV
			From Attendance
			Where 
			CSID = CS.CSID
			and
			ClassDate between @StartDate and @EndDate
			and
			datepart(weekday, ClassDate) != 1 and datepart(weekday, ClassDate) != 7
		) as AbsentTotal,
		(
			Select sum(Att2)*@Att2TV + sum(Att3)*@Att3TV + sum(Att4)*@Att4TV + sum(Att5)*@Att5TV
			From Attendance
			Where 
			CSID = CS.CSID
			and
			ClassDate between @StartDate and @EndDate
			and
			datepart(weekday, ClassDate) != 1 and datepart(weekday, ClassDate) != 7
		) as TardyTotal
	From 
		ClassesStudents CS
			inner join
		Attendance A
			on CS.CSID = A.CSID
	Where CS.ClassID = @ClassID




End



--Select * From #StudentTotals
--Where StudentID = 1049


Create Table #TheAttendance2
(
AttendanceID int identity,
StudentID int,
Student nvarchar(80),
Attendance nvarchar(30),
ClassDate datetime
)


Declare @ATitle1 nvarchar(50)
Declare @ATitle2 nvarchar(50)
Declare @ATitle3 nvarchar(50)
Declare @ATitle4 nvarchar(50)
Declare @ATitle5 nvarchar(50)
Declare @ATitle6 nvarchar(50)
Declare @ATitle7 nvarchar(50)
Declare @ATitle8 nvarchar(50)
Declare @ATitle9 nvarchar(50)
Declare @ATitle10 nvarchar(50)
Declare @ATitle11 nvarchar(50)
Declare @ATitle12 nvarchar(50)
Declare @ATitle13 nvarchar(50)
Declare @ATitle14 nvarchar(50)
Declare @ATitle15 nvarchar(50)
Declare @CAttendance1 nvarchar(50)
Declare @CAttendance2 nvarchar(50)
Declare @CAttendance3 nvarchar(50)
Declare @CAttendance4 nvarchar(50)
Declare @CAttendance5 nvarchar(50)


If @ClassTypeID = 5
Begin
	Set @ATitle1 = (Select ReportLegend From AttendanceSettings Where ID = 'Att1')
	Set @ATitle2 = (Select ReportLegend From AttendanceSettings Where ID = 'Att2')
	Set @ATitle3 = (Select ReportLegend From AttendanceSettings Where ID = 'Att3')
	Set @ATitle4 = (Select ReportLegend From AttendanceSettings Where ID = 'Att4')
	Set @ATitle5 = (Select ReportLegend From AttendanceSettings Where ID = 'Att5')
	Set @ATitle6 = (Select ReportLegend From AttendanceSettings Where ID = 'Att6')
	Set @ATitle7 = (Select ReportLegend From AttendanceSettings Where ID = 'Att7')
	Set @ATitle8 = (Select ReportLegend From AttendanceSettings Where ID = 'Att8')
	Set @ATitle9 = (Select ReportLegend From AttendanceSettings Where ID = 'Att9')
	Set @ATitle10 = (Select ReportLegend From AttendanceSettings Where ID = 'Att10')
	Set @ATitle11 = (Select ReportLegend From AttendanceSettings Where ID = 'Att11')
	Set @ATitle12 = (Select ReportLegend From AttendanceSettings Where ID = 'Att12')
	Set @ATitle13 = (Select ReportLegend From AttendanceSettings Where ID = 'Att13')
	Set @ATitle14 = (Select ReportLegend From AttendanceSettings Where ID = 'Att14')
	Set @ATitle15 = (Select ReportLegend From AttendanceSettings Where ID = 'Att15')		
End
Else
Begin
	Select 
	@ATitle1 = Attendance1Legend,
	@ATitle2 = Attendance2Legend,
	@ATitle3 = Attendance3Legend,
	@ATitle4 = Attendance4Legend,
	@ATitle5 = Attendance5Legend
	From Settings 
	Where SettingID = 1
End


-- Add blank days at the begining
Declare @FirstDayofWeek2 smalldatetime
Set @FirstDayofWeek2 = @FirstDayofWeek

While @FirstDayofWeek2 < @StartDate
Begin

	Insert Into #TheAttendance
	Select
		S.StudentID,
		S.Lname,
		S.Fname,
		'#Blank#' as Attendance,
		@FirstDayofWeek
	From 
		ClassesStudents CS
			inner join
		Students S
			on S.StudentID = CS.StudentID
	Where 
	CS.ClassID = @ClassID

	Set @FirstDayofWeek2 =  DATEADD(day , 1, @FirstDayofWeek2 )
 
End


-- Add Actual Attendance days
Insert Into #TheAttendance
Select
	S.StudentID,
	S.Lname,
	S.Fname,
	case
		when A.Att2 = 1 and @ATitle2 != '' then @ATitle2
		when A.Att3 = 1 and @ATitle3 != '' then @ATitle3
		when A.Att4 = 1 and @ATitle4 != '' then @ATitle4
		when A.Att5 = 1 and @ATitle5 != '' then @ATitle5
		when A.Att6 = 1 and @ATitle6 != '' then @ATitle6
		when A.Att7 = 1 and @ATitle7 != '' then @ATitle7
		when A.Att8 = 1 and @ATitle8 != '' then @ATitle8
		when A.Att9 = 1 and @ATitle9 != '' then @ATitle9
		when A.Att10 = 1 and @ATitle10 != '' then @ATitle10
		when A.Att11 = 1 and @ATitle11 != '' then @ATitle11
		when A.Att12 = 1 and @ATitle12 != '' then @ATitle12
		when A.Att13 = 1 and @ATitle13 != '' then @ATitle13
		when A.Att14 = 1 and @ATitle14 != '' then @ATitle14
		when A.Att15 = 1 and @ATitle15 != '' then @ATitle15
		when A.Att1 = 1 then @ATitle1
	end as Attendance,
	A.ClassDate
From 
	Attendance A
		inner join 
	ClassesStudents CS
		on A.CSID = CS.CSID
		inner join
	Students S
		on S.StudentID = CS.StudentID
Where 
CS.ClassID = @ClassID
and
A.ClassDate between @StartDate and @EndDate
and
datepart(weekday, ClassDate) != 1 and datepart(weekday, ClassDate) != 7



--------Find Attendance with Multiple entries ---------------------

Select 
@ClassID as ClassID,
CS.StudentID,
A.ClassDate,
(
Isnull((Select @ATitle3 + ',' From Attendance A2 Where A2.Att3 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle3 is not null), '')
+
Isnull((Select @ATitle4 + ',' From Attendance A2 Where A2.Att4 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle4 is not null), '')
+
Isnull((Select @ATitle5 + ',' From Attendance A2 Where A2.Att5 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle5 is not null), '')
+
Isnull((Select @ATitle6 + ',' From Attendance A2 Where A2.Att6 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle6 is not null), '')
+
Isnull((Select @ATitle7 + ',' From Attendance A2 Where A2.Att7 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle7 is not null), '')
+
Isnull((Select @ATitle8 + ',' From Attendance A2 Where A2.Att8 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle8 is not null), '')
+
Isnull((Select @ATitle9 + ',' From Attendance A2 Where A2.Att9 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle9 is not null), '')
+
Isnull((Select @ATitle10 + ',' From Attendance A2 Where A2.Att10 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle10 is not null), '')
+
Isnull((Select @ATitle11 + ',' From Attendance A2 Where A2.Att11 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle11 is not null), '')
+
Isnull((Select @ATitle12 + ',' From Attendance A2 Where A2.Att12 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle12 is not null), '')
+
Isnull((Select @ATitle13 + ',' From Attendance A2 Where A2.Att13 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle13 is not null), '')
+
Isnull((Select @ATitle14 + ',' From Attendance A2 Where A2.Att14 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle14 is not null), '')
+
Isnull((Select @ATitle15 + ',' From Attendance A2 Where A2.Att15 = 1 and A2.CSID = A.CSID and A2.ClassDate = A.ClassDate and @ATitle15 is not null), '')
) as AttendanceValue
into #AttendanceMultipleEntries
From
	Attendance A
		inner join 
	ClassesStudents CS
		on A.CSID = CS.CSID
Where
CS.ClassID = @ClassID
and
A.ClassDate between @StartDate and @EndDate
and
A.Att3 + A.Att4 + A.Att5 + A.Att6 + A.Att7 + A.Att8 + A.Att9 + A.Att10 + A.Att11 + A.Att12 + A.Att13 + A.Att14 + A.Att15 > 1




----- Update #TheAttendance for days that have multiple entries---------------

Update #TheAttendance
Set Attendance = substring(AM.AttendanceValue, 1, (len(AM.AttendanceValue) - 1))  -- remove the last comma
From 
#TheAttendance A
	inner join
#AttendanceMultipleEntries AM
	on 
	A.StudentID = AM.StudentID
	and
	A.ClassDate = AM.ClassDate












--Select * From #TheAttendance
--Select @EndDate as EndDate


-- Append The Tardy character for any Tardy days
--Update #TheAttendance
--Set Attendance = Attendance + 't'
--From
--#TheAttendance At
--	inner join
--ClassesStudents CS
--	on At.StudentID = CS.StudentID and CS.ClassID = @ClassID
--	inner join
--Attendance A
--	on A.CSID = CS.CSID and At.ClassDate = A.ClassDate
--Where
--(case
--	when @Att3Title like '%Tard%'and A.Att3 = 1 then 1
--	when @Att4Title like '%Tard%'and A.Att4 = 1 then 1
--	when @Att5Title like '%Tard%'and A.Att5 = 1 then 1
--	when @Att6Title like '%Tard%'and A.Att6 = 1 then 1
--	when @Att7Title like '%Tard%'and A.Att7 = 1 then 1
--	when @Att8Title like '%Tard%'and A.Att8 = 1 then 1
--	when @Att9Title like '%Tard%'and A.Att9 = 1 then 1
--	when @Att10Title like '%Tard%'and A.Att10 = 1 then 1
--	when @Att11Title like '%Tard%'and A.Att11 = 1 then 1
--	when @Att12Title like '%Tard%'and A.Att12 = 1 then 1
--	when @Att13Title like '%Tard%'and A.Att13 = 1 then 1
--	when @Att14Title like '%Tard%'and A.Att14 = 1 then 1
--	when @Att15Title like '%Tard%'and A.Att15 = 1 then 1
--	else 0
--end) = 1


--Select * From #TheAttendance


-- Add Blank days Where attendance is missing
Declare @CurrentDate2 smalldatetime
Set @CurrentDate2 = @StartDate

While @CurrentDate2 <= @EndDate
Begin

	if datepart(weekday, @CurrentDate2) != 1 and datepart(weekday, @CurrentDate2) != 7
	Begin

		Insert Into #TheAttendance
		Select
			S.StudentID,
			S.Lname,
			S.Fname,
			'#Blank#' as Attendance,
			@CurrentDate2
		From 
			ClassesStudents CS
				inner join
			Students S
				on S.StudentID = CS.StudentID
		Where 
		CS.ClassID = @ClassID
		and
		@CurrentDate2 not in 
		(
		Select ClassDate 
		From 
		Attendance A
		Where 
		A.CSID = CS.CSID

		)

	End

	Set @CurrentDate2 =  DATEADD(day, 1, @CurrentDate2 )
 
End




-- Add Blank days at the end
Declare @LastDayofWeek2 smalldatetime
Set @LastDayofWeek2 = @LastDayofWeek

While @LastDayofWeek2 > @EndDate
Begin

	Insert Into #TheAttendance
	Select
		S.StudentID,
		S.Lname,
		S.Fname,
		'#Blank#' as Attendance,
		@LastDayofWeek2
	From 
		ClassesStudents CS
			inner join
		Students S
			on S.StudentID = CS.StudentID
	Where 
	CS.ClassID = @ClassID

	Set @LastDayofWeek2 =  DATEADD(day , -1, @LastDayofWeek2 )
 
End












--Set @NumberofWeeks = (Select count(*)/5 From #SchoolDates)

--Select @NumberofWeeks as NumberofWeeks 
--
--Select * From #TheAttendance
--
--Select 'Test' as Test




---- Insert Blank Days into #TheAttendance Table
--Declare @BlankAttendanceCount int
--Set @BlankAttendanceCount = 0
--
--While @BlankAttendanceCount < @BlankAttendanceToAdd
--Begin
--	Insert into #TheAttendance (StudentID, Lname, Fname, Attendance, ClassDate)
--	Select 
--		CS.StudentID,
--		S.Lname,
--		S.Fname,
--		null,
--		'3000/01/01' as ClassDate
--	From 	ClassesStudents CS
--				inner join
--			Students S
--				on S.StudentID = CS.StudentID
--	Where ClassID = @ClassID
--
--	Set @BlankAttendanceCount = @BlankAttendanceCount + 1
--End


-- Order #TheAttendance data into table #TheAttendance2
Insert into #TheAttendance2
Select
	StudentID,
	Lname + ', ' + Fname as StudentName,
	Attendance,
	ClassDate
From #TheAttendance
Order By Lname, Fname, StudentID, ClassDate


--Select * From #TheAttendance2
--
--Select @NumberofWeeks as NumberofWeeks

If @NumberofWeeks = 1
Begin
	Create Table #StudentsAttendance1W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 2
Begin
	Create Table #StudentsAttendance2W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 3
Begin
	Create Table #StudentsAttendance3W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 4
Begin
	Create Table #StudentsAttendance4W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 5
Begin
	Create Table #StudentsAttendance5W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 6
Begin
	Create Table #StudentsAttendance6W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 7
Begin
	Create Table #StudentsAttendance7W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 8
Begin
	Create Table #StudentsAttendance8W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 9
Begin
	Create Table #StudentsAttendance9W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 10
Begin
	Create Table #StudentsAttendance10W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 11
Begin
	Create Table #StudentsAttendance11W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 12
Begin
	Create Table #StudentsAttendance12W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 13
Begin
	Create Table #StudentsAttendance13W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 14
Begin
	Create Table #StudentsAttendance14W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col67 nvarchar(50),
	Col68 nvarchar(50),
	Col69 nvarchar(50),
	Col70 nvarchar(50),
	Col71 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 15
Begin
	Create Table #StudentsAttendance15W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col67 nvarchar(50),
	Col68 nvarchar(50),
	Col69 nvarchar(50),
	Col70 nvarchar(50),
	Col71 nvarchar(50),
	Col72 nvarchar(50),
	Col73 nvarchar(50),
	Col74 nvarchar(50),
	Col75 nvarchar(50),
	Col76 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End
If @NumberofWeeks = 16
Begin
	Create Table #StudentsAttendance16W
	(
	IDCol int IDENTITY(1,1),
	Col1 nvarchar(50),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col67 nvarchar(50),
	Col68 nvarchar(50),
	Col69 nvarchar(50),
	Col70 nvarchar(50),
	Col71 nvarchar(50),
	Col72 nvarchar(50),
	Col73 nvarchar(50),
	Col74 nvarchar(50),
	Col75 nvarchar(50),
	Col76 nvarchar(50),
	Col77 nvarchar(50),
	Col78 nvarchar(50),
	Col79 nvarchar(50),
	Col80 nvarchar(50),
	Col81 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)
End


--While (Select Count(*) From #TheAttendance2) > 0
--Begin

Insert into #StudentNames2
Select StudentID, StudentName
From #StudentNames

Declare @SACol1 nvarchar(50)
Declare @SACol2 nvarchar(50)
Declare @SACol3 nvarchar(50)
Declare @SACol4 nvarchar(50)
Declare @SACol5 nvarchar(50)
Declare @SACol6 nvarchar(50)
Declare @SACol7 nvarchar(50)
Declare @SACol8 nvarchar(50)
Declare @SACol9 nvarchar(50)
Declare @SACol10 nvarchar(50)
Declare @SACol11 nvarchar(50)
Declare @SACol12 nvarchar(50)
Declare @SACol13 nvarchar(50)
Declare @SACol14 nvarchar(50)
Declare @SACol15 nvarchar(50)
Declare @SACol16 nvarchar(50)
Declare @SACol17 nvarchar(50)
Declare @SACol18 nvarchar(50)
Declare @SACol19 nvarchar(50)
Declare @SACol20 nvarchar(50)
Declare @SACol21 nvarchar(50)
Declare @SACol22 nvarchar(50)
Declare @SACol23 nvarchar(50)
Declare @SACol24 nvarchar(50)
Declare @SACol25 nvarchar(50)
Declare @SACol26 nvarchar(50)
Declare @SACol27 nvarchar(50)
Declare @SACol28 nvarchar(50)
Declare @SACol29 nvarchar(50)
Declare @SACol30 nvarchar(50)
Declare @SACol31 nvarchar(50)
Declare @SACol32 nvarchar(50)
Declare @SACol33 nvarchar(50)
Declare @SACol34 nvarchar(50)
Declare @SACol35 nvarchar(50)
Declare @SACol36 nvarchar(50)
Declare @SACol37 nvarchar(50)
Declare @SACol38 nvarchar(50)
Declare @SACol39 nvarchar(50)
Declare @SACol40 nvarchar(50)
Declare @SACol41 nvarchar(50)
Declare @SACol42 nvarchar(50)
Declare @SACol43 nvarchar(50)
Declare @SACol44 nvarchar(50)
Declare @SACol45 nvarchar(50)
Declare @SACol46 nvarchar(50)
Declare @SACol47 nvarchar(50)
Declare @SACol48 nvarchar(50)
Declare @SACol49 nvarchar(50)
Declare @SACol50 nvarchar(50)
Declare @SACol51 nvarchar(50)
Declare @SACol52 nvarchar(50)
Declare @SACol53 nvarchar(50)
Declare @SACol54 nvarchar(50)
Declare @SACol55 nvarchar(50)
Declare @SACol56 nvarchar(50)
Declare @SACol57 nvarchar(50)
Declare @SACol58 nvarchar(50)
Declare @SACol59 nvarchar(50)
Declare @SACol60 nvarchar(50)
Declare @SACol61 nvarchar(50)
Declare @SACol62 nvarchar(50)
Declare @SACol63 nvarchar(50)
Declare @SACol64 nvarchar(50)
Declare @SACol65 nvarchar(50)
Declare @SACol66 nvarchar(50)
Declare @SACol67 nvarchar(50)
Declare @SACol68 nvarchar(50)
Declare @SACol69 nvarchar(50)
Declare @SACol70 nvarchar(50)
Declare @SACol71 nvarchar(50)
Declare @SACol72 nvarchar(50)
Declare @SACol73 nvarchar(50)
Declare @SACol74 nvarchar(50)
Declare @SACol75 nvarchar(50)
Declare @SACol76 nvarchar(50)
Declare @SACol77 nvarchar(50)
Declare @SACol78 nvarchar(50)
Declare @SACol79 nvarchar(50)
Declare @SACol80 nvarchar(50)
Declare @SACol81 nvarchar(50)
Declare @SACol82 nvarchar(50)
Declare @SACol83 nvarchar(50)
Declare @SACol84 nvarchar(50)
Declare @StudentID int
Declare @AttendanceID int

--Select 'Test' as Test

	While (Select Count(*) From #StudentNames2) > 0
	Begin
	
		Set @SACol1 = '#Blank#'
		Set @SACol2 = '#Blank#'
		Set @SACol3 = '#Blank#'
		Set @SACol4 = '#Blank#'
		Set @SACol5 = '#Blank#'
		Set @SACol6 = '#Blank#'
		Set @SACol7 = '#Blank#'
		Set @SACol8 = '#Blank#'
		Set @SACol9 = '#Blank#'
		Set @SACol10 = '#Blank#'
		Set @SACol11 = '#Blank#'
		Set @SACol12 = '#Blank#'
		Set @SACol13 = '#Blank#'
		Set @SACol14 = '#Blank#'
		Set @SACol15 = '#Blank#'
		Set @SACol16 = '#Blank#'
		Set @SACol17 = '#Blank#'
		Set @SACol18 = '#Blank#'
		Set @SACol19 = '#Blank#'
		Set @SACol20 = '#Blank#'
		Set @SACol21 = '#Blank#'
		Set @SACol22 = '#Blank#'
		Set @SACol23 = '#Blank#'
		Set @SACol24 = '#Blank#'
		Set @SACol25 = '#Blank#'
		Set @SACol26 = '#Blank#'
		Set @SACol27 = '#Blank#'
		Set @SACol28 = '#Blank#'
		Set @SACol29 = '#Blank#'
		Set @SACol30 = '#Blank#'
		Set @SACol31 = '#Blank#'
		Set @SACol32 = '#Blank#'
		Set @SACol33 = '#Blank#'
		Set @SACol34 = '#Blank#'
		Set @SACol35 = '#Blank#'
		Set @SACol36 = '#Blank#'
		Set @SACol37 = '#Blank#'
		Set @SACol38 = '#Blank#'
		Set @SACol39 = '#Blank#'
		Set @SACol40 = '#Blank#'
		Set @SACol41 = '#Blank#'
		Set @SACol42 = '#Blank#'
		Set @SACol43 = '#Blank#'
		Set @SACol44 = '#Blank#'
		Set @SACol45 = '#Blank#'
		Set @SACol46 = '#Blank#'
		Set @SACol47 = '#Blank#'
		Set @SACol48 = '#Blank#'
		Set @SACol49 = '#Blank#'
		Set @SACol50 = '#Blank#'
		Set @SACol51 = '#Blank#'
		Set @SACol52 = '#Blank#'
		Set @SACol53 = '#Blank#'
		Set @SACol54 = '#Blank#'
		Set @SACol55 = '#Blank#'
		Set @SACol56 = '#Blank#'
		Set @SACol57 = '#Blank#'
		Set @SACol58 = '#Blank#'
		Set @SACol59 = '#Blank#'
		Set @SACol60 = '#Blank#'
		Set @SACol61 = '#Blank#'
		Set @SACol62 = '#Blank#'
		Set @SACol63 = '#Blank#'
		Set @SACol64 = '#Blank#'
		Set @SACol65 = '#Blank#'
		Set @SACol66 = '#Blank#'
		Set @SACol67 = '#Blank#'
		Set @SACol68 = '#Blank#'
		Set @SACol69 = '#Blank#'
		Set @SACol70 = '#Blank#'
		Set @SACol71 = '#Blank#'
		Set @SACol72 = '#Blank#'
		Set @SACol73 = '#Blank#'
		Set @SACol74 = '#Blank#'
		Set @SACol75 = '#Blank#'
		Set @SACol76 = '#Blank#'
		Set @SACol77 = '#Blank#'
		Set @SACol78 = '#Blank#'
		Set @SACol79 = '#Blank#'
		Set @SACol80 = '#Blank#'
		Set @SACol81 = '#Blank#'
		Set @SACol82 = '#Blank#'
		Set @SACol83 = '#Blank#'
		Set @SACol84 = '#Blank#'


		Select top 1
			@StudentID = StudentID,
			@SACol1 = StudentName
		From #StudentNames2
		Delete From #StudentNames2 Where StudentID = @StudentID

		If @NumberofWeeks >= 1
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol2 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
			
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol3 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol4 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol5 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol6 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 2
		Begin

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol7 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol8 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol9 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol10 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol11 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

		End
		If @NumberofWeeks >= 3
		Begin	
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol12 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
			
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol13 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol14 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol15 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol16 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 4
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol17 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol18 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol19 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol20 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol21 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 5
		Begin	
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol22 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
			
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol23 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol24 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol25 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol26 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 6
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol27 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol28 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol29 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol30 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol31 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 7
		Begin	
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol32 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
			
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol33 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol34 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol35 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol36 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID	
		End
		If @NumberofWeeks >= 8
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol37 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol38 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol39 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol40 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol41 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 9
		Begin	
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol42 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
			
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol43 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol44 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol45 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol46 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 10
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol47 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol48 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol49 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol50 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol51 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 11
		Begin	
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol52 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
			
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol53 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol54 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol55 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol56 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 12
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol57 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol58 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol59 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol60 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol61 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 13
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol62 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol63 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol64 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol65 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol66 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 14
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol67 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol68 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol69 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol70 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol71 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 15
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol72 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol73 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol74 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol75 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol76 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End
		If @NumberofWeeks >= 16
		Begin
				Select top 1
					@AttendanceID = AttendanceID,
					@SACol77 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol78 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol79 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol80 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID

				Select top 1
					@AttendanceID = AttendanceID,
					@SACol81 = Attendance
				From #TheAttendance2
				Where StudentID = @StudentID
				Delete From #TheAttendance2 Where AttendanceID = @AttendanceID
		End





				Select
					@SACol82 = PresentTotal
				From #StudentTotals
				Where StudentID = @StudentID

				Select
					@SACol83 = AbsentTotal
				From #StudentTotals
				Where StudentID = @StudentID

				Select
					@SACol84 = TardyTotal
				From #StudentTotals
				Where StudentID = @StudentID

		If @NumberofWeeks = 1
		Begin	
				Insert into #StudentsAttendance1W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 2
		Begin	
				Insert into #StudentsAttendance2W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 3
		Begin	
				Insert into #StudentsAttendance3W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 4
		Begin	
				Insert into #StudentsAttendance4W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 5
		Begin	
				Insert into #StudentsAttendance5W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 6
		Begin	
				Insert into #StudentsAttendance6W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 7
		Begin	
				Insert into #StudentsAttendance7W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 8
		Begin	
				Insert into #StudentsAttendance8W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 9
		Begin	
				Insert into #StudentsAttendance9W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 10
		Begin	
				Insert into #StudentsAttendance10W
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col47, 
					Col48, 
					Col49,
					Col50,
					Col51, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol47,
					@SACol48,
					@SACol49,
					@SACol50,
					@SACol51,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 11
		Begin	
				Insert into #StudentsAttendance11W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col47, 
					Col48, 
					Col49,
					Col50,
					Col51, 
					Col52, 
					Col53, 
					Col54, 
					Col55, 
					Col56, 
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol47,
					@SACol48,
					@SACol49,
					@SACol50,
					@SACol51,
					@SACol52,
					@SACol53,
					@SACol54,
					@SACol55,
					@SACol56,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 12
		Begin	
				Insert into #StudentsAttendance12W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col47, 
					Col48, 
					Col49,
					Col50,
					Col51, 
					Col52, 
					Col53, 
					Col54, 
					Col55, 
					Col56, 
					Col57, 
					Col58, 
					Col59,
					Col60,
					Col61,
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol47,
					@SACol48,
					@SACol49,
					@SACol50,
					@SACol51,
					@SACol52,
					@SACol53,
					@SACol54,
					@SACol55,
					@SACol56,
					@SACol57,
					@SACol58,
					@SACol59,
					@SACol60,
					@SACol61,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 13
		Begin	
				Insert into #StudentsAttendance13W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col47, 
					Col48, 
					Col49,
					Col50,
					Col51, 
					Col52, 
					Col53, 
					Col54, 
					Col55, 
					Col56, 
					Col57, 
					Col58, 
					Col59,
					Col60,
					Col61,
					Col62,
					Col63,
					Col64,
					Col65,
					Col66,
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol47,
					@SACol48,
					@SACol49,
					@SACol50,
					@SACol51,
					@SACol52,
					@SACol53,
					@SACol54,
					@SACol55,
					@SACol56,
					@SACol57,
					@SACol58,
					@SACol59,
					@SACol60,
					@SACol61,
					@SACol62,
					@SACol63,
					@SACol64,
					@SACol65,
					@SACol66,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 14
		Begin	
				Insert into #StudentsAttendance14W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col47, 
					Col48, 
					Col49,
					Col50,
					Col51, 
					Col52, 
					Col53, 
					Col54, 
					Col55, 
					Col56, 
					Col57, 
					Col58, 
					Col59,
					Col60,
					Col61,
					Col62,
					Col63,
					Col64,
					Col65,
					Col66,
					Col67,
					Col68,
					Col69,
					Col70,
					Col71,
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol47,
					@SACol48,
					@SACol49,
					@SACol50,
					@SACol51,
					@SACol52,
					@SACol53,
					@SACol54,
					@SACol55,
					@SACol56,
					@SACol57,
					@SACol58,
					@SACol59,
					@SACol60,
					@SACol61,
					@SACol62,
					@SACol63,
					@SACol64,
					@SACol65,
					@SACol66,
					@SACol67,
					@SACol68,
					@SACol69,
					@SACol70,
					@SACol71,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 15
		Begin	
				Insert into #StudentsAttendance15W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col47, 
					Col48, 
					Col49,
					Col50,
					Col51, 
					Col52, 
					Col53, 
					Col54, 
					Col55, 
					Col56, 
					Col57, 
					Col58, 
					Col59,
					Col60,
					Col61,
					Col62,
					Col63,
					Col64,
					Col65,
					Col66,
					Col67,
					Col68,
					Col69,
					Col70,
					Col71,
					Col72,
					Col73,
					Col74,
					Col75,
					Col76,
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol47,
					@SACol48,
					@SACol49,
					@SACol50,
					@SACol51,
					@SACol52,
					@SACol53,
					@SACol54,
					@SACol55,
					@SACol56,
					@SACol57,
					@SACol58,
					@SACol59,
					@SACol60,
					@SACol61,
					@SACol62,
					@SACol63,
					@SACol64,
					@SACol65,
					@SACol66,
					@SACol67,
					@SACol68,
					@SACol69,
					@SACol70,
					@SACol71,
					@SACol72,
					@SACol73,
					@SACol74,
					@SACol75,
					@SACol76,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End
		If @NumberofWeeks = 16
		Begin	
				Insert into #StudentsAttendance16W 
				(
					Col1, 
					Col2, 
					Col3, 
					Col4, 
					Col5, 
					Col6, 
					Col7, 
					Col8, 
					Col9,
					Col10,
					Col11, 
					Col12, 
					Col13, 
					Col14, 
					Col15, 
					Col16, 
					Col17, 
					Col18, 
					Col19,
					Col20,
					Col21, 
					Col22, 
					Col23, 
					Col24, 
					Col25, 
					Col26, 
					Col27, 
					Col28, 
					Col29,
					Col30,
					Col31, 
					Col32, 
					Col33, 
					Col34, 
					Col35, 
					Col36, 
					Col37, 
					Col38, 
					Col39,
					Col40,
					Col41, 
					Col42, 
					Col43, 
					Col44, 
					Col45, 
					Col46, 
					Col47, 
					Col48, 
					Col49,
					Col50,
					Col51, 
					Col52, 
					Col53, 
					Col54, 
					Col55, 
					Col56, 
					Col57, 
					Col58, 
					Col59,
					Col60,
					Col61,
					Col62,
					Col63,
					Col64,
					Col65,
					Col66,
					Col67,
					Col68,
					Col69,
					Col70,
					Col71,
					Col72,
					Col73,
					Col74,
					Col75,
					Col76,
					Col77,
					Col78,
					Col79,
					Col80,
					Col81,
					Col82,
					Col83,
					Col84
				)
				Values
				(
					@SACol1,
					@SACol2,
					@SACol3,
					@SACol4,
					@SACol5,
					@SACol6,
					@SACol7,
					@SACol8,
					@SACol9,
					@SACol10,
					@SACol11,
					@SACol12,
					@SACol13,
					@SACol14,
					@SACol15,
					@SACol16,
					@SACol17,
					@SACol18,
					@SACol19,
					@SACol20,
					@SACol21,
					@SACol22,
					@SACol23,
					@SACol24,
					@SACol25,
					@SACol26,
					@SACol27,
					@SACol28,
					@SACol29,
					@SACol30,
					@SACol31,
					@SACol32,
					@SACol33,
					@SACol34,
					@SACol35,
					@SACol36,
					@SACol37,
					@SACol38,
					@SACol39,
					@SACol40,
					@SACol41,
					@SACol42,
					@SACol43,
					@SACol44,
					@SACol45,
					@SACol46,
					@SACol47,
					@SACol48,
					@SACol49,
					@SACol50,
					@SACol51,
					@SACol52,
					@SACol53,
					@SACol54,
					@SACol55,
					@SACol56,
					@SACol57,
					@SACol58,
					@SACol59,
					@SACol60,
					@SACol61,
					@SACol62,
					@SACol63,
					@SACol64,
					@SACol65,
					@SACol66,
					@SACol67,
					@SACol68,
					@SACol69,
					@SACol70,
					@SACol71,
					@SACol72,
					@SACol73,
					@SACol74,
					@SACol75,
					@SACol76,
					@SACol77,
					@SACol78,
					@SACol79,
					@SACol80,
					@SACol81,
					@SACol82,
					@SACol83,
					@SACol84
				)
		End




	
	End


--End


--select * From #StudentsAttendance7W




-- Create Months Table

Select 
count(TheDayMonth) as MonthCount,
MonthNumber,
MonthYear,
TheDayMonth
into #MonthTable
From #SchoolDates
Group By TheDayMonth, MonthNumber, MonthYear
Order By MonthYear, MonthNumber


Update #MonthTable
Set TheDayMonth =
case
	when MonthCount < 2 then ' '
	when MonthCount < 5 and len(TheDayMonth) > 4 then substring(TheDayMonth, 1, 3)
	else TheDayMonth
end




Create Table #DatesTransposed
(
IDCol int IDENTITY(1,1),
Col1 nvarchar(50),
Col2 nvarchar(50),
Col3 nvarchar(50),
Col4 nvarchar(50),
Col5 nvarchar(50),
Col6 nvarchar(50),
Col7 nvarchar(50),
Col8 nvarchar(50),
Col9 nvarchar(50),
Col10 nvarchar(50),
Col11 nvarchar(50),
Col12 nvarchar(50),
Col13 nvarchar(50),
Col14 nvarchar(50),
Col15 nvarchar(50),
Col16 nvarchar(50),
Col17 nvarchar(50),
Col18 nvarchar(50),
Col19 nvarchar(50),
Col20 nvarchar(50),
Col21 nvarchar(50),
Col22 nvarchar(50),
Col23 nvarchar(50),
Col24 nvarchar(50),
Col25 nvarchar(50),
Col26 nvarchar(50),
Col27 nvarchar(50),
Col28 nvarchar(50),
Col29 nvarchar(50),
Col30 nvarchar(50),
Col31 nvarchar(50),
Col32 nvarchar(50),
Col33 nvarchar(50),
Col34 nvarchar(50),
Col35 nvarchar(50),
Col36 nvarchar(50),
Col37 nvarchar(50),
Col38 nvarchar(50),
Col39 nvarchar(50),
Col40 nvarchar(50),
Col41 nvarchar(50),
Col42 nvarchar(50),
Col43 nvarchar(50),
Col44 nvarchar(50),
Col45 nvarchar(50),
Col46 nvarchar(50),
Col47 nvarchar(50),
Col48 nvarchar(50),
Col49 nvarchar(50),
Col50 nvarchar(50),
Col51 nvarchar(50),
Col52 nvarchar(50),
Col53 nvarchar(50),
Col54 nvarchar(50),
Col55 nvarchar(50),
Col56 nvarchar(50),
Col57 nvarchar(50),
Col58 nvarchar(50),
Col59 nvarchar(50),
Col60 nvarchar(50),
Col61 nvarchar(50),
Col62 nvarchar(50),
Col63 nvarchar(50),
Col64 nvarchar(50),
Col65 nvarchar(50),
Col66 nvarchar(50),
Col67 nvarchar(50),
Col68 nvarchar(50),
Col69 nvarchar(50),
Col70 nvarchar(50),
Col71 nvarchar(50),
Col72 nvarchar(50),
Col73 nvarchar(50),
Col74 nvarchar(50),
Col75 nvarchar(50),
Col76 nvarchar(50),
Col77 nvarchar(50),
Col78 nvarchar(50),
Col79 nvarchar(50),
Col80 nvarchar(50),
Col81 nvarchar(50),
Col82 nvarchar(50),
Col83 nvarchar(50),
Col84 nvarchar(50)
)

Declare @DateID int


While (Select Count(*) From #SchoolDates) > 0
Begin

	Select @SACol1 = 'Signature'

	Select top 1
		@DateID = DateID,
		@SACol2 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol3 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol4 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol5 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol6 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol7 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol8 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol9 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol10 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol11 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol12 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol13 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol14 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol15 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol16 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol17 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol18 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol19 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol20 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol21 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol22 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol23 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol24 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol25 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol26 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol27 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol28 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol29 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol30 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol31 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol32 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol33 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol34 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol35 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol36 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol37 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol38 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol39 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol40 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol41 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol42 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol43 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol44 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol45 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol46 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol47 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol48 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol49 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol50 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol51 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol52 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol53 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol54 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol55 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol56 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol57 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol58 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol59 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol60 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol61 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID
-----
	Select top 1
		@DateID = DateID,
		@SACol62 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol63 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol64 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol65 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol66 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol67 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol68 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol69 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol70 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol71 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol72 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol73 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol74 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol75 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol76 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol77 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol78 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol79 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol80 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID

	Select top 1
		@DateID = DateID,
		@SACol81 = TheDayMonth + '|DName|' + TheDayName + '|DNum|' + convert(char(2),TheDayNumber)
	From #SchoolDates
	Delete From #SchoolDates Where DateID = @DateID



Select @SACol82 = 'Present'

Select @SACol83 = 'Absent'

Select @SACol84 = 'Tardy'








	Insert into #DatesTransposed 
	(
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61,
		Col62,
		Col63,
		Col64,
		Col65, 
		Col66, 
		Col67, 
		Col68, 
		Col69,
		Col70,
		Col71, 
		Col72, 
		Col73, 
		Col74, 
		Col75, 
		Col76, 
		Col77, 
		Col78, 
		Col79,
		Col80,
		Col81,
		Col82,
		Col83,
		Col84
	)
	Values
	(
		@SACol1,
		@SACol2,
		@SACol3,
		@SACol4,
		@SACol5,
		@SACol6,
		@SACol7,
		@SACol8,
		@SACol9,
		@SACol10,
		@SACol11,
		@SACol12,
		@SACol13,
		@SACol14,
		@SACol15,
		@SACol16,
		@SACol17,
		@SACol18,
		@SACol19,
		@SACol20,
		@SACol21,
		@SACol22,
		@SACol23,
		@SACol24,
		@SACol25,
		@SACol26,
		@SACol27,
		@SACol28,
		@SACol29,
		@SACol30,
		@SACol31,
		@SACol32,
		@SACol33,
		@SACol34,
		@SACol35,
		@SACol36,
		@SACol37,
		@SACol38,
		@SACol39,
		@SACol40,
		@SACol41,
		@SACol42,
		@SACol43,
		@SACol44,
		@SACol45,
		@SACol46,
		@SACol47,
		@SACol48,
		@SACol49,
		@SACol50,
		@SACol51,
		@SACol52,
		@SACol53,
		@SACol54,
		@SACol55,
		@SACol56,
		@SACol57,
		@SACol58,
		@SACol59,
		@SACol60,
		@SACol61,
		@SACol62,
		@SACol63,
		@SACol64,
		@SACol65,
		@SACol66,
		@SACol67,
		@SACol68,
		@SACol69,
		@SACol70,
		@SACol71,
		@SACol72,
		@SACol73,
		@SACol74,
		@SACol75,
		@SACol76,
		@SACol77,
		@SACol78,
		@SACol79,
		@SACol80,
		@SACol81,
		@SACol82,
		@SACol83,
		@SACol84
	)





End


-- Compile MainAttendance Table



If @NumberofWeeks = 1
Begin	

	Create Table #MainAttendance1W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance1W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance1W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance1W

		Select * From #MainAttendance1W FOR XML RAW

End

If @NumberofWeeks = 2
Begin	

	Create Table #MainAttendance2W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance2W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11,  
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance2W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11,  
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance2W

		Select * From #MainAttendance2W FOR XML RAW

End

If @NumberofWeeks = 3
Begin	

	Create Table #MainAttendance3W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance3W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance3W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance3W

		Select * From #MainAttendance3W FOR XML RAW

End

If @NumberofWeeks = 4
Begin	

	Create Table #MainAttendance4W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance4W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance4W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance4W

		Select * From #MainAttendance4W FOR XML RAW

End

If @NumberofWeeks = 5
Begin	

	Create Table #MainAttendance5W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance5W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26,  
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance5W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance5W

		Select * From #MainAttendance5W FOR XML RAW

End

If @NumberofWeeks = 6
Begin	

	Create Table #MainAttendance6W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance6W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance6W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31,  
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance6W

		Select * From #MainAttendance6W FOR XML RAW

End

If @NumberofWeeks = 7
Begin	

	Create Table #MainAttendance7W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance7W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36,  
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance7W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36,  
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance7W

		Select * From #MainAttendance7W FOR XML RAW

End

If @NumberofWeeks = 8
Begin	

	Create Table #MainAttendance8W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance8W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance8W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41,  
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance8W

		Select * From #MainAttendance8W FOR XML RAW

End

If @NumberofWeeks = 9
Begin	

	Create Table #MainAttendance9W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance9W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance9W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46,  
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance9W

		Select * From #MainAttendance9W FOR XML RAW

End

If @NumberofWeeks = 10
Begin	

	Create Table #MainAttendance10W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance10W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance10W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51,  
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance10W

		Select * From #MainAttendance10W FOR XML RAW

End

If @NumberofWeeks = 11
Begin	

	Create Table #MainAttendance11W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance11W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance11W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance11W

		Select * From #MainAttendance11W FOR XML RAW

End

If @NumberofWeeks = 12
Begin	

	Create Table #MainAttendance12W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance12W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance12W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance12W

		Select * From #MainAttendance12W FOR XML RAW

End
If @NumberofWeeks = 13
Begin	

	Create Table #MainAttendance13W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance13W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance13W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance13W

		Select * From #MainAttendance13W FOR XML RAW

End
If @NumberofWeeks = 14
Begin	

	Create Table #MainAttendance14W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col67 nvarchar(50),
	Col68 nvarchar(50),
	Col69 nvarchar(50),
	Col70 nvarchar(50),
	Col71 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance14W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col67, 
		Col68, 
		Col69,
		Col70,
		Col71, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance14W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col67, 
		Col68, 
		Col69,
		Col70,
		Col71, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance14W

		Select * From #MainAttendance14W FOR XML RAW

End
If @NumberofWeeks = 15
Begin	

	Create Table #MainAttendance15W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col67 nvarchar(50),
	Col68 nvarchar(50),
	Col69 nvarchar(50),
	Col70 nvarchar(50),
	Col71 nvarchar(50),
	Col72 nvarchar(50),
	Col73 nvarchar(50),
	Col74 nvarchar(50),
	Col75 nvarchar(50),
	Col76 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance15W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col67, 
		Col68, 
		Col69,
		Col70,
		Col71, 
		Col72, 
		Col73, 
		Col74,
		Col75,
		Col76, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance15W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col67, 
		Col68, 
		Col69,
		Col70,
		Col71, 
		Col72, 
		Col73, 
		Col74,
		Col75,
		Col76, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance15W

		Select * From #MainAttendance15W FOR XML RAW

End
If @NumberofWeeks = 16
Begin	

	Create Table #MainAttendance16W
	(
	Col1 nvarchar(100),
	Col2 nvarchar(50),
	Col3 nvarchar(50),
	Col4 nvarchar(50),
	Col5 nvarchar(50),
	Col6 nvarchar(50),
	Col7 nvarchar(50),
	Col8 nvarchar(50),
	Col9 nvarchar(50),
	Col10 nvarchar(50),
	Col11 nvarchar(50),
	Col12 nvarchar(50),
	Col13 nvarchar(50),
	Col14 nvarchar(50),
	Col15 nvarchar(50),
	Col16 nvarchar(50),
	Col17 nvarchar(50),
	Col18 nvarchar(50),
	Col19 nvarchar(50),
	Col20 nvarchar(50),
	Col21 nvarchar(50),
	Col22 nvarchar(50),
	Col23 nvarchar(50),
	Col24 nvarchar(50),
	Col25 nvarchar(50),
	Col26 nvarchar(50),
	Col27 nvarchar(50),
	Col28 nvarchar(50),
	Col29 nvarchar(50),
	Col30 nvarchar(50),
	Col31 nvarchar(50),
	Col32 nvarchar(50),
	Col33 nvarchar(50),
	Col34 nvarchar(50),
	Col35 nvarchar(50),
	Col36 nvarchar(50),
	Col37 nvarchar(50),
	Col38 nvarchar(50),
	Col39 nvarchar(50),
	Col40 nvarchar(50),
	Col41 nvarchar(50),
	Col42 nvarchar(50),
	Col43 nvarchar(50),
	Col44 nvarchar(50),
	Col45 nvarchar(50),
	Col46 nvarchar(50),
	Col47 nvarchar(50),
	Col48 nvarchar(50),
	Col49 nvarchar(50),
	Col50 nvarchar(50),
	Col51 nvarchar(50),
	Col52 nvarchar(50),
	Col53 nvarchar(50),
	Col54 nvarchar(50),
	Col55 nvarchar(50),
	Col56 nvarchar(50),
	Col57 nvarchar(50),
	Col58 nvarchar(50),
	Col59 nvarchar(50),
	Col60 nvarchar(50),
	Col61 nvarchar(50),
	Col62 nvarchar(50),
	Col63 nvarchar(50),
	Col64 nvarchar(50),
	Col65 nvarchar(50),
	Col66 nvarchar(50),
	Col67 nvarchar(50),
	Col68 nvarchar(50),
	Col69 nvarchar(50),
	Col70 nvarchar(50),
	Col71 nvarchar(50),
	Col72 nvarchar(50),
	Col73 nvarchar(50),
	Col74 nvarchar(50),
	Col75 nvarchar(50),
	Col76 nvarchar(50),
	Col77 nvarchar(50),
	Col78 nvarchar(50),
	Col79 nvarchar(50),
	Col80 nvarchar(50),
	Col81 nvarchar(50),
	Col82 nvarchar(50),
	Col83 nvarchar(50),
	Col84 nvarchar(50)
	)


		Insert Into #MainAttendance16W
		Select top 1 
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col67, 
		Col68, 
		Col69,
		Col70,
		Col71, 
		Col72, 
		Col73, 
		Col74,
		Col75,
		Col76, 
		Col77, 
		Col78, 
		Col79,
		Col80,
		Col81, 
		Col82, 
		Col83, 
		Col84
		From #DatesTransposed


		Insert Into #MainAttendance16W
		Select
		Col1, 
		Col2, 
		Col3, 
		Col4, 
		Col5, 
		Col6, 
		Col7, 
		Col8, 
		Col9,
		Col10,
		Col11, 
		Col12, 
		Col13, 
		Col14, 
		Col15, 
		Col16, 
		Col17, 
		Col18, 
		Col19,
		Col20,
		Col21, 
		Col22, 
		Col23, 
		Col24, 
		Col25, 
		Col26, 
		Col27, 
		Col28, 
		Col29,
		Col30,
		Col31, 
		Col32, 
		Col33, 
		Col34, 
		Col35, 
		Col36, 
		Col37, 
		Col38, 
		Col39,
		Col40,
		Col41, 
		Col42, 
		Col43, 
		Col44, 
		Col45, 
		Col46, 
		Col47, 
		Col48, 
		Col49,
		Col50,
		Col51, 
		Col52, 
		Col53, 
		Col54, 
		Col55, 
		Col56, 
		Col57, 
		Col58, 
		Col59,
		Col60,
		Col61, 
		Col62, 
		Col63, 
		Col64,
		Col65,
		Col66, 
		Col67, 
		Col68, 
		Col69,
		Col70,
		Col71, 
		Col72, 
		Col73, 
		Col74,
		Col75,
		Col76, 
		Col77, 
		Col78, 
		Col79,
		Col80,
		Col81, 
		Col82, 
		Col83, 
		Col84
		From #StudentsAttendance16W

		Select * From #MainAttendance16W FOR XML RAW

End








Select 
1 as tag,
null as parent,
MonthCount as [Month!1!MonthCount],
MonthNumber as [Month!1!MonthNumber],
TheDayMonth as [Month!1!TheDayMonth]
From #MonthTable
For XML EXPLICIT


Declare @TermTitle nvarchar(40)
Set @TermTitle = (	Select TermTitle 
					From 
					Terms T
						inner join
					Classes C
						on T.TermID = C.TermID
					Where ClassID = @ClassID)


Declare @ReportLegend nvarchar(400)

Declare @Att1Legend nvarchar(10)
Declare @Att2Legend nvarchar(10)
Declare @Att3Legend nvarchar(10)
Declare @Att4Legend nvarchar(10)
Declare @Att5Legend nvarchar(10)
Declare @Att6Legend nvarchar(10)
Declare @Att7Legend nvarchar(10)
Declare @Att8Legend nvarchar(10)
Declare @Att9Legend nvarchar(10)
Declare @Att10Legend nvarchar(10)
Declare @Att11Legend nvarchar(10)
Declare @Att12Legend nvarchar(10)
Declare @Att13Legend nvarchar(10)
Declare @Att14Legend nvarchar(10)
Declare @Att15Legend nvarchar(10)

Declare @Att1FullTitle nvarchar(50)
Declare @Att2FullTitle nvarchar(50)
Declare @Att3FullTitle nvarchar(50)
Declare @Att4FullTitle nvarchar(50)
Declare @Att5FullTitle nvarchar(50)
Declare @Att6FullTitle nvarchar(50)
Declare @Att7FullTitle nvarchar(50)
Declare @Att8FullTitle nvarchar(50)
Declare @Att9FullTitle nvarchar(50)
Declare @Att10FullTitle nvarchar(50)
Declare @Att11FullTitle nvarchar(50)
Declare @Att12FullTitle nvarchar(50)
Declare @Att13FullTitle nvarchar(50)
Declare @Att14FullTitle nvarchar(50)
Declare @Att15FullTitle nvarchar(50)








If @ClassTypeID = 5
Begin
Select @Att1Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att1'
Select @Att2Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att2'
Select @Att3Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att3'
Select @Att4Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att4'
Select @Att5Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att5'
Select @Att6Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att6'
Select @Att7Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att7'
Select @Att8Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att8'
Select @Att9Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att9'
Select @Att10Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att10'
Select @Att11Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att11'
Select @Att12Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att12'
Select @Att13Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att13'
Select @Att14Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att14'
Select @Att15Legend = '(' + isnull(ReportLegend, '') + ')' From AttendanceSettings Where ID = 'Att15'

Select @Att1FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att1'
Select @Att2FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att2'
Select @Att3FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att3'
Select @Att4FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att4'
Select @Att5FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att5'
Select @Att6FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att6'
Select @Att7FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att7'
Select @Att8FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att8'
Select @Att9FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att9'
Select @Att10FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att10'
Select @Att11FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att11'
Select @Att12FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att12'
Select @Att13FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att13'
Select @Att14FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att14'
Select @Att15FullTitle = isnull(rtrim(Title), '') From AttendanceSettings Where ID = 'Att15'	
End
Else
Begin
	Select 
	@Att1FullTitle = rtrim(Attendance1),
	@Att1Legend = '(' + Attendance1Legend + ')',
	@Att2FullTitle = rtrim(Attendance2),
	@Att2Legend = '(' + Attendance2Legend + ')',
	@Att3FullTitle = rtrim(Attendance3),
	@Att3Legend = '(' + Attendance3Legend + ')',
	@Att4FullTitle = rtrim(Attendance4),
	@Att4Legend = '(' + Attendance4Legend + ')',
	@Att5FullTitle = rtrim(Attendance5),
	@Att5Legend = '(' + Attendance5Legend + ')'
	From Settings 
	Where SettingID = 1
End











Set @ReportLegend = ''

if @Att1FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att1FullTitle + '=' + @Att1Legend
End
if @Att2FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att2FullTitle + '=' + @Att2Legend
End
if @Att3FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att3FullTitle + '=' + @Att3Legend
End
if @Att4FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att4FullTitle + '=' + @Att4Legend
End
if @Att5FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att5FullTitle + '=' + @Att5Legend
End
if @Att6FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att6FullTitle + '=' + @Att6Legend
End
if @Att7FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att7FullTitle + '=' + @Att7Legend
End
if @Att8FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att8FullTitle + '=' + @Att8Legend
End
if @Att9FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att9FullTitle + '=' + @Att9Legend
End
if @Att10FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att10FullTitle + '=' + @Att10Legend
End
if @Att11FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att11FullTitle + '=' + @Att11Legend
End
if @Att12FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att12FullTitle + '=' + @Att12Legend
End
if @Att13FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att13FullTitle + '=' + @Att13Legend
End
if @Att14FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att14FullTitle + '=' + @Att14Legend
End
if @Att15FullTitle != ''
Begin
	Set @ReportLegend = @ReportLegend + ' ' + @Att15FullTitle + '=' + @Att15Legend
End

Declare @ClassTitle nvarchar(100)
Declare @SchoolName nvarchar(100)
Declare @TeacherID int
Declare @TeacherName nvarchar(100)

Set @TeacherID = (Select TeacherID From Classes Where ClassID = @ClassID)
Set @ClassTitle = (Select ClassTitle From Classes Where ClassID = @ClassID)
Set @SchoolName = (Select SchoolName From Settings where SettingID = 1)

Select
@TeacherName = 
case
	when StaffTitle is null then glname
	when rtrim(StaffTitle) = '' then glname
	else StaffTitle + ' ' + Lname
end
From Teachers 
Where
TeacherID = @TeacherID



Declare @GraphicHTML nvarchar(2000)
Declare @PrincipalSignature nvarchar(10)
Set @GraphicHTML = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page Graphic HTML')
Set @PrincipalSignature = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Include principal signature')

-- Remove line feed carriage returns 
Set @GraphicHTML = REPLACE(@GraphicHTML , CHAR(13) , '' )
Set @GraphicHTML = REPLACE(@GraphicHTML , CHAR(10) , '' )


-- Replace single quotes with /' for javasript
Set @GraphicHTML = REPLACE(@GraphicHTML , '''' , '\''' )



Select 
1 as tag,
null as parent,
@ClassID as [General!1!ClassID],
@EK as [General!1!EK],
@ClassTitle as [General!1!ClassTitle],
@SchoolName as [General!1!SchoolName],
@TeacherName as [General!1!TeacherName],
@ATitle1 as [General!1!PresentSymbol],
@TermTitle as [General!1!TermTitle],
@ReportLegend as [General!1!ReportLegend],
@NumberofWeeks as [General!1!NumberofWeeks],
@PrincipalSignature as [General!1!PrincipalSignature],
@GraphicHTML as [General!1!GraphicHTML],
dbo.GLformatdate(@StartDate) as [General!1!StartDate],
dbo.GLformatdate(@EndDate) as [General!1!EndDate]
For XML EXPLICIT



--Drop table #TheAttendance
--Drop table #TheAttendance2
--Drop table #StudentNames
--Drop table #StudentNames2
--Drop table #StudentsAttendance
--Drop Table #SchoolDates
--Drop Table #DatesTransposed
--Drop Table #StudentTotals
--Drop Table #MonthTable
--Drop Table #StudentsAttendance1W
--Drop Table #StudentsAttendance2W
--Drop Table #StudentsAttendance3W
--Drop Table #StudentsAttendance4W
--Drop Table #StudentsAttendance5W
--Drop Table #StudentsAttendance6W
--Drop Table #StudentsAttendance7W
--Drop Table #StudentsAttendance8W
--Drop Table #StudentsAttendance9W
--Drop Table #StudentsAttendance10W
--Drop Table #StudentsAttendance11W
--Drop Table #StudentsAttendance12W
--Drop Table #StudentsAttendance13W
--Drop Table #StudentsAttendance14W
--Drop Table #StudentsAttendance15W
--Drop Table #StudentsAttendance16W
--Drop Table #MainAttendance1W
--Drop Table #MainAttendance2W
--Drop Table #MainAttendance3W
--Drop Table #MainAttendance4W
--Drop Table #MainAttendance5W
--Drop Table #MainAttendance6W
--Drop Table #MainAttendance7W
--Drop Table #MainAttendance8W
--Drop Table #MainAttendance9W
--Drop Table #MainAttendance10W
--Drop Table #MainAttendance11W
--Drop Table #MainAttendance12W
--Drop Table #MainAttendance13W
--Drop Table #MainAttendance14W
--Drop Table #MainAttendance15W
--Drop Table #MainAttendance16W
--Drop Table #AttendanceMultipleEntries






GO
