CREATE TABLE [dbo].[StudentEdFiPrograms]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[ProgID] [int] NOT NULL,
[BeginDate] [date] NULL,
[EndDate] [date] NULL,
[ExitReason] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Services] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltEdEligibilityReason] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgMeetingTime] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpEdSetting] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CircumstancesRelevantToTimeline] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimelineCompliance] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StudentEdFiPrograms] ADD CONSTRAINT [PK_StudentEdFiPrograms] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
