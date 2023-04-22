CREATE TABLE [dbo].[EnrollmentPrograms]
(
[EnrollmentProgramID] [int] NOT NULL IDENTITY(1, 1),
[SessionID] [int] NOT NULL,
[EnrollmentProgram] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnrollmentPrograms] ADD CONSTRAINT [PK_EnrollmentPrograms] PRIMARY KEY CLUSTERED ([EnrollmentProgramID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SessionID] ON [dbo].[EnrollmentPrograms] ([SessionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnrollmentPrograms] ADD CONSTRAINT [FK_EnrollmentPrograms_Session] FOREIGN KEY ([SessionID]) REFERENCES [dbo].[Session] ([SessionID])
GO
