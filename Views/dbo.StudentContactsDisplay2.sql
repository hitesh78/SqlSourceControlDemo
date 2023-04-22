SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[StudentContactsDisplay2] as
select StudentID, RelationAndName, ContactID, Name, Relation, Tags, 
case when Phone_Num_Desc_2 + Phone_Num_Desc_3 = '' then '<br/>' else '' end 
	+ Phone_Num_Desc_1 
	+ case when Phone_Num_Desc_2>'' then '<br/>' else '' end + Phone_Num_Desc_2  
	+ case when Phone_Num_Desc_3>'' then '<br/>' else '' end + Phone_Num_Desc_3 as Phones,
case when Email_Addr_Desc_2 + Email_Addr_Desc_3 = '' then '<br/>' else '' end 
	+ Email_Addr_Desc_1 
	+ case when Email_Addr_Desc_2>'' then '<br/>' else '' end + Email_Addr_Desc_2  
	+ case when Email_Addr_Desc_3>'' then '<br/>' else '' end + Email_Addr_Desc_3 as Emails,
Employer, Occupation
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
		+ isnull(Email3Desc,'')) as Email_Addr_Desc_3,

		occupation, employer

	from studentcontacts 
	where isnull(RolesAndPermissions,'') not like'%(SIS Parent Contact)%'
) x
GO
