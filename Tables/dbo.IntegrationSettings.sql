CREATE TABLE [dbo].[IntegrationSettings]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[EdFiSecret] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdFiKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdFiDOESchoolID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdFiStateOrgID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolYear] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationSettings] ADD CONSTRAINT [PK_IntegrationSettings] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
