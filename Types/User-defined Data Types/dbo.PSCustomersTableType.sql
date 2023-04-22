CREATE TYPE [dbo].[PSCustomersTableType] AS TABLE
(
[PSCustomerID] [int] NOT NULL,
[PSFirstName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLastName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
