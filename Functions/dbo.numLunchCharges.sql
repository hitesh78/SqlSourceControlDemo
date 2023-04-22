SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[numLunchCharges]
(
	@InvoicePeriodID int
)
RETURNS int
AS
--
-- Referencing function instead of subquery in vInvoicePeriods
-- sped up views and this function can be optimized further if needed
--
BEGIN
	return (select count(*) from lunchcharges where InvoicePeriodID=@InvoicePeriodID)
END



GO
