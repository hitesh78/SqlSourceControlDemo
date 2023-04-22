SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[glUncompletedAttendanceNotices] (@error varchar(8000)=null OUTPUT)
as
begin

	DECLARE @errmsg varchar(MAX) = null
	DECLARE @errsev int
	DECLARE @errsta int
	DECLARE @errnum int
	DECLARE @errpro varchar(8000)
	DECLARE @errlin int

--	BEGIN TRANSACTION
	BEGIN TRY

    -- Eval and add any uncompleted attendance notices...
    exec dbo.QueueUncompletedAttendanceAlerts

	END TRY
	BEGIN CATCH

--		IF @@TRANCOUNT > 0
--			ROLLBACK TRANSACTION

		SELECT @errmsg = ERROR_MESSAGE(), 
			@errsev = ERROR_SEVERITY(), 
			@errsta = ERROR_STATE(),
			@errnum = ERROR_NUMBER(),
			@errpro = ERROR_PROCEDURE(),
			@errlin = ERROR_LINE()
		IF @errsev <> 18
			SET @errmsg = @errmsg + '<br/>Error #:   ' + CAST(@errnum as varchar(20))
								  + '<br/>Procedure: ' + @errpro
								  + '<br/>Line #:    ' + CAST(@errlin as varchar(20))
        set @error = @errmsg

	END CATCH

--	IF @@TRANCOUNT > 0
--		COMMIT TRANSACTION
	
	return	
end
GO
