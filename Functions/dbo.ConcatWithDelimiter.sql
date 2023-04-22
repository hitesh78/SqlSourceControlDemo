SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ConcatWithDelimiter](@a nvarchar(4000), @b nvarchar(4000), @delimit nvarchar(256))
RETURNS nvarchar(4000)
AS
BEGIN
 
  return(
	Select
	case
		when isnull(@a,'') > '' and isnull(@b,'') > '' then isnull(@a,'') + @delimit + isnull(@b,'')
		else isnull(@a,'') + isnull(@b,'')
	end
  )


END
GO
