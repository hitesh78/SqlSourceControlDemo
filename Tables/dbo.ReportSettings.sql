CREATE TABLE [dbo].[ReportSettings]
(
[SettingID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[SettingName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SettingValue] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BasicSetting] [bit] NOT NULL CONSTRAINT [DF_ReportSettings_BasicSetting] DEFAULT ((0)),
[Tooltip] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TipImage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportSettings] ADD CONSTRAINT [PK_ReportSettings] PRIMARY KEY CLUSTERED ([SettingID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProfileID] ON [dbo].[ReportSettings] ([ProfileID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportSettings] ADD CONSTRAINT [FK_ReportSettings_ReportProfiles] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[ReportProfiles] ([ProfileID]) ON DELETE CASCADE
GO
