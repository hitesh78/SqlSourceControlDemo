SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--The following is a general purpose UDF to split comma separated lists into individual items.
--There is an additional input parameter for the delimiter, so that you can use any delimiter you like.
CREATE FUNCTION [dbo].[SplitCSVStringsDelimiter]
(
	@StringList nvarchar(1000),
	@Delimiter nvarchar(50)
)
RETURNS 
@ParsedList table
(
	TheString nvarchar(100)
)
AS
BEGIN
	DECLARE @AString nvarchar(100), @Pos int, @DelimiterLength int = len(@Delimiter)

	SET @StringList = LTRIM(RTRIM(@StringList))+ @Delimiter
	SET @Pos = CHARINDEX(@Delimiter, @StringList, 1)

	IF REPLACE(@StringList, @Delimiter, '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @AString = LTRIM(RTRIM(LEFT(@StringList, @Pos - 1)))
			IF @AString <> ''
			BEGIN
				INSERT INTO @ParsedList (TheString) 
				VALUES (@AString) 
			END
			SET @StringList = RIGHT(@StringList, LEN(@StringList) - @Pos - @DelimiterLength + 1)
			SET @Pos = CHARINDEX(@Delimiter, @StringList, 1)
		END
	END	
	RETURN
END



GO
