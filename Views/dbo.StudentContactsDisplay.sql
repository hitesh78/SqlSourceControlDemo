SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[StudentContactsDisplay] as
select StudentID, RelationAndName, ContactID, Name, Relation, Tags, 
case when Phone_Num_Desc_2 + Phone_Num_Desc_3 = '' then '<br/>' else '' end 
	+ Phone_Num_Desc_1 
	+ case when Phone_Num_Desc_2>'' then '<br/>' else '' end + Phone_Num_Desc_2  
	+ case when Phone_Num_Desc_3>'' then '<br/>' else '' end + Phone_Num_Desc_3 as Phones,
case when Email_Addr_Desc_2 + Email_Addr_Desc_3 = '' then '<br/>' else '' end 
	+ Email_Addr_Desc_1 
	+ case when Email_Addr_Desc_2>'' then '<br/>' else '' end + Email_Addr_Desc_2  
	+ case when Email_Addr_Desc_3>'' then '<br/>' else '' end + Email_Addr_Desc_3 as Emails
from (
select StudentID,ContactID,
FullName as Name,
Relationship Relation,
case when CHARINDEX('; ',RolesAndPermissions) > 0 then '' else '<br/>' end +
replace(RolesAndPermissions,'; ','<br/>') as tags,

case when DB_NAME()='1081' and Phone1Desc='(DOB)' then 
    dbo.ConcatWithDelimiter('<b>' + FullName + '</b>',
	'(born in '+Relationship+')', '<br/>') 
else
    dbo.ConcatWithDelimiter('<i>'+Relationship+':</i>',
	    '<b>' + FullName + '</b>', '<br/>') 
end	
	as RelationAndName,

rtrim(isnull(Phone1Num,'') + CASE WHEN Phone1Desc IS NULL THEN '' ELSE ' - ' END
 + isnull(Phone1Desc,'')) as Phone_Num_Desc_1,
rtrim(isnull(Phone2Num,'') + CASE WHEN Phone2Desc IS NULL THEN '' ELSE ' - ' END
 + isnull(Phone2Desc,'')) as Phone_Num_Desc_2,
rtrim(isnull(Phone3Num,'') + CASE WHEN Phone3Desc IS NULL THEN '' ELSE ' - ' END
 + isnull(Phone3Desc,'')) as Phone_Num_Desc_3,
rtrim(isnull(Email1,'') + CASE WHEN Email1Desc IS NULL THEN '' ELSE ' - ' END
 + isnull(Email1Desc,'')) as Email_Addr_Desc_1,
rtrim(isnull(Email2,'') + CASE WHEN Email2Desc IS NULL THEN '' ELSE ' - ' END
 + isnull(Email2Desc,'')) as Email_Addr_Desc_2,
rtrim(isnull(Email3,'') + CASE WHEN Email3Desc IS NULL THEN '' ELSE ' - ' END
 + isnull(Email3Desc,'')) as Email_Addr_Desc_3
from studentcontacts 
where isnull(RolesAndPermissions,'') not like'%(SIS Parent Contact)%'
--union 
--select StudentID, -StudentID as ContactID,
--isnull(Father,'') + case when isnull(Father,'')>'' AND isnull(Mother,'')>'' then '<br />' else '' end + isnull(Mother,''),
--'*Family*' as Relation,'' as Tags,
--isnull(Phone1,'') as Phone_Num_Desc_1, 
--isnull(Phone2,'') as Phone_Num_Desc_2, 
--isnull(Phone3,'') as Phone_Num_Desc_3,
--isnull(Email1,'') as Email_Addr_Desc_1,
--isnull(Email2,'') as Email_Addr_Desc_2,
--isnull(Email3,'') as Email_Addr_Desc_3
--from Students
union 
select s.StudentID, -ss.StudentID as ContactID,
ss.FullName /* Students.glName */ as Name,
'*Sibling*' as Relation,
'<br/>(' 
+ case when ss.Active=0 then ss._Status else 'Grade '+ss.GradeLevel end
+ ')' as Tags,
'&shy;<i>Sibling:</i><br/><b>'+ss.FullName /* Students.glName */ +'</b>' as RelationAndName,
'' as Phone1, '' as Phone2, '' as Phone3,
'' as Email1, '' as Email2, '' as Email2
FROM Students s 
INNER JOIN vStudents ss 
   --  Join in view: primary purpose is to gain _Status field "rule" I think
on -- Filters for siblings only - not self
	s.FamilyID = ss.FamilyID 
	AND s.StudentID<>ss.StudentID
) x
GO
