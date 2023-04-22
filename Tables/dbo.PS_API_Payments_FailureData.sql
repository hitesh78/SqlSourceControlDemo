CREATE TABLE [dbo].[PS_API_Payments_FailureData]
(
[Code] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MerchantActionText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDecline] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PS_API_Payments_Id] [int] NULL,
[PaymentID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
