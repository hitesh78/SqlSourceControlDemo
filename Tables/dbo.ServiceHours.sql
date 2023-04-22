CREATE TABLE [dbo].[ServiceHours]
(
[SEID] [int] NOT NULL IDENTITY(1, 1),
[AccountID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeElapsed] [time] NOT NULL,
[SupervisorName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateSubmitted] [date] NOT NULL,
[DateApproved] [date] NULL,
[IsApproved] [bit] NULL,
[IsManualEntry] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ServiceHours] ADD CONSTRAINT [PK_ServiceHours] PRIMARY KEY CLUSTERED ([SEID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ServiceHours] ADD CONSTRAINT [FK_ServiceHours_Accounts] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Accounts] ([AccountID]) ON UPDATE CASCADE
GO
