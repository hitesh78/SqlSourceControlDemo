CREATE TABLE [dbo].[CalendarEventRepeatBlocked]
(
[CalendarEventRepeatBlockedId] [int] NOT NULL IDENTITY(1, 1),
[CalendarEventRepeatId] [int] NOT NULL,
[BlockedDate] [datetime] NOT NULL,
[ActiveInd] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarEventRepeatBlocked] ADD CONSTRAINT [PK_CalendarEventRepeatBlocked] PRIMARY KEY CLUSTERED ([CalendarEventRepeatBlockedId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CalendarEventRepeatId] ON [dbo].[CalendarEventRepeatBlocked] ([CalendarEventRepeatId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarEventRepeatBlocked] ADD CONSTRAINT [FK_CalendarEventRepeatBlocked_CalendarEventRepeat] FOREIGN KEY ([CalendarEventRepeatId]) REFERENCES [dbo].[CalendarEventRepeat] ([CalendarEventRepeatId])
GO
