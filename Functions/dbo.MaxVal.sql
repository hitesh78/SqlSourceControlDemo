SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[MaxVal](@a bigint, @b bigint)
RETURNS bigint
AS
BEGIN
  if @a>@b
  begin
     return @a
  end
  
  return @b
END

GO
