CREATE TABLE [dbo].[PaymentPlans]
(
[PaymentPlanID] [int] NOT NULL IDENTITY(1, 1),
[SessionID] [int] NOT NULL,
[Title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PaymentPlans_Title] DEFAULT (''),
[TotalAmount] AS (((((((((((isnull([Amount1],(0.00))+isnull([Amount2],(0.00)))+isnull([Amount3],(0.00)))+isnull([Amount4],(0.00)))+isnull([Amount5],(0.00)))+isnull([Amount6],(0.00)))+isnull([Amount7],(0.00)))+isnull([Amount8],(0.00)))+isnull([Amount9],(0.00)))+isnull([Amount10],(0.00)))+isnull([Amount11],(0.00)))+isnull([Amount12],(0.00))),
[Date1] [date] NOT NULL,
[Amount1] [money] NOT NULL,
[Date2] [date] NULL,
[Amount2] [money] NULL,
[Date3] [date] NULL,
[Amount3] [money] NULL,
[Date4] [date] NULL,
[Amount4] [money] NULL,
[Date5] [date] NULL,
[Amount5] [money] NULL,
[Date6] [date] NULL,
[Amount6] [money] NULL,
[Date7] [date] NULL,
[Amount7] [money] NULL,
[Date8] [date] NULL,
[Amount8] [money] NULL,
[Date9] [date] NULL,
[Amount9] [money] NULL,
[Date10] [date] NULL,
[Amount10] [money] NULL,
[Date11] [date] NULL,
[Amount11] [money] NULL,
[Date12] [date] NULL,
[Amount12] [money] NULL,
[DescPrefix1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix1] DEFAULT (''),
[DescPrefix2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix2] DEFAULT (''),
[DescPrefix3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix3] DEFAULT (''),
[DescPrefix4] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix4] DEFAULT (''),
[DescPrefix5] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix5] DEFAULT (''),
[DescPrefix6] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix6] DEFAULT (''),
[DescPrefix7] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix7] DEFAULT (''),
[DescPrefix8] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix8] DEFAULT (''),
[DescPrefix9] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix9] DEFAULT (''),
[DescPrefix10] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix10] DEFAULT (''),
[DescPrefix11] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix11] DEFAULT (''),
[DescPrefix12] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PaymentPlans_DescPrefix12] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaymentPlans] ADD CONSTRAINT [PK_PaymentPlans] PRIMARY KEY CLUSTERED ([PaymentPlanID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SessionID] ON [dbo].[PaymentPlans] ([SessionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaymentPlans] ADD CONSTRAINT [FK_PaymentPlans_Session] FOREIGN KEY ([SessionID]) REFERENCES [dbo].[Session] ([SessionID])
GO
