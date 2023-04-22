SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Don Puls
-- Create date: 05/12/2021
-- Modified dt: 02/08/2022 
-- Description:	Takes 4 parameters and returns a JSON string of edfi edfiStudentsSchoolAttendanceEvents data
-- =============================================
CREATE           PROCEDURE [dbo].[edfiStudentsSchoolAttendanceEvents]
@SchoolYear int,
@CalendarStartDate date,
@CalendarEndDate date,
@CalendarEventsJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	Declare @AttendanceEvents table (ID nvarchar(10) PRIMARY KEY, edfiAttendanceEvent nvarchar(50));
	Insert into @AttendanceEvents
	Select
	A.ID,
	EA.edfiAttendanceEvent 
	From 
	AttendanceSettings A
		inner join
	EdfiAttendanceEvents EA
		on A.edfiAttendanceEventID = EA.edfiAttendanceEventID
	Where 
	A.MultiSelect = 0 and 
	A.ExcludedAttendance = 0;

	Declare @AttendanceData table (
				sessionReference_termDescriptor nvarchar(50),
				studentReference_studentUniqueId nvarchar(50),
				attendanceEventCategoryDescriptor nvarchar(50),
				eventDate date,
				eventDuration decimal(3,2)
		)

	Declare @ValidStudentIDs table (StudentID int PRIMARY KEY);
	Insert into @ValidStudentIDs
	Select StudentID
	From dbo.fnEdfiValidStudents(@CalendarStartDate, @CalendarEndDate);

	Insert into @AttendanceData
	Select
	E.[Sessions] as [sessionReference.termDescriptor],
	sm.StandTestID as [studentReference.studentUniqueId],
	case
		when A.Att1 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att1') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att1')
		when A.Att2 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att2') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att2')
		when A.Att3 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att3') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att3')
		when A.Att4 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att4') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att4')
		when A.Att5 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att5') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att5')
		when A.Att6 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att6') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att6')
		when A.Att7 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att7') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att7')
		when A.Att8 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att8') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att8')
		when A.Att9 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att9') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att9')
		when A.Att10 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att10') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att10')
		when A.Att11 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att11') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att11')
		when A.Att12 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att12') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att12')
		when A.Att13 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att13') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att13')
		when A.Att14 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att14') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att14')
		when A.Att15 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att15') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att15')
	end as [attendanceEventCategoryDescriptor],
	convert(date,A.ClassDate) as [eventDate],
	1 as [eventDuration]
	From 
	Terms T
		inner join
	EdfiPeriods E
		on T.EdfiPeriodID = E.EdfiPeriodID
		inner join
	Classes C
		on T.TermID = C.TermID
		inner join
	ClassesStudents CS
		on C.ClassID = CS.ClassID
		inner join
	Attendance A
		on A.CSID = CS.CSID
		inner join
	Students S
		on S.StudentID = CS.StudentID
		left join
	StudentMiscFields sm
		on S.StudentID = sm.StudentID
	Where
	T.ExamTerm = 0        -- exclude exam terms
	and
	T.TermID not in (Select ParentTermID From Terms)
	and
	T.StartDate >= @CalendarStartDate
	and
	T.EndDate <= @CalendarEndDate
	--and
	--A.ClassDate between '2021-05-01' and '2021-05-20'	-- Comment this line out before releasing
	and
	C.ClassTypeID = 5
	and
	case
		when A.Att1 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att1') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att1')
		when A.Att2 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att2') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att2')
		when A.Att3 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att3') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att3')
		when A.Att4 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att4') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att4')
		when A.Att5 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att5') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att5')
		when A.Att6 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att6') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att6')
		when A.Att7 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att7') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att7')
		when A.Att8 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att8') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att8')
		when A.Att9 = 1 and	exists (Select * From @AttendanceEvents Where ID = 'Att9') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att9')
		when A.Att10 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att10') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att10')
		when A.Att11 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att11') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att11')
		when A.Att12 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att12') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att12')
		when A.Att13 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att13') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att13')
		when A.Att14 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att14') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att14')
		when A.Att15 = 1 and exists (Select * From @AttendanceEvents Where ID = 'Att15') then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att15')
	end is not null
	and
	S.StudentID in (select StudentID from @ValidStudentIDs);

	-- Add .5 In Attendance records for half days 
	insert into @AttendanceData
	Select
	sessionReference_termDescriptor,
	studentReference_studentUniqueId,
	'In Attendance',
	eventDate,
	.5
	From @AttendanceData
	Where
	attendanceEventCategoryDescriptor = 'Half Day Excused Absence'
	or 
	attendanceEventCategoryDescriptor = 'Half Day Unexcused Absence';


	-- Update Half Days to .5 duration and set to Excused Absence or Unexcused Absence
	Update @AttendanceData
	set 
	attendanceEventCategoryDescriptor = 
		case
			when attendanceEventCategoryDescriptor = 'Half Day Excused Absence' then 'Excused Absence'
			when attendanceEventCategoryDescriptor = 'Half Day Unexcused Absence' then 'Unexcused Absence'
		end,
	eventDuration = .5
	Where
	attendanceEventCategoryDescriptor = 'Half Day Excused Absence'
	or
	attendanceEventCategoryDescriptor = 'Half Day Unexcused Absence';

	-- Return results	
	set @CalendarEventsJSON = (
		Select
		@SchoolID as [schoolReference.schoolId],
		@SchoolID as [sessionReference.schoolId],
		@SchoolYear as [sessionReference.schoolYear],
		'http://doe.in.gov/Descriptor/TermDescriptor.xml/' + sessionReference_termDescriptor as [sessionReference.termDescriptor],
		studentReference_studentUniqueId as [studentReference.studentUniqueId],
		'http://doe.in.gov/Descriptor/AttendanceEventCategoryDescriptor.xml/' + attendanceEventCategoryDescriptor as [attendanceEventCategoryDescriptor],
		eventDate as [eventDate],
		eventDuration as [eventDuration]
		From @AttendanceData
		FOR JSON PATH
	);


END
GO
