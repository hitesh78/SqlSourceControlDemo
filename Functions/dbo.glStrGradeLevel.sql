SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 8/16/2018
-- Description:	Used to get the String Grade level such as 2nd, 3rd, 4th, etc.
--				Just do a left join on Gradelevel
-- =============================================
CREATE FUNCTION [dbo].[glStrGradeLevel] ()
RETURNS TABLE 
AS
RETURN 
(
		-- Add the SELECT statement with parameter references here
	Select 'PS' as GradeLevel, dbo.T(0, 'PS') as strGradeLevel Union
	Select 'PK' as GradeLevel, dbo.T(0, 'PK') as strGradeLevel Union
	Select 'K' as GradeLevel, dbo.T(0, 'K') as strGradeLevel Union
	Select '1' as GradeLevel, dbo.T(0, '1st') as strGradeLevel Union
	Select '2' as GradeLevel, dbo.T(0, '2nd') as strGradeLevel Union
	Select '3' as GradeLevel, dbo.T(0, '3rd') as strGradeLevel Union
	Select '4' as GradeLevel, dbo.T(0, '4th') as strGradeLevel Union
	Select '5' as GradeLevel, dbo.T(0, '5th') as strGradeLevel Union
	Select '6' as GradeLevel, dbo.T(0, '6th') as strGradeLevel Union
	Select '7' as GradeLevel, dbo.T(0, '7th') as strGradeLevel Union
	Select '8' as GradeLevel, dbo.T(0, '8th') as strGradeLevel Union
	Select '9' as GradeLevel, dbo.T(0, '9th') as strGradeLevel Union
	Select '10' as GradeLevel, dbo.T(0, '10th') as strGradeLevel Union
	Select '11' as GradeLevel, dbo.T(0, '11th') as strGradeLevel Union
	Select '12' as GradeLevel, dbo.T(0, '12th') as strGradeLevel Union
	Select '13' as GradeLevel, dbo.T(0, '13th') as strGradeLevel Union
	Select '14' as GradeLevel, dbo.T(0, '14th') as strGradeLevel Union
	Select '15' as GradeLevel, dbo.T(0, '15th') as strGradeLevel Union
	Select '16' as GradeLevel, dbo.T(0, '16th') as strGradeLevel Union
	Select '17' as GradeLevel, dbo.T(0, '17th') as strGradeLevel Union
	Select '18' as GradeLevel, dbo.T(0, '18th') as strGradeLevel Union
	Select '19' as GradeLevel, dbo.T(0, '19th') as strGradeLevel Union
	Select '20' as GradeLevel, dbo.T(0, '20th') as strGradeLevel

)
GO
