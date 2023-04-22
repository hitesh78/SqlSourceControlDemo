SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Matt Ford
-- Create date: 6/25/2018
-- Description:	Translate items in delimited lists
-- =============================================
CREATE FUNCTION [dbo].[TranslateDelimitedList]
(
	@StringList nvarchar(1000)
)
RETURNS nvarchar(1000)
AS
BEGIN
	-- Declare the return variable here
	declare @Delimiter nvarchar(50) = ''
	declare @Output nvarchar(1000) = ''

	IF @StringList like '%<br/>%'
		SET @Delimiter = '<br/>'
	IF @StringList like '%;%'
		SET @Delimiter = ';'

	DECLARE @AString nvarchar(100), @Pos int, @DelimiterLength int = len(@Delimiter)

	SET @StringList = LTRIM(RTRIM(@StringList))+ @Delimiter
	SET @Pos = CHARINDEX(@Delimiter, @StringList, 1)

	IF @Delimiter = '' and @Stringlist <> ''
		SET @Output = dbo.T(0,@StringList)
	ELSE
		IF REPLACE(@StringList, @Delimiter, '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @AString = LTRIM(RTRIM(LEFT(@StringList, @Pos - 1)))
				IF @AString <> ''
				BEGIN
					SET @Output = @Output + dbo.T(0,@AString) + @Delimiter 
				END
				SET @StringList = RIGHT(@StringList, LEN(@StringList) - @Pos - @DelimiterLength + 1)
				SET @Pos = CHARINDEX(@Delimiter, @StringList, 1)
			END
		END	

	-- Return the result of the function
	RETURN @Output

END
GO
