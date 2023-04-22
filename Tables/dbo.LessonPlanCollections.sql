CREATE TABLE [dbo].[LessonPlanCollections]
(
[LCID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NULL,
[Title] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
ALTER TABLE [dbo].[LessonPlanCollections] ADD CONSTRAINT [PK_LessonPlanCollections] PRIMARY KEY CLUSTERED ([LCID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LessonPlanCollections] ADD CONSTRAINT [FK_LessonPlanCollections_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID]) ON DELETE CASCADE
GO
