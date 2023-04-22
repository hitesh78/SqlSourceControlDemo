SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vChestXraysLatest] as
select * from vChestXrays
where CONVERT(nvarchar(20),xray_film_date,21)+';'+CAST(studentID as nvarchar(20)) in
(Select MAX(CONVERT(nvarchar(20),xray_film_date,21)+';'+CAST(studentID as nvarchar(20))) x
from vChestXrays group by StudentID)
GO
