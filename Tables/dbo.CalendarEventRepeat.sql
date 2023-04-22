CREATE TABLE [dbo].[CalendarEventRepeat]
(
[CalendarEventRepeatId] [int] NOT NULL IDENTITY(1, 1),
[CalendarEventId] [int] NOT NULL,
[FrequencyTypeId] [int] NULL,
[FrequencyNumber] [int] NULL,
[FrequencyDay] [int] NULL,
[FrequencyDayOrdinal] [int] NULL,
[AdvancedFrequencySelection] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RepeatStopTypeId] [int] NULL,
[RepeatOccurrenceNumber] [int] NULL,
[RepeatStopDate] [datetime] NULL,
[ActiveInd] [bit] NULL,
[freq] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtstart] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interval] [int] NULL,
[wkst] [int] NULL,
[count] [int] NULL,
[bysetpos] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bymonth] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bymonthday] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[byyearday] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[byweekday] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[byweekno] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[byhour] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[byminute] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[until] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarEventRepeat] ADD CONSTRAINT [PK_CalendarEventRepeat] PRIMARY KEY CLUSTERED ([CalendarEventRepeatId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CalendarEventId] ON [dbo].[CalendarEventRepeat] ([CalendarEventId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarEventRepeat] ADD CONSTRAINT [FK_CalendarEventRepeat_CalendarEvent] FOREIGN KEY ([CalendarEventId]) REFERENCES [dbo].[CalendarEvent] ([CalendarEventId])
GO
