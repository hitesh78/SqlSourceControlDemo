CREATE TABLE [dbo].[PSCustomers]
(
[PSCustomerID] [int] NOT NULL,
[PSFirstName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLastName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSPhone] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSEmail] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSWebsite] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSCompany] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSBillingAddressID] [bigint] NULL,
[PSAltPhone] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSAltEmail] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSNotes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSMobilePhone] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSShippingAddressSameAsBilling] [bit] NOT NULL CONSTRAINT [DF_PSCustomers_PSShippingAddressSameAsBilling] DEFAULT ((1)),
[PSShippingAddressID] [bigint] NULL,
[PSFax] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLCreatingUserID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLContactID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLUserID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLDeletedFromPS] [bit] NOT NULL CONSTRAINT [DF_PSCustomers_GLDeletedFromPS] DEFAULT ((0)),
[StudentID] [int] NULL,
[FamilyID] [int] NULL,
[GLFamilyInfo] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateGLFamilyInfoOnPSCustomersInsert] 
   ON  [dbo].[PSCustomers] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	Declare @CRNL nchar(1) = char(13)

	Update [PSCustomers]
	Set 
	GLFamilyInfo =
	isnull(
		(select Access +' Login '''+ i.GLCreatingUserID + ''' on behalf of: ' + @CRNL 
		from Accounts where AccountID = i.GLCreatingUserID
		and Access in ('Admin','Principal')), '') +
		(
		Select
		case
			when isnull(ltrim(rtrim(Father)),'') = '' and isnull(ltrim(rtrim(Mother)),'') = '' then ltrim(rtrim(Lname))
			when isnull(ltrim(rtrim(Father)),'') = '' and isnull(ltrim(rtrim(Mother)),'') != ''	
				then ltrim(rtrim(replace(Mother, Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
			when isnull(ltrim(rtrim(Father)),'') != '' and isnull(ltrim(rtrim(Mother)),'') = ''	
				then ltrim(rtrim(replace(Father, Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
			else ltrim(rtrim(replace(Father, Lname, '')	)) + ' & ' + ltrim(rtrim(replace(Mother, Lname, '')	)) + ' ' + ltrim(rtrim(Lname))
		end +
		(	-- get Sibling Students Info
			Select
			  (	Select @CRNL + N' - ' + ltrim(rtrim(Fname)) + ' (' + GradeLevel + ')' 
				From Students
				Where FamilyID = S.FamilyID
				FOR XML PATH(''),TYPE)
			  .value('text()[1]','nvarchar(max)')
		)	
		+	-- get Student Email1 if it exists
		case 
			when isnull(ltrim(rtrim(Email1)),'') != '' then
			+ @CRNL +
			isnull(ltrim(rtrim(Email1)),'')
			else ''
		end		
		From Students S
		Where
		S.StudentID = I.StudentID
		)
	From 
	PSCustomers P
	inner join Inserted I
	on p.PSCustomerID = I.PSCustomerID
	where I.StudentID is not null

END

GO
ALTER TABLE [dbo].[PSCustomers] ADD CONSTRAINT [PK_PSCustomers] PRIMARY KEY CLUSTERED ([PSCustomerID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
