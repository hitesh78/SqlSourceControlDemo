CREATE TABLE [dbo].[EdfiPeriods]
(
[EdfiPeriodID] [int] NOT NULL IDENTITY(1, 1),
[EdfiPeriodDesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sessions] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Group] [int] NULL,
[Order] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdfiPeriods] ADD CONSTRAINT [PK_EdfiPeriods] PRIMARY KEY CLUSTERED ([EdfiPeriodID]) ON [PRIMARY]
GO
