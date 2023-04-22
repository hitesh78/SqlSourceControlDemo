CREATE TABLE [dbo].[PSAddressTypes]
(
[AddressTypeID] [int] NOT NULL,
[AddressTypeName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSAddressTypes] ADD CONSTRAINT [PK_PSAddressTypes] PRIMARY KEY CLUSTERED ([AddressTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
