CREATE TABLE [dbo].[IBCustomRecurringFees]
(
[IBFeeID] [int] NOT NULL IDENTITY(1, 1),
[IBConfigurationID] [int] NOT NULL CONSTRAINT [DF_IBCustomRecurringFees_IBConfigurationID] DEFAULT ((1)),
[IBFeeDescription] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBFeeStartDate] [datetime] NULL,
[IBFeeEndDate] [datetime] NULL,
[IBFeeFrequencyID] [int] NULL CONSTRAINT [DF_IBCustomRecurringFees_IBFeeFrequencyID] DEFAULT ((6)),
[IBWeeklyBillingDayOfWeekID] [int] NULL,
[IBMonthlyBillingDayOfMonth] [int] NULL,
[IBFeeAmount] [decimal] (15, 5) NULL,
[PSScheduleID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBCustomRecurringFees] ADD CONSTRAINT [PK_IBCustomRecurringFees] PRIMARY KEY CLUSTERED ([IBFeeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
