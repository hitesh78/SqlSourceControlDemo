CREATE TABLE [dbo].[MedicalLog]
(
[MedicalLogID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[Date] [smalldatetime] NOT NULL,
[Time] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MedicalLog_Time] DEFAULT (''),
[Duration] [nchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MedicalLog_Duration] DEFAULT (''),
[GradeLevel] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MedicalLog_GradeLevel] DEFAULT (''),
[Type] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Completed] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MedicalLog_Completed] DEFAULT ('No'),
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[staff] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[result] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowupDate] [date] NULL,
[FamilyNotifiedDate] [date] NULL,
[PhysicianReferralDate] [date] NULL,
[PhysicianReportDate] [date] NULL,
[ClosedDate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalLog] ADD CONSTRAINT [PK_MedicalLog] PRIMARY KEY CLUSTERED ([MedicalLogID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StudentID] ON [dbo].[MedicalLog] ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalLog] ADD CONSTRAINT [FK_MedicalLog_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID])
GO
