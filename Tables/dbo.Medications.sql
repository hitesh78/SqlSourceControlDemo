CREATE TABLE [dbo].[Medications]
(
[MedicationID] [int] NOT NULL IDENTITY(1, 1),
[StudentID] [int] NOT NULL,
[Medication] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReasonTaken] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Medications_ReasonTaken] DEFAULT (''),
[StartDate] [date] NULL,
[StopDate] [date] NULL,
[OTCorRx] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Medications_OTCorRx] DEFAULT (''),
[DoseAndFreq] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Medications_DoseAndFreq] DEFAULT (''),
[TakenAtSchool] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Medications_TakenAtSchool] DEFAULT (''),
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
