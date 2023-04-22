CREATE TYPE [dbo].[PSPaymentsTableType] AS TABLE
(
[PSPaymentID] [bigint] NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSAccountID] [int] NOT NULL,
[PSAmount] [money] NOT NULL,
[PSIsDebit] [bit] NOT NULL,
[PSReferenceID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLatitude] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLongitude] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSStatus] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSRecurringScheduleID] [bigint] NULL,
[PSPaymentType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSPaymentSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSProviderAuthCode] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[PSIsDecline] [bit] NULL
)
GO