SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 7/20/2017
-- Description:	Used for the Student Schedule report
-- =============================================
CREATE Procedure [dbo].[StudentSchedule]
	-- Add the parameters for the stored procedure here
@Admin nvarchar(3),
@Sort int,
@StudentID int,
@GradeLevelSelected nvarchar(10),
@ShowAllClasses nvarchar(3),
@ShowTimeMap nvarchar(3),
@TimeHeightFactor decimal(2,1),
@ShowClassColor nvarchar(3),
@ShowBiWeeklySchedule nvarchar(3),
@ClassID int,
@EK decimal(15,15)

AS
BEGIN


--Declare
--@Admin nvarchar(100) = 'yes',
--@Sort nvarchar(100) = '1',
--@StudentID nvarchar(100) = '1753', --'1753', '-1',
--@GradeLevelSelected nvarchar(100) = '7',
--@ShowAllClasses nvarchar(100) = 'no',
--@ShowTimeMap nvarchar(100) = 'no',
--@TimeHeightFactor decimal(5,1) = 1.0,
--@ShowClassColor nvarchar(100) = 'no',
--@ShowBiWeeklySchedule nvarchar(100) = 'no',
--@ClassID nvarchar(100) = '11562',
--@EK nvarchar(100) = '.046009173939490'


	SET NOCOUNT ON;


	Declare @ClassDivAdditionalHeightSpacing int = 6; 
	Declare @TwoLineThreshold int = 44;
	Declare @SingleLineThreshold int = 29;
	Declare @SmallFontThreshold int = 13;	
	 
	Declare @Periods table (PeriodID int, PeriodString nvarchar(30))
	Insert into @Periods
	select
	PeriodID,
	case
		when PeriodID = 0 then ''
		else
			LOWER(
			LEFT(
			CONVERT(nvarchar(7), PeriodStartTime, 0)
			,LEN(CONVERT(nvarchar(7), PeriodStartTime, 0)) - 1)
			+ '-' +
			LEFT(
			CONVERT(nvarchar(7), PeriodEndTime, 0)
			,LEN(CONVERT(nvarchar(7), PeriodEndTime, 0)) - 1)
			) 
	end as PeriodString
	From 
	Periods   
	 
	 

	Declare @School nvarchar(100)
	Declare @SchoolAddress nvarchar(100)
	Declare @SchoolPhone nvarchar(40)
	Declare @SchoolFax nvarchar(40)

	Set @School = (Select SchoolName From Settings where SettingID = 1)
	Set @SchoolAddress = (Select SchoolStreet + ', ' + SchoolCity + ', ' + SchoolState + ' ' + SchoolZip From Settings where SettingID = 1)
	Set @SchoolPhone = (Select SchoolPhone From Settings where SettingID = 1)
	Set @SchoolFax = (Select SchoolFax From Settings where SettingID = 1)

		declare @StudentsParentsCanViewLockerInfo bit = (Select StudentsParentsCanViewLockerInfo From Settings Where SettingID = 1)
		

		Declare @EnableStudentLockerInfo bit
		Set @EnableStudentLockerInfo = (Select EnableStudentLockerInfo From Settings Where SettingID = 1);


	Create table #StudentTerms
	(
	StudentID int, 
	TermID int, 
	StartTimePadding int, 
	TimeLegendHTML nvarchar(1000)
	)
	CREATE CLUSTERED INDEX IDX_C_StudentID ON #StudentTerms(StudentID)

	Declare @HoursHTML table (hrInt int, hrDiv nvarchar(40))

	;with   Hours as
			(
			select  
			0 as hrInt
			union all
			select  hrInt + 1
			from Hours
			where   hrInt < 23
			)
	Insert into @HoursHTML
	Select
	hrInt,
	--lower(STUFF(RIGHT(' ' + CONVERT(nvarchar(7), CONVERT(time, DATEADD(hh,hrInt,'00:00:00')), 0), 7), 6, 0, '')) as thetime,
	'<div class="timeDiv">' +
	REPLACE(lower(STUFF(RIGHT(' ' + CONVERT(nvarchar(7), CONVERT(time, DATEADD(hh,hrInt,'00:00:00')), 0), 7), 6, 0, '')),':00', '') +
	'</div>' as TimeLegend
	From Hours

	Declare
	@AttSunday tinyint,
	@AttMonday tinyint,
	@AttTuesday tinyint,
	@AttWednesday tinyint,
	@AttThursday tinyint,
	@AttFriday tinyint,
	@AttSaturday tinyint


	Select
	@AttSunday = AttSunday,
	@AttMonday = AttMonday,
	@AttTuesday = AttTuesday,
	@AttWednesday = AttWednesday,
	@AttThursday = AttThursday,
	@AttFriday = AttFriday,
	@AttSaturday = AttSaturday
	From Settings
	Where
	SettingID = 1


	;with cte as (
		Select 
		S.StudentID, T.TermID
		From 
		Terms T
			inner join
		Classes C
			on 
				C.TermID = T.TermID
				and 
				T.Status = 1   
				and 
				T.ExamTerm = 0							
			inner join 
		ClassesStudents CS
			on CS.ClassID = C.ClassID
			inner join
		Students S
			on CS.StudentID = S.StudentID
		Where
			C.ClassTitle is not null 
			and
			T.TermID not in (Select ParentTermID From Terms)
			and 
			case
				when @ShowAllClasses = 'yes' then 1
				when C.ClassTypeID in (1,8) then 1
				else 0
			end = 1
			and 
			case
				when @GradeLevelSelected = 'All' and @StudentID = -1 then 1
				when @GradeLevelSelected = S.GradeLevel and @StudentID = -1 then 1
				when CS.StudentID = @StudentID then 1
			end = 1
			and
			case 
				when @ShowAllClasses = 'yes' then 1
				when C.ClassTitle like '%Study Hall%' then 1
				when C.NonAcademic = 0 then 1
				else 0
			end = 1	  
		  group by S.StudentID, T.TermID
	)

	insert into #StudentTerms
	Select
	CS.StudentID,
	C.TermID,
	convert(int,left(min(P.PeriodStartTime),2)) * 60 * @TimeHeightFactor as StartTimePadding,
	(
	SELECT 
	  (
	  SELECT N'' + hrDiv FROM @HoursHTML 
	  Where 
	  hrInt between 
	  (convert(int,left(min(P.PeriodStartTime),2))) 
	  and 
	  (convert(int,left(max(P.PeriodEndTime),2))) 
	  FOR XML PATH(''),TYPE)
	  .value('text()[1]','nvarchar(1000)')
	) as TimeLegendHTML
	From 
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	(
	Select distinct
	CS.StudentID,
	C.TermID,
	CP.PeriodID
	From 
	ClassesStudents CS
		inner join
	Classes C
		on C.ClassID = CS.ClassID
		inner join
	(
		Select ClassID, Period as PeriodID From Classes Where ScheduleType = 1 Union
		Select ClassID, PeriodOnSunday as PeriodID From Classes Where ScheduleType > 1 and @AttSunday = 1 Union
		Select ClassID, PeriodOnMonday as PeriodID From Classes Where ScheduleType > 1 and @AttMonday = 1 Union
		Select ClassID, PeriodOnTuesday as PeriodID From Classes Where ScheduleType > 1 and @AttTuesday = 1 Union
		Select ClassID, PeriodOnWednesday as PeriodID From Classes Where ScheduleType > 1 and @AttWednesday = 1 Union
		Select ClassID, PeriodOnThursday as PeriodID From Classes Where ScheduleType > 1 and @AttThursday = 1 Union
		Select ClassID, PeriodOnFriday as PeriodID From Classes Where ScheduleType > 1 and @AttFriday = 1 Union
		Select ClassID, PeriodOnSaturday as PeriodID From Classes Where ScheduleType > 1 and @AttSaturday = 1 Union
		Select ClassID, BPeriodOnSunday as PeriodID From Classes Where ScheduleType = 3 and @AttSunday = 1 Union
		Select ClassID, BPeriodOnMonday as PeriodID From Classes Where ScheduleType = 3 and @AttMonday = 1 Union
		Select ClassID, BPeriodOnTuesday as PeriodID From Classes Where ScheduleType = 3 and @AttTuesday = 1 Union
		Select ClassID, BPeriodOnWednesday as PeriodID From Classes Where ScheduleType = 3 and @AttWednesday = 1 Union
		Select ClassID, BPeriodOnThursday as PeriodID From Classes Where ScheduleType = 3 and @AttThursday = 1 Union
		Select ClassID, BPeriodOnFriday as PeriodID From Classes Where ScheduleType = 3 and @AttFriday = 1 Union
		Select ClassID, BPeriodOnSaturday as PeriodID From Classes Where ScheduleType = 3 and @AttSaturday = 1
		) CP
			on CP.ClassID = C.ClassID
		Where
		C.ParentClassID = 0
		and
		CP.PeriodID != 0
	) SP
		on	SP.StudentID = CS.StudentID
			and 
			SP.TermID = C.TermID
		inner join
	Periods P
		on SP.PeriodID = P.PeriodID
		inner join
	cte 
		on
		C.TermID = cte.TermID and CS.StudentID = cte.StudentID	
	Where
	C.ParentClassID = 0
	Group By CS.StudentID, C.TermID
	
	
	


	Select
		1 as tag,
		Null as parent,
		datename(month,dbo.GLgetdatetime()) + ' ' + datename(day,dbo.GLgetdatetime()) + ', ' + datename(year,dbo.GLgetdatetime()) As [General!1!TheDate],
		@StudentsParentsCanViewLockerInfo as [General!1!StudentsParentsCanViewLockerInfo],
		@Admin as [General!1!Admin],
		@Sort AS [General!1!Sort],
		@ClassID AS [General!1!ClassID],
		@EK AS [General!1!EK],
		@StudentID as [General!1!StudentID],
		@GradeLevelSelected as [General!1!GradeLevelSelected],
		@ShowAllClasses AS [General!1!ShowAllClasses],
		@ShowTimeMap AS [General!1!ShowTimeMap],
		@ShowClassColor AS [General!1!ShowClassColor],
		@ShowBiWeeklySchedule AS [General!1!ShowBiWeeklySchedule],
		@School AS [General!1!School],
		@SchoolAddress AS [General!1!SchoolAddress],
		@SchoolPhone AS [General!1!SchoolPhone],
		@SchoolFax AS [General!1!SchoolFax],
		@EnableStudentLockerInfo AS [General!1!EnableStudentLockerInfo],
		@TimeHeightFactor as [General!1!TimeHeightFactor],
		@AttSunday as [General!1!AttSunday],
		@AttMonday as [General!1!AttMonday],
		@AttTuesday as [General!1!AttTuesday],
		@AttWednesday as [General!1!AttWednesday],
		@AttThursday as [General!1!AttThursday],
		@AttFriday as [General!1!AttFriday],
		@AttSaturday as [General!1!AttSaturday],
        
		Null as [Student!2!Term],
		Null AS [Student!2!StudentID],
		Null AS [Student!2!xStudentID],
		Null AS [Student!2!Lname],
		Null AS [Student!2!Fname],
		Null AS [Student!2!Mname],
		Null AS [Student!2!Sname],
		Null AS [Student!2!GradeLevel],
		Null as [Student!2!LockerNumber],
		Null as [Student!2!LockerCode],
		Null as [Student!2!TimeLegendHTML],

	 	Null As [Class!3!Period],
		Null As [Class!3!ClassTitle],
		Null As [Class!3!Teacher],
		Null As [Class!3!Location],
		Null as [Class!3!LPClassColor],
		Null as [Class!3!PeriodOnSunday],
		Null as [Class!3!PeriodOnSundayConflicts],
		Null as [Class!3!PeriodOnSundayStartMinute],
		Null as [Class!3!PeriodOnSundayEndMinute],
		Null as [Class!3!PeriodOnSundayTime],
		Null as [Class!3!BPeriodOnSunday],
		Null as [Class!3!BPeriodOnSundayConflicts],
		Null as [Class!3!BPeriodOnSundayStartMinute],
		Null as [Class!3!BPeriodOnSundayEndMinute],
		Null as [Class!3!BPeriodOnSundayTime],
		Null as [Class!3!PeriodOnMonday],
		Null as [Class!3!PeriodOnMondayConflicts],
		Null as [Class!3!PeriodOnMondayStartMinute],
		Null as [Class!3!PeriodOnMondayEndMinute],
		Null as [Class!3!PeriodOnMondayTime],			
		Null as [Class!3!BPeriodOnMonday],
		Null as [Class!3!BPeriodOnMondayConflicts],
		Null as [Class!3!BPeriodOnMondayStartMinute],
		Null as [Class!3!BPeriodOnMondayEndMinute],
		Null as [Class!3!BPeriodOnMondayTime],			
		Null as [Class!3!PeriodOnTuesday],
		Null as [Class!3!PeriodOnTuesdayConflicts],
		Null as [Class!3!PeriodOnTuesdayStartMinute],
		Null as [Class!3!PeriodOnTuesdayEndMinute],
		Null as [Class!3!PeriodOnTuesdayTime],
		Null as [Class!3!BPeriodOnTuesday],
		Null as [Class!3!BPeriodOnTuesdayConflicts],
		Null as [Class!3!BPeriodOnTuesdayStartMinute],
		Null as [Class!3!BPeriodOnTuesdayEndMinute],	
		Null as [Class!3!BPeriodOnTuesdayTime],
		Null as [Class!3!PeriodOnWednesday],
		Null as [Class!3!PeriodOnWednesdayConflicts],
		Null as [Class!3!PeriodOnWednesdayStartMinute],
		Null as [Class!3!PeriodOnWednesdayEndMinute],
		Null as [Class!3!PeriodOnWednesdayTime],
		Null as [Class!3!BPeriodOnWednesday],
		Null as [Class!3!BPeriodOnWednesdayConflicts],
		Null as [Class!3!BPeriodOnWednesdayStartMinute],
		Null as [Class!3!BPeriodOnWednesdayEndMinute],	
		Null as [Class!3!BPeriodOnWednesdayTime],
		Null as [Class!3!PeriodOnThursday],
		Null as [Class!3!PeriodOnThursdayConflicts],
		Null as [Class!3!PeriodOnThursdayStartMinute],
		Null as [Class!3!PeriodOnThursdayEndMinute],	
		Null as [Class!3!PeriodOnThursdayTime],
		Null as [Class!3!BPeriodOnThursday],
		Null as [Class!3!BPeriodOnThursdayConflicts],
		Null as [Class!3!BPeriodOnThursdayStartMinute],
		Null as [Class!3!BPeriodOnThursdayEndMinute],
		Null as [Class!3!BPeriodOnThursdayTime],
		Null as [Class!3!PeriodOnFriday],
		Null as [Class!3!PeriodOnFridayConflicts],
		Null as [Class!3!PeriodOnFridayStartMinute],
		Null as [Class!3!PeriodOnFridayEndMinute],	
		Null as [Class!3!PeriodOnFridayTime],
		Null as [Class!3!BPeriodOnFriday],
		Null as [Class!3!BPeriodOnFridayConflicts],
		Null as [Class!3!BPeriodOnFridayStartMinute],
		Null as [Class!3!BPeriodOnFridayEndMinute],
		Null as [Class!3!BPeriodOnFridayTime],
		Null as [Class!3!PeriodOnSaturday],
		Null as [Class!3!PeriodOnSaturdayConflicts],
		Null as [Class!3!PeriodOnSaturdayStartMinute],
		Null as [Class!3!PeriodOnSaturdayEndMinute],
		Null as [Class!3!PeriodOnSaturdayTime],
		Null as [Class!3!BPeriodOnSaturday],
		Null as [Class!3!BPeriodOnSaturdayConflicts],
		Null as [Class!3!BPeriodOnSaturdayStartMinute],
		Null as [Class!3!BPeriodOnSaturdayEndMinute],
		Null as [Class!3!BPeriodOnSaturdayTime],
		Null as [Class!3!LocationOnSunday],
		Null as [Class!3!LocationOnMonday],
		Null as [Class!3!LocationOnTuesday],
		Null as [Class!3!LocationOnWednesday],
		Null as [Class!3!LocationOnThursday],
		Null as [Class!3!LocationOnFriday],
		Null as [Class!3!LocationOnSaturday],
		Null as [Class!3!BLocationOnSunday],
		Null as [Class!3!BLocationOnMonday],
		Null as [Class!3!BLocationOnTuesday],
		Null as [Class!3!BLocationOnWednesday],
		Null as [Class!3!BLocationOnThursday],
		Null as [Class!3!BLocationOnFriday],
		Null as [Class!3!BLocationOnSaturday]
		

	Union All

	Select Distinct	
		2 as tag,
		1 as parent,
		null as [General!1!StudentsParentsCanViewLockerInfo],
		null as [General!1!Admin],
 		Null As [General!1!TheDate],
		Null AS [General!1!Sort],
		Null AS [General!1!ClassID],
		Null AS [General!1!EK],
		Null as [General!1!StudentID],
		Null as [General!1!GradeLevelSelected],
		Null as [General!1!ShowAllClasses],
		Null AS [General!1!ShowTimeMap],
		Null AS [General!1!ShowClassColor],
		Null AS [General!1!ShowBiWeeklySchedule],
		Null AS [General!1!School],
		Null AS [General!1!SchoolAddress],
		Null AS [General!1!SchoolPhone],
		Null AS [General!1!SchoolFax],
		Null AS [General!1!EnableStudentLockerInfo],
		Null as [General!1!TimeHeightFactor],
		Null as [General!1!AttSunday],
		Null as [General!1!AttMonday],
		Null as [General!1!AttTuesday],
		Null as [General!1!AttWednesday],
		Null as [General!1!AttThursday],
		Null as [General!1!AttFriday],
		Null as [General!1!AttSaturday],

		Tm.TermTitle as [Student!2!Term],
		S.StudentID AS [Student!2!StudentID],
		S.xStudentID AS [Student!2!xStudentID],
		S.Lname AS [Student!2!Lname],
		S.Fname AS [Student!2!Fname],
		S.Mname AS [Student!2!Mname],
		S.glname AS [Student!2!Sname],
		S.GradeLevel AS [Student!2!GradeLevel],
		S.LockerNumber as [Student!2!LockerNumber],
		S.LockerCode as [Student!2!LockerCode],
		ST.TimeLegendHTML as [Student!2!TimeLegendHTML],

	 	Null As [Class!3!Period],
		Null As [Class!3!ClassTitle],
		Null As [Class!3!Teacher],
		Null As [Class!3!Location],
		Null as [Class!3!LPClassColor],
		Null as [Class!3!PeriodOnSunday],
		Null as [Class!3!PeriodOnSundayConflicts],
		Null as [Class!3!PeriodOnSundayStartMinute],
		Null as [Class!3!PeriodOnSundayEndMinute],
		Null as [Class!3!PeriodOnSundayTime],
		Null as [Class!3!BPeriodOnSunday],
		Null as [Class!3!BPeriodOnSundayConflicts],
		Null as [Class!3!BPeriodOnSundayStartMinute],
		Null as [Class!3!BPeriodOnSundayEndMinute],
		Null as [Class!3!BPeriodOnSundayTime],
		Null as [Class!3!PeriodOnMonday],
		Null as [Class!3!PeriodOnMondayConflicts],
		Null as [Class!3!PeriodOnMondayStartMinute],
		Null as [Class!3!PeriodOnMondayEndMinute],
		Null as [Class!3!PeriodOnMondayTime],			
		Null as [Class!3!BPeriodOnMonday],
		Null as [Class!3!BPeriodOnMondayConflicts],
		Null as [Class!3!BPeriodOnMondayStartMinute],
		Null as [Class!3!BPeriodOnMondayEndMinute],
		Null as [Class!3!BPeriodOnMondayTime],			
		Null as [Class!3!PeriodOnTuesday],
		Null as [Class!3!PeriodOnTuesdayConflicts],
		Null as [Class!3!PeriodOnTuesdayStartMinute],
		Null as [Class!3!PeriodOnTuesdayEndMinute],
		Null as [Class!3!PeriodOnTuesdayTime],
		Null as [Class!3!BPeriodOnTuesday],
		Null as [Class!3!BPeriodOnTuesdayConflicts],
		Null as [Class!3!BPeriodOnTuesdayStartMinute],
		Null as [Class!3!BPeriodOnTuesdayEndMinute],	
		Null as [Class!3!BPeriodOnTuesdayTime],
		Null as [Class!3!PeriodOnWednesday],
		Null as [Class!3!PeriodOnWednesdayConflicts],
		Null as [Class!3!PeriodOnWednesdayStartMinute],
		Null as [Class!3!PeriodOnWednesdayEndMinute],
		Null as [Class!3!PeriodOnWednesdayTime],
		Null as [Class!3!BPeriodOnWednesday],
		Null as [Class!3!BPeriodOnWednesdayConflicts],
		Null as [Class!3!BPeriodOnWednesdayStartMinute],
		Null as [Class!3!BPeriodOnWednesdayEndMinute],	
		Null as [Class!3!BPeriodOnWednesdayTime],
		Null as [Class!3!PeriodOnThursday],
		Null as [Class!3!PeriodOnThursdayConflicts],
		Null as [Class!3!PeriodOnThursdayStartMinute],
		Null as [Class!3!PeriodOnThursdayEndMinute],	
		Null as [Class!3!PeriodOnThursdayTime],
		Null as [Class!3!BPeriodOnThursday],
		Null as [Class!3!BPeriodOnThursdayConflicts],
		Null as [Class!3!BPeriodOnThursdayStartMinute],
		Null as [Class!3!BPeriodOnThursdayEndMinute],
		Null as [Class!3!BPeriodOnThursdayTime],
		Null as [Class!3!PeriodOnFriday],
		Null as [Class!3!PeriodOnFridayConflicts],
		Null as [Class!3!PeriodOnFridayStartMinute],
		Null as [Class!3!PeriodOnFridayEndMinute],	
		Null as [Class!3!PeriodOnFridayTime],
		Null as [Class!3!BPeriodOnFriday],
		Null as [Class!3!BPeriodOnFridayConflicts],
		Null as [Class!3!BPeriodOnFridayStartMinute],
		Null as [Class!3!BPeriodOnFridayEndMinute],
		Null as [Class!3!BPeriodOnFridayTime],
		Null as [Class!3!PeriodOnSaturday],
		Null as [Class!3!PeriodOnSaturdayConflicts],
		Null as [Class!3!PeriodOnSaturdayStartMinute],
		Null as [Class!3!PeriodOnSaturdayEndMinute],
		Null as [Class!3!PeriodOnSaturdayTime],
		Null as [Class!3!BPeriodOnSaturday],
		Null as [Class!3!BPeriodOnSaturdayConflicts],
		Null as [Class!3!BPeriodOnSaturdayStartMinute],
		Null as [Class!3!BPeriodOnSaturdayEndMinute],
		Null as [Class!3!BPeriodOnSaturdayTime],
		Null as [Class!3!LocationOnSunday],
		Null as [Class!3!LocationOnMonday],
		Null as [Class!3!LocationOnTuesday],
		Null as [Class!3!LocationOnWednesday],
		Null as [Class!3!LocationOnThursday],
		Null as [Class!3!LocationOnFriday],
		Null as [Class!3!LocationOnSaturday],
		Null as [Class!3!BLocationOnSunday],
		Null as [Class!3!BLocationOnMonday],
		Null as [Class!3!BLocationOnTuesday],
		Null as [Class!3!BLocationOnWednesday],
		Null as [Class!3!BLocationOnThursday],
		Null as [Class!3!BLocationOnFriday],
		Null as [Class!3!BLocationOnSaturday]

	From 
	Classes C 
		inner join 
	Teachers T
		on C.TeacherID = T.TeacherID 
		inner join 
	ClassesStudents CS
		on C.ClassID = CS.ClassID 
		inner join 
	Students S
		on S.StudentID = CS.StudentID
		inner join 
	Terms Tm
			on	C.TermID = Tm.TermID
				and 
				Tm.Status = 1
				and 
				Tm.ExamTerm = 0							
			inner join 
	#StudentTerms ST 
		on 
			ST.StudentID = CS.StudentID 
			and 
			ST.TermID=Tm.TermID 
	Where 	
			C.ClassTitle is not null 
			and
			Tm.TermID not in (Select ParentTermID From Terms)
			and 
			case
				when C.ShowOnSchedule = 1 then 1
				when @ShowAllClasses = 'yes' then 1
				when C.ClassTypeID in (1,8) then 1
				else 0
			end = 1
			and 
			case
				when @GradeLevelSelected = 'All' and @StudentID = -1 then 1
				when @GradeLevelSelected = S.GradeLevel and @StudentID = -1 then 1
				when CS.StudentID = @StudentID then 1
			end = 1

	Union All

	Select
		3 as tag,
		2 as parent,
		null as [General!1!StudentsParentsCanViewLockerInfo],
		null as [General!1!Admin],
 		Null As [General!1!TheDate],
		Null AS [General!1!Sort],
		Null AS [General!1!ClassID],
		Null AS [General!1!EK],
		Null as [General!1!StudentID],
		Null as [General!1!GradeLevelSelected],
		Null as [General!1!ShowAllClasses],
		Null AS [General!1!ShowTimeMap],
		Null AS [General!1!ShowClassColor],
		Null AS [General!1!ShowBiWeeklySchedule],
		Null AS [General!1!School],
		Null AS [General!1!SchoolAddress],
		Null AS [General!1!SchoolPhone],
		Null AS [General!1!SchoolFax],
		Null AS [General!1!EnableStudentLockerInfo],
		Null as [General!1!TimeHeightFactor],
		Null as [General!1!AttSunday],
		Null as [General!1!AttMonday],
		Null as [General!1!AttTuesday],
		Null as [General!1!AttWednesday],
		Null as [General!1!AttThursday],
		Null as [General!1!AttFriday],
		Null as [General!1!AttSaturday],
        
        Tm.TermTitle as [Student!2!Term],
		S.StudentID AS [Student!2!StudentID],
		Null AS [Student!2!xStudentID],
		S.Lname AS [Student!2!Lname],
		S.Fname AS [Student!2!Fname],
		S.Mname AS [Student!2!Mname],
		S.glname AS [Student!2!Sname],
		S.GradeLevel AS [Student!2!GradeLevel],
		Null as [Student!2!LockerNumber],
		Null as [Student!2!LockerCode],
		Null as [Student!2!TimeLegendHTML],
		
	 	C.Period as [Class!3!Period],
		C.ClassTitle as [Class!3!ClassTitle],
		case
			when isnull(ltrim(rtrim(T.StaffTitle)),'') = '' then T.glname
			else ltrim(rtrim(T.StaffTitle)) + ' ' + T.glname
		end as [Class!3!Teacher],
		C.Location as [Class!3!Location],
		C.LPClassColor as [Class!3!LPClassColor],
		-- Sunday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end as [Class!3!PeriodOnSunday],
		dbo.PeriodOnSundayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekA') as [Class!3!PeriodOnSundayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end)  as [Class!3!PeriodOnSundayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end)  as [Class!3!PeriodOnSundayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSunday else C.PeriodOnSunday end) end)  as [Class!3!PeriodOnSundayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end as [Class!3!BPeriodOnSunday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnSundayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekB') 
		end as [Class!3!BPeriodOnSundayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end)  as [Class!3!BPeriodOnSundayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end)  as [Class!3!BPeriodOnSundayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSunday else C.BPeriodOnSunday end) end)  as [Class!3!BPeriodOnSundayTime],
		-- Monday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end as [Class!3!PeriodOnMonday],
		dbo.PeriodOnMondayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekA') as [Class!3!PeriodOnMondayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end)  as [Class!3!PeriodOnMondayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end)  as [Class!3!PeriodOnMondayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnMonday else C.PeriodOnMonday end) end)  as [Class!3!PeriodOnMondayTime],			
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end as [Class!3!BPeriodOnMonday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnMondayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekB') 
		end as [Class!3!BPeriodOnMondayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end)  as [Class!3!BPeriodOnMondayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end)  as [Class!3!BPeriodOnMondayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnMonday else C.BPeriodOnMonday end) end)  as [Class!3!BPeriodOnMondayTime],			
		-- Tuesday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end as [Class!3!PeriodOnTuesday],
		dbo.PeriodOnTuesdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekA')	as [Class!3!PeriodOnTuesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end)  as [Class!3!PeriodOnTuesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end)  as [Class!3!PeriodOnTuesdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnTuesday else C.PeriodOnTuesday end) end)  as [Class!3!PeriodOnTuesdayTime],		
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end as [Class!3!BPeriodOnTuesday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnTuesdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekB') 
		end as [Class!3!BPeriodOnTuesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end)  as [Class!3!BPeriodOnTuesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end)  as [Class!3!BPeriodOnTuesdayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnTuesday else C.BPeriodOnTuesday end) end)  as [Class!3!BPeriodOnTuesdayTime],
		-- Wednesday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end as [Class!3!PeriodOnWednesday],
		dbo.PeriodOnWednesdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekA') as [Class!3!PeriodOnWednesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end)  as [Class!3!PeriodOnWednesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end)  as [Class!3!PeriodOnWednesdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnWednesday else C.PeriodOnWednesday end) end)  as [Class!3!PeriodOnWednesdayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end as [Class!3!BPeriodOnWednesday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnWednesdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekB') 
		end as [Class!3!BPeriodOnWednesdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end)  as [Class!3!BPeriodOnWednesdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end)  as [Class!3!BPeriodOnWednesdayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnWednesday else C.BPeriodOnWednesday end) end)  as [Class!3!BPeriodOnWednesdayTime],
		-- Thursday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end as [Class!3!PeriodOnThursday],
		dbo.PeriodOnThursdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekA') as [Class!3!PeriodOnThursdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end)  as [Class!3!PeriodOnThursdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end)  as [Class!3!PeriodOnThursdayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnThursday else C.PeriodOnThursday end) end)  as [Class!3!PeriodOnThursdayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end as [Class!3!BPeriodOnThursday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnThursdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekB') 
		end as [Class!3!BPeriodOnThursdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end)  as [Class!3!BPeriodOnThursdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end)  as [Class!3!BPeriodOnThursdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnThursday else C.BPeriodOnThursday end) end)  as [Class!3!BPeriodOnThursdayTime],
		-- Friday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end as [Class!3!PeriodOnFriday],
		dbo.PeriodOnFridayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekA') as [Class!3!PeriodOnFridayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end)  as [Class!3!PeriodOnFridayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end)  as [Class!3!PeriodOnFridayEndMinute],	
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnFriday else C.PeriodOnFriday end) end)  as [Class!3!PeriodOnFridayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end as [Class!3!BPeriodOnFriday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnFridayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekB') 
		end as [Class!3!BPeriodOnFridayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end)  as [Class!3!BPeriodOnFridayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end)  as [Class!3!BPeriodOnFridayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnFriday else C.BPeriodOnFriday end) end)  as [Class!3!BPeriodOnFridayTime],
		-- Saturday
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end as [Class!3!PeriodOnSaturday],
		dbo.PeriodOnSaturdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekA') as [Class!3!PeriodOnSaturdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end)  as [Class!3!PeriodOnSaturdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end)  as [Class!3!PeriodOnSaturdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.BPeriodOnSaturday else C.PeriodOnSaturday end) end)  as [Class!3!PeriodOnSaturdayTime],
		case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end as [Class!3!BPeriodOnSaturday],
		case
			when @ShowBiWeeklySchedule = 'no' then 0
			else dbo.PeriodOnSaturdayClassConflictsExist(ST.TermID, C.ClassID, ST.StudentID, 'WeekB') 
		end as [Class!3!BPeriodOnSaturdayConflicts],
		(Select (DATEDIFF(MINUTE, 0, PeriodStartTime)* @TimeHeightFactor)- ST.StartTimePadding From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end)  as [Class!3!BPeriodOnSaturdayStartMinute],
		(Select (DATEDIFF(MINUTE, PeriodStartTime, PeriodEndTime)* @TimeHeightFactor) - @ClassDivAdditionalHeightSpacing From Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end)  as [Class!3!BPeriodOnSaturdayEndMinute],
		(Select PeriodString From @Periods Where PeriodID = case when C.ScheduleType = 1 then C.Period else (case when C.BiWeeklySchedStart2ndWeek = 1 then C.PeriodOnSaturday else C.BPeriodOnSaturday end) end)  as [Class!3!BPeriodOnSaturdayTime],
		
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnSunday)
		end as [Class!3!LocationOnSunday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnMonday) 
		end as [Class!3!LocationOnMonday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnTuesday) 
		end as [Class!3!LocationOnTuesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnWednesday) 
		end as [Class!3!LocationOnWednesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnThursday) 
		end as [Class!3!LocationOnThursday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnFriday) 
		end as [Class!3!LocationOnFriday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.LocationOnSaturday) 
		end as [Class!3!LocationOnSaturday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnSunday) 
		end as [Class!3!BLocationOnSunday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnMonday) 
		end as [Class!3!BLocationOnMonday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnTuesday) 
		end as [Class!3!BLocationOnTuesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnWednesday) 
		end as [Class!3!BLocationOnWednesday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnThursday) 
		end as [Class!3!BLocationOnThursday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnFriday) 
		end as [Class!3!BLocationOnFriday],
		case 
			when C.ScheduleType = 1 then C.Location
			else (Select Location From Locations Where LocationID = C.BLocationOnSaturday) 
		end as [Class!3!BLocationOnSaturday]
		
	From 
	Classes C 
		inner join 
	Teachers T
		on C.TeacherID = T.TeacherID 
		inner join 
	ClassesStudents CS
		on C.ClassID = CS.ClassID 
		inner join 
	Students S
		on S.StudentID = CS.StudentID 
		inner join 
	Terms Tm
			on	C.TermID = Tm.TermID
				and 
				Tm.Status = 1
				and 
				Tm.ExamTerm = 0							
			inner join 
	#StudentTerms ST 
		on 
			ST.StudentID = CS.StudentID 
			and 
			ST.TermID=Tm.TermID 
	Where 	C.ClassTitle is not null 
			and
			Tm.TermID not in (Select ParentTermID From Terms)
			and 
			case
				when C.ShowOnSchedule = 1 then 1
				when @ShowAllClasses = 'yes' then 1
				when C.ClassTypeID in (1,8) then 1
				else 0
			end = 1
			and
			ParentClassID = 0
			and 
			case
				when @GradeLevelSelected = 'All' and @StudentID = -1 then 1
				when @GradeLevelSelected = S.GradeLevel and @StudentID = -1 then 1
				when CS.StudentID = @StudentID then 1
			end = 1

	Order By [Student!2!Lname], [Student!2!Fname], [Student!2!Mname], [Student!2!StudentID], [Student!2!Term], [Class!3!Period], [Class!3!ClassTitle], tag
	FOR XML EXPLICIT


	Select
	(
		Select
		convert(tinyint, AttSunday) +
		convert(tinyint, AttMonday ) +
		convert(tinyint, AttTuesday ) +
		convert(tinyint, AttWednesday ) +
		convert(tinyint, AttThursday ) +
		convert(tinyint, AttFriday ) +
		convert(tinyint, AttSaturday)
		From Settings
		Where
		SettingID = 1
	) as NumberOfDays,
	AttSunday,
	AttMonday,
	AttTuesday,
	AttWednesday,
	AttThursday,
	AttFriday,
	AttSaturday
	From Settings
	Where
	SettingID = 1
	FOR XML RAW	

	drop table #StudentTerms;
	        
END
GO
