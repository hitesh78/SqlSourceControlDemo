SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vPPDtests] AS
select x.table_pk_id as StudentID,
t.c.value('Type[1]','nvarchar(16)') as PPD_Type,
t.c.value('DateGiven[1]','date') as PPD_Given,
t.c.value('DateRead[1]','date') as PPD_Read,
t.c.value('Induration[1]','nvarchar(10)') as PPD_Induration,
t.c.value('Impression[1]','nvarchar(16)') as PPD_Impression
FROM xml_records x
CROSS APPLY xml_fields.nodes('/') as t(c)
WHERE entityName = 'PPD' 

GO
