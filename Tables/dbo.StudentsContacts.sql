CREATE TABLE [dbo].[StudentsContacts]
(
[StudentID] [int] NOT NULL,
[ContactID] [int] NOT NULL,
[Relationship] [nvarchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FamilyID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentsContacts] ADD CONSTRAINT [PK_StudentsContacts] PRIMARY KEY CLUSTERED ([StudentID], [ContactID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentsContacts] ADD CONSTRAINT [FK_StudentsContacts_Families] FOREIGN KEY ([FamilyID]) REFERENCES [dbo].[Families] ([FamilyID])
GO
ALTER TABLE [dbo].[StudentsContacts] ADD CONSTRAINT [FK_StudentsContacts_StudentContacts] FOREIGN KEY ([ContactID]) REFERENCES [dbo].[StudentContacts] ([ContactID])
GO
ALTER TABLE [dbo].[StudentsContacts] ADD CONSTRAINT [FK_StudentsContacts_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
