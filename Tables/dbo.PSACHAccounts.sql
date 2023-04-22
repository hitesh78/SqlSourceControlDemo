CREATE TABLE [dbo].[PSACHAccounts]
(
[PSACHAccountID] [int] NOT NULL,
[PSACHBankName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSACHBankRoutingNumber] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSACHBankAccountNumber] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSACHDefaultACHAccount] [bit] NOT NULL CONSTRAINT [DF_PSACHAccounts_PSACHDefaultACHAccount] DEFAULT ((1)),
[PSACHAccountTypeID] [int] NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSLastModified] [datetime] NULL,
[PSCreatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSACHAccounts] ADD CONSTRAINT [PK_PSACHAccounts] PRIMARY KEY CLUSTERED ([PSACHAccountID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSACHAccountTypeID] ON [dbo].[PSACHAccounts] ([PSACHAccountTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSCustomerID] ON [dbo].[PSACHAccounts] ([PSCustomerID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSACHAccounts] ADD CONSTRAINT [FK_PSACHAccounts_PSACHAccountTypes] FOREIGN KEY ([PSACHAccountTypeID]) REFERENCES [dbo].[PSACHAccountTypes] ([PSACHAccountTypeID])
GO
ALTER TABLE [dbo].[PSACHAccounts] ADD CONSTRAINT [FK_PSACHAccounts_PSCustomers] FOREIGN KEY ([PSCustomerID]) REFERENCES [dbo].[PSCustomers] ([PSCustomerID])
GO
