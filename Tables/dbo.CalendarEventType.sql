CREATE TABLE [dbo].[CalendarEventType]
(
[CalendarEventTypeId] [int] NOT NULL IDENTITY(1, 1),
[Title] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Color] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReservedTypeId] [int] NOT NULL CONSTRAINT [DF_CalendarEventType_ReservedTypeId] DEFAULT ((0)),
[CreatedById] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDttm] [datetime] NOT NULL,
[LastEditedById] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastEditedDttm] [datetime] NOT NULL,
[ActiveInd] [bit] NOT NULL,
[RowVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CalendarEventType] ADD CONSTRAINT [PK_dbo.CalendarEventType] PRIMARY KEY CLUSTERED ([CalendarEventTypeId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
