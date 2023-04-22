SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vImmunStatus] AS
SELECT s.StudentID, s.xStudentID, s.GradeLev, s._Status, s.FullName,
s.FullName + ' (' +cast(s.xStudentID as nvarchar(12))+ ')' as FullNameAndID,
s.CampusAndNationality, s.Campus, s.Nationality,
Next_dose_due,ImmuneCertSignature,ImmuneCertDate,ImmuneRec_State,
ImmuneRec_OutOfState,ImmuneRec_Other,ImmuneOtherRecord_Desc,ImmuneStatus,ImmuneGrade7Status,
(SELECT stuff((SELECT  '<br/>' + isnull(Immunization,'')
	FROM	( Select Immunization from Immunizations i where StudentID = s.StudentID) 
	xx FOR XML PATH(''), TYPE, 
	ROOT ).value('root[1]', 'nvarchar(max)'), 1, 5, '')) as Immunizations
FROM
(select x.table_pk_id as StudentID,
	(SELECT MIN(next_dose_due) FROM Immunizations i WHERE i.StudentID = x.table_pk_id) Next_dose_due,
t.c.value('ImmuneCertSignature[1]','nvarchar(50)') as ImmuneCertSignature,
t.c.value('ImmuneCertDate[1]','date') as ImmuneCertDate,
t.c.value('ImmuneRec_State[1]','bit') as ImmuneRec_State,
t.c.value('ImmuneRec_OutOfState[1]','bit') as ImmuneRec_OutOfState,
t.c.value('ImmuneRec_Other[1]','bit') as ImmuneRec_Other,
t.c.value('ImmuneOtherRecord_Desc[1]','nvarchar(50)') as ImmuneOtherRecord_Desc,
t.c.value('ImmuneStatus[1]','nvarchar(50)') as ImmuneStatus,
t.c.value('ImmuneGrade7Status[1]','nvarchar(50)') as ImmuneGrade7Status               
FROM xml_records x
CROSS APPLY xml_fields.nodes('/') as t(c)
WHERE entityName = 'ImmunStatus' ) z
right JOIN StudentRoster s on s.StudentID = z.StudentID
WHERE s.StudentID>-1


GO
