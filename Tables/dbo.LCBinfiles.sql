CREATE TABLE [dbo].[LCBinfiles]
(
[LCBinfilesID] [int] NOT NULL IDENTITY(1, 1),
[LCID] [int] NOT NULL,
[FileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCBinfiles] ADD CONSTRAINT [PK_LCBinfiles] PRIMARY KEY CLUSTERED ([LCBinfilesID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCBinfiles] ADD CONSTRAINT [FK_LCBinfiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID])
GO
ALTER TABLE [dbo].[LCBinfiles] ADD CONSTRAINT [FK_LCBinfiles_LessonPlanCollections] FOREIGN KEY ([LCID]) REFERENCES [dbo].[LessonPlanCollections] ([LCID]) ON DELETE CASCADE
GO
