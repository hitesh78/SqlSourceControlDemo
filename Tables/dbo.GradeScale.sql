CREATE TABLE [dbo].[GradeScale]
(
[GradeScaleID] [int] NOT NULL IDENTITY(1, 1),
[ClassTypeID] [int] NOT NULL,
[GradeScaleOrder] [int] NOT NULL,
[GradeScaleItem] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GradeScaleItemDescription] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GradeScale] ADD CONSTRAINT [PK_GradeScale] PRIMARY KEY CLUSTERED ([GradeScaleID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassTypeID] ON [dbo].[GradeScale] ([ClassTypeID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GradeScale] ADD CONSTRAINT [FK_GradeScale_ClassType] FOREIGN KEY ([ClassTypeID]) REFERENCES [dbo].[ClassType] ([ClassTypeID])
GO
