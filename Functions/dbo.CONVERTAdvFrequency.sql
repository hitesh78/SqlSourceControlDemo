SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	CREATE FUNCTION [dbo].[CONVERTAdvFrequency]
	(  
		@List NVARCHAR(MAX)  
	)  
	RETURNS NVARCHAR(200)
	AS  
	BEGIN  
		Declare @csvTable table
		(
			IntegerID int
		)
		Declare @result NVARCHAR(200)
		SET @result = ''
		INSERT INTO @csvTable Select * From dbo.SplitCSVIntegers(@List)
		Update @csvTable set IntegerID = IntegerID - 1
		SELECT @result = @result + CAST(IntegerID AS nvarchar(10)) + N','
		FROM @csvTable
		WHERE IntegerID IS NOT NULL
		RETURN LEFT(@result, LEN(@result) - 1) 
	END 
GO
