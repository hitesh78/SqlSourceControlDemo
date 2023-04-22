SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- =============================================
-- Author:		Joey
-- Create date: 06/15/2021
-- Modified dt: 02/08/2022
-- Description:	This returns the valid edfi Students
-- Parameters: startDate, endDate 
-- select * from dbo.fnEdfiValidStudents('2020-08-01', '2021-05-28')
-- =============================================
CREATE        FUNCTION [dbo].[fnEdfiValidStudents]
(
	@CalendarStartDate datetime,
	@CalendarEndDate datetime
)
RETURNS 
@StudentIDs TABLE
(
	StudentID int
)
AS
BEGIN

	Declare @AttendanceEvents table (ID nvarchar(10), edfiAttendanceEvent nvarchar(50));
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

	Declare @StudentIDsWithAttendance table (StudentID int PRIMARY KEY);
	Insert into @StudentIDsWithAttendance
	Select distinct
	S.StudentID
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
	Where
	T.ExamTerm = 0        -- exclude exam terms
	and
	T.TermID not in (Select ParentTermID From Terms)
	and
	T.StartDate >= @CalendarStartDate
	and
	T.EndDate <= @CalendarEndDate
	and
	C.ClassTypeID = 5
	and
	isnull(s.Affiliations,'') not like '%Staff%'
	and
	case
		when A.Att1 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att1')
		when A.Att2 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att2')
		when A.Att3 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att3')
		when A.Att4 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att4')
		when A.Att5 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att5')
		when A.Att6 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att6')
		when A.Att7 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att7')
		when A.Att8 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att8')
		when A.Att9 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att9')
		when A.Att10 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att10')
		when A.Att11 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att11')
		when A.Att12 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att12')
		when A.Att13 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att13')
		when A.Att14 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att14')
		when A.Att15 = 1 then (Select EdfiAttendanceEvent From @AttendanceEvents Where ID = 'Att15')
	end is not null;

	Declare @DuplicateStnIDs table (StudentID int PRIMARY KEY, StandTestID nvarchar(30));
	Insert into @DuplicateStnIDs
	Select 
		s.StudentID,
		sm.StandTestID
	From
	StudentMiscFields sm
		inner join
	Students s
		on s.StudentID = sm.StudentID
	where sm.StandTestID IN (
		Select StandTestID 
		From 
		StudentMiscFields sm2
			inner join
		Students s2
			on s2.StudentID = sm2.StudentID
		where sm2.StandTestID <> ''
		and
		(
			s2.Active = 1
			or
			s2.StudentID in (Select StudentID From @StudentIDsWithAttendance)
		)
		group by StandTestID 
		having COUNT(*) > 1
	);

	Insert into @StudentIDs
	Select distinct
	S.StudentID
	From
	Students S
		left join
	StudentMiscFields SM
		on S.StudentID = SM.StudentID
		left join
	StudentRace SR
		on S.StudentID = SR.StudentID
	Where
	(
		S.Active = 1
		or
		s.StudentID in (Select StudentID From @StudentIDsWithAttendance)
	)
	and
	isnull(s.Affiliations,'') not like '%Staff%'
	and
	isnull(ltrim(rtrim(SM.StandTestID)),'') <> ''
	and
	isnull(ltrim(rtrim(S.Sex)),'') <> ''
	and
	isnull(ltrim(rtrim(S.StateAbbr)),'') <> ''
	and
	isnull(ltrim(rtrim(S.Street)),'') <> ''
	and
	isnull(ltrim(rtrim(S.City)),'') <> ''
	and
	isnull(ltrim(rtrim(S.Zip)),'') <> ''
	and
	isnull(SR.RaceID,0) <> 0
	and
	isnull(S.BirthDate,'1900-01-01') <> '1900-01-01'
	and
	case 
		when isnull(rtrim(ltrim(S.WithdrawalDate)),'') != '' and convert(nvarchar(100), isnull(S.WithdrawReason,'')) = '' then 0
		else 1
	end = 1
	and
	case 
		when	isnull(rtrim(ltrim(SM.EdfiBirthCountryCodeValue)),'USA') != 'USA' 
				and
				isnull(rtrim(ltrim(SM.USEntryDate)),'') = '' 
			then 0
		else 1
	end = 1
	and
	isnull((
		Select top 1 Phone
		From
		(
			Select Phone From PhoneNumbers Where StudentID = S.StudentID
			Union
			Select P.Phone 
			From 
			PhoneNumbers P
				inner join
			StudentContacts SC
				on SC.RolesAndPermissions = '(SIS Parent Contact)' 
				and P.ContactID = SC.ContactID
			Where SC.StudentID = S.StudentID
		) x)
	,'') <> ''
	and
	(
		isnull(ltrim(rtrim(S.Email1)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(S.Email2)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(S.Email3)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(S.Email4)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(S.Email5)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(S.Email6)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(S.Email7)),'') LIKE '%_@%_.__%'
		or
		isnull(ltrim(rtrim(S.Email8)),'') LIKE '%_@%_.__%'
	)
	and
	S.StudentID not in (Select StudentID From @DuplicateStnIDs)
	and
	ltrim(rtrim(isnull(SM.CorpNumberIndiana_DOE_MV,''))) != '0'
	and
	ltrim(rtrim(isnull(SM.CorpNumberIndiana_DOE_MV,''))) != '';


	RETURN

END
GO
