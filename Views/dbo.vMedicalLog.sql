SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vMedicalLog]
AS
SELECT     
	dbo.MedicalLog.MedicalLogID, 
	dbo.MedicalLog.StudentID, 
	dbo.MedicalLog.Date, 
	dbo.MedicalLog.Type, 
	dbo.MedicalLog.Notes, 
	dbo.MedicalLog.Time, 
    dbo.MedicalLog.Duration, 
	dbo.MedicalLog.Completed,
    (SELECT     TOP (1) TermTitle
		FROM  (
			SELECT TermTitle, StartDate, EndDate, 
				CASE WHEN Status = 1 THEN 'Active Term' ELSE '' END AS TermStatus
				FROM dbo.Terms WHERE (ExamTerm = 0) 
					AND (TermID NOT IN (SELECT ParentTermID	FROM dbo.Terms AS Terms_1)) 
					AND (TermTitle <> 'InitTerm')) AS y
					WHERE (dbo.MedicalLog.Date >= StartDate) 
						AND (dbo.MedicalLog.Date <= EndDate)) 
		AS TermTitle, 
	s.FullName AS StudentName, 
    '&nbsp;' + 
	CASE 
		WHEN MedicalLog.GradeLevel = 'K' THEN ' &nbsp;&nbsp;' 
		WHEN MedicalLog.GradeLevel = 'PK' OR MedicalLog.GradeLevel = 'PS' 
			THEN '  &nbsp;' 
			ELSE replicate('&nbsp;', 4 - LEN(RTRIM(MedicalLog.GradeLevel))) END 
				+ dbo.MedicalLog.GradeLevel 
		AS GradeLev, 
	dbo.MedicalLog.GradeLevel, 
	dbo.MedicalLog.staff, 
	dbo.MedicalLog.Result, 
	dbo.MedicalLog.FollowupDate, 
	dbo.MedicalLog.FamilyNotifiedDate, 
	dbo.MedicalLog.PhysicianReferralDate, 
	dbo.MedicalLog.PhysicianReportDate, 
	dbo.MedicalLog.ClosedDate,
	s._Status Status,
	xx.Office_Visit_Reasons,
	xx.Office_Visit_Reasons_Notes,
	xx.Office_Visit_Findings,
	xx.Office_Visit_Findings_Notes,
	xx.Office_Visit_Treatments,
	xx.Office_Visit_Treatments_Notes,
	xx.Office_Visit_Referrals,
	xx.Office_Visit_Referrals_Notes
FROM dbo.vStudents s 
INNER JOIN dbo.MedicalLog 
ON s.StudentID = dbo.MedicalLog.StudentID
INNER JOIN (
	SELECT table_pk_id as MedicalLogID,  
		t.c.value('reasons[1]','nvarchar(500)') Office_Visit_Reasons,
		t.c.value('reasonsNotes[1]','nvarchar(4000)') Office_Visit_Reasons_Notes,
		t.c.value('findings[1]','nvarchar(500)') Office_Visit_Findings,
		t.c.value('findingsNotes[1]','nvarchar(4000)') Office_Visit_Findings_Notes,
		t.c.value('treatments[1]','nvarchar(500)') Office_Visit_Treatments,
		t.c.value('treatmentsNotes[1]','nvarchar(4000)') Office_Visit_Treatments_Notes,
		t.c.value('referrals[1]','nvarchar(500)') Office_Visit_Referrals,
		t.c.value('referralsNotes[1]','nvarchar(4000)') Office_Visit_Referrals_Notes
		FROM xml_records x
	CROSS APPLY xml_fields.nodes('/') as t(c)
	WHERE entityName = 'Medical_Record') xx
ON xx.MedicalLogID = MedicalLog.MedicalLogID
GO
