SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vDiscipline]
AS
SELECT DisciplineID, Discipline.StudentID, Discipline.GradeLevel, 
replace(Discipline.IncidentCodes, '; ', '<br/>') IncidentCodesHTML, 
Discipline.IncidentCodes, 
Discipline.IncidentDesc, 
Discipline.IncidentHist, 
Discipline.Location, 
'&nbsp;' + 
	CASE 
		WHEN Discipline.GradeLevel = 'K' 
			THEN ' &nbsp;&nbsp;' 
		WHEN Discipline.GradeLevel = 'PK' OR Discipline.GradeLevel = 'PS' 
			THEN '  &nbsp;' 
		ELSE replicate('&nbsp;', 4 - LEN(RTRIM(Discipline.GradeLevel))) END 
	+ dbo.Discipline.GradeLevel AS GradeLev,
(SELECT TOP 1 TermTitle
	FROM (
		SELECT TermTitle, StartDate, EndDate, 
			CASE WHEN Status = 1 THEN 'Active Term' 
			ELSE '' END AS TermStatus
			FROM Terms
			WHERE ExamTerm = 0 
				AND TermID NOT IN (
					SELECT ParentTermID FROM Terms) 
				AND TermTitle <> 'InitTerm') y
	WHERE DateOfIncident >= y.StartDate AND DateOfIncident <= y.EndDate) 
	AS TermTitle, 
s._status Status,
s.FullName AS StudentName, 
Lname, Mname, Fname, 
DateOfIncident, DateReportClosed, 
ReferredBy, ReferredTo, 
(stuff(
	(SELECT '<br />' + ActionCode
		FROM (SELECT t.c.value('Type[1]', 'nvarchar(50)') AS ActionCode
			FROM xml_records CROSS APPLY xml_fields.nodes('/') AS t (c)
			WHERE entityName = 'DisciplineActionTaken' 
				AND xml_records.table_pk_id = Discipline.DisciplineID) x 
		FOR XML PATH(''), TYPE, ROOT).value('root[1]', 'nvarchar(max)'), 1, 6, '')) 
	AS ActionCodes,
	s.xStudentID
FROM discipline 
INNER JOIN vStudents s
ON s.studentid = discipline.studentid
GO
