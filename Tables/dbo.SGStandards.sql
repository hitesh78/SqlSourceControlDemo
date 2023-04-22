CREATE TABLE [dbo].[SGStandards]
(
[SGStandards] [int] NOT NULL IDENTITY(1, 1),
[SGID] [int] NOT NULL,
[StandardID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SGStandards] ADD CONSTRAINT [PK_SGStandards] PRIMARY KEY CLUSTERED ([SGStandards]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SGID] ON [dbo].[SGStandards] ([SGID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StandardID] ON [dbo].[SGStandards] ([StandardID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SGStandards] ADD CONSTRAINT [FK_SGStandards_Standards] FOREIGN KEY ([StandardID]) REFERENCES [dbo].[Standards] ([ID]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[SGStandards] ADD CONSTRAINT [FK_SGStandards_StandardsGroups] FOREIGN KEY ([SGID]) REFERENCES [dbo].[StandardsGroups] ([SGID]) ON DELETE CASCADE
GO
