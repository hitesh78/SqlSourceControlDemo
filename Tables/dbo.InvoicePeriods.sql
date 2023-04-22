CREATE TABLE [dbo].[InvoicePeriods]
(
[InvoicePeriodID] [int] NOT NULL IDENTITY(1, 1),
[FromDate] [date] NOT NULL,
[ThruDate] [date] NOT NULL,
[Status] [nchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Opened] [date] NULL,
[Closed] [date] NULL,
[SessionID] [int] NOT NULL,
[BillingNote] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] AS ((datename(month,[ThruDate])+' ')+datename(year,[ThruDate])),
[SessionID_TransferBalances] [int] NULL,
[CloseSessionInfo] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[InstallmentBilling]
on [dbo].[InvoicePeriods]
after update
as
begin

-- Note this trigger can probably be combined with InvoicePeriodUpdateStatus (instead of) trigger
-- to avoid duplication and to also allow for creation of receivables records before setting closed
-- on period (which now requires a hack to allow updates to the newly created transactions if getdate()=InvoicePeriods.Closed)

	declare @SessionID int = null;
	declare @InvoicePeriodID int = null;
	declare @FromDate date = null;
	declare @ThruDate date = null;
	declare @Status nchar(7) = null;
	declare @oldStatus nchar(7) = null;
	declare @oldFrom date = null;
	declare @oldThru date = null;
	declare @EnableInstallmentBilling bit 
		= (select EnableInstallmentBilling from settings where SettingID=1);

	if (select count(*) from inserted) > 1
	begin
		RAISERROR ('Business logic (database trigger) only allows one period row to be updated at a time.',15,1);
		rollback;
		return;
    end	

	select 
		@SessionID = SessionID,
		@InvoicePeriodID = InvoicePeriodID,
		@FromDate = FromDate,
		@ThruDate = ThruDate,
		@Status = Status
	from inserted

	-- Get the previous (old) status
	select 
		@oldStatus = Status,
		@oldFrom = FromDate,
		@oldThru = ThruDate
	from deleted

    if @Status='Closed' and @oldStatus='Closed'
    begin
		RAISERROR ('You may not changed a closed period, except to reopen it.',15,1);
		rollback;
		return;
    end

    if @Status='Closed' and @ThruDate>cast(getdate() as date)
    begin
		RAISERROR ('"Transactions Through" date must not be after today. Correct this field and try again.',15,1);
		rollback;
		return;
    end

	--if @ThruDate >= '2012-10-20' /* implementation cutoff, earlier records may not comply */
	--begin
		-- Create installment transactions....
		if @oldStatus = 'Open' and @Status='Closed' 
		begin
			if @EnableInstallmentBilling=0
			begin
				-- Make sure no transaction are already created...
				if (select count(*) from Receivables r
					inner join Contract c 
						on r.ContractID = c.ContractID
					where c.SessionID = @SessionID
						and r.date >= @FromDate) > 0
				begin
					RAISERROR ('Unexpected installments transactions already posted.  You may have used the installment billing dialogue but later turned it off from Settings. Please re-enable the installment billing dialogue.  Then you may revert this period to pending status to erase these installments, and you may then turn off the installment billing dialogue again if you wish.',15,1);
					rollback;
					return;
				end

				-- Create installment transaction for this month...
				insert into Receivables 
					(StudentID,Date,TransactionTypeID,ContractID,Amount,Notes)
				select	StudentID,
						case when @EnableInstallmentBilling=0
						then @ThruDate else date end,
						TransactionTypeID,
						ContractID,
						amnt,
						descr 
					from ContractNormalized
					where SessionID = @SessionID
					and date between @FromDate and @ThruDate
					and amnt<>0
			end
			else
				if (select 1 from vInvoicePeriods
					where InvoicePeriodID = @InvoicePeriodID
						and isnull(NumPendInstallmentDB,0) = isnull(NumInstallmentDB,0)
						and isnull(SumPendInstallmentDB,0) = isnull(SumInstallmentDB,0)
						and isnull(NumPendInstallmentCR,0) = isnull(NumInstallmentCR,0)
						and isnull(SumPendInstallmentCR,0) = isnull(SumInstallmentCR,0)) is null
				begin
					RAISERROR ('Please change the Period Status back to OPEN and then post/refresh installment billing before closing this period.',15,1);
					rollback;
					return;
				end

			-- Set closed date...
			update InvoicePeriods set Closed = getdate()
				where InvoicePeriodID = @InvoicePeriodID;
		end
		else 
		if @oldStatus = 'Closed' and @Status='Open'
		begin
			 if @EnableInstallmentBilling=0
				-- Back out previously generated installment transactions...
				delete r
					from Receivables r
					inner join Contract c 
						on r.ContractID = c.ContractID
					where c.SessionID = @SessionID
						and r.date = @OldThru -- use old thru date since original installments were created on this date
				
			-- Clear closed date...
			update InvoicePeriods set Closed = null 
				where InvoicePeriodID = @InvoicePeriodID;
		end
		else 
		if @oldStatus = 'Open' and @Status='Pending' and @EnableInstallmentBilling=1
		begin
			-- Back out previously generated installment transactions...
			delete r
				from Receivables r
				inner join Contract c 
					on r.ContractID = c.ContractID
				where c.SessionID = @SessionID
					and r.date >= @OldFrom -- use old thru date since original installments were created on this date
		end

	-- end

