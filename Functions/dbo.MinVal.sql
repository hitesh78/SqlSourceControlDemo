SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
drop function MinVal;
drop function splitSISphones_markNumberOrDelimiterStart;
drop function splitSISphones_parse_next;
drop function splitSISphones;
--drop function splitSISphonesALL;
go
*/

CREATE FUNCTION [dbo].[MinVal](@a bigint, @b bigint)
RETURNS bigint
AS
BEGIN
  if @a<@b
  begin
     return @a
  end
  
  return @b
END

GO
