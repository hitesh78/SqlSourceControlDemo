CREATE TABLE [dbo].[EdFiEventTypes]
(
[EventTypeID] [int] NOT NULL IDENTITY(1, 1),
[EventType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdFiEventTypes] ADD CONSTRAINT [PK_EdFiEventTypes] PRIMARY KEY CLUSTERED ([EventTypeID]) ON [PRIMARY]
GO
