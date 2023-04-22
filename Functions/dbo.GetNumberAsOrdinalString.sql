SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[GetNumberAsOrdinalString]
(
    @num int
)
RETURNS nvarchar(max)
AS
BEGIN

    DECLARE @Suffix nvarchar(2);
    DECLARE @Ones int;  
    DECLARE @Tens int;

    SET @Ones = @num % 10;
    SET @Tens = FLOOR(@num / 10) % 10;

    IF @Tens = 1
    BEGIN
        SET @Suffix = 'th';
    END
    ELSE
    BEGIN

    SET @Suffix = 
        CASE @Ones
            WHEN 1 THEN 'st'
            WHEN 2 THEN 'nd'
            WHEN 3 THEN 'rd'
            ELSE 'th'
        END
    END

    RETURN CONVERT(nvarchar(max), @num) + @Suffix;
END

GO
