SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[MinFloatVal](@a float, @b float)
RETURNS float
AS
BEGIN
  if @a>@b
  begin
     return @b
  end
  
  return @a
END

GO
