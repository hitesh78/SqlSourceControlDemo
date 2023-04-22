SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Joey
-- Create date: 10/14/2021
-- Modified dt: 11/19/2021
-- Description:	
-- =============================================
CREATE       PROCEDURE [dbo].[edfiClassPeriodsJSON]
--@SchoolYear int,
--@CalendarStartDate date,
--@CalendarEndDate date,
@SPAJSON nvarchar(max) output
AS
BEGIN
	SET NOCOUNT ON;

	Declare @SchoolID nvarchar(50) = (SELECT EdFiDOESchoolID FROM IntegrationSettings Where ID = 1);

	set @SPAJSON = (
		select 
			@SchoolID as [schoolReference.schoolId],
			PeriodSymbol as [name] 
		From [Periods]
		Where PeriodID > 0
		FOR JSON PATH
	);

END
GO
