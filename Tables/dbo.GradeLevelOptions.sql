CREATE TABLE [dbo].[GradeLevelOptions]
(
[GradeLevelOptionID] [int] NOT NULL IDENTITY(1, 1),
[GradeLevelOption] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GradeLevel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GradeLevelOptions] ADD CONSTRAINT [PK_GradeLevelOptions] PRIMARY KEY CLUSTERED ([GradeLevelOptionID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
