SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_StripHTML2]
(
@text nvarchar(MAX)
)
returns nvarchar(max) as
begin
    declare @textXML xml
    declare @result nvarchar(max)
    set @textXML = REPLACE( @text, '&', '' );
    with doc(contents) as
    (
        select chunks.chunk.query('.') from @textXML.nodes('/') as chunks(chunk)
    )
    select @result = contents.value('.', 'nvarchar(max)') from doc
    return @result
end
GO
