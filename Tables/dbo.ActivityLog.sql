CREATE TABLE [dbo].[ActivityLog]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[ClassID] [int] NOT NULL,
[LogDate] [datetime] NOT NULL,
[TheWeekday] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Item] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BeforeChange] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AfterChange] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivityLog] ADD CONSTRAINT [PK_ActivityLog] PRIMARY KEY CLUSTERED ([LogID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassID] ON [dbo].[ActivityLog] ([ClassID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivityLog] ADD CONSTRAINT [FK_ActivityLog_Classes] FOREIGN KEY ([ClassID]) REFERENCES [dbo].[Classes] ([ClassID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
