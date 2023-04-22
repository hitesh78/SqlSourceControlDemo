SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LKG_ImportStrucTablesPicklist] as
select distinct 
TableName as ID, -- to support FK picklist
TableName as Title -- to support FK picklist
from LKG.dbo.ImportStructures

GO
