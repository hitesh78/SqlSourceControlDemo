CREATE TABLE [dbo].[TeacherRace]
(
[TeacherID] [int] NOT NULL,
[RaceID] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RaceID] ON [dbo].[TeacherRace] ([RaceID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TeacherID] ON [dbo].[TeacherRace] ([TeacherID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TeacherRace] ON [dbo].[TeacherRace] ([TeacherID], [RaceID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TeacherRace] ADD CONSTRAINT [FK_TeacherRace_Race] FOREIGN KEY ([RaceID]) REFERENCES [dbo].[Race] ([RaceID])
GO
ALTER TABLE [dbo].[TeacherRace] ADD CONSTRAINT [FK_TeacherRace_Teachers] FOREIGN KEY ([TeacherID]) REFERENCES [dbo].[Teachers] ([TeacherID]) ON DELETE CASCADE
GO
