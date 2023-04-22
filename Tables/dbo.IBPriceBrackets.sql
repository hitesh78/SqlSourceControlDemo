CREATE TABLE [dbo].[IBPriceBrackets]
(
[IBPriceBracketID] [int] NOT NULL IDENTITY(1, 1),
[IBPriceBracketDescription] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBPriceBracketAmount] [decimal] (9, 3) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBPriceBrackets] ADD CONSTRAINT [PK_IBPriceBrackets] PRIMARY KEY CLUSTERED ([IBPriceBracketID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
