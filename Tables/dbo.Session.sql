CREATE TABLE [dbo].[Session]
(
[SessionID] [int] NOT NULL,
[Title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromDate] [date] NOT NULL,
[ThruDate] [date] NOT NULL,
[BillingFromDate] [date] NULL,
[BillingThruDate] [date] NULL,
[Status] [nchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingClosedDate] [date] NULL,
[SuppressOnlineStatements] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[SessionCascadeDeleteToInvoicePeriods]
 on [dbo].[Session]
 Instead Of Delete
As
Begin
	delete from InvoicePeriods where SessionID in (select SessionID from deleted)
	delete Session where SessionID in (select SessionID from deleted)
End

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Trigger [dbo].[SessionCreateBillingPeriods]
 on [dbo].[Session]
 instead of Insert, Update
As
begin

	if (select count(*) from inserted) <> 1
	begin
		RAISERROR ('Business logic (database trigger) only allows one session record to be updated at a time.',15,1);
		return;
    end
    
    declare @debug bit = 0;
    	
    declare @monthFrom int;
    declare @yearFrom int;
    declare @monthThru int;
    declare @yearThru int;
    declare @schoolThruMonth int;
    declare @schoolThruYear int;
    declare @months int;
    declare @dtStr1 nvarchar(20);
    declare @dtStr2 nvarchar(20);
    declare @dt1 date;
    declare @dt2 date;
    declare @mo2 int;
    declare @yr2 int;
    declare @dtMin date, @dtMax date;
    declare @SessionID int;
    declare @UseSessionID int;
    declare @FirstNonPendingInvoicePeriodDate date;
    declare @errStr nvarchar(256);
    declare @status nvarchar(10);
	declare @priorStatus nvarchar(10);
	declare @thruDate date;
	declare @priorThruDate date;
	declare @priorSessionID int;
	declare @AutoCopyTransactionTypes bit;

if @debug=1
begin
	delete messages
	insert into messages (message) values ('check 1');
end

    select	@monthFrom = datepart(month,BillingFromDate),
			@yearFrom = datepart(year,BillingFromDate),
			@monthThru = datepart(month,BillingThruDate),
			@yearThru = datepart(year,BillingThruDate),
			@schoolThruMonth = datepart(month,ThruDate),
			@schoolThruYear = datepart(year,ThruDate),
			@SessionID = SessionID
	from inserted
	
	-- If insert case, then assign @SessionID to next available...
	IF NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @UseSessionID =  isnull((SELECT MAX(SessionID) from Session),0) + 1
		-- handle this new records inserts...
		insert into Session 
				(SessionID,Title,FromDate,ThruDate,BillingFromDate,
					BillingThruDate,Status,BillingClosedDate,SuppressOnlineStatements)
			select @UseSessionID,
					i.Title,i.FromDate,i.ThruDate,
					i.BillingFromDate,i.BillingThruDate,
					i.Status,i.BillingClosedDate,
					i.SuppressOnlineStatements
			from inserted i	
			left join deleted d on i.SessionID = d.SessionID
			where d.SessionID is null
	END
	ELSE
	BEGIN
		SET @UseSessionID = @SessionID

		-- try to copy prior transaction types if we are opening a period...
		select @AutoCopyTransactionTypes = AutoCopyTransactionTypes from settings
		--
		select 
			@Status = isnull(i.Status,''), 
			@priorStatus = isnull(d.Status,''),
			@thruDate = i.BillingThruDate
		from inserted i 
		inner join deleted d on i.SessionID = d.SessionID
		--
		if @AutoCopyTransactionTypes=1 
			and @thruDate is not null 
			and @Status='Open' and @priorStatus<>'Open'
		begin
			select @priorThruDate = max(BillingThruDate)
			from Session where BillingThruDate < @thruDate

			select @priorSessionID = max(SessionID)
			from Session where BillingThruDate = @priorThruDate

			if @priorSessionID is not null
				insert into TransactionTypes
				(
					title,
					AccountingCodeID,
					ReceivableCategory,
					DB_CR_Code,
					Amount,
					Notes,
					SessionID,
					FinAid,
					AttendanceCode,
					daycare_tax_report,
					balanceTransferType,
					GLAccount
				)
				select 
					title,
					AccountingCodeID,
					ReceivableCategory,
					DB_CR_Code,
					Amount,
					Notes,
					@SessionID, -- target session
					FinAid,
					AttendanceCode,
					daycare_tax_report,
					balanceTransferType,
					GLAccount
				from TransactionTypes
				where SessionID = @priorSessionID -- source session
					and balanceTransferType = 0
					and title not in 
					( 
						select title from TransactionTypes 
							where SessionID = @SessionID -- target session
					)
		end

		-- handle updates to existing records...
		update Session 
			set 
				Title = i.Title,
				FromDate = i.FromDate,
				ThruDate = i.ThruDate,
				BillingFromDate = i.BillingFromDate,
				BillingThruDate = i.BillingThruDate,
				Status = i.Status,
				BillingClosedDate = i.BillingClosedDate,
				SuppressOnlineStatements = i.SuppressOnlineStatements
			from Session s
			inner join inserted i on s.SessionID = i.SessionID
			inner join deleted d on i.SessionID = d.SessionID
	END
	
	if @monthThru is null and @yearThru is null and 
		@schoolThruMonth is not null and @schoolThruYear is not null
	begin
		set @monthThru = @schoolThruMonth;
		set @yearThru = @schoolThruYear;
	end

if @debug=1
begin
	if (@yearThru is null)
	insert into messages (message) values ('@yearThru is null');
	if (@yearFrom is null)
	insert into messages (message) values ('@yearFrom is null');
	if (@monthThru is null)
	insert into messages (message) values ('@monthThru is null');
	if (@monthFrom is null)
	insert into messages (message) values ('@monthFrom is null');
end
	-- make sure we have valid dates to use...
	set @months = (@yearThru - @yearFrom) * 12 + (@monthThru - @monthFrom) + 1;

if @debug=1
begin
	insert into messages (message) values ('from '+cast(@monthFrom as nvarchar(8))+'/'+cast(@yearFrom as nvarchar(8)));
	insert into messages (message) values ('thru '+cast(@monthThru as nvarchar(8))+'/'+cast(@yearThru as nvarchar(8)));
	insert into messages (message) values ('months = '+cast(@months as nvarchar(8)));
end	
	if (@months<1 or @months>25)
	begin
		RAISERROR ('The billing period (school year term, or billing date range if provided) must be at least one month and less than 25 months.',15,1);
		return;
    end

	-- See if current date range information requires us to delete any prior periods
	set @dtStr1 = cast(@yearFrom as nchar(4))+'-'+cast(@monthFrom as nvarchar(2))+'-01';
	set @dt1 = cast(@dtStr1 as date);
	select 
		@dtMax = MAX(ThruDate), @dtMin = MIN(FromDate) 
		from InvoicePeriods where SessionID = @SessionID and FromDate<@dt1
	
	if (@dtMin is not null)
	begin
		-- Make sure none of the invoice periods that will be deleted have associated transactions
		if ((select distinct 1 from Receivables r
				inner join TransactionTypes tt on r.TransactionTypeID = tt.TransactionTypeID 
				where	tt.SessionID=@SessionID
						and r.Date between @dtMin and @dtMax) is not null)
		begin
			set @errStr = 'The changes to this session are not allowed because you have transactions within the date range from '
						+ cast(@dtMin as nvarchar(32)) + ' through ' + cast(@dtMax as nvarchar(32));
			RAISERROR(@errStr,15,1);
			return;
		end
	end

	-- See if current date range information requires us 
	-- to delete any invoice periods after the current session date range
	set @mo2 = @monthThru;
	set @yr2 = @yearThru;
	set @mo2 = @mo2 + 1;
	if @mo2 > 12
	begin
		set @mo2 = 1;
		set @yr2 = @yr2 + 1;
	end
	set @dtStr2 = cast(@yr2 as nchar(4))+'-'+cast(@mo2 as nvarchar(2))+'-01';
	set @dt2 = cast(@dtStr2 as date);
	select 
		@dtMax = MAX(ThruDate), @dtMin = MIN(FromDate) 
		from InvoicePeriods where SessionID = @SessionID and ThruDate>@dt2
	
	if (@dtMin is not null)
	begin
		-- Make sure none of the invoice periods that will be deleted have associated transactions
		if ((select distinct 1 from Receivables r
				inner join TransactionTypes tt on r.TransactionTypeID = tt.TransactionTypeID 
				where	tt.SessionID=@SessionID
						and r.Date between @dtMin and @dtMax) is not null)
		begin
			set @errStr = 'The changes to this session are not allowed because you have transactions after the end of the session specified, within the date range from '
						+ cast(@dtMin as nvarchar(32)) + ' through ' + cast(@dtMax as nvarchar(32));
			RAISERROR(@errStr,15,1);
			return;
		end
	end

if @debug=1
begin
	insert into messages (message) values (
		'Deleting invoice periods from ' 
		+ @dtStr1 + ' through ' + @dtStr2 + '.');
end

	delete InvoicePeriods where SessionID = @SessionID and (ThruDate<@dt1 or FromDate>@dt2);
    
    -- Status dependends on date of current open period (if any) 
    select @FirstNonPendingInvoicePeriodDate = MAX(FromDate) from InvoicePeriods 
	    where SessionID = @SessionID and Status != 'Pending'
	
	while @months > 0
	begin
		set @dtStr1 = cast(@yearFrom as nchar(4))+'-'+cast(@monthFrom as nvarchar(2))+'-01';
		
		set @mo2 = @monthFrom;
		set @yr2 = @yearFrom;
		set @mo2 = @mo2 + 1;
		if @mo2 > 12
		begin
			set @mo2 = 1;
			set @yr2 = @yr2 + 1;
		end
		set @dtStr2 = cast(@yr2 as nchar(4))+'-'+cast(@mo2 as nvarchar(2))+'-01';
		set @dt2 = dateadd(day,-1,cast(@dtStr2 as date));

		-- if the monthly period doesn't already exist, create it...
		if (select 1 from InvoicePeriods where SessionID=@SessionID and cast(@dtStr1 as date) between FromDate and ThruDate) is null
		begin
if @debug=1
begin
	insert into messages (message) values (
		'Adding period. Thru date = ' 
		+ @dtStr2 + ' minus 1 day: ' 
		+ isnull(cast(@dt2 as nvarchar(20)),'NONE') + ', Open invoice period = '
		+ isnull(cast(@FirstNonPendingInvoicePeriodDate as nvarchar(20)),'NONE') );
end		
			if @dt2 < @FirstNonPendingInvoicePeriodDate
				begin
					set @status = 'Closed'
				end
			else
				begin
					set @status = 'Pending'
				end

			insert into InvoicePeriods (SessionID,FromDate,ThruDate,Status)
				values (@UseSessionID,cast(@dtStr1 as date), @dt2, @status);
		end

		set @monthFrom = @monthFrom + 1;
		if @monthFrom > 12
		begin
			set @yearFrom = @yearFrom + 1;
			set @monthFrom = @monthFrom - 12;
		end
		
		set @months = @months - 1;

	end

end
GO
ALTER TABLE [dbo].[Session] ADD CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED ([SessionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Session] ON [dbo].[Session] ([Title]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
