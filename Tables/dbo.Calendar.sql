CREATE TABLE [dbo].[Calendar]
(
[CalendarId] [int] NOT NULL IDENTITY(1, 1),
[CalendarTypeId] [int] NOT NULL,
[Title] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueIdentifier] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Calendar_UniqueIdentifier] DEFAULT (newid()),
[CreatedById] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDttm] [datetime] NOT NULL,
[LastEditedById] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastEditedDttm] [datetime] NOT NULL,
[ActiveInd] [bit] NOT NULL,
[RowVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Calendar] ADD CONSTRAINT [PK_dbo.Calendar] PRIMARY KEY CLUSTERED ([CalendarId]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
