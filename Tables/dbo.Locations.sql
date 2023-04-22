CREATE TABLE [dbo].[Locations]
(
[LocationID] [int] NOT NULL IDENTITY(0, 1),
[LocationOrder] [int] NOT NULL,
[Location] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocationDescription] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Locations] ADD CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED ([LocationID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
