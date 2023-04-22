CREATE TABLE [dbo].[LessonPlanBinFiles]
(
[LPFID] [int] NOT NULL IDENTITY(1, 1),
[LPID] [int] NOT NULL,
[FileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LessonPlanBinFiles] ADD CONSTRAINT [PK_LessonPlanBinFiles] PRIMARY KEY CLUSTERED ([LPFID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LessonPlanBinFiles] ADD CONSTRAINT [FK_LessonPlanBinFiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID])
GO
ALTER TABLE [dbo].[LessonPlanBinFiles] ADD CONSTRAINT [FK_LessonPlanBinFiles_LessonPlans] FOREIGN KEY ([LPID]) REFERENCES [dbo].[LessonPlans] ([LPID]) ON DELETE CASCADE
GO
