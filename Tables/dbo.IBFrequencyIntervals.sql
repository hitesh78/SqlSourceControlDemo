CREATE TABLE [dbo].[IBFrequencyIntervals]
(
[IBFrequencyID] [int] NOT NULL IDENTITY(1, 1),
[IBFrequencyDescription] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBFrequencyAnnualPayments] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBFrequencyIntervals] ADD CONSTRAINT [PK_IBFrequencyIntervals] PRIMARY KEY CLUSTERED ([IBFrequencyID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
