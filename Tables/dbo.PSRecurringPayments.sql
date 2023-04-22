CREATE TABLE [dbo].[PSRecurringPayments]
(
[PaymentPlanID] [int] NOT NULL,
[CustomerId] [int] NOT NULL,
[CustomerFirstName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerLastName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerCompany] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextScheduleDate] [datetime] NULL,
[BalanceRemaining] [money] NULL,
[NumberOfPaymentsRemaining] [int] NULL,
[PauseUntilDate] [datetime] NULL,
[PaymentAmount] [money] NOT NULL,
[FirstPaymentDone] [bit] NOT NULL,
[DateOfLastPaymentMade] [datetime] NULL,
[TotalAmountPaid] [money] NULL,
[NumberOfPaymentsMade] [int] NULL,
[TotalDueAmount] [money] NULL,
[TotalNumberOfPayments] [int] NULL,
[PaymentSubType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountId] [int] NULL,
[InvoiceNumber] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstPaymentAmount] [money] NULL,
[FirstPaymentDate] [datetime] NULL,
[StartDate] [datetime] NULL,
[ScheduleStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExecutionFrequencyType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExecutionFrequencyParameter] [int] NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL,
[CreatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSRecurringPayments] ADD CONSTRAINT [PK_PSRecurringPayments] PRIMARY KEY CLUSTERED ([PaymentPlanID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
