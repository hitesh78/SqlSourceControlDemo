CREATE TABLE [dbo].[ReportProfiles]
(
[ProfileID] [int] NOT NULL IDENTITY(1, 1),
[ReportName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProfileName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProfileJson] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportProfiles] ADD CONSTRAINT [PK_ReportProfiles] PRIMARY KEY CLUSTERED ([ProfileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
