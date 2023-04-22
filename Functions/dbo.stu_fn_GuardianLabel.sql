SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   Function [dbo].[stu_fn_GuardianLabel](@RelationShip varchar(100))
RETURNS varchar(50)
AS
/*

	Author: Hitesh Choudhary
	Date: 2023.03.31
	Usage: Used to Generalize Guardian Labels based on Relationships; only applies to Family/Family2
	Example: select dbo.stu_fn_GuardianLabel('Father 2')
	________________________________________________________________
	Revision History:
	2023.03.31	HC	Initial Implementation

*/
BEGIN

	Declare @GuardianLabel varchar(50) = ''
	
	IF @RelationShip = 'Father' SET @GuardianLabel = 'Guardian 1'
	ELSE IF @RelationShip = 'Mother' SET @GuardianLabel = 'Guardian 2'
	ELSE IF @RelationShip like 'Father 2' SET @GuardianLabel = 'Guardian 3'
	ELSE IF @RelationShip = 'Mother 2' SET @GuardianLabel = 'Guardian 4'
	ELSE SET @GuardianLabel = 'Guardian 5'


	RETURN @GuardianLabel

END
GO
