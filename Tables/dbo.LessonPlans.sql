CREATE TABLE [dbo].[LessonPlans]
(
[LPID] [int] NOT NULL IDENTITY(1, 1),
[TTID] [int] NOT NULL,
[ClassID] [int] NOT NULL,
[Title] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[theDate] [date] NOT NULL,
[Tab1Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab2Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab3Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab4Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab5Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab6Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab7Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tab8Content] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LessonPlans] ADD CONSTRAINT [PK_LessonPlans] PRIMARY KEY CLUSTERED ([LPID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LessonPlans] ADD CONSTRAINT [FK_LessonPlans_Classes] FOREIGN KEY ([ClassID]) REFERENCES [dbo].[Classes] ([ClassID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonPlans] ADD CONSTRAINT [FK_LessonPlans_TeacherTerms] FOREIGN KEY ([TTID]) REFERENCES [dbo].[TeacherTerms] ([TTID])
GO
