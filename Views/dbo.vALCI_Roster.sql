SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vALCI_Roster]
AS
select 
s.*,
es.*
from 
StudentRoster s
left join 
(select EnrollmentStudentID,duration,other_program,housing_type,other_housing,learn_about,learn_about_name 
from vEnrollmentStudent) es
on es.EnrollmentStudentID = 
(select top 1 es1.EnrollmentStudentID 
	from EnrollmentStudent es1
	where s.StudentID = es1.ImportStudentID or s.StudentID = es1.StudentID
	and es1.SessionID=(Select SessionID from EnrollmentFormSettings)
	order by es1.EnrollmentStudentID desc
)

GO
