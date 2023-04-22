SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vBlockSchedule]
as
select 
	b.BlockSchedID,
	b.SessionID,
	b.Title,
	b.Period,
	b.StartTime,
	b.EndTime,
	b.Sunday,b.Monday,b.Tuesday,b.Wednesday,b.Thursday,b.Friday,b.Saturday,
	s.title as SessionTitle,
	s._title as _SessionTitle
from BlockSchedule b
INNER JOIN vSession s on s.SessionID = b.SessionID
union all
select 
	-1 as BlockSchedID, 
	(Select SessionID from vSession where _Title like '%*') as SessionID,
	'' as Title, 
	null as Period,
	null as StartTime,
	null as EndTime,
	0 Sunday,0 Monday,0 Tuesday,0 Wednesday,0 Thursday,0 Friday,0 Saturday,
	(Select Title from vSession where _Title like '%*') as  SessionTitle,
	(Select _Title from vSession where _Title like '%*') as  _SessionTitle	


GO
