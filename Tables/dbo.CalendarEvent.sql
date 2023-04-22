CREATE TABLE [dbo].[CalendarEvent]
(
[CalendarEventId] [int] NOT NULL IDENTITY(1, 1),
[CalendarId] [int] NOT NULL,
[CalendarEventTypeId] [int] NOT NULL,
[Title] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Url] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllDayInd] [bit] NOT NULL,
[ShareTypeId] [int] NOT NULL,
[StartDttm] [datetime] NOT NULL,
[EndDttm] [datetime] NOT NULL,
[CreatedById] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDttm] [datetime] NOT NULL,
[LastEditedById] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastEditedDttm] [datetime] NOT NULL,
[ActiveInd] [bit] NOT NULL,
[RowVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarEvent] ADD CONSTRAINT [PK_dbo.CalendarEvent] PRIMARY KEY CLUSTERED ([CalendarEventId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CalendarEventTypeId] ON [dbo].[CalendarEvent] ([CalendarEventTypeId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CalendarId] ON [dbo].[CalendarEvent] ([CalendarId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarEvent] ADD CONSTRAINT [FK_CalendarEvent_Accounts2] FOREIGN KEY ([LastEditedById]) REFERENCES [dbo].[Accounts] ([AccountID]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CalendarEvent] ADD CONSTRAINT [FK_CalendarEvent_Calendar] FOREIGN KEY ([CalendarId]) REFERENCES [dbo].[Calendar] ([CalendarId])
GO
ALTER TABLE [dbo].[CalendarEvent] ADD CONSTRAINT [FK_CalendarEvent_CalendarEventType] FOREIGN KEY ([CalendarEventTypeId]) REFERENCES [dbo].[CalendarEventType] ([CalendarEventTypeId])
GO
