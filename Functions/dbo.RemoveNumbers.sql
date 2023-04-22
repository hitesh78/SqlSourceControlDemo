SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 CREATE FUNCTION [dbo].[RemoveNumbers](@Input nvarchar(1000))
 RETURNS nVARCHAR(1000)
 BEGIN
 DECLARE @pos INT
 SET @Pos = PATINDEX('%[0-9]%',@Input)
 WHILE @Pos > 0
 BEGIN
 SET @Input = STUFF(@Input,@pos,1,'')
 SET @Pos = PATINDEX('%[0-9]%',@Input)
 END
 RETURN @Input
 END

GO
