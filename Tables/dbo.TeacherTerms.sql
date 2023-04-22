CREATE TABLE [dbo].[TeacherTerms]
(
[TTID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NOT NULL,
[TermID] [int] NOT NULL,
[CalendarView] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TeacherTerms_CalendarView] DEFAULT ('weekView'),
[Tab1Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab1Active] DEFAULT ((1)),
[Tab1Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab1Name] DEFAULT ('Lesson'),
[Tab2Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab2Active] DEFAULT ((1)),
[Tab2Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab2Name] DEFAULT ('Objectives'),
[Tab3Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab3Active] DEFAULT ((1)),
[Tab3Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab3Name] DEFAULT ('Plan'),
[Tab4Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab4Active] DEFAULT ((1)),
[Tab4Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab4Name] DEFAULT ('Notes'),
[Tab5Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab5Active] DEFAULT ((1)),
[Tab5Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab5Name] DEFAULT ('Materials'),
[Tab6Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab6Active] DEFAULT ((0)),
[Tab6Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab7Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab7Active] DEFAULT ((0)),
[Tab7Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab8Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab8Active] DEFAULT ((0)),
[Tab8Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab9Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab9Active] DEFAULT ((1)),
[Tab9Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab9Name] DEFAULT ('Assignments'),
[Tab10Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab10Active] DEFAULT ((0)),
[Tab10Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab10Name] DEFAULT ('Standards'),
[Tab11Active] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_Tab11Active] DEFAULT ((1)),
[Tab11Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TeacherTerms_Tab11Name] DEFAULT ('Attachments'),
[MVDisplayTab1] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab1] DEFAULT ((1)),
[MVDisplayTab2] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab2] DEFAULT ((1)),
[MVDisplayTab3] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab3] DEFAULT ((1)),
[MVDisplayTab4] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab4] DEFAULT ((1)),
[MVDisplayTab5] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab5] DEFAULT ((1)),
[MVDisplayTab6] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab6] DEFAULT ((1)),
[MVDisplayTab7] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab7] DEFAULT ((1)),
[MVDisplayTab8] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab8] DEFAULT ((1)),
[MVDisplayTab9] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab9] DEFAULT ((1)),
[MVDisplayTab10] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab10] DEFAULT ((1)),
[MVDisplayTab11] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_MVDisplayTab11] DEFAULT ((0)),
[WVDisplayTab1] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab1] DEFAULT ((1)),
[WVDisplayTab2] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab2] DEFAULT ((1)),
[WVDisplayTab3] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab3] DEFAULT ((1)),
[WVDisplayTab4] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab4] DEFAULT ((1)),
[WVDisplayTab5] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab5] DEFAULT ((1)),
[WVDisplayTab6] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab6] DEFAULT ((1)),
[WVDisplayTab7] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab7] DEFAULT ((1)),
[WVDisplayTab8] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab8] DEFAULT ((1)),
[WVDisplayTab9] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab9] DEFAULT ((1)),
[WVDisplayTab10] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab10] DEFAULT ((1)),
[WVDisplayTab11] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_WVDisplayTab11] DEFAULT ((0)),
[DVDisplayTab1] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab1] DEFAULT ((1)),
[DVDisplayTab2] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab2] DEFAULT ((1)),
[DVDisplayTab3] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab3] DEFAULT ((1)),
[DVDisplayTab4] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab4] DEFAULT ((1)),
[DVDisplayTab5] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab5] DEFAULT ((1)),
[DVDisplayTab6] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab6] DEFAULT ((1)),
[DVDisplayTab7] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab7] DEFAULT ((1)),
[DVDisplayTab8] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab8] DEFAULT ((1)),
[DVDisplayTab9] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab9] DEFAULT ((1)),
[DVDisplayTab10] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab10] DEFAULT ((1)),
[DVDisplayTab11] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_DVDisplayTab11] DEFAULT ((0)),
[LVDisplayTab1] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab1] DEFAULT ((1)),
[LVDisplayTab2] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab2] DEFAULT ((1)),
[LVDisplayTab3] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab3] DEFAULT ((1)),
[LVDisplayTab4] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab4] DEFAULT ((1)),
[LVDisplayTab5] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab5] DEFAULT ((1)),
[LVDisplayTab6] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab6] DEFAULT ((1)),
[LVDisplayTab7] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab7] DEFAULT ((1)),
[LVDisplayTab8] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab8] DEFAULT ((1)),
[LVDisplayTab9] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab9] DEFAULT ((1)),
[LVDisplayTab10] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab10] DEFAULT ((1)),
[LVDisplayTab11] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_LVDisplayTab11] DEFAULT ((1)),
[CVDisplayTab1] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab1] DEFAULT ((1)),
[CVDisplayTab2] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab2] DEFAULT ((1)),
[CVDisplayTab3] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab3] DEFAULT ((1)),
[CVDisplayTab4] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab4] DEFAULT ((1)),
[CVDisplayTab5] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab5] DEFAULT ((1)),
[CVDisplayTab6] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab6] DEFAULT ((1)),
[CVDisplayTab7] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab7] DEFAULT ((1)),
[CVDisplayTab8] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab8] DEFAULT ((1)),
[CVDisplayTab9] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab9] DEFAULT ((1)),
[CVDisplayTab10] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab10] DEFAULT ((1)),
[CVDisplayTab11] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_CVDisplayTab11] DEFAULT ((1)),
[ShowWeekDaySunday] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_ShowWeekDaySunday] DEFAULT ((0)),
[ShowWeekDayMonday] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_ShowWeekDayMonday] DEFAULT ((1)),
[ShowWeekDayTuesday] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_ShowWeekDayTuesday] DEFAULT ((1)),
[ShowWeekDayWednesday] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_ShowWeekDayWednesday] DEFAULT ((1)),
[ShowWeekDayThursday] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_ShowWeekDayThursday] DEFAULT ((1)),
[ShowWeekDayFriday] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_ShowWeekDayFriday] DEFAULT ((1)),
[ShowWeekDaySaturday] [bit] NOT NULL CONSTRAINT [DF_TeacherTerms_ShowWeekDaySaturday] DEFAULT ((0)),
[CalendarDisplayClasses] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdminCalendarDisplayClasses] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TeacherTerms] ADD CONSTRAINT [PK_TeacherTerms] PRIMARY KEY CLUSTERED ([TTID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TeacherTerms] ADD CONSTRAINT [ForceUniqueTeacherTermRecords] UNIQUE NONCLUSTERED ([TeacherID], [TermID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TeacherTerms] ADD CONSTRAINT [FK_TeacherTerms_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TeacherTerms] ADD CONSTRAINT [FK_TeacherTerms_Terms] FOREIGN KEY ([TermID]) REFERENCES [dbo].[Terms] ([TermID]) ON DELETE CASCADE
GO