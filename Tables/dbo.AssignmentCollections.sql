CREATE TABLE [dbo].[AssignmentCollections]
(
[ACID] [int] NOT NULL IDENTITY(1, 1),
[TeacherID] [int] NOT NULL,
[AssignmentTitle] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignmentTypeName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GradeStyle] [tinyint] NOT NULL,
[OutOf] [smallint] NULL,
[DateAssigned] [date] NULL,
[DateDue] [date] NULL,
[MiscID] [int] NULL,
[NongradedAssignment] [bit] NOT NULL CONSTRAINT [DF_AssignmentCollections_NongradedAssignment] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentCollections] ADD CONSTRAINT [PK_AssignmentCollections] PRIMARY KEY CLUSTERED ([ACID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
