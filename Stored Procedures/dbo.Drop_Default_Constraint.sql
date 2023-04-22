SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Drop_Default_Constraint]
(
 @table_name sysname,
 @column_name sysname
)
AS

--declare @table_name sysname, @column_name sysname,
--select
-- @table_name = N'SampleConstraintsSQLTable',
-- @column_name = N'IsDefaultConstraintColumn'

declare @default_constraint_name sysname, @sql nvarchar(max)

if exists (
 select *
 from sys.default_constraints
 where
  parent_object_id = OBJECT_ID(@table_name)
  AND type = 'D'
  AND parent_column_id = (
   select column_id
   from sys.columns
   where
   object_id = OBJECT_ID(@table_name)
   and name = @column_name
  )
)
begin

 select @default_constraint_name = name
 from sys.default_constraints
  where
   parent_object_id = OBJECT_ID(@table_name)
   AND type = 'D'
   AND parent_column_id = (
    select column_id
    from sys.columns
    where
    object_id = OBJECT_ID(@table_name)
    and name = @column_name
   )

 SET @sql = N'ALTER TABLE ' + @table_name + ' DROP Constraint ' + @default_constraint_name

 exec sp_executesql @sql

end

GO
