SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[SIS_Util_Stats] as

WITH 

activeStudents (StudentID,GradeLevel) as (
	select StudentID,GradeLevel from Students where active=1
),
numStudents (cnt) as (
	select count(*) from activeStudents
),
gradeStudents (GradeLevel, cnt) as (
	select GradeLevel, count(*) cnt 
	from activeStudents group by GradeLevel
),
gradeImmunizations (GradeLevel, cnt, numStudents) as (
	select s.GradeLevel, count(distinct i.StudentID) cnt, max(gs.cnt) numStudents
	from Immunizations i 
	inner join activeStudents s on i.StudentID = s.StudentID
	inner join gradeStudents gs on s.GradeLevel = gs.GradeLevel
	group by s.GradeLevel
),
activeMedicalLog (StudentID,Date,type) 
as (
	select ml.StudentID,ml.Date,ml.type from MedicalLog ml 
	inner join activeStudents s on ml.StudentID=s.StudentID
),
numActiveBilling (cnt) 
as (
	select count(distinct x.StudentID) from Receivables x 
	inner join activeStudents s on x.StudentID=s.StudentID
	where DateDiff(month, x.date, getDate()) <= 12
),
numDemographicDocs (cnt) 
as (
	select count(distinct x.StudentID) from StudentMiscFields x 
	inner join activeStudents s on x.StudentID=s.StudentID
),
numActiveIEP (cnt) 
as (
	select count(distinct x.StudentID) from IEP_Report x 
	inner join activeStudents s on x.StudentID=s.StudentID
	where DateDiff(month, x.date, getDate()) <= 12
),
numActiveDonations (cnt) 
as (
	select count(distinct x.StudentID) from Donations x 
	inner join activeStudents s on x.StudentID=s.StudentID
	where DateDiff(month, x.date, getDate()) <= 12
),
numContacts (cnt) 
as (
	select count(distinct x.StudentID) from StudentContacts x 
	inner join activeStudents s on x.StudentID=s.StudentID
),
numActiveEnrollments (cnt) 
as (
	select count(distinct es.StudentID) 
	from EnrollStudentStatusDates x 
	inner join EnrollmentStudent es on x.EnrollmentStudentID = es.EnrollmentStudentID
	where DateDiff(month, x.updatedate, getDate()) <= 12
	and x.FormStatus = 'Submitted'
),
numMedications (cnt) 
as (
	select count (distinct m.StudentID) from Medications m 
	inner join activeStudents s on m.StudentID=s.StudentID
),
numStateImmunizationReports (cnt) 
as (
	select count (distinct x.table_pk_id) from xml_records x
	inner join activeStudents s on x.table_pk_id=s.StudentID
	where x.entityName='ImmunStatus'
),
medicalExams (cnt, numStudents) as (
	select count(distinct x.StudentID) cnt, (select cnt from numStudents) numStudents
	from activeMedicalLog x
	where DateDiff(month, x.date, getDate()) < 12
	and type not like '%screening%'
),
gradeMedicalScreenings (GradeLevel, cnt, numStudents) as (
	select s.GradeLevel, count(distinct x.StudentID) cnt, max(gs.cnt) numStudents
	from activeMedicalLog x 
	inner join activeStudents s on x.StudentID = s.StudentID
	inner join gradeStudents gs on s.GradeLevel = gs.GradeLevel
	where DateDiff(month, x.date, getDate()) < 14
	and type like '%screening%'
	group by s.GradeLevel
)

SELECT

-- Maximum percentage of students within any grade level 
-- that have at least one immunization record.  (Since immunization
-- requirement checkpoints are monitored at specific grades levels.)
-- This does not take into account how recently immunizations records were logged.
-- This is not the same as State law requirements that require records for ALL students;
-- see the Medical_StateReport for percentage compliance with that feature.
(select cast(isnull(max(100.00 * cnt / numstudents),0.0) as int)
from gradeImmunizations) as Medical_Immunizations,

-- If 5% of active students have an MEDICAL EXAM record, the exams feature is considered 100% utilized.
-- Only exam records entered within the past 12 months are considered.
(select cast(dbo.MinFloatVal(cnt*20.0/numStudents,1.0)*100 as int)
from medicalExams)
as Medical_Exams,

-- Maximum percentage of students within any grade level 
-- that has at least one medical screening record.  (Since screening
-- requirement checkpoints may be monitored at specific grades levels.)
-- Only screening records entered within the past 14 months are considered.
(select cast(isnull(max(100.00 * cnt / numstudents),0.0) as int)
from gradeMedicalScreenings) as Medical_Screenings,

-- If 5% of active students have a medication logged, this feature is considered 100% utilized.
cast((dbo.MinFloatVal((select cnt from numMedications)*20.0/((select cnt from numStudents)),1.0)*100.0) as int) as Medical_Prescriptions,

-- All students should be certified by the school as being up-to-date or exempt from state immunization requirements, 
-- this reports the percentage of active students with a state compliance record in GL.
cast(((select cnt from numStateImmunizationReports)*100.0/((select cnt from numStudents))) as int) as Medical_StateReport,

-- This is the percentage of active students with any account receivable record logged
-- within the past 12 months
cast((select cnt from numActiveBilling)*100.0 / (select cnt from numStudents)*1.0 as int) as Financial_Billing,

-- This is an approximate percentage of active and potential new students that have submitted
-- an enrollment form within the past 12 months
cast(dbo.MinFloatVal((select cnt from numActiveEnrollments)*100.0 / (select cnt from numStudents)*1.0, 100.00) as int) as Enrollme_Usage,

-- If 5% of active students have an IEP report logged, this feature is considered 100% utilized.
cast((dbo.MinFloatVal((select cnt from numActiveIEP)*20.0/((select cnt from numStudents)),1.0)*100.0) as int) as SIS_IEP,

-- This is the percentage of active student records that have associated contact records on file.
cast(dbo.MinFloatVal((select cnt from numActiveEnrollments)*100.0 / (select cnt from numStudents)*1.0, 100.00) as int) as SIS_Contacts,

-- This is the percentage of active student records that have associated demographic document records on file.
cast(dbo.MinFloatVal((select cnt from numDemographicDocs)*100.0 / (select cnt from numStudents)*1.0, 100.00) as int) as SIS_Documents,

-- If 5% of active students have a donation record, 
-- logged within the past 12 months then
-- this feature is considered 100% utilized.
cast((dbo.MinFloatVal((select cnt from numActiveDonations)*20.0/((select cnt from numStudents)),1.0)*100.0) as int) as Financial_Donations


GO
