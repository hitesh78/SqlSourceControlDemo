CREATE TABLE [dbo].[Immunizations]
(
[ImmunizationID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[Immunization] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dose1date] [smalldatetime] NULL,
[dose2date] [smalldatetime] NULL,
[dose3date] [smalldatetime] NULL,
[dose4date] [smalldatetime] NULL,
[dose5date] [smalldatetime] NULL,
[dose6date] [smalldatetime] NULL,
[dose7date] [smalldatetime] NULL,
[dose8date] [smalldatetime] NULL,
[dose9date] [smalldatetime] NULL,
[dose10date] [smalldatetime] NULL,
[next_dose_due] [smalldatetime] NULL,
[notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[Immunizations] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UniqueImmunizationRows] ON [dbo].[Immunizations] ([StudentID], [Immunization]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Immunizations] ADD CONSTRAINT [FK_Immunizations_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID])
GO
