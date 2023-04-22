SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- =============================================
-- Author:		Don Puls
-- Create date: 3/11/2016
-- Description:	returns all the dates within a specified Start and End Date   
-- =============================================
CREATE FUNCTION [dbo].[GetDates]
(
	@StartDate date,
	@EndDate date
)
RETURNS TABLE AS
 RETURN
	SELECT  TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
			theDate = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @StartDate)
	FROM    sys.all_objects a
			CROSS JOIN sys.all_objects b;

GO
