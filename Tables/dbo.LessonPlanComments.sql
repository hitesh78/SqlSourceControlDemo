CREATE TABLE [dbo].[LessonPlanComments]
(
[CommentID] [int] NOT NULL IDENTITY(1, 1),
[LPID] [int] NOT NULL,
[TeacherID] [int] NOT NULL,
[DateCreated] [datetime] NOT NULL,
[DateLastEdited] [datetime] NULL,
[CommentText] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TeacherHasRead] [bit] NOT NULL CONSTRAINT [DF_LessonPlanComments_TeacherHasRead] DEFAULT ((0)),
[AdminHasRead] [bit] NOT NULL CONSTRAINT [DF_LessonPlanComments_AdminHasRead] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LessonPlanComments] ADD CONSTRAINT [PK_LessonPlanComments] PRIMARY KEY CLUSTERED ([CommentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LessonPlanComments] ADD CONSTRAINT [FK_LessonPlanComments_LessonPlans] FOREIGN KEY ([LPID]) REFERENCES [dbo].[LessonPlans] ([LPID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonPlanComments] ADD CONSTRAINT [FK_LessonPlanComments_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID])
GO
