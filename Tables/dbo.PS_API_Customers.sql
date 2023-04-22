CREATE TABLE [dbo].[PS_API_Customers]
(
[MiddleName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltPhone] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobilePhone] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Website] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PS_API_Customers_Id] [int] NULL,
[BillingAddress] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingSameAsBilling] [bit] NULL,
[ShippingAddress] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerAccount] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueID] [int] NOT NULL IDENTITY(1, 1),
[UpdateTime] [datetime] NULL CONSTRAINT [DF_PS_API_Customers_UpdateTime] DEFAULT (getdate())
) ON [PRIMARY]
GO
