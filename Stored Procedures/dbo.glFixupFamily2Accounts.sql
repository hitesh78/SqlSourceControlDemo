SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[glFixupFamily2Accounts] (@error varchar(8000)=null OUTPUT)
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
		-- See DS-1065 / FD 144106 and prior history
		--
		-- Existing trigger code sometimes assign Access = 'Family' when
		-- Accounts.Access field should be Family 2.  The following script
		-- fixes this....
		--
		declare @cnt integer;

		UPDATE a
		SET Access = 'Family2'
		FROM Accounts a
		INNER join Families f
		ON a.AccountID = f.AccountID
		INNER join Students s
		ON s.Family2ID = f.FamilyID
		WHERE a.Access = 'Family'

		set @cnt = @@ROWCOUNT

		IF @cnt>0
		BEGIN
			SET @error = 'Notice: Accounts table "Family" Access field correct to "Family2", # fixes = ' + CAST(@cnt as varchar(20))
		END
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