end


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[InvoicePeriodsReceivablesRI]
 on [dbo].[InvoicePeriods]
 Instead Of Delete
As
Begin
	If (select count(*) from deleted d 
			inner join Receivables r on r.date between d.FromDate and d.ThruDate
			inner join TransactionTypes tt on tt.TransactionTypeID = r.TransactionTypeID
			where tt.SessionID=d.SessionID 
		) > 0
		begin
			RAISERROR ('Cannot delete one or more billing periods because of associated transactions.',15,1);
			return;
		end
    else
	    begin
			delete from InvoicePeriods where InvoicePeriodID in (select InvoicePeriodID from deleted)
		end

End

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[InvoicePeriodUpdateStatus]
on [dbo].[InvoicePeriods]
instead of update
as
Begin

	declare @SessionID int = null;
	declare @priorSessionID int = null;
	declare @InvoicePeriodID int = null;
	declare @FromDate date = null;
	declare @ThruDate date = null;
	declare @Status nchar(7) = null;
	declare @oldStatus nchar(7) = null;
	declare @nextStatus nchar(7) = null;
	declare @priorStatus nchar(7) = null;
	declare @nextMonth int = null;
	declare @nextYear int = null;
	declare @priorMonth int = null;
	declare @priorYear int = null;
	declare @oldMonth int = null;
	declare @oldYear int = null;
	declare @BillingNote nvarchar(MAX) = null;
	declare @SessionID_TransferBalances int = null;
	declare @ThruMonth int = null;
	declare @ThruYear int = null;
	declare @nextInvoicePeriodID int = null;
	declare @Opened date = null;
	declare @Closed date = null;

	if (select count(*) from inserted) <> 1
	begin
		RAISERROR ('Business logic (database trigger) only allows one period row to be updated at a time.',15,1);
		return;
    end

	select 
		@SessionID = SessionID,
		@InvoicePeriodID = InvoicePeriodID,
		@FromDate = FromDate,
		@ThruDate = ThruDate,
		@Status = Status,
		@BillingNote = BillingNote,
		@SessionID_TransferBalances = SessionID_TransferBalances,
		@ThruMonth = datepart(month,ThruDate),
		@ThruYear = datepart(year,ThruDate),
		@Opened = Opened,
		@Closed = Closed
	from inserted

	if @SessionID = @SessionID_TransferBalances
	begin
		RAISERROR ('Please select the new session where balances should be transfered; or erase the transfer field and try again when a new session is created.  You have selected the same session this period is in.',15,1);
		return;
    end

	-- Get the previous (old) status
	select 
		@oldStatus = Status,
		@oldMonth = datepart(month,ThruDate),
		@oldYear = datepart(year,ThruDate)
	from deleted

	-- get the status for the following month
	set @nextMonth = datepart(month,@ThruDate);
	set @nextYear = datepart(year,@ThruDate);
	set @nextMonth = @nextMonth + 1;
	if @nextMonth > 12
	begin
		set @nextMonth = 1;
		set @nextYear = @nextYear + 1;
	end
	select	@nextInvoicePeriodID = InvoicePeriodID,
			@nextStatus = Status
		from InvoicePeriods
		where SessionID = @SessionID
			and datepart(month,ThruDate) = @nextMonth
			and datepart(year,ThruDate) = @nextYear

	-- get the status for the prior month
	set @priorMonth = datepart(month,@ThruDate);
	set @priorYear = datepart(year,@ThruDate);
	set @priorMonth = @priorMonth - 1;
	if @priorMonth = 0
	begin
		set @priorMonth = 12;
		set @priorYear = @priorYear - 1;
	end
	select	@priorStatus = Status,
			@priorSessionID = SessionID
		from InvoicePeriods
		where SessionID = @SessionID
			and datepart(month,ThruDate) = @priorMonth
			and datepart(year,ThruDate) = @priorYear

	-- If updating status, make sure the change is valid..
	if @Status <> @oldStatus
	begin
		
		-- Closed status only allowed if prior status was "Open"...
		if @Status = 'Closed' and @oldStatus <> 'Open'
		begin
			RAISERROR ('Pending periods must be Opened before being Closed.',15,1);
			return;
		end
		
		if @Status = 'Pending' and @oldStatus = 'Closed'
		begin
			RAISERROR ('A closed period must be reopened before it can be switched to pending.',15,1);
			return;
		end
		
		if @Status = 'Open' and @priorStatus is not null and @priorStatus<>'Closed'
		begin
			RAISERROR ('You may only open a period when the prior month is closed.',15,1);
			return;
		end
		
		if @Status = 'Open' and @nextStatus is not null and @nextStatus<>'Pending'
		begin
			RAISERROR ('You may not open a period that is followed by another open or closed period.',15,1);
			return;
		end

		if @Status = 'Closed'
			set @Closed = getdate();
			
		if @Status = 'Open'
			set @Opened = getdate();
	end

	if @ThruMonth <> @oldMonth or @ThruYear <> @oldYear
	begin
		RAISERROR ('The "Transactions Through Date" must remain within the current month.',15,1);
		return;
	end

	begin transaction
		if @nextInvoicePeriodID is not null
			update InvoicePeriods set FromDate = dateadd(day,1,@ThruDate)
				where InvoicePeriodID = @nextInvoicePeriodID
					and FromDate <> dateadd(day,1,@ThruDate);

		update InvoicePeriods
			set FromDate = @FromDate,
				ThruDate = @ThruDate,
				Status = @Status,
				SessionID = @SessionID,
				BillingNote = @BillingNote,
				SessionID_TransferBalances = @SessionID_TransferBalances,
				Opened = @Opened,
				Closed = @Closed
			where InvoicePeriodID = @InvoicePeriodID;
	commit

