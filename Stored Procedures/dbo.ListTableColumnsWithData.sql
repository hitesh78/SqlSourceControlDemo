SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/6/2021
-- Description:	For a given table it will return all columns with data. Columns with spaces or null values will be excluted.
-- =============================================
CREATE PROCEDURE [dbo].[ListTableColumnsWithData]
	@TableName nvarchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SQLString nvarchar(max)
	SELECT @SQLString = Stuff(
	  (SELECT N' UNION ALL ' + 
			'SELECT COUNT( case when rtrim(ltrim([' + COLUMN_NAME + '])) = '''' then null else rtrim(ltrim([' + COLUMN_NAME + '])) end) AS UniqueValues, ''' + COLUMN_NAME + ''' AS ColumnName FROM [' + TABLE_NAME + ']'
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = N'' + @TableName + ''
			  FOR XML PATH(''),TYPE)
	  .value('text()[1]','nvarchar(max)'),1,11,N'')

	Declare @SQLString2 nvarchar(max) = 'Select ColumnName From (' + @SQLString + ') x Where UniqueValues > 0';

	EXEC(@SQLString2)

END
GO
