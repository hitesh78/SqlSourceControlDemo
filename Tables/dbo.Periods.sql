CREATE TABLE [dbo].[Periods]
(
[PeriodID] [int] NOT NULL IDENTITY(1, 1),
[PeriodOrder] [smallint] NOT NULL,
[PeriodSymbol] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PeriodDescription] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PeriodStartTime] [time] (0) NOT NULL,
[PeriodEndTime] [time] (0) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Periods] ADD CONSTRAINT [PK_Periods] PRIMARY KEY CLUSTERED ([PeriodID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
