SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[MinDate](@a date, @b date)
RETURNS date
AS
BEGIN
  if @a<@b
  begin
     return @a
  end
  
  return @b
END


GO
