SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Skupen
-- Create date: 05/15/2013
-- Description:	This stored procedure replaces the Attendance Sheet stored procedure for generating an attendance sheet.
-- =============================================
CREATE Procedure [dbo].[AttendanceSheetMVC] 
	-- Add the parameters for the stored procedure here
(
	@ClassID int,
	@EK Decimal(15,15),
	@StartDate smalldatetime,
	@EndDate smalldatetime,
	@ProfileID int
)
AS
BEGIN


--Declare
--@StartDate smalldatetime = '2017-11-06', 
--@EndDate smalldatetime = '2018-01-26', 
--@ClassID int = 18495,
--@EK decimal(15,15) = 0.609188397255472,
--@ProfileID int = 10

	-- Get Days School has enabled Attendance For
	Declare
	@AttSunday bit,
	@AttMonday bit,
	@AttTuesday bit,
	@AttWednesday bit,
	@AttThursday bit,
	@AttFriday bit,
	@AttSaturday bit

	Select
	@AttSunday = AttSunday,
	@AttMonday = AttMonday,
	@AttTuesday = AttTuesday,
	@AttWednesday = AttWednesday,
	@AttThursday = AttThursday,
	@AttFriday = AttFriday,
	@AttSaturday = AttSaturday
	From Settings Where SettingID = 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	/* Here are the variables we will need. */
	Declare @SchoolID nvarchar(128), @SchoolName nvarchar(400), @PresentSymbol nvarchar(50), @TimeoutLength int;
	Declare @Attendance2 nvarchar(50), @Attendance3 nvarchar(50), @Attendance4 nvarchar(50), @Attendance5 nvarchar(50);
	Declare @Attendance2Legend nvarchar(50), @Attendance3Legend nvarchar(50), @Attendance4Legend nvarchar(50), @Attendance5Legend nvarchar(50);
	Select 
		@SchoolID = DB_NAME(), 
		@SchoolName = SchoolName,
		@PresentSymbol = Attendance1Legend,
		@TimeoutLength = TimeOutLength,
		@Attendance2 = Attendance2,
		@Attendance2Legend = Attendance2Legend,
		@Attendance3 = Attendance3,
		@Attendance3Legend = Attendance3Legend,
		@Attendance4 = Attendance4,
		@Attendance4Legend = Attendance4Legend,
		@Attendance5 = Attendance5,
		@Attendance5Legend = Attendance5Legend
	From
		Settings
	Where
		SettingID = 1;

	Declare @TeacherID int, @ClassTitle nvarchar(200), @ClassTypeID int;
	Select
		@TeacherID = TeacherID,
		@ClassTitle = ClassTitle,
		@ClassTypeID = ClassTypeID
	From
		Classes
	Where
		ClassID = @ClassID;

	If @ClassTypeID = 5
		Set @PresentSymbol = (Select ReportLegend From AttendanceSettings Where ID = 'Att1');
	Declare @TeacherName nvarchar(100) = (Select glname From Teachers Where TeacherID = @TeacherID);
	Declare @TermTitle nvarchar(40) = (Select TermTitle From Terms As T inner join Classes As C on T.TermID = C.TermID Where ClassID = @ClassID);
	Declare @ReportLegend nvarchar(MAX) = (Select dbo.GetAttendanceLegend(@ClassTypeID));
	Declare @GraphicHTML nvarchar(2000) = (Select [HTML] From ReportHTML Where ProfileID = @ProfileID and HTMLSection = 'Front Page Graphic HTML');
	Declare @PrincipalSignature nvarchar(10) = (Select SettingValue From ReportSettings Where ProfileID = @ProfileID and SettingName = 'Include principal signature');
	Declare @FromClause nvarchar(200) = N'#AttendanceValues As AV inner join #AttendanceColumns As AC on AV.ClassDate = AC.ClassDate';
	Declare @OrderByClause nvarchar(50) = N' Order By P.FullName';

	-- Remove line feed carriage returns 
	Set @GraphicHTML = REPLACE(@GraphicHTML , CHAR(13) , '' );
	Set @GraphicHTML = REPLACE(@GraphicHTML , CHAR(10) , '' );

	-- Replace single quotes with /' for javasript
	Set @GraphicHTML = REPLACE(@GraphicHTML , '''' , '\''' );

	/*
	 * Ok, now we start with the procedure.
	 * This first temporary table holds all of the dates
	 * for which attendance will be shown.
	 */

	Declare @WeekDayPartValuesString nvarchar(50) = '';
	If @AttSunday = 1 set @WeekDayPartValuesString += '1,';
	If @AttMonday = 1 set @WeekDayPartValuesString += '2,';
	If @AttTuesday = 1 set @WeekDayPartValuesString += '3,';
	If @AttWednesday = 1 set @WeekDayPartValuesString += '4,';
	If @AttThursday = 1 set @WeekDayPartValuesString += '5,';
	If @AttFriday = 1 set @WeekDayPartValuesString += '6,';
	If @AttSaturday = 1 set @WeekDayPartValuesString += '7,';


	With AttendanceDateCTE
	As
	(
		Select
			@StartDate As DateValue
		Union All
		Select
			DateValue + 1
		From
			AttendanceDateCTE
		Where
			DateValue + 1 <= @EndDate
	)
	Select 
		DateValue As ClassDate,
		DatePart(Weekday, DateValue) As DayInt
	Into
		#AttendanceDates
	From 
		AttendanceDateCTE
	Where
		DatePart(Weekday, DateValue) in (Select IntegerID From dbo.SplitCSVIntegers(@WeekDayPartValuesString))
	Option (Maxrecursion 1095);

	--Select * From #AttendanceDates;

	/*
	 * Now we can calculate the number of weeks
	 * these dates span.
	 */

	Declare @NumberofDaysInAWeek int  = 
	convert(int,@AttSunday) + 
	convert(int,@AttMonday) +
	convert(int,@AttTuesday) +
	convert(int,@AttWednesday) +
	convert(int,@AttThursday) +
	convert(int,@AttFriday) +
	convert(int,@AttSaturday);

	Declare @NumberOfWeeks int = (Select ceiling(convert(decimal(4,1),count(*))/@NumberofDaysInAWeek) From #AttendanceDates)

	/*
	 * Here is a table to hold all of the weekdays
	 * of the week.
	 */
	Create Table #Days 
	(
		DayID int,
		DayString nvarchar(10)
	);


	If @AttSunday = 1 Insert Into #Days Values (1, 'Sun');
	If @AttMonday = 1 Insert Into #Days Values (2, 'Mon');
	If @AttTuesday = 1 Insert Into #Days Values (3, 'Tues');
	If @AttWednesday = 1 Insert Into #Days Values (4, 'Wed');
	If @AttThursday = 1 Insert Into #Days Values (5, 'Thur');
	If @AttFriday = 1 Insert Into #Days Values (6, 'Fri');
	If @AttSaturday = 1 Insert Into #Days Values (7, 'Sat');

	Declare @LastDayOfWeek nvarchar(10) = 
	(
	Select 
	case max(DayID) 
		when 1 then 'Sun'
		when 2 then 'Mon'
		when 3 then 'Tues'
		when 4 then 'Wed'
		when 5 then 'Thur'
		when 6 then 'Fri'
		when 7 then 'Sat'
	end as LastDayOfWeek
	From #Days 
	)



	-- Select * from #Days;

	/*
	 * This one holds all of the months of the year.
	 */
	Create Table #Months
	(
		MonthID int,
		MonthString nvarchar(50)
	);

	Insert Into #Months
	Values
		(1, 'January'),
		(2, 'February'),
		(3, 'March'),
		(4, 'April'),
		(5, 'May'),
		(6, 'June'),
		(7, 'July'),
		(8, 'August'),
		(9, 'September'),
		(10, 'October'),
		(11, 'November'),
		(12, 'December');

	--Select * From #Months;

	/* 
	 * Now this table is for generating the columns of the report.
	 * It will generate one column for each date that attendance will be shown for.
	 */
	Select
		#AttendanceDates.ClassDate,
		#Days.DayString + 
		' ' + 
		Cast(DatePart(Day, #AttendanceDates.ClassDate) As nvarchar(4)) +
		'.' +
		Cast(Row_Number() over (Order By #AttendanceDates.ClassDate) As nvarchar(8)) As ColumnHeader
	Into #AttendanceColumns
	From 
		#Days 
			inner join 
		#AttendanceDates 
			on #Days.DayID = #AttendanceDates.DayInt;

	--Select * From #AttendanceColumns;

	/*
	 * This will replicate the Month XML tags from the previous version 
	 * of this procedure. Each row of this table shows how many of the
	 * attendance dates fall into each month.
	 */
	With MonthNumberCTE
	As
	(
		Select Distinct 
			DatePart(Month, ClassDate) As MonthNumber,
			DatePart(Year, ClassDate) As MonthYear,
			Count(ClassDate) Over (Partition By DatePart(Year, ClassDate), DatePart(Month, ClassDate)) As MonthCount
		From 
			#AttendanceColumns
	)
	Select 
		MonthCount,
		MonthNumber,
		MonthString As [TheDayMonth],
		MonthYear
	From 
		MonthNumberCTE
			inner join
		#Months	
			on MonthNumberCTE.MonthNumber = #Months.MonthID
	Order By MonthYear, MonthNumber;

	/*
	 * This replicates the General XML tag from the previous version of this procedure.
	 * This is just one row to hold general information necessary for the attendance sheet.
	 */
	Select 
		@ClassID As [ClassID],
		@EK As [EK],
		@ClassTitle As [ClassTitle],
		@SchoolID As [SchoolID],
		@SchoolName As [SchoolName],
		@TimeoutLength As [TimeoutLength],
		@TeacherName As [TeacherName],
		@PresentSymbol As [PresentSymbol],
		@TermTitle As [TermTitle],
		@ReportLegend As [ReportLegend],
		@NumberofWeeks As [NumberofWeeks],
		@LastDayOfWeek As [LastDayOfWeek],
		@PrincipalSignature As [PrincipalSignature],
		@GraphicHTML As [GraphicHTML],
		dbo.GLformatdate(@StartDate) As [StartDate],
		dbo.GLformatdate(@EndDate) As [EndDate];

	/*
	 * Now this AttendanceValues temporary table is for generating the actual attendance codes
	 * for each student on each date.
	 */
	With UnpivotCTE
	As
	(
		Select
		ROW_NUMBER() Over (Partition By StudentID, ClassDate Order By AttendanceAtt Desc) As RowNumber, 
		StudentID, FullName, ClassDate, CSID, AttendanceAtt, Title, AttendanceValue, PresentValue, AbsentValue, ReportLegend
		From
		(
		Select
			Students.StudentID,
			Students.glname As FullName,
			Attendance.ClassDate,
			ClassesStudents.CSID,
			Case When Attendance.ClassDate Is Not Null Then Att1 Else 0.0 End As Att1,
			Case When Attendance.ClassDate Is Not Null Then Att2 Else 0.0 End As Att2,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att3 As Decimal(3,2)) Else 0.0 End As Att3,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att4 As Decimal(3,2)) Else 0.0 End As Att4,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att5 As Decimal(3,2)) Else 0.0 End As Att5,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att6 As Decimal(3,2)) Else 0.0 End As Att6,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att7 As Decimal(3,2)) Else 0.0 End As Att7,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att8 As Decimal(3,2)) Else 0.0 End As Att8,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att9 As Decimal(3,2)) Else 0.0 End As Att9,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att10 As Decimal(3,2)) Else 0.0 End As Att10,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att11 As Decimal(3,2)) Else 0.0 End As Att11,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att12 As Decimal(3,2)) Else 0.0 End As Att12,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att13 As Decimal(3,2)) Else 0.0 End As Att13,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att14 As Decimal(3,2)) Else 0.0 End As Att14,
			Case When Attendance.ClassDate Is Not Null Then Cast(Att15 As Decimal(3,2)) Else 0.0 End As Att15
		From 
			ClassesStudents	
				inner join
			Students
				on Students.StudentID = ClassesStudents.StudentID
				left outer join
			(
				Attendance
					right outer join
				#AttendanceDates
					on Attendance.ClassDate = #AttendanceDates.ClassDate
			)
				on ClassesStudents.CSID = Attendance.CSID
		Where
			ClassesStudents.ClassID = @ClassID
		) As AttendanceData
		Unpivot
		(AttendanceValue for AttendanceAtt in ([Att1],[Att2],[Att3],[Att4],[Att5],[Att6],[Att7],[Att8],[Att9],[Att10],[Att11],[Att12],[Att13],[Att14],[Att15])) As Tp
			inner join
		AttendanceSettings
			on AttendanceAtt = AttendanceSettings.ID
		Where 
			AttendanceSettings.LunchValue = 0
--				And
--			IsNull(ReportLegend, '') != '' 
				And
			(((ClassDate Is Null) And (IsNull(AttendanceValue, 0.0) = 0.0))
				Or 
			((ClassDate Is Not Null) And (AttendanceValue > 0.0)))
	)
	Select 
		RowNumber, 
		StudentID, 
		FullName, 
		ClassDate, 
		CSID, 
		AttendanceAtt, 
		Title,
		AttendanceValue,
		PresentValue,
		AbsentValue,
		Case
			When AttendanceAtt = 'Att2' And (@Attendance2 Like '%Absent%' Or @Attendance2 Like '%Absence%') Then 1.0
			When AttendanceAtt = 'Att3' And (@Attendance3 Like '%Absent%' Or @Attendance3 Like '%Absence%') Then 1.0
			When AttendanceAtt = 'Att4' And (@Attendance4 Like '%Absent%' Or @Attendance4 Like '%Absence%') Then 1.0
			When AttendanceAtt = 'Att5' And (@Attendance5 Like '%Absent%' Or @Attendance5 Like '%Absence%') Then 1.0
			Else 0.0
		End As SettingsAbsentValue,
		Case
			When AttendanceAtt = 'Att2' And (@Attendance2 Like '%Tard%' Or @Attendance2 Like '%Late%') Then 1.0
			When AttendanceAtt = 'Att3' And (@Attendance3 Like '%Tard%' Or @Attendance3 Like '%Late%') Then 1.0
			When AttendanceAtt = 'Att4' And (@Attendance4 Like '%Tard%' Or @Attendance4 Like '%Late%') Then 1.0
			When AttendanceAtt = 'Att5' And (@Attendance5 Like '%Tard%' Or @Attendance5 Like '%Late%') Then 1.0
			Else 0.0
		End As SettingsTardyValue,
		Case
			When ClassDate Is Not Null And @ClassTypeID = 5 Then 
				Replace(Replace((Select UnpivotCTE2.ReportLegend + ',' 
				From 
					UnpivotCTE As UnpivotCTE2
				Where
					UnpivotCTE2.ClassDate = UnpivotCTE.ClassDate	
						And
					UnpivotCTE2.StudentID = UnpivotCTE.StudentID
				FOR XML PATH('')) + '', ',', ''), @PresentSymbol + ',', '')
			When ClassDate Is Not Null And @ClassTypeID != 5 Then
				Replace(Replace((Select Case
							When UnpivotCTE2.AttendanceAtt = 'Att1' Then @PresentSymbol + ','
							When UnpivotCTE2.AttendanceAtt = 'Att2' Then @Attendance2Legend + ','
							When UnpivotCTE2.AttendanceAtt = 'Att3' Then @Attendance3Legend + ','
							When UnpivotCTE2.AttendanceAtt = 'Att4' Then @Attendance4Legend + ','
							When UnpivotCTE2.AttendanceAtt = 'Att5' Then @Attendance5Legend + ','
						End
				From
					UnpivotCTE As UnpivotCTE2
				Where
					UnpivotCTE2.ClassDate = UnpivotCTE.ClassDate
						And
					UnpivotCTE2.StudentID = UnpivotCTE.StudentID
				FOR XML PATH('')) + '', ',', ''), @PresentSymbol + ',', '')
		End As ReportLegend
	Into
		#AttendanceValues
	From 
		UnpivotCTE
	Order By ClassDate

	/* 
	 * Now, if we didn't get any attendance values, 
	 * we will have to change the FROM clause in our final query,
	 * as well as the ORDER BY clause (setting it to nothing).
	 * We will also reduce our #AttendanceValues table to just
	 * one row per student. 
	 */
	If (Select Max(ClassDate) From #AttendanceValues) Is Null
	Begin
		Set @FromClause = N'#AttendanceValues As AV cross join #AttendanceColumns As AC';
		Set @OrderByClause = N'';
		Delete From #AttendanceValues Where RowNumber != 1;
	End

	--Select * From #AttendanceValues

	/*
	 * This AttendanceTotals table holds the summation columns on the right end
	 * of the attendance sheet.
	 */
	Select Distinct
		#AttendanceValues.StudentID,
		#AttendanceValues.FullName,
		Case @ClassTypeID
			When 5 Then (Select dbo.trimzeros3(IsNull(Sum(AV.AttendanceValue * AV.PresentValue), 0.0)) From #AttendanceValues As AV Where AV.StudentID = #AttendanceValues.StudentID)
			Else (Select dbo.trimzeros3(IsNull(Sum(AV.AttendanceValue), 0.0)) From #AttendanceValues As AV Where AV.StudentID = #AttendanceValues.StudentID And AV.AttendanceAtt = 'Att1')
		End As [Total Days Present],
		Case @ClassTypeID
			When 5 Then (Select dbo.trimzeros3(IsNull(Sum(AV.AttendanceValue * AV.AbsentValue), 0.0)) From #AttendanceValues As AV Where AV.StudentID = #AttendanceValues.StudentID)
			Else (Select dbo.trimzeros3(IsNull(Sum(AV.AttendanceValue * AV.SettingsAbsentValue), 0.0)) From #AttendanceValues As AV Where AV.StudentID = #AttendanceValues.StudentID)
		End As [Total Days Absent],
		Case @ClassTypeID
			When 5 Then (Select dbo.trimzeros3(IsNull(Sum(AV.AttendanceValue), 0.0)) From #AttendanceValues As AV Where AV.StudentID = #AttendanceValues.StudentID And ((AV.Title Like '%Tard%') Or (AV.Title Like '%Late%')))
			Else (Select dbo.trimzeros3(IsNull(Sum(AV.AttendanceValue * AV.SettingsTardyValue), 0.0)) From #AttendanceValues As AV Where AV.StudentID = #AttendanceValues.StudentID)
		End As [Total Days Tardy]
	Into
		#AttendanceTotals
	From 
		#AttendanceValues
	Order By
		#AttendanceValues.[FullName]

	/*
	 * Now we need our columns from the AttendanceColumns table
	 * written out as a comma delineated list so they can be used
	 * in the Pivot clause of the final query.
	 */
	Declare @ColumnList nvarchar(MAX);

	Select @ColumnList = Stuff((Select '], [' + 
	#Days.DayString + 
	' ' + 
	Cast(DatePart(Day, #AttendanceDates.ClassDate) As nvarchar(4)) +
	'.' +
	Cast(Row_Number() over (order by #AttendanceDates.ClassDate) As nvarchar(8)) 
	From 
		#Days 
			inner join 
		#AttendanceDates 
			on #Days.DayID = #AttendanceDates.DayInt 
	FOR XML PATH('')), 1, 2, '') + 
	']';

	--Select @ColumnList as Columns

	/*
	 * Now we execute our final query to generate the table of data
	 * that makes up the attendance sheet.
	 */
	Declare @query nvarchar(MAX);
	Set @query = N'Select P.StudentID, P.FullName, ' +
	@ColumnList + 
	N', [Total Days Present] ' + 
	N', [Total Days Absent] ' +
	N', [Total Days Tardy] ' +
	N'From
	(Select 
		AV.StudentID,
		AV.FullName,
		AC.ColumnHeader,
		AV.ReportLegend
	From ' + 
	@FromClause + 
	N') As T
	Pivot
	(
		Max([ReportLegend]) 
		For ColumnHeader In (' + 
		@ColumnList + 
		N')
	) As P
		inner join
	#AttendanceTotals As AT
		on P.StudentID = AT.StudentID' +
	@OrderByClause + N';';
	

	Execute(@query);

	Drop Table #AttendanceDates;
	Drop Table #Days;
	Drop Table #Months;
	Drop Table #AttendanceColumns;
	Drop Table #AttendanceValues;
	Drop Table #AttendanceTotals

END

GO
