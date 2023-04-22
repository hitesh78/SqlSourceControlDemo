SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vEnrollmentPrograms]
as
select 
	ep.EnrollmentProgramID,
	ep.SessionID,
	ep.EnrollmentProgram,
	s.title as SessionTitle,
	s._title as _SessionTitle
from EnrollmentPrograms ep
INNER JOIN vSession s on s.SessionID = ep.SessionID
union all
select 
	-1 as EnrollmentProgramID, 
	(Select SessionID from vSession where _Title like '%*') as SessionID,
	'' as EnrollmentProgram,
	(Select Title from vSession where _Title like '%*') as  SessionTitle,
	(Select _Title from vSession where _Title like '%*') as  _SessionTitle	



GO
