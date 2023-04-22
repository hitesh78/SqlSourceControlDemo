SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/16/2018
-- Description:	Used to get the transaleted month values, both full name months and 3 char. abbr.
-- Just do a left join on this funciton
-- =============================================
Create FUNCTION [dbo].[glTMonths] ()
RETURNS TABLE 
AS
RETURN 
(
	Select 'January' as Month, dbo.T(0, 'January') as tMonth Union
	Select 'February' as Month, dbo.T(0, 'February') as tMonth Union
	Select 'March' as Month, dbo.T(0, 'March') as tMonth Union
	Select 'April' as Month, dbo.T(0, 'April') as tMonth Union
	Select 'May' as Month, dbo.T(0, 'May') as tMonth Union
	Select 'June' as Month, dbo.T(0, 'June') as tMonth Union
	Select 'July' as Month, dbo.T(0, 'July') as tMonth Union
	Select 'August' as Month, dbo.T(0, 'August') as tMonth Union
	Select 'September' as Month, dbo.T(0, 'September') as tMonth Union
	Select 'October' as Month, dbo.T(0, 'October') as tMonth Union
	Select 'November' as Month, dbo.T(0, 'November') as tMonth Union
	Select 'December' as Month, dbo.T(0, 'December') as tMonth Union
	Select 'Jan' as Month, dbo.T(0, 'Jan') as tMonth Union
	Select 'Feb' as Month, dbo.T(0, 'Feb') as tMonth Union
	Select 'Mar' as Month, dbo.T(0, 'Mar') as tMonth Union
	Select 'Apr' as Month, dbo.T(0, 'Apr') as tMonth Union
	Select 'May' as Month, dbo.T(0, 'May') as tMonth Union
	Select 'Jun' as Month, dbo.T(0, 'Jun') as tMonth Union
	Select 'Jul' as Month, dbo.T(0, 'Jul') as tMonth Union
	Select 'Aug' as Month, dbo.T(0, 'Aug') as tMonth Union
	Select 'Sep' as Month, dbo.T(0, 'Sep') as tMonth Union
	Select 'Oct' as Month, dbo.T(0, 'Oct') as tMonth Union
	Select 'Nov' as Month, dbo.T(0, 'Nov') as tMonth Union
	Select 'Dec' as Month, dbo.T(0, 'Dec') as tMonth
)
GO
