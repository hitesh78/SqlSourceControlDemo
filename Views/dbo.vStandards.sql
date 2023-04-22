SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vStandards]
as
select
 s.ID,
 s.CCSSID,
 case when isnull(s.GradeLevel,N'')=N'' 
	then isnull(ccss.GradeLevel,s.GradeLevel) 
	else s.GradeLevel end COLLATE DATABASE_DEFAULT as GradeLevel,
 s.CategoryID,
 s.ItemID,
 s.SubItemID,

 isnull(ccss.Subject,s.Subject) COLLATE DATABASE_DEFAULT as Subject,
 isnull(ccss.Category,s.Category) COLLATE DATABASE_DEFAULT as Category,
 isnull(ccss.SubCategory,s.SubCategory) COLLATE DATABASE_DEFAULT as SubCategory,
 isnull(ccss.StandardText,s.StandardText) COLLATE DATABASE_DEFAULT as StandardText

from Standards s
left join LKG.dbo.Standards ccss
on ccss.ID = s.ID

GO
