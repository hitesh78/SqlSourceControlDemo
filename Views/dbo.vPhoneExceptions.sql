SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vPhoneExceptions] as
with vphones as (
	select 
		ContactID, 
		case when Phone is not null and LEN(phone)=10
		then '(' + SUBSTRING(Phone,1,3) +') '+ SUBSTRING(Phone,4,3) +'-'+ SUBSTRING(Phone,7,4)
		else rtrim(Phone) + ' *' end as Phone, 
		Extension,
		Type,
		isWorkPhone, isDefaultAreaCodeApplied, isNumberOfDigitsValid, 
		OptIn -- Wrike 145242054
	from vPhoneNumbersWithOptOuts -- Wrike 145242054
	where ContactID is not null
),
xSettings as (
	select 
		isnull(Comm2DefaultAreaCode,0) as Comm2DefaultAreaCode,
		isnull(AdultSchool,0) as AdultSchool 
	from settings
),
vcontacts as ( 
	select 
		sc.ContactID,
		s.StudentID,
		s.xStudentID,
		sc.StudentFullName StudentName, 
		case when sc.Relationship='Father' 
			then s.Phone1 else '' end + 
		case when sc.Relationship='Mother' 
			then s.Phone2 else '' end + 
		case when sc.Relationship='Father 2' 
			then s.Family2Phone1 else '' end + 
		case when sc.Relationship='Mother 2' 
			then s.Family2Phone2 else '' end		
		as SIS_Phone,
		sc.FullName ParentName, sc.Relationship,
		sc.Phone1 + '<br/>' + isnull(p1.Phone,'')+isnull(' | '+p1.Extension,'') as Phone1HTML,
		sc.Phone1, c.Phone1Desc, p1.phone newPhone1, p1.Extension newExtension1,
		sc.Phone2 + '<br/>' + isnull(p2.Phone,'')+isnull(' | '+p2.Extension,'') as Phone2HTML,
		sc.Phone2, c.Phone2Desc, p2.phone newPhone2, p2.Extension newExtension2,
		sc.Phone3 + '<br/>' + isnull(p3.Phone,'')+isnull(' | '+p3.Extension,'') as Phone3HTML,
		sc.Phone3, c.Phone3Desc, p3.phone newPhone3, p3.Extension newExtension3,
		case when p1.isDefaultAreaCodeApplied=1 or p2.isDefaultAreaCodeApplied=1 or p3.isDefaultAreaCodeApplied=1
			then 'Yes' else 'No' end as isDefaultAreaCodeApplied,
		case when p1.isNumberOfDigitsValid=0 
				or p2.isNumberOfDigitsValid=0 
				or p3.isNumberOfDigitsValid=0
				or (rtrim(isnull(case when sc.Relationship='Father' then s.Phone1 else s.Phone2 end,''))>'' 
					and sc.Phone1='') 
				or (sc.Phone1>'' and p1.Phone is null)
				or (sc.Phone2>'' and p2.Phone is null)
				or (sc.Phone3>'' and p3.Phone is null)
				then 'No' else 'Yes' end as isNumberOfDigitsValid,
		s._status Status
	from vStudentContacts_orig sc
	cross join xSettings
	inner join vstudents_orig s 
		on sc.StudentID = s.StudentID
	inner join StudentContacts c
		on sc.ContactID = c.contactid
	left join vphones p1 
		on sc.ContactID = p1.ContactID and p1.Type='Phone 1'
	left join vphones p2
		on sc.ContactID = p2.ContactID and p2.Type='Phone 2'
	left join vphones p3
		on sc.ContactID = p3.ContactID and p3.Type='Phone 3'
	where sc.RolesAndPermissions = '(SIS Parent Contact)' 
		and xSettings.AdultSchool=0
		and (p1.OptIn is null or p1.OptIn=1) -- Wrike 145242054
		and (p2.OptIn is null or p2.OptIn=1) -- Wrike 145242054
		and (p3.OptIn is null or p3.OptIn=1) -- Wrike 145242054
)
select * from vcontacts
where SIS_Phone is not null
GO
