SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[showASCII](@string VARCHAR(100))
returns varchar(100)
AS
BEGIN
   DECLARE @length smallint = LEN(@string)
   DECLARE @position smallint = 0
   DECLARE @codes varchar(max) = ''
 
   WHILE @length >= @position
   BEGIN
      SELECT @codes = @codes + CONCAT(ASCII(SUBSTRING(@string,@position,1)),',')
      SELECT @position = @position + 1
   END
 
   SELECT @codes = SUBSTRING(@codes,2,LEN(@codes)-2)
   RETURN @codes
END
GO
