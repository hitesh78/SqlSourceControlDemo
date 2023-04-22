SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LKG_ImportStructures] as
select 
FieldName as ID, -- to support FK picklist
FieldName + ' - ' + TableName as Title, -- to support FK picklist
* from LKG.dbo.ImportStructures

GO
