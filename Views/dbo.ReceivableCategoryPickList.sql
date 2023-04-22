SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[ReceivableCategoryPickList]
as
select 
	ReceivableCategory + ' - ' + SessionTitle Title,
	max(ReceivableCategory) ID
from vtransactiontypes
where ReceivableCategory > '' and inUseLock='Yes'
group by ReceivableCategory + ' - ' + SessionTitle

GO
