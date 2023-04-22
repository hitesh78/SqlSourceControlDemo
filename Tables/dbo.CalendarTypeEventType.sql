CREATE TABLE [dbo].[CalendarTypeEventType]
(
[CalendarTypeEventTypeId] [int] NOT NULL IDENTITY(1, 1),
[CalendarTypeId] [int] NOT NULL,
[CalendarEventTypeId] [int] NOT NULL,
[ActiveInd] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarTypeEventType] ADD CONSTRAINT [PK_dbo.CalendarTypeEventType] PRIMARY KEY CLUSTERED ([CalendarTypeEventTypeId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CalendarEventTypeId] ON [dbo].[CalendarTypeEventType] ([CalendarEventTypeId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarTypeEventType] ADD CONSTRAINT [FK_CalendarTypeEventType_CalendarEventType] FOREIGN KEY ([CalendarEventTypeId]) REFERENCES [dbo].[CalendarEventType] ([CalendarEventTypeId])
GO
