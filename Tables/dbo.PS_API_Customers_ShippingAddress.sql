CREATE TABLE [dbo].[PS_API_Customers_ShippingAddress]
(
[StreetAddress1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StreetAddress2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateCode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PS_API_Customers_Id] [int] NULL,
[CustomerID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
