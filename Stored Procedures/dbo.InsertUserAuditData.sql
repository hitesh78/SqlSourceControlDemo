SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Matt Ford>
-- Create date: <3.16.2015>
-- Description:	<Inserts User Info into LKG.dbo.UserAudit>
-- =============================================
CREATE Procedure [dbo].[InsertUserAuditData] 
	-- Add the parameters for the stored procedure here
	@Username nvarchar(50),
    @Page nvarchar(100),
    @DBAffected nvarchar(50),
    @Action nvarchar(50)
AS
BEGIN
	DECLARE @SchoolID nvarchar(20) = (Select DB_NAME())
	DECLARE @TimeStamp datetime = GETDATE()

    -- Insert statements for procedure here
	INSERT INTO LKG.dbo.UserAudit (
        Username,
        SchoolID,
        Page,
        DBAffected,
        Action,
        Date
    )
    SELECT
        @Username,
        @SchoolID,
        @Page,
        @DBAffected,
        @Action,
        @TimeStamp
END

GO
