SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vChestXrays] AS
select x.table_pk_id as StudentID,
t.c.value('FilmDate[1]','date') as xray_film_date,
t.c.value('Impression[1]','nvarchar(16)') as xray_Impression,
t.c.value('FreeOfCommunicableTB[1]','nvarchar(10)') as xray_free_of_tb
FROM xml_records x
CROSS APPLY xml_fields.nodes('/') as t(c)
WHERE entityName = 'CHEST_XRAY' 

GO
