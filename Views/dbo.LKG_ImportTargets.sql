SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[LKG_ImportTargets] as
select replace(SourceFieldName,' - '+SourceTableName,'') ShortSourceFieldName,* from LKG_TEST.dbo.ImportTargets

GO
