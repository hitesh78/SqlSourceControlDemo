CREATE TABLE [dbo].[PSPaymentBCBalances]
(
[bcBalanceID] [int] NOT NULL IDENTITY(1, 1),
[PSPaymentID] [bigint] NOT NULL,
[StudentID] [int] NOT NULL,
[bcTitle] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bcBalance] [money] NOT NULL,
[bcRowOrder] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSPaymentBCBalances] ADD CONSTRAINT [PK_PSPaymentBCBalances] PRIMARY KEY CLUSTERED ([bcBalanceID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSPaymentBCBalances] ADD CONSTRAINT [FK_PSPaymentBCBalances_PSPayments] FOREIGN KEY ([PSPaymentID]) REFERENCES [dbo].[PSPayments] ([PSPaymentID]) ON DELETE CASCADE
GO
