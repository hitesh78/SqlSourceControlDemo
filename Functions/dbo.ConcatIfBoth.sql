SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [dbo].[ConcatIfBoth](@a nvarchar(MAX), @b nvarchar(MAX))
RETURNS nvarchar(MAX)
AS
BEGIN
  set @a = rtrim(isnull(@a,''));
  set @b = rtrim(isnull(@b,''));
  if @a>'' and @b>''
  begin
	set @a = @a + @b;
  end
  else
  begin
	set @a = '';
  end
  
  return @a
END



GO
