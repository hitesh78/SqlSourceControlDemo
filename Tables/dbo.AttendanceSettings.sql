CREATE TABLE [dbo].[AttendanceSettings]
(
[ID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Title] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbbrTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportLegend] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportTitle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowOnReportCard] [bit] NOT NULL,
[MultiSelect] [bit] NOT NULL,
[PresentValue] [decimal] (3, 2) NOT NULL,
[AbsentValue] [decimal] (3, 2) NOT NULL,
[ExcludedAttendance] [bit] NOT NULL CONSTRAINT [DF_AttendanceSettings_ExcludedAttendance] DEFAULT ((0)),
[LunchValue] [bit] NOT NULL CONSTRAINT [DF_AttendanceSettings_LunchValue] DEFAULT ((0)),
[edfiAttendanceEventID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AttendanceSettings] ADD CONSTRAINT [FK_AttendanceSettings_EdfiAttendanceValues] FOREIGN KEY ([edfiAttendanceEventID]) REFERENCES [dbo].[EdfiAttendanceEvents] ([edfiAttendanceEventID])
GO
