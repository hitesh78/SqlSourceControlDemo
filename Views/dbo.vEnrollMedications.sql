SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vEnrollMedications] as
select 
	1 as InstanceID,
	EnrollmentStudentID,
	StudentID,
	'Tylenol is permitted' as Medication,
	TylenolChildOrJunior + ' Strength' as DosageAndFreq,
	'Parent/Guardian permits use of Tylenol when needed up to the strength indicated.' as Notes,
	'(EnrollMe, imported ' + dbo.GLgetdate() + ')' as ReasonTaken
from EnrollmentStudent
where TylenolOK = 'Yes'
union
select 
	1 as InstanceID,
	EnrollmentStudentID,
	StudentID,
	'Tylenol is NOT permitted' as Medication,
	'' as DosageAndFreq,
	'Parent/Guardian DOES NOT permit use of Tylenol.' as Notes,
	'(EnrollMe, imported ' + dbo.GLgetdate() + ')' as ReasonTaken
from EnrollmentStudent
where TylenolOK = 'No'
union
select 
	2 as InstanceID,
	EnrollmentStudentID,
	StudentID,
	'Medications (see notes)' as Medication,
	'' as DosageAndFreq,
	MedicationsDesc as Notes,
	'(EnrollMe, imported ' + dbo.GLgetdate() + ')' as ReasonTaken
from EnrollmentStudent
where MedicationsYN = 'Yes'

GO
