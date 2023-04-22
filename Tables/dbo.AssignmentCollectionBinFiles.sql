CREATE TABLE [dbo].[AssignmentCollectionBinFiles]
(
[ACBID] [int] NOT NULL IDENTITY(1, 1),
[ACID] [int] NOT NULL,
[FileID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollectionBinFiles] ADD CONSTRAINT [PK_AssignmentCollectionBinFiles] PRIMARY KEY CLUSTERED ([ACBID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollectionBinFiles] ADD CONSTRAINT [ucACID_FileID] UNIQUE NONCLUSTERED ([ACID], [FileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollectionBinFiles] ADD CONSTRAINT [FK_AssignmentCollectionBinFiles_AssignmentCollections] FOREIGN KEY ([ACID]) REFERENCES [dbo].[AssignmentCollections] ([ACID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentCollectionBinFiles] ADD CONSTRAINT [FK_AssignmentCollectionBinFiles_BinFiles] FOREIGN KEY ([FileID]) REFERENCES [dbo].[BinFiles] ([FileID])
GO
