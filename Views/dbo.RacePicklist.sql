SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[RacePicklist] as
-- framework requires 'ID' and 'Title' if views are used in selects
select 
	RaceID as ID, Name as Title
from Race 
where Deprecated=0
GO
