SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[tableLastUpdated]
--
-- Given the name of a table, this function returns
-- the time it was last updated as long as it has
-- been updated since the last SQL server restart,
-- otherwise the time the server was last started
-- is returned.
(
	@tableName nvarchar(50)
)
RETURNS datetime
AS
BEGIN

	RETURN ISNULL(
		(SELECT  [last_user_update] 
				FROM    sys.dm_db_index_usage_stats
		WHERE   [index_id] = 1 
				and OBJECT_NAME([object_id], [database_id])=@tableName
				and DB_NAME(database_id) = DB_NAME())
	,(SELECT sqlserver_start_time FROM sys.dm_os_sys_info))
END

GO
