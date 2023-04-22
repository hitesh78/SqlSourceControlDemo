CREATE TABLE [dbo].[Overlays]
(
[OverlayID] [int] NOT NULL IDENTITY(1, 1),
[OverlayName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_Overlays_Active] DEFAULT ((1)),
[RemindCycleInHours] [int] NOT NULL CONSTRAINT [DF_Overlays_RemindCycleInHours] DEFAULT ((48)),
[LearnMoreLink] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Overlays] ADD CONSTRAINT [PK_Overlays] PRIMARY KEY CLUSTERED ([OverlayID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
