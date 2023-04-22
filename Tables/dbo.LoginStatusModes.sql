CREATE TABLE [dbo].[LoginStatusModes]
(
[LoginStatusModeID] [int] NOT NULL,
[Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoginStatusModes] ADD CONSTRAINT [PK_LoginStatusModes] PRIMARY KEY CLUSTERED ([LoginStatusModeID]) ON [PRIMARY]
GO
