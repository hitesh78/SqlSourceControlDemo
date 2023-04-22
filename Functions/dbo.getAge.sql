SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 5/1/2013
-- Description:	Returns Age from a given date
-- =============================================
CREATE FUNCTION [dbo].[getAge]
(
	@BirthDate date
)
RETURNS int
AS
BEGIN

Declare @theAge int

if @BirthDate = '01/01/1900'
begin
	set @theAge = null;
end
else
begin
	set @theAge =  CONVERT(int, datediff(SECOND, @BirthDate,
		/* wrong: dbo.GLgetdate() */ getdate()) / (365.23076923074 * 24 * 60 * 60))
end

return @theAge

END


GO
