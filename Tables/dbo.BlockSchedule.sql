CREATE TABLE [dbo].[BlockSchedule]
(
[BlockSchedID] [int] NOT NULL IDENTITY(1, 1),
[SessionID] [int] NOT NULL,
[Title] [nchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Period] [int] NOT NULL,
[StartTime] [time] NULL,
[EndTime] [time] NULL,
[Sunday] [bit] NOT NULL,
[Monday] [bit] NOT NULL,
[Tuesday] [bit] NOT NULL,
[Wednesday] [bit] NOT NULL,
[Thursday] [bit] NOT NULL,
[Friday] [bit] NOT NULL,
[Saturday] [bit] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SessionID] ON [dbo].[BlockSchedule] ([SessionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BlockSchedule] ADD CONSTRAINT [FK_BlockSchedule_Session1] FOREIGN KEY ([SessionID]) REFERENCES [dbo].[Session] ([SessionID])
GO
