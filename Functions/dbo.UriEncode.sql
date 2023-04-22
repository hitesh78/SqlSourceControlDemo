SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[UriEncode]
(
    @UnEncoded as nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN
  DECLARE @Encoded as nvarchar(MAX)

  SELECT @Encoded = 
      Replace(@UnEncoded,'&','%26')

  RETURN @Encoded
END
GO
