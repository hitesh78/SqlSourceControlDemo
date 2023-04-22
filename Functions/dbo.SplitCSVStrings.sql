SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[SplitCSVStrings]
(
	@StringList nvarchar(max)
)
RETURNS 
@ParsedList table
(
	TheString nvarchar(1000)
)
AS
BEGIN
	DECLARE @AString nvarchar(1000), @Pos int

	SET @StringList = LTRIM(RTRIM(@StringList))+ ','
	SET @Pos = CHARINDEX(',', @StringList, 1)

	IF REPLACE(@StringList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @AString = LTRIM(RTRIM(LEFT(@StringList, @Pos - 1)))
			IF @AString <> ''
			BEGIN
				INSERT INTO @ParsedList (TheString) 
				VALUES (@AString) --Use Appropriate conversion
			END
			SET @StringList = RIGHT(@StringList, LEN(@StringList) - @Pos)
			SET @Pos = CHARINDEX(',', @StringList, 1)

		END
	END	
	RETURN
END
GO
