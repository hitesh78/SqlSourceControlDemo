CREATE TABLE [dbo].[ReportHTML]
(
[HTMLID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[HTMLSection] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HTML] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportHTML] ADD CONSTRAINT [PK_ReportHTML] PRIMARY KEY CLUSTERED ([HTMLID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProfileID] ON [dbo].[ReportHTML] ([ProfileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportHTML] ADD CONSTRAINT [FK_ReportHTML_ReportProfiles] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[ReportProfiles] ([ProfileID]) ON DELETE CASCADE
GO