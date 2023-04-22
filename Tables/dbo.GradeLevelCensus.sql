CREATE TABLE [dbo].[GradeLevelCensus]
(
[GradeLevel] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ManualEntry] [bit] NOT NULL,
[Male] [int] NULL,
[Female] [int] NULL,
[udfRace1Catholic] [int] NULL,
[udfRace1NonCatholic] [int] NULL,
[udfRace2Catholic] [int] NULL,
[udfRace2NonCatholic] [int] NULL,
[udfRace3Catholic] [int] NULL,
[udfRace3NonCatholic] [int] NULL,
[udfRace4Catholic] [int] NULL,
[udfRace4NonCatholic] [int] NULL,
[udfRace5Catholic] [int] NULL,
[udfRace5NonCatholic] [int] NULL,
[udfRace6Catholic] [int] NULL,
[udfRace6NonCatholic] [int] NULL,
[udfRace7Catholic] [int] NULL,
[udfRace7NonCatholic] [int] NULL,
[udfRace8Catholic] [int] NULL,
[udfRace8NonCatholic] [int] NULL,
[udfRace9Catholic] [int] NULL,
[udfRace9NonCatholic] [int] NULL,
[HispanicEthnicity_Catholic] [int] NULL,
[HispanicEthnicity_NonCatholic] [int] NULL,
[NonHispanicEthnicity_Catholic] [int] NULL,
[NonHispanicEthnicity_NonCatholic] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GradeLevelCensus] ADD CONSTRAINT [PK_GradeLevelCensus_GradeLevel] PRIMARY KEY CLUSTERED ([GradeLevel]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
