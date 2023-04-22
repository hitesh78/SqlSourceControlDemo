CREATE TABLE [dbo].[CustomTypeComments]
(
[CommentID] [int] NOT NULL IDENTITY(1, 1),
[ClassTypeID] [int] NOT NULL,
[CommentNumber] [int] NOT NULL,
[CommentDescription] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomTypeComments] ADD CONSTRAINT [PK_CustomTypeComments] PRIMARY KEY CLUSTERED ([CommentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassTypeID] ON [dbo].[CustomTypeComments] ([ClassTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomTypeComments] ADD CONSTRAINT [FK_CustomTypeComments_ClassType] FOREIGN KEY ([ClassTypeID]) REFERENCES [dbo].[ClassType] ([ClassTypeID]) ON DELETE CASCADE
GO
