SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vEnrollmentProspects]
as 
select 
	ProspectID,
	Address,
	Email,
	Phone,
	BirthDate,
	GradeEnteringSchool,
	NamePreviousSchool,
	HowHearAboutSchool,
	GuardianName,
	StudentName,
	ProcessingNotes,
	Tags,
	REPLACE(Tags,'; ','<br />') as TagsHTML,
	LogDate,
	FollowupDate,
	NextActionNote,
	CloseDate,
	CloseDisposition,
	0 as EditResponse,
	dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter('<b>'+StudentName+'</b>',GradeEnteringSchool,'<br/>&nbsp;&nbsp;'), 
		dbo.ConcatIfBoth('DOB: ',BirthDate), '<br/>&nbsp;&nbsp;') as Student,
	dbo.ConcatWithDelimiter('<b>'+GuardianName+'</b>', dbo.ConcatWithDelimiter(Phone,Email,'<br/>&nbsp;&nbsp;'),'<br/>&nbsp;&nbsp;') as Contact,
	case when CloseDate is null then 'Open' else 'Closed' end as OpenOrClosed
from EnrollmentProspects
union select
	-1 as ProspectID,
	null as Address,
	null as Email,
	null as Phone,
	null as BirthDate,
	null as GradeEnteringSchool,
	null as NamePreviousSchool,
	null as HowHearAboutSchool,
	null as GuardianName,
	null as StudentName,
	null as ProcessingNotes,
	null as Tags,
	null as TagsHTML,
	getdate() as LogDate,
	null as FollowupDate,
	null as NextActionNote,
	null as CloseDate,
	null as CloseDisposition,
	1 as EditResponse,
	null as Student,
	null as Contact,
	'Open' as OpenOrClosed
	

GO
