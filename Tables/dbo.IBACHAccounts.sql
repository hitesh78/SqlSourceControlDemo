CREATE TABLE [dbo].[IBACHAccounts]
(
[PSACHAccountID] [int] NOT NULL,
[PSACHBankName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSACHBankRoutingNumber] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSACHBankAccountNumber] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSACHDefaultACHAccount] [bit] NOT NULL CONSTRAINT [DF_IBACHAccounts_PSACHDefaultACHAccount] DEFAULT ((1)),
[PSACHAccountTypeID] [int] NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSLastModified] [datetime] NULL,
[PSCreatedOn] [datetime] NULL,
[GLDeletedFromPS] [bit] NOT NULL CONSTRAINT [DF_IBACHAccounts_GLDeletedFromPS] DEFAULT ((0)),
[GLIsDefaultPaymentMethod] [bit] NOT NULL CONSTRAINT [DF_IBACHAccounts_GLIsDefaultPaymentMethod] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBACHAccounts] ADD CONSTRAINT [PK_IBACHAccounts] PRIMARY KEY CLUSTERED ([PSACHAccountID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSACHAccountTypeID] ON [dbo].[IBACHAccounts] ([PSACHAccountTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBACHAccounts] ADD CONSTRAINT [FK_IBACHAccounts_PSACHAccountTypes] FOREIGN KEY ([PSACHAccountTypeID]) REFERENCES [dbo].[PSACHAccountTypes] ([PSACHAccountTypeID])
GO
