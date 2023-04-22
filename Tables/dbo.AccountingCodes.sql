CREATE TABLE [dbo].[AccountingCodes]
(
[AccountingCodeID] [int] NOT NULL,
[Title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GL_Account] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountingCodes] ADD CONSTRAINT [PK_AccountCodes] PRIMARY KEY CLUSTERED ([AccountingCodeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
