SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[EnrollWorkflow]
as

with SubmitDates as (
	select EnrollmentStudentID,max(UpdateDateTime) UpdateDateTime
	from EnrollStudentStatusDates
	where FormStatus = 'Submitted'
	group by EnrollmentStudentID
), udf_for_595 as (
	SELECT table_pk_id as StudentID,  
		t.c.value('payment[1]','nvarchar(50)') udf1
		FROM xml_records x
	CROSS APPLY xml_fields.nodes('/') as t(c)
	WHERE DB_NAME() like '595%' AND entityName = 'RegTuition'
)
select x.*, ''/*deprecated*/ as EnrollFamilyID, udf1 from
( select
glo.GradeLevelOption, glo.GradeLevel,

	'<b>'+ glName + '</b>'
	+ dbo.ConcatIfBoth('<br/>&nbsp;&nbsp;-', glo.GradeLevelOption)
	+ dbo.ConcatIfBoth('<br/>&nbsp;&nbsp', sess.Title)
	+ case when es.EnteredByAdmin=1 
		then '<br/><span style=''font-style: italic; font-weight: bold; font-size: 10px; color: maroon !important''>&nbsp;&nbsp;MANUAL ENTRY</span>' 
		else '' end 
	AS FullName,

	case when es.StudentID>999999999 
		then 
			'New enrollment' 
		else 'Re-enrollment' 
		end + '<br/>&nbsp;&nbsp;-' + es.FormStatus
	+ '<br/><span style="font-size:10px; font-weight: bold; font-style: italic; color: maroon">'
	+ case when (Select max(convert(varchar,UpdateDate,21)+FormStatus) from EnrollStudentStatusDates e
			where e.EnrollmentStudentID = es.EnrollmentStudentID
				and FormStatus in ('Imported','Import deleted','Started') ) like '%Imported'
				and (Select 1 from Students where StudentID = es.ImportStudentID) is not null
			then 'IMPORTED' 
			else 
				case when es.FormStatus='Approved' then 'IMPORT PENDING' else '' end
			end
		+'</span>'

		as FormStatus,
	
	es.EnrollmentStudentID,
	es.StudentID,
	
	sess.Title
		+	case when sess.SessionID = (Select SessionID from EnrollmentFormSettings)
			then '*'
			else '' 
			end
		as SessionTitle,
	glName as StudentName,
	
	case when es.StudentID>999999999 
		then 
			'New enrollment' 
		else 'Re-enrollment' end as FormType,
	
	es.FormStatus frmStatus,
	
	(Select left(cast(max(convert(varchar,UpdateDate,21)) as varchar(50)), 19)
		from EnrollStudentStatusDates e
		where e.EnrollmentStudentID = es.EnrollmentStudentID) as LastStatusUpdate,
	
	case when (Select max(convert(varchar,UpdateDate,21)+FormStatus) from EnrollStudentStatusDates e
		where e.EnrollmentStudentID = es.EnrollmentStudentID
			and FormStatus in ('Imported','Import deleted','Started') ) like '%Imported'
			and (Select 1 from Students where StudentID = es.ImportStudentID) is not null
		then 'IMPORTED' 
		else 
			case when es.FormStatus='Approved' then 'PENDING' else '' end
		end	as ImportStatus,

	(select xStudentID from Students where StudentID = isnull(es.ImportStudentID,
		case when es.StudentID<1000000000 
		then abs(es.StudentID)%1000000000 else null end)) 
		as AssignedStudentID,

	case when es.EnteredByAdmin=1 then 'Yes' else 'No' end as ManualEntry,

	sd.UpdateDateTime
	
	from EnrollmentStudentDefaults es
left join GradeLevelOptions glo on es.GradeLevelOptionID = glo.GradeLevelOptionID
left join Session sess on es.SessionID = sess.SessionID
left join SubmitDates sd on sd.EnrollmentStudentID = es.EnrollmentStudentID
where 
es.ShowOnWorkflow = 1 ) x
left join udf_for_595 udfs on udfs.StudentID = x.StudentID 

GO
