SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vRace] as
select RaceID,Name,Description,FederalRaceMapping,Deprecated,
case when deprecated=1 then 'Hide' else 'Show' end as HideShow
from Race 
union
select -1,'','','',0,''
GO
