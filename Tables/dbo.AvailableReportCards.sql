CREATE TABLE [dbo].[AvailableReportCards]
(
[ReportCardID] [int] NOT NULL,
[ReportCardDescription] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowReportCard] [bit] NOT NULL CONSTRAINT [DF_AvailableReportCards_ShowReportCard] DEFAULT ((1)),
[ReportCardSettingsPage] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SampleLink] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TeachersCanRun] [bit] NULL
) ON [PRIMARY]
GO
