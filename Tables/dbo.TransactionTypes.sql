CREATE TABLE [dbo].[TransactionTypes]
(
[TransactionTypeID] [int] NOT NULL IDENTITY(1, 1),
[Title] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountingCodeID] [int] NULL,
[ReceivableCategory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DB_CR_Code] [nchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount] [money] NULL CONSTRAINT [DF_TransactionCodes_DefaultAmount] DEFAULT ((0)),
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionID] [int] NOT NULL,
[FinAid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttendanceCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[daycare_tax_report] [bit] NOT NULL CONSTRAINT [DF_TransactionTypes_daycare_tax_report] DEFAULT ((0)),
[balanceTransferType] [bit] NOT NULL CONSTRAINT [DF_TransactionTypes_balanceTransferType] DEFAULT ((0)),
[GLAccount] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[TransactionTypesAfterTrigger]
on [dbo].[TransactionTypes]
after update /*, delete , insert - useful to allow for some backfile remedations... */
as
Begin

	declare @insertedWithinTransferedSession int
	 = (
	 select count(*) 
	 from inserted i
	 left join deleted d 
	 on d.TransactionTypeID = i.TransactionTypeID
	 where i.SessionID in (
			select distinct SessionID 
				from InvoicePeriods
				where Status = 'Closed'
				and SessionID_TransferBalances is not null
		)
		and d.TransactionTypeID is null
		 -- allow transaction that writes balance transfer records to go through
		and i.balanceTransferType=0
	 )

	declare @deletedWithinTransferedSession int
	 = (
	 select count(*) from deleted d
	 left join inserted i 
	 on d.TransactionTypeID = i.TransactionTypeID
	 where 
		/* 
		-- Actually we don't care about deletes (if the records were not in use 
		-- which is protect by RI, so I've COMMENT OUT the following condition...
		d.SessionID in (
			select distinct SessionID 
				from InvoicePeriods
				where Status = 'Closed'
				and SessionID_TransferBalances is not null
		) and
		*/
		-- an actual delete, not a change that has both inserted and deleted sides
		i.TransactionTypeID is null
	 )
	 
	declare @changedWithinTransferedSession int
	 = (
	 select count(*) from deleted d
	 inner join inserted i 
	 on d.TransactionTypeID = i.TransactionTypeID
	 where d.SessionID in (
			select distinct SessionID 
				from InvoicePeriods
				where Status = 'Closed'
				and SessionID_TransferBalances is not null
		)
		and (	
			d.ReceivableCategory <> i.ReceivableCategory
		 or d.DB_CR_Code <> i.DB_CR_Code
		 or d.SessionID <> i.SessionID
		 or d.FinAid <> i.FinAid
		 or d.AttendanceCode <> i.AttendanceCode
		 or d.balanceTransferType <> i.balanceTransferType
		 or d.TransactionTypeID <> i.TransactionTypeID
		 or d.AccountingCodeID <> i.AccountingCodeID
		 or d.Amount <> i.Amount
		 -- Note: allows changes to title, notes and daycare_tax_report fields...
		)
	 )
	 
	if (@insertedWithinTransferedSession>0 
		or @deletedWithinTransferedSession>0
		 or @changedWithinTransferedSession>0) 
	begin
		ROLLBACK TRANSACTION;
		RAISERROR ('You may not make major changes to prior session transaction types and you may only make corrections to the title, notes or daycare tax credit fields after balances have been transfered forward to a new session.',15,1);
		return;
	end

End

GO
ALTER TABLE [dbo].[TransactionTypes] ADD CONSTRAINT [PK_TransactionTypes] PRIMARY KEY CLUSTERED ([TransactionTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AccountingCodeID] ON [dbo].[TransactionTypes] ([AccountingCodeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SessionID] ON [dbo].[TransactionTypes] ([SessionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TITLE_UNIQUE] ON [dbo].[TransactionTypes] ([SessionID], [Title]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransactionTypes] ADD CONSTRAINT [FK_TransactionTypes_AccountCodes] FOREIGN KEY ([AccountingCodeID]) REFERENCES [dbo].[AccountingCodes] ([AccountingCodeID])
GO
ALTER TABLE [dbo].[TransactionTypes] ADD CONSTRAINT [FK_TransactionTypes_Session] FOREIGN KEY ([SessionID]) REFERENCES [dbo].[Session] ([SessionID])
GO
