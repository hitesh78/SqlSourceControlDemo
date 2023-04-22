CREATE TABLE [dbo].[ClassType]
(
[ClassTypeID] [int] NOT NULL IDENTITY(1, 1),
[ClassTypeName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClassTypeCategory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportSectionTitle] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListOrder] [int] NULL,
[UnrestrictedGrading] [bit] NOT NULL CONSTRAINT [DF_ClassType_UnrestrictedGrading] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClassType] ADD CONSTRAINT [PK_ClassType] PRIMARY KEY CLUSTERED ([ClassTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
