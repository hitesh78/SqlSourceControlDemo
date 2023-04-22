SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vSelectLists] as
select * from LKG.dbo.SelectLists where SystemList=0


GO
