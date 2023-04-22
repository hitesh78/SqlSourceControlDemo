SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vIEP_Report] AS
SELECT i.StudentID, table_pk_id IEP_Report_ID, xml_pk_id Area_ID,
		s.xStudentID, replace(GradeLev,'&nbsp;','') GradeLev, s._Status, s.FullName,
		t.c.value('Area[1]','nvarchar(150)') Area,
		1 Line,
		t.c.value('Objective1[1]','nvarchar(MAX)') Objective,
		t.c.value('Prompt1[1]','nvarchar(50)') Prompt,
		t.c.value('Mastery1[1]','nvarchar(50)') Mastery,
		t.c.value('Comments[1]','nvarchar(MAX)') Comments
	FROM xml_records x
	CROSS APPLY xml_fields.nodes('/') as t(c)
	INNER JOIN IEP_Report i ON i.IEP_Report_ID = x.table_pk_id
	INNER JOIN vStudents s ON s.StudentID = i.StudentID
	WHERE entityName = 'IEP_Details' 
		AND t.c.value('Area[1]','nvarchar(50)')>'' 
		AND t.c.value('Objective1[1]','nvarchar(50)')>''
UNION
	select i.StudentID, table_pk_id IEP_Report_ID, xml_pk_id Area_ID,
		s.xStudentID, replace(GradeLev,'&nbsp;','') GradeLev, s._Status, s.FullName,
		t.c.value('Area[1]','nvarchar(150)') Area,
		2 Line,
		t.c.value('Objective2[1]','nvarchar(MAX)') Objective,
		t.c.value('Prompt2[1]','nvarchar(50)') Prompt,
		t.c.value('Mastery2[1]','nvarchar(50)') Mastery,
		'' Comments
	from xml_records x
	CROSS APPLY xml_fields.nodes('/') as t(c)
	INNER JOIN IEP_Report i ON i.IEP_Report_ID = x.table_pk_id
	INNER JOIN vStudents s ON s.StudentID = i.StudentID
	WHERE entityName = 'IEP_Details' 
		AND t.c.value('Area[1]','nvarchar(50)')>'' 
		AND t.c.value('Objective2[1]','nvarchar(50)')>''
UNION
	select i.StudentID, table_pk_id IEP_Report_ID, xml_pk_id Area_ID,
		s.xStudentID, replace(GradeLev,'&nbsp;','') GradeLev, s._Status, s.FullName,
		t.c.value('Area[1]','nvarchar(150)') Area,
		3 Line,
		t.c.value('Objective3[1]','nvarchar(MAX)') Objective,
		t.c.value('Prompt3[1]','nvarchar(50)') Prompt,
		t.c.value('Mastery3[1]','nvarchar(50)') Mastery,
		'' Comments
	from xml_records x
	CROSS APPLY xml_fields.nodes('/') as t(c)
	INNER JOIN IEP_Report i ON i.IEP_Report_ID = x.table_pk_id
	INNER JOIN vStudents s ON s.StudentID = i.StudentID
	WHERE entityName = 'IEP_Details' 
		AND t.c.value('Area[1]','nvarchar(50)')>'' 
		AND t.c.value('Objective3[1]','nvarchar(50)')>''
UNION
	select i.StudentID, table_pk_id IEP_Report_ID, xml_pk_id Area_ID, 
		s.xStudentID, replace(GradeLev,'&nbsp;','') GradeLev, s._Status, s.FullName,
		t.c.value('Area[1]','nvarchar(150)') Area,
		4 Line,
		t.c.value('Objective4[1]','nvarchar(MAX)') Objective,
		t.c.value('Prompt4[1]','nvarchar(50)') Prompt,
		t.c.value('Mastery4[1]','nvarchar(50)') Mastery,
		'' Comments
	from xml_records x
	CROSS APPLY xml_fields.nodes('/') as t(c)
	INNER JOIN IEP_Report i ON i.IEP_Report_ID = x.table_pk_id
	INNER JOIN vStudents s ON s.StudentID = i.StudentID
	WHERE entityName = 'IEP_Details' 
		AND t.c.value('Area[1]','nvarchar(150)')>'' 
		AND t.c.value('Objective4[1]','nvarchar(MAX)')>''
UNION
	select i.StudentID, table_pk_id IEP_Report_ID, xml_pk_id Area_ID, 
		s.xStudentID, replace(GradeLev,'&nbsp;','') GradeLev, s._Status, s.FullName,
		t.c.value('Area[1]','nvarchar(150)') Area,
		5 Line,
		t.c.value('Objective5[1]','nvarchar(MAX)') Objective,
		t.c.value('Prompt5[1]','nvarchar(50)') Prompt,
		t.c.value('Mastery5[1]','nvarchar(50)') Mastery,
		'' Comments
	from xml_records x
	CROSS APPLY xml_fields.nodes('/') as t(c)
	INNER JOIN IEP_Report i ON i.IEP_Report_ID = x.table_pk_id
	INNER JOIN vStudents s ON s.StudentID = i.StudentID
	WHERE entityName = 'IEP_Details' 
		AND t.c.value('Area[1]','nvarchar(50)')>'' 
		AND t.c.value('Objective5[1]','nvarchar(50)')>''


GO
