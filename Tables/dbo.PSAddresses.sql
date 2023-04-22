CREATE TABLE [dbo].[PSAddresses]
(
[AddressID] [int] NOT NULL IDENTITY(1, 1),
[AddressLine1] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine2] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateAbbreviation] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressTypeID] [int] NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSCountryCode] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSAddresses] ADD CONSTRAINT [PK_PSAddresses] PRIMARY KEY CLUSTERED ([AddressID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AddressTypeID] ON [dbo].[PSAddresses] ([AddressTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSCustomerID] ON [dbo].[PSAddresses] ([PSCustomerID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StateAbbreviation] ON [dbo].[PSAddresses] ([StateAbbreviation]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSAddresses] ADD CONSTRAINT [FK_PSAddresses_PSAddressTypes] FOREIGN KEY ([AddressTypeID]) REFERENCES [dbo].[PSAddressTypes] ([AddressTypeID])
GO
ALTER TABLE [dbo].[PSAddresses] ADD CONSTRAINT [FK_PSAddresses_PSCustomers] FOREIGN KEY ([PSCustomerID]) REFERENCES [dbo].[PSCustomers] ([PSCustomerID])
GO
ALTER TABLE [dbo].[PSAddresses] ADD CONSTRAINT [FK_PSAddresses_PSStates] FOREIGN KEY ([StateAbbreviation]) REFERENCES [dbo].[PSStates] ([StateAbbreviation])
GO