End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[TransferBalances]
on [dbo].[InvoicePeriods]
after update
as
begin

-- Note this trigger can probably be combined with InvoicePeriodUpdateStatus (instead of) trigger
-- to avoid duplication and to also allow for creation of receivables records before setting closed
-- on period (which now requires a hack to allow updates to the newly created transactions if getdate()=InvoicePeriods.Closed)

	declare @SessionID int = null;
	declare @InvoicePeriodID int = null;
	declare @SourceInvoicePeriodID int = null;
	declare @FromDate date = null;
	declare @ThruDate date = null;
	declare @Status nchar(7) = null;
	declare @oldStatus nchar(7) = null;
	declare @oldFrom date = null;
	declare @oldThru date = null;
	declare @SessionID_TransferBalances int = null;
	declare @FromSessionTitle nvarchar(50) = null;
	declare @ToSessionTitle nvarchar(50) = null;
    declare @BalanceTransferByAccount bit = null;
    declare @str nvarchar(500) = null;

	if (select count(*) from inserted) > 1
	begin
		RAISERROR ('Business logic (database trigger) only allows one period row to be updated at a time.',15,1);
		rollback;
		return;
    end	

	select @BalanceTransferByAccount = BalanceTransferByAccount from settings

	select 
		@SessionID = i.SessionID,
		@InvoicePeriodID = i.InvoicePeriodID,
		@FromDate = i.FromDate,
		@ThruDate = i.ThruDate,
		@Status = i.Status,
		@SessionID_TransferBalances = i.SessionID_TransferBalances,
		@FromSessionTitle = fs.Title,
		@ToSessionTitle = ts.Title
	from inserted i
	inner join Session fs
	on i.SessionID = fs.SessionID
	left join Session ts
	on i.SessionID_TransferBalances = ts.SessionID

	-- Get the previous (old) status
	select 
		@oldStatus = Status,
		@oldFrom = FromDate,
		@oldThru = ThruDate
	from deleted

	if @SessionID_TransferBalances is null
	begin
		if @oldStatus <> @Status 
		begin
			if (select distinct 1 from InvoicePeriods 
					where
					SessionID = @SessionID 
					and SessionID_TransferBalances is not null
					and Status = 'Closed')
				is not null
			begin
				set @str = 'You may not open a new period after transferring balances. Please cancel this change. ';
				RAISERROR (@str,15,1);
				rollback;
				return;
			end
		end
