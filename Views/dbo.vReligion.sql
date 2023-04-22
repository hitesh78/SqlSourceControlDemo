SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vReligion]
as
select 
	s.StudentID,
	s.xStudentID,
	s.FamilyID,
	s.FullName,
	s._Status Status,
	s._Status _Status_no_export,
	s.GradeLevX,
	Religion,
	ReligionChurch,
	ReligionConversionDate,
	BaptismDate,
	CommunionDate,
	ReconciliationDate,
	ConfirmationDate,
	WeddingDate
from vStudentMiscFields m
right join vStudents s on s.StudentID = m.StudentID


GO
