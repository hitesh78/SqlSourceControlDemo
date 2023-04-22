SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vMergeForms] as
/*
OLD view:
select ViewTitle,mf.*
from MergeForms mf
inner join LKG_MergeViews mv
on mf.MergeViewID = mv.MergeViewID

NEW view adds list of available merge fields:
*/
select ViewTitle,mf.*,
stuff((select char(10) + '{' + CAST(ff.fieldName as nvarchar(30)) + '}'
     from LKG.dbo.glFormFields ff where 
     (select glFormName from LKG.dbo.glForms where glFormId = ff.glFormId) = mv.glFormName     
     for xml path('')),1,1,'') MergeFields 
from mergeforms mf
inner join LKG_MergeViews mv on mf.MergeViewID = mv.MergeViewID


GO
