SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--The following is a general purpose UDF to split comma separated lists into individual items.
--Consider an additional input parameter for the delimiter, so that you can use any delimiter you like.
CREATE FUNCTION [dbo].[SplitCSVIntegers]
(
	@IntegerList nvarchar(MAX)
)
RETURNS 
@ParsedList table
(
	IntegerID int
)
AS
BEGIN
	DECLARE @IntegerID nvarchar(10), @Pos int

	SET @IntegerList = LTRIM(RTRIM(@IntegerList))+ ','
	SET @Pos = CHARINDEX(',', @IntegerList, 1)

	IF REPLACE(@IntegerList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @IntegerID = LTRIM(RTRIM(LEFT(@IntegerList, @Pos - 1)))
			IF @IntegerID <> ''
			BEGIN
				INSERT INTO @ParsedList (IntegerID) 
				VALUES (CAST(@IntegerID AS int)) --Use Appropriate conversion
			END
			SET @IntegerList = RIGHT(@IntegerList, LEN(@IntegerList) - @Pos)
			SET @Pos = CHARINDEX(',', @IntegerList, 1)

		END
	END	
	RETURN
END



-- Example
-- 
-- CREATE PROC dbo.GetOrderList6
-- (
-- 	@OrderList nvarchar(500)
-- )
-- AS
-- BEGIN
-- 	SET NOCOUNT ON
-- 	
-- 	SELECT 	o.OrderID, CustomerID, EmployeeID, OrderDate
-- 	FROM	dbo.Orders AS o
-- 		JOIN
-- 		dbo.SplitCSVIntegers(@OrderList) AS s
-- 		ON
-- 		o.OrderID = s.OrderID
-- END
-- GO




GO
