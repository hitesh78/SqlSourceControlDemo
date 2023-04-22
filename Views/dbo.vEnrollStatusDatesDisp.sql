SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vEnrollStatusDatesDisp] as
select 
	EnrollStudentStatusDateID,
	EnrollmentStudentID,
	FormStatus,
	UpdateDateTime,
	s.Title as SessionTitle 
from EnrollStudentStatusDates essd
left join Session s
on essd.SessionID = s.SessionID
GO
