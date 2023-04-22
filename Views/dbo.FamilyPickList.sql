SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[FamilyPickList]
as
--select top 100 percent FamilyID,Title from
--(
select FamilyID as ID, 
max(replace(dbo.ConcatWithDelimiter(FamilyID,dbo.ConcatWithDelimiter(Father,Mother,' / '),' - '),'&',' ') + ' ('+Lname+')' ) as Title
--,FamilyID as ord 
from students where FamilyID is not null
group by FamilyID
--union
--select isnull((select MAX(isnull(FamilyID,0)) from Students),0) + 1 as ID,
--' ' + cast( isnull((select MAX(isnull(FamilyID,0)) from Students),0) + 1 as nvarchar(10)) + ' - (Next Family #)' as Title
--,-1 as ord
--) x
--order by ord




GO
