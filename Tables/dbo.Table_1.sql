CREATE TABLE [dbo].[Table_1]
(
[LEID] [int] NOT NULL,
[PSPaymentID] [bigint] NOT NULL,
[StudentID] [int] NOT NULL,
[TransactionTypeID] [int] NOT NULL,
[TTAmount] [money] NOT NULL,
[OverPayment] [bit] NOT NULL CONSTRAINT [DF_Table_1_OverPayment] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Table_1] ADD CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED ([LEID]) ON [PRIMARY]
GO
