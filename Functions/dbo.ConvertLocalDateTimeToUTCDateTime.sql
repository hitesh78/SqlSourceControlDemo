SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 05/08/2020
-- Description:	Takes a given school's local datetime and converts it to UTC datetime
-- =============================================
CREATE FUNCTION [dbo].[ConvertLocalDateTimeToUTCDateTime]
(
	@LocalDateTimeToConvert datetime
)
RETURNS datetime
AS
BEGIN
	RETURN dateadd(n, datediff(n, dbo.GLgetdatetime(), GETUTCDATE()), @LocalDateTimeToConvert)
END
GO
