CREATE TABLE [dbo].[PSPaymentPlans]
(
[PSPaymentPlanId] [int] NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSAccountID] [int] NOT NULL,
[ACHorCC] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PaymentsAmount] [money] NOT NULL,
[ConvenienceFeeRate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalDueAmount] [money] NOT NULL,
[StartDate] [date] NOT NULL,
[ExecutionFrequencyType] [int] NOT NULL,
[ExecutionFrequencyParameter] [int] NULL,
[TotalNumberOfPayments] [int] NOT NULL,
[FirstPaymentDate] [date] NOT NULL,
[FirstPaymentAmount] [money] NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSPaymentPlans] ADD CONSTRAINT [PK_PSPaymentPlans] PRIMARY KEY CLUSTERED ([PSPaymentPlanId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
