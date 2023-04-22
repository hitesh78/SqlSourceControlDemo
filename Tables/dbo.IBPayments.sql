CREATE TABLE [dbo].[IBPayments]
(
[PSPaymentID] [bigint] NOT NULL,
[PSAccountID] [int] NOT NULL,
[PSAmount] [money] NOT NULL CONSTRAINT [DF_IBPayments_PSAmount] DEFAULT ((0.00)),
[PSIsDebit] [bit] NOT NULL CONSTRAINT [DF_IBPayments_PSIsDebit] DEFAULT ((0)),
[PSReferenceID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLatitude] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLongitude] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSStatus] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSRecurringScheduleID] [bigint] NULL,
[PSPaymentType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSPaymentSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSProviderAuthCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSTraceNumber] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSPaymentDate] [datetime] NULL,
[PSReturnDate] [datetime] NULL,
[PSEstimatedSettleDate] [datetime] NULL,
[PSActualSettledDate] [datetime] NULL,
[PSCanVoidUntil] [datetime] NULL,
[PSInvoiceID] [bigint] NULL,
[PSInvoiceNumber] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSOrderID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLastModified] [datetime] NULL,
[PSCreatedOn] [datetime] NULL,
[PSCVV] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSErrorCode] [int] NULL,
[PSErrorDescription] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSMerchantActionText] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSIsDecline] [bit] NULL,
[GLPSCustomerID] [int] NOT NULL,
[GLCreatingUserID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBPayments] ADD CONSTRAINT [PK_IBPayments] PRIMARY KEY CLUSTERED ([PSPaymentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
