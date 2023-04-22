CREATE TABLE [dbo].[Receivables]
(
[ReceivableID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[Date] [date] NULL,
[SortOrder] AS (CONVERT([bigint],datediff(day,'2000-01-01',[date]),(0))*(10000000000.)+[ReceivableID]),
[TransactionTypeID] [int] NOT NULL,
[ContractID] [int] NULL,
[TransactionMethod] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Receivables_ReferenceType] DEFAULT (''),
[ReferenceNumber] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Receivables_ReferenceNumber] DEFAULT (''),
[Amount] [money] NOT NULL CONSTRAINT [DF_Receivables_Amount] DEFAULT (''),
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueContractID] AS (case  when [ContractID] IS NULL then -[ReceivableID] else [ContractID] end),
[PaymentID] [int] NULL,
[AccountingCodeID] [int] NULL,
[FamilyID] [int] NULL,
[BTID] [int] NULL,
[PostID] [int] NULL,
[OverPaymentEntry] [bit] NULL CONSTRAINT [DF_Receivables_OverPaymentEntry] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[ReceivablesAfterTrigger]
on [dbo].[Receivables]
after insert, update, delete
as
Begin

	--
	-- Don't allow changes to non-balance transfer records if within a session that has had closing balances transfered
	--
	declare @insertedWithinTransferedSession int
	 = (
	 select count(*) 
	 from inserted i
	 inner join TransactionTypes t
	 on i.TransactionTypeID = t.TransactionTypeID
		 -- allow transaction that writes balance transfer records to go through
		and t.balanceTransferType = 0 
	 where t.SessionID in (
			select distinct SessionID 
				from InvoicePeriods
				where Status = 'Closed'
				and SessionID_TransferBalances is not null
		)
	 )
	declare @deletedWithinTransferedSession int
	 = (
	 select count(*) 
	 from deleted d
	 inner join TransactionTypes t
	 on d.TransactionTypeID = t.TransactionTypeID
		 -- allow transaction that writes balance transfer records to go through
		and t.balanceTransferType = 0
	 where t.SessionID in (
			select distinct SessionID 
				from InvoicePeriods
				where Status = 'Closed'
				and SessionID_TransferBalances is not null
		)
	 )
	if @insertedWithinTransferedSession>0 or @deletedWithinTransferedSession>0
	begin
		ROLLBACK TRANSACTION;
		RAISERROR ('You may not change any transactions for a session after balances have been transfered forward to a new session.',15,1);
		return;
	end

	declare @insertedOnBalanceTransferType int
	 = (
	 select count(*) 
	 from inserted i
	 inner join TransactionTypes t
	 on i.TransactionTypeID = t.TransactionTypeID
	 where balanceTransferType = 1
	)
	
	declare @deletedOnBalanceTransferType int
	 = (
	 select count(*) 
	 from deleted d
	 inner join TransactionTypes t
	 on d.TransactionTypeID = t.TransactionTypeID
	 where balanceTransferType = 1
	 )

	if @insertedWithinTransferedSession>0 or @deletedWithinTransferedSession>0
	begin
		ROLLBACK TRANSACTION;
		RAISERROR ('You may not change any balance transfer transactions.  Reopen and change information in prior session if needed, or (better yet) create adjusting transaction as needed.',15,1);
		return;
	end

