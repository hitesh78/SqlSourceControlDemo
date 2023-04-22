SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[glRefreshReceivablesFamilyID] (@table_name nvarchar(50), @table_pk_id int = null, @error nvarchar(4000)=null OUTPUT)
as
begin

	DECLARE @errmsg nvarchar(MAX) = null
	DECLARE @errsev int
	DECLARE @errsta int
	DECLARE @errnum int
	DECLARE @errpro nvarchar(4000)
	DECLARE @errlin int

--	BEGIN TRANSACTION
	BEGIN TRY

		if (select top 1 1 from Receivables r
			inner join students s
			on s.StudentID = r.StudentID
			where isnull(r.FamilyID,-2) <> isnull(s.FamilyID,-3)) is not null
		begin

			exec('disable trigger ReceivablesValidateDate,ReceivablesAfterTrigger on Receivables')

			update Receivables
				set FamilyID = s.FamilyID
			from Receivables r
				inner join students s
				on s.StudentID = r.StudentID
			where isnull(r.FamilyID,-2) <> isnull(s.FamilyID,-3)

			exec('enable trigger ReceivablesValidateDate,ReceivablesAfterTrigger on Receivables')

			set @error = 'Notice: Family IDs needed to be synchronized.'
		
		end

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
			SET @errmsg = @errmsg + '<br/>Error #:   ' + CAST(@errnum as nvarchar(20))
								  + '<br/>Procedure: ' + @errpro
								  + '<br/>Line #:    ' + CAST(@errlin as nvarchar(20))
		if @table_pk_id is not null
			RAISERROR(@errmsg,@errsev,@errsta);
		ELSE
			set @error = @errmsg

	END CATCH

--	IF @@TRANCOUNT > 0
--		COMMIT TRANSACTION
	
	return	
end

GO
