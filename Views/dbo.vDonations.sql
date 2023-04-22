SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vDonations] as
select s.FullName,s.Fname,s.Mname,s.Lname,s.GradeLevX GradeLevel,s.xStudentID,d.*,
	replace(FundraisingCodes,'; ','<br/>') as FundraisingCodesHTML
from Donations d
left join vStudents s 
on d.StudentID=s.StudentID
GO
