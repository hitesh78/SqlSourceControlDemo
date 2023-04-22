CREATE TABLE [dbo].[IBPremiumServices]
(
[IBPremiumServiceID] [int] NOT NULL IDENTITY(1, 1),
[IBConfigurationID] [int] NOT NULL CONSTRAINT [DF_IBPremiumServices_IBConfigurationID] DEFAULT ((1)),
[IBPremiumServiceName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBPremiumServiceDescription] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBPremiumServiceLearnMoreText] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IBPremiumServiceCost] [decimal] (15, 5) NULL,
[IBPremiumServiceStartDate] [datetime] NULL,
[IBPremiumServiceEndDate] [datetime] NULL,
[IBPremiumServiceEnabled] [bit] NOT NULL CONSTRAINT [DF_IBPremiumServices_IBPremiumServiceEnabled] DEFAULT ((0)),
[IBPremiumServicePSScheduleID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IBPremiumServices] ADD CONSTRAINT [PK_IBPremiumServices] PRIMARY KEY CLUSTERED ([IBPremiumServiceID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
