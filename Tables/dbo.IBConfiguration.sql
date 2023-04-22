CREATE TABLE [dbo].[IBConfiguration]
(
[IBConfigurationID] [int] NOT NULL,
[ManualStudentCount] [int] NULL,
[ManualStudentCountLastUpdated] [datetime] NULL,
[CurrentPriceBracketID] [int] NULL CONSTRAINT [DF_IBConfiguration_CurrentPriceBracketID] DEFAULT ((1)),
[BillingStartDate] [datetime] NULL,
[DiscountAmount] [decimal] (15, 5) NULL,
[DiscountExpiration] [datetime] NULL,
[BillingFrequencyID] [int] NULL CONSTRAINT [DF_IBConfiguration_BillingFrequencyID] DEFAULT ((6)),
[WeeklyBillingDayOfWeekID] [int] NULL,
[MonthlyBillingDayOfMonth] [int] NULL,
[AdHocPaymentsEnabled] [bit] NOT NULL CONSTRAINT [DF_IBConfiguration_AdHocPaymentsEnabled] DEFAULT ((0)),
[ConfigurationIsSuspended] [bit] NOT NULL CONSTRAINT [DF_IBConfiguration_ConfigurationIsSuspended] DEFAULT ((0)),
[Notes] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StandardServicePSScheduleID] [int] NULL,
[StandardServicePSDiscountScheduleID] [int] NULL,
[EULADateAgreed] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBConfiguration] ADD CONSTRAINT [PK_IBConfiguration] PRIMARY KEY CLUSTERED ([IBConfigurationID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
