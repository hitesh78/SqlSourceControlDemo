CREATE TABLE [dbo].[EdFiCalendarEvents]
(
[EventID] [int] NOT NULL IDENTITY(1, 1),
[CalendarEvent] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventTypeID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdFiCalendarEvents] ADD CONSTRAINT [PK_EdFiCalendarEvents] PRIMARY KEY CLUSTERED ([EventID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdFiCalendarEvents] ADD CONSTRAINT [FK_EdFiCalendarEvents_EdFiEventTypes] FOREIGN KEY ([EventTypeID]) REFERENCES [dbo].[EdFiEventTypes] ([EventTypeID])
GO