End
 
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[ReceivablesBlockClosedPeriodDeletes]
on [dbo].[Receivables]
instead of delete
as
--
-- This trigger is multiple-row compatible
--
begin

	if (select distinct 1
		from deleted r
		left join InvoicePeriods ip 
			on r.Date >= ip.FromDate and r.Date <= ip.ThruDate
				and (select SessionID from transactiontypes t where r.transactiontypeid=t.transactiontypeid) = ip.SessionID
		inner join TransactionTypes t 
			on r.transactiontypeid=t.transactiontypeid
		where 
		(
			(ip.Status='Closed' -- BLOCK If trying to deleted in closed period, ...
				and ( 
					-- ... and edits to closed periods are not allowed.
					(select EnableReceivablesEditsToClosedPeriods from settings) = 0	
					or	
					-- ... and this is a balance transfer transaction.
					t.balanceTransferType = 1
				)
			)
			OR
			(ip.Status<>'Closed' 
				and ( 
					-- ... and this is a balance transfer transaction ...
					t.balanceTransferType = 1
					and 
					-- ... and the target of a source transfer in a closed period.
					(select Status from InvoicePeriods ip2
						where SessionID_TransferBalances = t.SessionID
							and r.Date >= ip2.FromDate and r.Date <= ip2.ThruDate
						) = 'Closed'
				) 
			)
		)
	) is not null
	begin
		RAISERROR ('You may not delete a transaction in a closed period, or a balance transfer transaction. If you are reopening a prior session period that had balance transfers make sure the period into which balances were being transfered is also open, since those will be reversed out (deleted) too. This can also occur when reopening a period that has balance transfers.',15,1);
		rollback;
		return;
	end

	delete r
	from Receivables r 
	inner join deleted d 
	on r.ReceivableID = d.ReceivableID
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[ReceivablesValidateDate]
on [dbo].[Receivables]
instead of insert, update
as
--
-- This trigger is multiple-row compatible
--
begin
	if (select EnableReceivablesEditsToClosedPeriods from settings)=0 and
		((select distinct 1 
			from inserted r
			left join InvoicePeriods ip 
				on r.Date >= ip.FromDate and r.Date <= ip.ThruDate
					and (select SessionID from transactiontypes t where r.transactiontypeid=t.transactiontypeid) = ip.SessionID
			where r.ContractID is null -- no a installment billing transaction (those rules are below after -or-)
			and -- enumerate error conditions:		
				(	-- no matching period would be an error
					ip.InvoicePeriodID is null 
					OR
					-- Closed period and not:
					-- (1) an OUTBOUND 
					-- (2) balance transfer transaction
					-- (3) dated on the thru date of the OUTBOUND transfer period
					-- (4) for a transfer period being closed today
					( ip.Status='Closed'
						and not (
							-- all the following is an exception where the system creates transaction in a closed period...
							ip.SessionID_TransferBalances is not null -- test 1
							and (select 1 from transactiontypes t 
							  where r.transactiontypeid=t.transactiontypeid
								and t.balanceTransferType=1) is not null -- test (2) 
							and ip.ThruDate = r.Date -- test (3)
							and ip.Closed = cast(getdate() as date) -- test (4)
						) 
					) 
					OR
					-- Pending period and 
					-- (1) a balance transfer transaction
					( ip.Status='Pending'
						and (select balanceTransferType from transactiontypes t 
							  where r.transactiontypeid=t.transactiontypeid) = 1 
					) 
					/* ... don't need to finish this case because UI doesn't allow adding or editing balance transfer rows,
					   and trying to create them into a TARGET period that's closed or pending is covered above 
					OR
					-- Open period and a balance transfer transaction
					-- that does not:
					-- (1) match a closed period that has this session's ID in SessionID_BalanceTransfer
					( ip.Status='Open'
						and (select balanceTransferType from transactiontypes t 
							  where r.transactiontypeid=t.transactiontypeid) = 1 
						and 
					) 
					*/
				)  
			) is not null -- i.e., an error!
		or 
			(select distinct 1 
			from inserted r
			left join InvoicePeriods ip 
				on r.Date >= ip.FromDate and r.Date <= ip.ThruDate
					and (select SessionID from transactiontypes t where r.transactiontypeid=t.transactiontypeid) = ip.SessionID
			where r.ContractID is not null and (ip.InvoicePeriodID is null 
				or (ip.Status='Closed' 
				/* allow internal installment billing records to be created on close date only since we use AFTER trigger */
				and ip.Closed <> cast(getdate() as date))) /* instead of trigger could close this 'loophole' */
			) is not null)
	begin
		RAISERROR ('Transaction date is not within an open billing period. You may not save any transaction to a non-existant or closed billing period. Note: Both the source and target periods for balance transfers must be Open AND for BALANCE TRANSFERS use the Admin Setting "Enable edits to closed periods" and try again.',15,1);
		rollback;
		return;
	end
	else
	begin
		-- handle updates to existing balance transfer records...
		if (select DISTINCT 1 from Receivables r
				inner join inserted i on r.ReceivableID = i.ReceivableID
				inner join deleted d on i.ReceivableID = d.ReceivableID
			where
				d.Notes like 'Balance transfer%') is not NULL
		BEGIN
			RAISERROR ('You may not alter balance transfer transactions. Please canel this change. ',15,1);
			rollback;
			return;
		END

		-- handle updates to existing installment billing records...
		if (select DISTINCT 1 from Receivables r
				inner join inserted i on r.ReceivableID = i.ReceivableID
				inner join deleted d on i.ReceivableID = d.ReceivableID
			where
				d.ContractID is not null) is not NULL
		BEGIN
			RAISERROR ('You may not edit installment billing transactions. Please cancel this change. ',15,1);
			rollback;
			return;
		END

		-- handle this new records inserts...
		insert into Receivables (
			StudentID,Date,TransactionTypeID,ContractID,
			TransactionMethod,ReferenceNumber,Amount,Notes,PaymentID,FamilyID,BTID,PostID,OverPaymentEntry)
			select 
				i.StudentID,i.Date,i.TransactionTypeID,i.ContractID,
				i.TransactionMethod,i.ReferenceNumber,i.Amount,i.Notes,
				i.PaymentID,
				(Select FamilyID from Students s where s.StudentID = i.StudentID),
				i.BTID,
				i.PostID,
				i.OverPaymentEntry
			from inserted i	
			left join deleted d on i.ReceivableID = d.ReceivableID
			where d.ReceivableID is null

		-- handle updates to existing records...
		update Receivables 
			set StudentID = i.StudentID,
				Date = i.Date,
				TransactionTypeID = i.TransactionTypeID,
				ContractID = i.ContractID,
				TransactionMethod = i.TransactionMethod,
				ReferenceNumber = i.ReferenceNumber,
				Amount = i.Amount,
				Notes = i.Notes,
				PaymentID = i.PaymentID,
				FamilyID = (Select FamilyID from Students s where s.StudentID = i.StudentID),
				BTID = i.BTID,
				PostID = i.PostID,
				OverPaymentEntry = i.OverPaymentEntry
			from Receivables r
			inner join inserted i on r.ReceivableID = i.ReceivableID
			inner join deleted d on i.ReceivableID = d.ReceivableID
	end
end
GO
ALTER TABLE [dbo].[Receivables] ADD CONSTRAINT [PK_Receivables] PRIMARY KEY CLUSTERED ([ReceivableID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountingCodeID] ON [dbo].[Receivables] ([AccountingCodeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ContractID] ON [dbo].[Receivables] ([ContractID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PaymentID] ON [dbo].[Receivables] ([PaymentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[Receivables] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransactionTypeID] ON [dbo].[Receivables] ([TransactionTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Receivables] ADD CONSTRAINT [FK_Receivables_AccountCodes] FOREIGN KEY ([AccountingCodeID]) REFERENCES [dbo].[AccountingCodes] ([AccountingCodeID])
GO
ALTER TABLE [dbo].[Receivables] ADD CONSTRAINT [FK_Receivables_Contract] FOREIGN KEY ([ContractID]) REFERENCES [dbo].[Contract] ([ContractID])
GO
ALTER TABLE [dbo].[Receivables] ADD CONSTRAINT [FK_Receivables_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID])
GO
ALTER TABLE [dbo].[Receivables] ADD CONSTRAINT [FK_Receivables_TransactionTypes] FOREIGN KEY ([TransactionTypeID]) REFERENCES [dbo].[TransactionTypes] ([TransactionTypeID])
GO
