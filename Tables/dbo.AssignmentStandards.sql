CREATE TABLE [dbo].[AssignmentStandards]
(
[ASID] [int] NOT NULL IDENTITY(1, 1),
[AssignmentID] [int] NOT NULL,
[StandardID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentStandards] ADD CONSTRAINT [PK_AssignmentStandards] PRIMARY KEY CLUSTERED ([ASID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AssignmentID] ON [dbo].[AssignmentStandards] ([AssignmentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StandardID] ON [dbo].[AssignmentStandards] ([StandardID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentStandards] ADD CONSTRAINT [FK_AssignmentStandards_Assignments] FOREIGN KEY ([AssignmentID]) REFERENCES [dbo].[Assignments] ([AssignmentID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentStandards] ADD CONSTRAINT [FK_AssignmentStandards_Standards] FOREIGN KEY ([StandardID]) REFERENCES [dbo].[Standards] ([ID]) ON UPDATE CASCADE
GO
