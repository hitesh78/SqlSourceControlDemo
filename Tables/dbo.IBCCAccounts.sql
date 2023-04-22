CREATE TABLE [dbo].[IBCCAccounts]
(
[PSCCAccountID] [int] NOT NULL,
[PSCCNumber] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSCCExpDateMonth] [int] NULL,
[PSCCExpDateYear] [int] NULL,
[PSCCBillingPostalCode] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSCCDefaultCCAccount] [bit] NOT NULL CONSTRAINT [DF_IBCCAccounts_PSCCDefaultAccount] DEFAULT ((1)),
[PSCCTypeID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSLastModified] [datetime] NULL,
[PSCreatedOn] [datetime] NULL,
[GLCVV2Code] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLDeletedFromPS] [bit] NOT NULL CONSTRAINT [DF_IBCCAccounts_GLDeletedFromPS] DEFAULT ((0)),
[GLIsDefaultPaymentMethod] [bit] NOT NULL CONSTRAINT [DF_IBCCAccounts_GLIsDefaultPaymentMethod] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBCCAccounts] ADD CONSTRAINT [PK_IBCCAccounts] PRIMARY KEY CLUSTERED ([PSCCAccountID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSCCTypeID] ON [dbo].[IBCCAccounts] ([PSCCTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBCCAccounts] ADD CONSTRAINT [FK_IBCCAccounts_PSCCCardTypes] FOREIGN KEY ([PSCCTypeID]) REFERENCES [dbo].[PSCCCardTypes] ([PSCCTypeID])
GO
