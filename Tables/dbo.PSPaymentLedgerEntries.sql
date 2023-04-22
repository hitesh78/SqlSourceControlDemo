CREATE TABLE [dbo].[PSPaymentLedgerEntries]
(
[LEID] [int] NOT NULL IDENTITY(1, 1),
[PSPaymentID] [bigint] NOT NULL,
[StudentID] [int] NOT NULL,
[TransactionTypeID] [int] NOT NULL,
[TTAmount] [money] NOT NULL,
[OverPayment] [bit] NOT NULL CONSTRAINT [DF_PSPaymentLedgerEntries_OverPayment] DEFAULT ((0)),
[NewRowOrder] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSPaymentLedgerEntries] ADD CONSTRAINT [PK_PSPaymentLedgerEntries] PRIMARY KEY CLUSTERED ([LEID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSPaymentLedgerEntries] ADD CONSTRAINT [FK_PSPaymentLedgerEntries_PSPayments] FOREIGN KEY ([PSPaymentID]) REFERENCES [dbo].[PSPayments] ([PSPaymentID]) ON DELETE CASCADE
GO
