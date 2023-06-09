SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[RemoveNonPrintableChars] (
    @string nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
RETURN (
SELECT
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(@string, 
CHAR(00), ''), CHAR(01), ''), CHAR(02), ''), CHAR(03), ''), CHAR(04), ''),
CHAR(05), ''), CHAR(06), ''), CHAR(07), ''), CHAR(08), ''), CHAR(09), ''),
CHAR(10), ''), CHAR(11), ''), CHAR(12), ''), CHAR(13), ''), CHAR(14), ''),
CHAR(15), ''), CHAR(16), ''), CHAR(17), ''), CHAR(18), ''), CHAR(19), ''),
CHAR(20), ''), CHAR(21), ''), CHAR(22), ''), CHAR(23), ''), CHAR(24), ''),
CHAR(25), ''), CHAR(26), ''), CHAR(27), ''), CHAR(28), ''), CHAR(29), ''),
CHAR(30), ''), CHAR(31), ''), CHAR(127), '')
)
END --FUNCTION
GO
