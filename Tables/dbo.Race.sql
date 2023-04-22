CREATE TABLE [dbo].[Race]
(
[RaceID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FederalRaceMapping] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Deprecated] [bit] NOT NULL CONSTRAINT [DF_Race_Deprecated] DEFAULT ((0)),
[RaceOrder] [int] NOT NULL CONSTRAINT [DF_Race_RaceOrder] DEFAULT ((10))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Race] ADD CONSTRAINT [CK_PreventEmptyString] CHECK (([Name]<>N''))
GO
ALTER TABLE [dbo].[Race] ADD CONSTRAINT [PK_Race] PRIMARY KEY CLUSTERED ([RaceID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Name] ON [dbo].[Race] ([Name]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
