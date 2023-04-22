CREATE TABLE [dbo].[StudentRace]
(
[StudentID] [int] NOT NULL,
[RaceID] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RaceID] ON [dbo].[StudentRace] ([RaceID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[StudentRace] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StudentRace] ON [dbo].[StudentRace] ([StudentID], [RaceID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentRace] ADD CONSTRAINT [FK_StudentRace_Race] FOREIGN KEY ([RaceID]) REFERENCES [dbo].[Race] ([RaceID])
GO
ALTER TABLE [dbo].[StudentRace] ADD CONSTRAINT [FK_StudentRace_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO
