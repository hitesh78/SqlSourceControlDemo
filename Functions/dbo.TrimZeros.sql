SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/28/2012
-- Description:	Removes trailing blanks from a number, returns it as a string
--				Support numbers up to tow decimals
-- =============================================
CREATE FUNCTION [dbo].[TrimZeros]
(
@Number decimal(8,2)
)
RETURNS nvarchar(10)
AS
BEGIN
	return
	case
		when @Number % 1 = 0 then convert(nvarchar(10),convert(int,@Number))
		when @Number % .1 = 0 then convert(nvarchar(10),convert(decimal(6,1), @Number))
		else convert(nvarchar(10),@Number)
	end

END

GO
