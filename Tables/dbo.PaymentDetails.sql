CREATE TABLE [dbo].[PaymentDetails]
(
[PaymentDetailsID] [int] NOT NULL IDENTITY(1, 1),
[PSPaymentID] [bigint] NOT NULL,
[TransactionTypeID] [int] NOT NULL,
[TransactionTypeBalance] [money] NOT NULL,
[PaymentDateTime] [datetime] NOT NULL,
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentID] [int] NULL,
[PostID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaymentDetails] ADD CONSTRAINT [PK_PaymentDetails] PRIMARY KEY CLUSTERED ([PaymentDetailsID]) ON [PRIMARY]
GO
