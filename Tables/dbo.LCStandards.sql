CREATE TABLE [dbo].[LCStandards]
(
[LCSID] [int] NOT NULL IDENTITY(1, 1),
[LCID] [int] NOT NULL,
[StandardID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCStandards] ADD CONSTRAINT [PK_LCStandards] PRIMARY KEY CLUSTERED ([LCSID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCStandards] ADD CONSTRAINT [FK_LCStandards_LessonPlanCollections] FOREIGN KEY ([LCID]) REFERENCES [dbo].[LessonPlanCollections] ([LCID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LCStandards] ADD CONSTRAINT [FK_LCStandards_Standards] FOREIGN KEY ([StandardID]) REFERENCES [dbo].[Standards] ([ID])
GO
