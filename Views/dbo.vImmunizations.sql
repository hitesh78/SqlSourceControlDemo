SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vImmunizations] AS
SELECT s.xStudentID, s.GradeLev, s._Status, s.FullName,
s.FullName + ' (' +cast(s.xStudentID as nvarchar(12))+ ')' as FullNameAndID,
s.CampusAndNationality, s.Campus, s.Nationality,
dbo.GLformatdate(s.BirthDate) BirthDate,
ImmuneCertDate,ImmuneStatus,
dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose1date),
  dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose2date),
    dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose3date),
      dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose4date),
	    dbo.GLformatdate(i.dose5date),'<br/>'),'<br/>'),'<br/>'),'<br/>')
		+'<br/>' as doses,
case when i.dose1date is not null then 1 else 0 end
	+ case when i.dose2date is not null then 1 else 0 end
	+ case when i.dose3date is not null then 1 else 0 end
	+ case when i.dose4date is not null then 1 else 0 end
	+ case when i.dose5date is not null then 1 else 0 end as num_doses,
dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose6date),
  dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose7date),
    dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose8date),
      dbo.ConcatWithDelimiter(dbo.GLformatdate(i.dose9date),
	    dbo.GLformatdate(i.dose10date),'<br/>'),'<br/>'),'<br/>'),'<br/>') 
		+'<br/>' as booster_doses,
case when i.dose6date is not null then 1 else 0 end
	+ case when i.dose7date is not null then 1 else 0 end
	+ case when i.dose8date is not null then 1 else 0 end
	+ case when i.dose9date is not null then 1 else 0 end
	+ case when i.dose10date is not null then 1 else 0 end as num_booster_doses,
i.*
FROM
(select x.table_pk_id as StudentID,
t.c.value('ImmuneCertDate[1]','date') as ImmuneCertDate,
t.c.value('ImmuneStatus[1]','nvarchar(50)') as ImmuneStatus
FROM xml_records x
CROSS APPLY xml_fields.nodes('/') as t(c)
WHERE entityName = 'ImmunStatus' ) z
right JOIN StudentRoster s on s.StudentID = z.StudentID
inner JOIN Immunizations i on s.StudentID = i.StudentID
WHERE s.StudentID>-1


GO