/*
		-- If this is the target session and period for a balance transfer, then confirm that all
		-- transfers-in match all transfers-out from the source period...
		set @SourceInvoicePeriodID = (select InvoicePeriod from InvoicePeriods
				where SessionID_TransferBalances = @SessionID and Status='Closed');
		if @SourceInvoicePeriodID is not null
		begin
			// integrity check that could be added in the future...
		end
*/	
	end
	else
	begin

		-- Create installment transactions....
		if @oldStatus = 'Open' and @Status='Closed' 
		begin
		
		/*  Source may have destination transfers from last year, so comment out....

			-- Make sure no transaction are already created in this session...
			if (select count(*) 
					from TransactionTypes 
					where balanceTransferType = 1
						and SessionID = @SessionID) 
				> 0
			begin
				set @str = 'Unexpected balance transfer data is already posted for source session '
					+ @FromSessionTitle
					+'. Please call Gradelink for assistance.';
				RAISERROR (@str,15,1);
				rollback;
				return;
			end
		*/

			-- Make sure no transaction are already created in the target session...
			if (select count(*) 
					from TransactionTypes 
					where balanceTransferType = 1
						and SessionID = @SessionID_TransferBalances) 
				> 0
			begin
				set @str = '<span>Unexpected balance transfer data is already posted for target session</span> '
					+ @ToSessionTitle
					+'<span>.</span> <span>Please call Gradelink for assistance.</span>';
				RAISERROR (@str,15,1);
				rollback;
				return;
			end

			-- Compute data to transfer
			select  
				s.StudentID,
				case when @BalanceTransferByAccount=1 then tt.ReceivableCategory else 'Balance Transfer' end as ReceivableCategory,
				sum(case when tt.DB_CR_Code in ('Payment','Credit memo') 
					then  -r.Amount else r.Amount end) SignedAmount
			into #BalanceTransfer
			from Receivables r
			inner join TransactionTypes tt on r.TransactionTypeID = tt.TransactionTypeID
			inner join Students s on r.StudentID = s.StudentID
			where 
				r.Date <= @ThruDate 
				and tt.SessionID = @SessionID
			group by s.StudentID, case when @BalanceTransferByAccount=1 then tt.ReceivableCategory else 'Balance Transfer' end 
			
