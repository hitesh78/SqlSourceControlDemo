SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[EnrollmentLevels] as
select top 100 percent
	max(ID) as ID,
	SessionID, 
	SessionTitle,
	GradeLevelOptionID,
	MAX(GradeLevelOption) GradeLevelOption,
	COUNT(*) as TotalEnrollments,
	SUM(NewEnrollments) NewEnrollments,
	SUM(ReEnrollments) ReEnrollments,
	SUM(Started) Started,
	SUM(Submitted) Submitted,
	SUM(InProcess) InProcess,
	SUM(Pending) Pending,
	SUM(Cancelled) Cancelled,
	SUM(Approved) Approved,
	SUM(NotApproved) NotApproved
	FROM
		(select
			cast(SessionID as bigint) * 1000000000 + isnull(GradeLevelOptionID,0) as ID,
			SessionID, 
			SessionTitle + 
				case when SessionID=(Select SessionID from EnrollmentFormSettings)
					then ' *' else '' end as SessionTitle,
			GradeLevelOptionID,
			GradeLevelOption,
			(case when StudentID>=1000000000 then 1 else 0 end) as NewEnrollments,
			(case when StudentID>=1000000000 then 0 else 1 end) as ReEnrollments,
			(case when FormStatus='Started' then 1 else 0 end) as Started,
			(case when FormStatus='Submitted' then 1 else 0 end) as Submitted,
			(case when FormStatus='In-Process' then 1 else 0 end) as InProcess,
			(case when FormStatus='Pending' then 1 else 0 end) as Pending,
			(case when FormStatus='Cancelled' then 1 else 0 end) as Cancelled,
			(case when FormStatus='Approved' then 1 else 0 end) as Approved,
			(case when FormStatus='Not Approved' then 1 else 0 end) as NotApproved
			from vEnrollmentStudent
			where EnrollmentStudentID is not null
				and GradeLevelOptionID is not null
		) x 
	group by SessionTitle, SessionID, GradeLevelOptionID
	order by 4,5

GO
