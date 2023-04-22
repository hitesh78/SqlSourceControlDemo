CREATE TABLE [dbo].[IBOneTimeFees]
(
[IBOneTimeFeeID] [int] NOT NULL IDENTITY(1, 1),
[IBConfigurationID] [int] NOT NULL CONSTRAINT [DF_IBOneTimeFees_IBConfigurationID] DEFAULT ((1)),
[IBOneTimeFeeName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBOneTimeFeeDescription] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBOneTimeFeeInvoiceDate] [datetime] NULL,
[IBOneTimeFeeAmount] [decimal] (15, 5) NOT NULL,
[IBPaymentID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBOneTimeFees] ADD CONSTRAINT [PK_IBOneTimeFees] PRIMARY KEY CLUSTERED ([IBOneTimeFeeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
