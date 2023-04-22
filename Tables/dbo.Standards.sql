CREATE TABLE [dbo].[Standards]
(
[ID] [int] NOT NULL IDENTITY(100000, 1),
[Subject] [nvarchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCSSID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GradeLevel] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CategoryID] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemID] [int] NULL,
[SubItemID] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubCategory] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StandardText] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Standards] ADD CONSTRAINT [PK_Standards] PRIMARY KEY CLUSTERED ([ID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Standards] ADD CONSTRAINT [CK_CCSSID] UNIQUE NONCLUSTERED ([CCSSID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
