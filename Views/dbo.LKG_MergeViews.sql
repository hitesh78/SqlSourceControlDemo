SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LKG_MergeViews] as
select 
MergeViewID as ID, -- to support FK picklist
ViewTitle as Title, -- to support FK picklist
* from LKG.dbo.MergeViews

GO
