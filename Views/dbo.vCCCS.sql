SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCCCS] as
select ID, Subject, CCSSID, Category, SubCategory, StateStandard, GradeLevel, CategoryID, ItemID, SubItemID, TempID
from LKG.dbo.CCSS
GO
