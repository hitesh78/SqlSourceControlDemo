SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[unPivotTable] (@tableName nvarchar(100),@whereClause nvarchar(1000),@identityFieldName nvarchar(100))
as
DECLARE @colsUnpivot AS nvarchar(MAX),
    @query  AS nvarchar(MAX),
    @colsPivot as  nvarchar(MAX),
    @tableColumns as nvarchar(MAX)
--    @tableName as nvarchar(100) = 'EnrollmentStudent',
--    @identityFieldName as nvarchar(100) = 'StudentID'

select @colsUnpivot = stuff((select ','+quotename(C.name)
         from sys.columns as C
         where C.object_id = object_id(@tableName) 
         for xml path('')), 1, 1, '')

set @tableColumns = REPLACE(@colsUnpivot,'],[','] nvarchar(max) null,[') + ' nvarchar(max) null';

set @query = 
'use ['+DB_NAME()+']; declare @tempTable TABLE(' + @tableColumns + ');
insert into @tempTable ('+@colsUnpivot+')
select '+@colsUnpivot+' from '+@tableName+' '+@whereClause+';

SELECT *
FROM
(
  select '+@identityFieldName + ' id, col, value
  from @tempTable
  unpivot
  (
    value for col in ('+ replace(@colsUnpivot,'['+@identityFieldName+'],','') +')
  ) u
)x1 

'

exec(@query)

--select @query




/*
set @query = 
'
SELECT *
FROM
(
  select StudentID, col, value
  from Students
  unpivot
  (
    value for col in ('+ @colsUnpivot+')
  ) u
)x1 
'

exec @query
*/



GO
