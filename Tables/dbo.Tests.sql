CREATE TABLE [dbo].[Tests]
(
[TestID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NULL,
[Item] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Tests_Item] DEFAULT ('Test'),
[TestName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestDate] [smalldatetime] NULL,
[TestGrade] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StudentGradeLevel] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TestOrder] [int] NULL,
[IgnoreTranscriptGradeLevelFilter] [bit] NOT NULL CONSTRAINT [DF_Tests_IgnoreTranscriptGradeLevelFilter] DEFAULT ((0)),
[DiplomaLevelType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecognitionType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AchievementCategory] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocalPathway] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiplomaType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssessmentIdentifier] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcademicSubjectDescriptor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccommodationDescriptor] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tests] ADD CONSTRAINT [PK_Tests] PRIMARY KEY CLUSTERED ([TestID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
