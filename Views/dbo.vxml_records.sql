SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[vxml_records] as 
select 
	xml_pk_id,
	table_name,
	entityName,
	table_pk_id,
	xml_fields,
	records_version,
	deprecated
from xml_records 
union all 
SELECT 
 	100000000+StudentID as xml_pk_id, -- just enough offset to make sure it doesn't collide with the base table identity values
	'vStudents' as table_name,
	'SIS-Student' as entityName,
	StudentID as table_pk_id,
	cast('<RaceCodes><![CDATA['+STUFF((SELECT '; ' + CAST(RaceID as varchar(10))
        FROM StudentRace sr1
        where sr1.StudentID = sr.StudentID
        FOR XML PATH('')) ,1,2,'')+']]></RaceCodes>' as xml) xml_fields,
	null as records_version,
	null as deprecated
from StudentRace sr
group by StudentID
GO
