CREATE TABLE [dbo].[AssignmentCollectionTags]
(
[TagID] [int] NOT NULL IDENTITY(1, 1),
[ACID] [int] NOT NULL,
[TagTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollectionTags] ADD CONSTRAINT [PK_AssignmentCollectionTags] PRIMARY KEY CLUSTERED ([TagID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollectionTags] ADD CONSTRAINT [FK_AssignmentCollectionTags_AssignmentCollections] FOREIGN KEY ([ACID]) REFERENCES [dbo].[AssignmentCollections] ([ACID]) ON DELETE CASCADE
GO
