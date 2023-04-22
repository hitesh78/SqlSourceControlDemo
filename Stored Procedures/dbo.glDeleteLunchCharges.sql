SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[glDeleteLunchCharges] (@table_name varchar(50), @table_pk_id int = null, @error varchar(8000)=null OUTPUT)
as
begin

	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

	declare @SessionID int = null;
	declare @InvoicePeriodID int = null;
	declare @FromDate date = null;
	declare @ThruDate date = null;
	declare @Status char(7) = null;
	declare @FromDateStr nvarchar(20) = '';
	declare @ThruDateStr nvarchar(20) = '';
	
	declare @pkids varchar(8000);
	declare @pk_id int;
	declare @pos int

	DECLARE @errmsg nvarchar(MAX) = null
	DECLARE @errsev int
	DECLARE @errsta int
	DECLARE @errnum int
	DECLARE @errpro nvarchar(4000)
	DECLARE @errlin int

--	BEGIN TRANSACTION
	BEGIN TRY

		if @table_pk_id is not null
			set @pkids = cast(@table_pk_id as varchar(10))
		else
		begin
			-- if called from accounts trigger, then compute open invoice periods...
			set @pkids = 
				STUFF(
					(SELECT ',' + cast(ip.InvoicePeriodID as varchar(10))
					FROM InvoicePeriods ip
					INNER JOIN Session s on ip.SessionID = s.SessionID
					where ip.Status = 'Open' and s.Status = 'Open'
					FOR XML PATH (''))
					, 1, 1, '')
		end
		
		while len(@pkids)>0
		begin
		
			SET @pos = CHARINDEX(',', @pkids)
			if @pos=0
			BEGIN
				set @pk_id = cast(@pkids as int)
				set @pkids = ''
			END
			ELSE
			BEGIN
				set @pk_id = cast(substring(@pkids,1,@pos-1) as int)
				set @pkids = SUBSTRING(@pkids, @pos + 1, 8000)
			END

			if @pk_id is null
				RAISERROR ('You must specify a period in which to delete installments.',18, 1);

			select 
				@SessionID = SessionID,
				@InvoicePeriodID = InvoicePeriodID,
				@FromDate = FromDate,
				@ThruDate = ThruDate,
				@Status = Status
			from InvoicePeriods where InvoicePeriodID = @pk_id

			if @Status <> 'Open'
				RAISERROR ('You may only delete lunch charges for an open period.',18, 1);

			-- delete all lunch charges in the period (ie transaction types tied to attendance lunch options)
			delete from Receivables
				where Date between @FromDate and @ThruDate
				and TransactionTypeID 
					in (Select TransactionTypeID from TransactionTypes tt
							inner join attendancesettings aset 
								on tt.AttendanceCode = aset.id
							where 
								tt.SessionID = @SessionID /* and -- FD 105415 some schools do not use CHARGE :(
								tt.DB_CR_Code = 'Charge' */ /*safeguard*/)				
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
		
end

GO
