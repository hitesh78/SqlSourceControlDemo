CREATE TABLE [dbo].[PSCCAccounts]
(
[PSCCAccountID] [int] NOT NULL,
[PSCCNumber] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSCCExpDateMonth] [int] NULL,
[PSCCExpDateYear] [int] NULL,
[PSCCBillingPostalCode] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSCCDefaultCCAccount] [bit] NOT NULL CONSTRAINT [DF_PSCCAccounts_PSCCDefaultAccount] DEFAULT ((1)),
[PSCCTypeID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSLastModified] [datetime] NULL,
[PSCreatedOn] [datetime] NULL,
[GLCVV2Code] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCCAccounts] ADD CONSTRAINT [PK_PSCCAccounts] PRIMARY KEY CLUSTERED ([PSCCAccountID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSCCTypeID] ON [dbo].[PSCCAccounts] ([PSCCTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSCustomerID] ON [dbo].[PSCCAccounts] ([PSCustomerID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCCAccounts] ADD CONSTRAINT [FK_PSCCAccounts_PSCCCardTypes] FOREIGN KEY ([PSCCTypeID]) REFERENCES [dbo].[PSCCCardTypes] ([PSCCTypeID])
GO
ALTER TABLE [dbo].[PSCCAccounts] ADD CONSTRAINT [FK_PSCCAccounts_PSCustomers] FOREIGN KEY ([PSCustomerID]) REFERENCES [dbo].[PSCustomers] ([PSCustomerID])
GO
