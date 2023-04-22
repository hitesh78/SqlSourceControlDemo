SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 5/9/2016
-- Description:	Returns a Students Attendance Data for WISE 
-- =============================================
CREATE Procedure [dbo].[GetStudentAttendanceData] 
@StudentID int,
@SchoolYear nvarchar(10),
@hideXML bit
AS
BEGIN

	SET NOCOUNT ON;

	Declare
	@StudentEntryDate date,
	@StudentWithdrawalDate date,
	@StudentName nvarchar(50)

	Select
	@StudentName = glname, 
	@StudentEntryDate = EntryDate,
	@StudentWithdrawalDate = WithdrawalDate
	From 
	Students
	Where StudentID = @StudentID


	Declare 
	@StartDate date,
	@EndDate date


	-- Use TermStart/EndDates or Student Entry/Withdrawal Dates whichever is small range
	Select 
	@StartDate = 
	case
		when @StudentEntryDate is not null and @StudentEntryDate > min(StartDate) then @StudentEntryDate
		else MIN(StartDate)
	end,
	@EndDate = 
	case
		when @StudentWithdrawalDate is not null and @StudentWithdrawalDate < MAX(EndDate) then @StudentWithdrawalDate
		else MAX(EndDate)
	end
	From Terms
	Where
	TermID in (SELECT * FROM dbo.GetYearTermIDsByDate(@SchoolYear))

	--check for existing attendance in the current School year, if so, provide the data below, otherwise return defaults
	IF EXISTS(
		SELECT 1
		FROM
		Attendance A
			inner join
		ClassesStudents CS
			ON A.CSID = CS.CSID
			inner join
		Classes C
			ON C.ClassID = CS.ClassID
			inner join
		Terms Tm
			ON Tm.TermID = C.TermID
			inner join
		Students S
			ON S.StudentID = CS.StudentID
		WHERE
			Tm.TermID in(SELECT * FROM dbo.GetYearTermIDsByDate(@SchoolYear))
		and
			Tm.TermID not in (SELECT ParentTermID FROM Terms)
		and
			C.ClassTypeID = 5
		and
			C.NONAcademic = 0
		and
			S.StudentID = @StudentID
	)
	BEGIN

	Declare @AttTitle1 nvarchar(50)
	Declare @AttTitle2 nvarchar(50)
	Declare @AttTitle3 nvarchar(50)
	Declare @AttTitle4 nvarchar(50)
	Declare @AttTitle5 nvarchar(50)
	Declare @AttTitle6 nvarchar(50)
	Declare @AttTitle7 nvarchar(50)
	Declare @AttTitle8 nvarchar(50)
	Declare @AttTitle9 nvarchar(50)
	Declare @AttTitle10 nvarchar(50)
	Declare @AttTitle11 nvarchar(50)
	Declare @AttTitle12 nvarchar(50)
	Declare @AttTitle13 nvarchar(50)
	Declare @AttTitle14 nvarchar(50)
	Declare @AttTitle15 nvarchar(50)
	Declare @ExcludeAtt1 bit
	Declare @ExcludeAtt2 bit
	Declare @ExcludeAtt3 bit
	Declare @ExcludeAtt4 bit
	Declare @ExcludeAtt5 bit
	Declare @ExcludeAtt6 bit
	Declare @ExcludeAtt7 bit
	Declare @ExcludeAtt8 bit
	Declare @ExcludeAtt9 bit
	Declare @ExcludeAtt10 bit
	Declare @ExcludeAtt11 bit
	Declare @ExcludeAtt12 bit
	Declare @ExcludeAtt13 bit
	Declare @ExcludeAtt14 bit
	Declare @ExcludeAtt15 bit


	Set @AttTitle1 = (Select Title From AttendanceSettings Where ID = 'Att1')
	Set @AttTitle2 = (Select Title From AttendanceSettings Where ID = 'Att2')
	Set @AttTitle3 = (Select Title From AttendanceSettings Where ID = 'Att3')
	Set @AttTitle4 = (Select Title From AttendanceSettings Where ID = 'Att4')
	Set @AttTitle5 = (Select Title From AttendanceSettings Where ID = 'Att5')
	Set @AttTitle6 = (Select Title From AttendanceSettings Where ID = 'Att6')
	Set @AttTitle7 = (Select Title From AttendanceSettings Where ID = 'Att7')
	Set @AttTitle8 = (Select Title From AttendanceSettings Where ID = 'Att8')
	Set @AttTitle9 = (Select Title From AttendanceSettings Where ID = 'Att9')
	Set @AttTitle10 = (Select Title From AttendanceSettings Where ID = 'Att10')
	Set @AttTitle11 = (Select Title From AttendanceSettings Where ID = 'Att11')
	Set @AttTitle12 = (Select Title From AttendanceSettings Where ID = 'Att12')
	Set @AttTitle13 = (Select Title From AttendanceSettings Where ID = 'Att13')
	Set @AttTitle14 = (Select Title From AttendanceSettings Where ID = 'Att14')
	Set @AttTitle15 = (Select Title From AttendanceSettings Where ID = 'Att15')	
	Set @ExcludeAtt1 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att1')
	Set @ExcludeAtt2 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att2')
	Set @ExcludeAtt3 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att3')
	Set @ExcludeAtt4 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att4')
	Set @ExcludeAtt5 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att5')
	Set @ExcludeAtt6 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att6')
	Set @ExcludeAtt7 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att7')
	Set @ExcludeAtt8 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att8')
	Set @ExcludeAtt9 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att9')
	Set @ExcludeAtt10 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att10')
	Set @ExcludeAtt11 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att11')
	Set @ExcludeAtt12 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att12')
	Set @ExcludeAtt13 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att13')
	Set @ExcludeAtt14 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att14')
	Set @ExcludeAtt15 = (Select ExcludedAttendance From AttendanceSettings Where ID = 'Att15')		


	Declare @StudentAttendance table(theDate date, theWeekday nvarchar(30), TermTitle nvarchar(80), Attendance nvarchar(80))



	Insert into @StudentAttendance(theDate, theWeekday, TermTitle, Attendance)
	SELECT
	A.ClassDate as theDate,
	datename(weekday, A.ClassDate) as theWeekday,
	Tm.TermTitle,
	reverse(stuff(reverse(
	(
	case when A.Att1 = 1 and @ExcludeAtt1 = 0 then @AttTitle1 + ', ' else '' end +
	case when A.Att2 = 1 and @ExcludeAtt2 = 0 then @AttTitle2 + ', ' else '' end +
	case when A.Att3 = 1 and @ExcludeAtt3 = 0 then @AttTitle3 + ', ' else '' end +
	case when A.Att4 = 1 and @ExcludeAtt4 = 0 then @AttTitle4 + ', ' else '' end +
	case when A.Att5 = 1 and @ExcludeAtt5 = 0 then @AttTitle5 + ', ' else '' end +
	case when A.Att6 = 1 and @ExcludeAtt6 = 0 then @AttTitle6 + ', ' else '' end +
	case when A.Att7 = 1 and @ExcludeAtt7 = 0 then @AttTitle7 + ', ' else '' end +
	case when A.Att8 = 1 and @ExcludeAtt8 = 0 then @AttTitle8 + ', ' else '' end +
	case when A.Att9 = 1 and @ExcludeAtt9 = 0 then @AttTitle9 + ', ' else '' end +
	case when A.Att10 = 1 and @ExcludeAtt10 = 0 then @AttTitle10 + ', ' else '' end +
	case when A.Att11 = 1 and @ExcludeAtt11 = 0 then @AttTitle11 + ', ' else '' end +
	case when A.Att12 = 1 and @ExcludeAtt12 = 0 then @AttTitle12 + ', ' else '' end +
	case when A.Att13 = 1 and @ExcludeAtt13 = 0 then @AttTitle13 + ', ' else '' end +
	case when A.Att14 = 1 and @ExcludeAtt14 = 0 then @AttTitle14 + ', ' else '' end +
	case when A.Att15 = 1 and @ExcludeAtt15 = 0 then @AttTitle15 + ', ' else '' end
	) 
	), 1, 2, ''))as Attendance
	FROM
	Attendance A
		inner join
	ClassesStudents CS
		ON A.CSID = CS.CSID
		inner join
	Classes C
		ON C.ClassID = CS.ClassID
		inner join
	Terms Tm
		ON Tm.TermID = C.TermID
		inner join
	Students S
		ON S.StudentID = CS.StudentID
	WHERE
		Tm.TermID in(SELECT * FROM dbo.GetYearTermIDsByDate(@SchoolYear))
	and
		Tm.TermID not in (SELECT ParentTermID FROM Terms)
	and
		C.ClassTypeID = 5
	and
		C.NONAcademic = 0
	and
		S.StudentID = @StudentID
	and
	A.ClassDate not in (Select * From dbo.getNonSchoolDates())
	and
	datename(weekday, A.ClassDate) != 'Sunday'
	and
	datename(weekday, A.ClassDate) != 'Saturday'
	Order By A.ClassDate

	if @hideXML = 0
	Begin
	
		Select
		1 as tag,
		null as parent,
		dbo.GLformatdate(theDate) as [StudentAtt!1!theDate], 
		theWeekday as [StudentAtt!1!theWeekday],
		TermTitle as [StudentAtt!1!TermTitle],
		Attendance as [StudentAtt!1!Attendance]
		From 
		@StudentAttendance
		Where
		Attendance is not null
		FOR XML EXPLICIT


		Declare @MissingAttendance table (TermTitle nvarchar(30), theDate date)
		insert into @MissingAttendance (TermTitle, theDate)
		Select
		(
			Select top 1 TermTitle
			From Terms
			Where
			TermID in
			(
				SELECT * 
				FROM dbo.GetYearTermIDsByDate(@SchoolYear)
			)
			and
			D.theDate between StartDate and EndDate
		),
		theDate
		From dbo.GetDates(@StartDate, @EndDate) D
		where
		DATENAME ( weekday , theDate ) != 'Sunday'
		and
		DATENAME ( weekday , theDate ) != 'Saturday'
		and
		theDate not in (Select * From dbo.getNonSchoolDates())
		and
		theDate < dbo.GLgetdatetime()
		and
		theDate not in (Select theDate From @StudentAttendance)
		Order By theDate



		Select 
		1 as tag,
		null as parent,
		TermTitle as [MissingAtt!1!TermTitle],
		dbo.GLformatdate(theDate) as [MissingAtt!1!theDate],
		DATENAME(weekday, theDate) as [MissingAtt!1!theWeekday]
		From @MissingAttendance
		FOR XML EXPLICIT


		Select
		@StudentName as StudentName,
		(Select count(*) From @StudentAttendance Where Attendance is not null) as StudentTotalAttendanceDays,
		(Select count(*) From @MissingAttendance) as PotentialMissingAttendanceDays
		FOR XML RAW
	
	End -- if @hideXML = 0


	Declare @StudentFirstDateOfAttendance date = (Select top 1 theDate From @StudentAttendance) 

	SELECT 
	CS.StudentID,
	dbo.GLformatdate(@StudentFirstDateOfAttendance) as StudentFirstAttendanceEntry,
	dbo.GLformatdate(@StartDate) as EntryDate,
	CONVERT(DECIMAL(6,2),COUNT(A.ClassDate)) as TotalAttDaysPossible,
	CONVERT(DECIMAL(6,2),(
	Sum(A.Att1) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att1')
	+
	Sum(A.Att2) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att2')
	+
	case 
		when @ExcludeAtt3 = 1 THEN 0
		else Sum(A.Att3) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att3')
	end
	+
	case 
		when @ExcludeAtt4 = 1 THEN 0
		else Sum(A.Att4) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att4')
	end
	+
	case 
		when @ExcludeAtt5 = 1 THEN 0
		else Sum(A.Att5) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att5')
	end
	+
	case 
		when @ExcludeAtt6 = 1 THEN 0
		else Sum(A.Att6) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att6')
	end
	+
	case 
		when @ExcludeAtt7 = 1 THEN 0
		else Sum(A.Att7) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att7')
	end
	+
	case 
		when @ExcludeAtt8 = 1 THEN 0
		else Sum(A.Att8) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att8')
	end
	+
	case 
		when @ExcludeAtt9 = 1 THEN 0
		else Sum(A.Att9) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att9')
	end
	+
	case 
		when @ExcludeAtt10 = 1 THEN 0
		else Sum(A.Att10) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att10')
	end
	+
	case 
		when @ExcludeAtt11 = 1  THEN 0
		else Sum(A.Att11) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att11')
	end
	+
	case 
		when @ExcludeAtt12 = 1  THEN 0
		else Sum(A.Att12) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att12')
	end
	+
	case 
		when @ExcludeAtt13 = 1  THEN 0
		else Sum(A.Att13) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att13')
	end
	+
	case 
		when @ExcludeAtt14 = 1  THEN 0
		else Sum(A.Att14) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att14')
	end
	+
	case 
		when @ExcludeAtt15 = 1  THEN 0
		else Sum(A.Att15) * (SELECT PresentValue FROM AttendanceSettings WHERE ID = 'Att15')
	end
	)) AS TotalPresentValue,
	(Select count(*) From @MissingAttendance) as PotentialMissingAttDays
	FROM
	Attendance A
		inner join
	ClassesStudents CS
		ON A.CSID = CS.CSID
		inner join
	Classes C
		ON C.ClassID = CS.ClassID
		inner join
	Terms Tm
		ON Tm.TermID = C.TermID
		inner join
	Students S
		ON S.StudentID = CS.StudentID
	WHERE
		Tm.TermID in(SELECT * FROM dbo.GetYearTermIDsByDate(@SchoolYear))
	and
		Tm.TermID not in (SELECT ParentTermID FROM Terms)
	and
		C.ClassTypeID = 5
	and
		C.NONAcademic = 0
	and
		S.StudentID = @StudentID
	and
	A.ClassDate not in (Select * From dbo.getNonSchoolDates())
	and
	A.ClassDate in (Select theDate From @StudentAttendance Where Attendance is not null)
	and
	datename(weekday, A.ClassDate) != 'Sunday'
	and
	datename(weekday, A.ClassDate) != 'Saturday'
	GROUP BY CS.StudentID

	END
	ELSE
	BEGIN
		--no attendance provided for this Student, so the StartDate is set to TermStart/EndDates or Student Entry/Withdrawal Dates whichever is small range
		SELECT 
			0 as TotalPresentValue, 
			0 as TotalAttDaysPossible, 
			@StartDate as StudentFirstAttendanceEntry, 
			0 as PotentialMissingAttDays
		From 
			Students
		WHERE StudentID = @StudentID
	END

END
GO
