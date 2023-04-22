CREATE TABLE [dbo].[CustomGradeScale]
(
[CustomGradeScaleID] [int] NOT NULL IDENTITY(1, 1),
[GradeScaleName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CalculateGPA] [bit] NOT NULL CONSTRAINT [DF_CustomGradeScale_CalculateGPA] DEFAULT (0),
[ShowPercentageGrade] [bit] NOT NULL CONSTRAINT [DF_CustomGradeScale_ShowPercentageGrade] DEFAULT ((1)),
[DefReportThreshold] [tinyint] NULL,
[GPABoost] [decimal] (5, 2) NOT NULL CONSTRAINT [DF_CustomGradeScale_GPABoost] DEFAULT ((0)),
[HighlightThreshold] [tinyint] NULL,
[PositiveAvgDefault] [tinyint] NULL,
[PositiveAssignDefault] [tinyint] NULL,
[NegativeAvgDefault] [tinyint] NULL,
[NegativeAssignDefault] [tinyint] NULL,
[PositiveAvgToggle] [bit] NOT NULL CONSTRAINT [DF_CustomGradeScale_PositiveAvgToggle] DEFAULT ((0)),
[PositiveAssignToggle] [bit] NOT NULL CONSTRAINT [DF_CustomGradeScale_PositiveAssignToggle] DEFAULT ((0)),
[NegativeAvgToggle] [bit] NOT NULL CONSTRAINT [DF_CustomGradeScale_NegativeAvgToggle] DEFAULT ((0)),
[NegativeAssignToggle] [bit] NOT NULL CONSTRAINT [DF_CustomGradeScale_NegativeAssignToggle] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomGradeScale] ADD CONSTRAINT [PK__CustomGradeScale__2E9BCA86] PRIMARY KEY CLUSTERED ([CustomGradeScaleID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
