SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/26/2020
-- Description:	Given a full state name or state Abbreviation it will return 
--				the state Abbreviation. This us used for the two calculated columns in 
--				the Students table - StateAbbr and State2Abbr
-- =============================================
Create FUNCTION [dbo].[getStateAbbr](@StateString nvarchar(100))

RETURNS nvarchar(5)
AS
BEGIN
	-- Return the result of the function
	RETURN 
	(
		Select Abbr 
		From [LKG].dbo.usaStates
		Where
		ltrim(rtrim(@StateString)) = [Name]
		or
		ltrim(rtrim(@StateString)) = [Abbr]
	)

END
GO
