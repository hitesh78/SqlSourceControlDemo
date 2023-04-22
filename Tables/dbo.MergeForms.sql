CREATE TABLE [dbo].[MergeForms]
(
[MergeFormID] [int] NOT NULL IDENTITY(1000000000, 1),
[FormName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MergeViewID] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PageHTML] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MergeForms] ADD CONSTRAINT [PK_MergeForms] PRIMARY KEY CLUSTERED ([MergeFormID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
