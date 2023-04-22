CREATE TABLE [dbo].[AssignmentCollectionStandards]
(
[ACSID] [int] NOT NULL IDENTITY(1, 1),
[ACID] [int] NOT NULL,
[StandardID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollectionStandards] ADD CONSTRAINT [PK_AssignmentCollectionStandards] PRIMARY KEY CLUSTERED ([ACSID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollectionStandards] ADD CONSTRAINT [FK_AssignmentCollectionStandards_AssignmentCollections] FOREIGN KEY ([ACID]) REFERENCES [dbo].[AssignmentCollections] ([ACID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentCollectionStandards] ADD CONSTRAINT [FK_AssignmentCollectionStandards_Standards] FOREIGN KEY ([StandardID]) REFERENCES [dbo].[Standards] ([ID]) ON UPDATE CASCADE
GO
