SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Matt Ford
-- Create date: 12/4/2014
-- Description:	Inserts Audit Data into [LKG].[dbo].[Audits]
-- =============================================
CREATE Procedure [dbo].[InsertAuditData]
	@Source nvarchar(200),
	@Quantity int,
	@TimeElapsed time,
	@DefaultName nvarchar(50),
	@ReportProfile nvarchar(10)
AS
BEGIN

	DECLARE @SchoolID nvarchar(20) = (Select DB_NAME())
	DECLARE @TimeStamp datetime = GETDATE()
	DECLARE @currentHour nvarchar(5)
	SET @currentHour = (SELECT DATEPART(HOUR, GETDATE()))

    INSERT INTO [LKG].[dbo].[Audits] (
		SchoolID,
		Source,
		Type,
		Method,
		Quantity,
		TimeStamp,
		Hour,
		Duration
		
    )
    SELECT
    @SchoolID as SchoolID,
    @Source as Source,
    @DefaultName as Type,
    @ReportProfile as Method,
    @Quantity as Quantity,
    @TimeStamp as TimeStamp,
    @currentHour as Hour,
    @TimeElapsed as Duration
    
	
END

GO
