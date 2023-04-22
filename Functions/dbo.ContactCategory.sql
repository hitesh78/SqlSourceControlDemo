SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[ContactCategory]
(
	@Relationship nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN

	SET @Relationship = UPPER(@Relationship)
	
	IF ( CHARINDEX('PARENT',@Relationship) <> 0
			AND CHARINDEX('GODPARENT',@Relationship) = 0
			AND CHARINDEX('GRANDPARENT',@Relationship) = 0 )
		OR ( CHARINDEX('FATHER',@Relationship) <> 0
			AND CHARINDEX('GODFATHER',@Relationship) = 0
			AND CHARINDEX('GRANDFATHER',@Relationship) = 0 )
		OR ( CHARINDEX('MOTHER',@Relationship) <> 0
			AND CHARINDEX('GODMOTHER',@Relationship) = 0
			AND CHARINDEX('GRANDMOTHER',@Relationship) = 0 )				
		RETURN 'PARENT'
	
	RETURN ''
END
GO
