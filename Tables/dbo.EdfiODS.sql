CREATE TABLE [dbo].[EdfiODS]
(
[ODSID] [int] NOT NULL IDENTITY(1, 1),
[StateAbbr] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolYear] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ODSUrl] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthorizeUrl] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TokenUrl] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchoolSchedule] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalendarType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DailyInstructionalMinutes] [int] NOT NULL CONSTRAINT [DF_EdfiODS_DailyInstructionalMinutes] DEFAULT ((360)),
[DailyBeginTime] [time] (0) NOT NULL CONSTRAINT [DF_EdfiODS_DailyBeginTime] DEFAULT ('08:00:00'),
[DailyEndTime] [time] (0) NOT NULL CONSTRAINT [DF_EdfiODS_DailyEndTime] DEFAULT ('15:00:00'),
[ApiVersion] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IdentityUrl] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EdfiODS] ADD CONSTRAINT [PK_EdfiODS] PRIMARY KEY CLUSTERED ([ODSID]) ON [PRIMARY]
GO