/*
			print '@SessionID'
			print @SessionID
			print '@SessionID_TransferBalances'
			print @SessionID_TransferBalances
			print '@BalanceTransferByAccount'
			print @BalanceTransferByAccount
			print '@ThruDate'
			print @ThruDate
*/

			-- Create source transaction types
			insert into TransactionTypes
				(title,ReceivableCategory,DB_CR_Code,SessionID,balanceTransferType)
			select distinct 
				left(rtrim(ReceivableCategory) + ' ', 30) + 
					case when SignedAmount>0 then 'CR' else 'DB' end,
				rtrim(ReceivableCategory),
				case when SignedAmount>0 then 'Credit' else 'Debit' end + ' memo',
				@SessionID,
				1
			from #BalanceTransfer
			where SignedAmount<>0
			--  Source may have destination transfers from last year, so only add missing types...
				and (select left(rtrim(ReceivableCategory) + ' ', 30) + 
						case when SignedAmount>0 then 'CR' else 'DB' end) 
						not in (
							select title from TransactionTypes 
								where SessionID = @SessionID
						)

			-- Post source balance out transfers
			insert into Receivables 
				(StudentID,Date,TransactionTypeID,Amount,Notes)
			select 
				StudentID,
				@ThruDate,
				(select TransactionTypeID from TransactionTypes
					where Title = left(rtrim(bt.ReceivableCategory) + ' ',30) +
					case when SignedAmount>0 then 'CR' else 'DB' end
					and SessionID = @SessionID ),
				abs(bt.SignedAmount),
				'Balance transfer to ' + rtrim(@ToSessionTitle)
			from #BalanceTransfer bt
			where SignedAmount<>0

			-- Create target transaction types
			insert into TransactionTypes
				(title,ReceivableCategory,DB_CR_Code,SessionID,balanceTransferType)
			select distinct 
				left(rtrim(ReceivableCategory) + ' ',30) + 
					case when SignedAmount>0 then 'DB' else 'CR' end,
				rtrim(ReceivableCategory),
				case when SignedAmount>0 then 'Debit' else 'Credit' end + ' memo',
				@SessionID_TransferBalances,
				1
			from #BalanceTransfer
			where SignedAmount<>0

			-- Post balance in transfers to target
			insert into Receivables 
				(StudentID,Date,TransactionTypeID,Amount,Notes)
			select 
				StudentID,
				@ThruDate,
				(select TransactionTypeID from TransactionTypes
					where Title = left(rtrim(bt.ReceivableCategory) + ' ',30) +
					case when SignedAmount>0 then 'DB' else 'CR' end 
					and SessionID = @SessionID_TransferBalances),
				abs(bt.SignedAmount),
				'Balance transfer from ' + rtrim(@FromSessionTitle)
			from #BalanceTransfer bt
			where SignedAmount<>0
			
		end

else if @oldStatus = 'Closed' and @Status='Open'
		begin
			-- Back out previously generated installment transactions from source session...
			delete r
				from Receivables r
				inner join TransactionTypes t 
					on r.TransactionTypeID = t.TransactionTypeID
				where t.SessionID = @SessionID
					and t.balanceTransferType = 1
					-- use old thru date since original transfers were created on this date
 					and r.date = @OldThru

/* Source may have destination transfers from last year, so comment out....
			delete from TransactionTypes
				where balanceTransferType = 1
					and SessionID = @SessionID
*/

			-- Back out previously generated installment transactions from target session...
			delete r
				from Receivables r
				inner join TransactionTypes t 
					on r.TransactionTypeID = t.TransactionTypeID
				where t.SessionID = @SessionID_TransferBalances
					and t.balanceTransferType = 1
					-- use old thru date since original transfers were created on this date
 					and r.date = @OldThru
	
			delete from TransactionTypes
				where balanceTransferType = 1
					and SessionID = @SessionID_TransferBalances

		end
    end
end
GO
ALTER TABLE [dbo].[InvoicePeriods] ADD CONSTRAINT [PK_InvoicePeriods] PRIMARY KEY CLUSTERED ([InvoicePeriodID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
