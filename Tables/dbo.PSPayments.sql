CREATE TABLE [dbo].[PSPayments]
(
[PSPaymentID] [bigint] NOT NULL,
[PSCustomerID] [int] NOT NULL,
[PSAccountID] [int] NOT NULL,
[PSAmount] [money] NOT NULL CONSTRAINT [DF_PSPayments_PSAmount] DEFAULT ((0.00)),
[PSIsDebit] [bit] NOT NULL CONSTRAINT [DF_PSPayments_PSIsDebit] DEFAULT ((0)),
[PSReferenceID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLatitude] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLongitude] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSStatus] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSRecurringScheduleID] [bigint] NULL,
[PSPaymentType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSPaymentSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSProviderAuthCode] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSTraceNumber] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSPaymentDate] [datetime] NULL,
[PSReturnDate] [datetime] NULL,
[PSEstimatedSettleDate] [datetime] NULL,
[PSActualSettledDate] [datetime] NULL,
[PSCanVoidUntil] [datetime] NULL,
[PSInvoiceID] [bigint] NULL,
[PSInvoiceNumber] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSOrderID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSLastModified] [datetime] NULL,
[PSCreatedOn] [datetime] NULL,
[PSCVV] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSErrorCode] [int] NULL,
[PSErrorDescription] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSMerchantActionText] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSIsDecline] [bit] NULL,
[GLCreatingUserID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLXrefID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLPaymentPurpose] [nvarchar] (1280) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLPaymentContext] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLFamilyHTML] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatementAmount] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PSPayments_StatementAmount] DEFAULT (NULL),
[ConvenienceFee] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PSPayments_ConvenienceFee] DEFAULT (NULL),
[PaymentSource] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentEventType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SettlementBatchID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostID] [int] NULL,
[PostDate] [datetime] NULL,
[TotalDue] [money] NULL,
[BalanceAfterPayment] [money] NULL,
[IgnorePayment] [bit] NULL,
[PaymentIDs] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parentPSPaymentID] [int] NULL,
[SumOfPayments] [money] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UpdateGLFamilyHTMLOnInsert] 
   ON  [dbo].[PSPayments] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	
	Declare @CRNL nchar(5) = '<br/>'

	Update PSPayments
	Set 
	GLPaymentPurpose = 
		case when P.GLPaymentContext = 'Tuition' then 'Online Billing Payment' else '' end
		+ case when P.GLPaymentContext = 'ReEnrollment' then 'EnrollMe Reenrollment Payment' else '' end
		+ case when P.GLPaymentContext = 'NewEnrollment' then 'EnrollMe New Enrollment Payment' else '' end
		+ case when P.GLPaymentContext = 'TuitionAutoPay' then 'Online Billing AutoPay' else '' end
		+ case when P.GLPaymentContext = 'PSRecurringPay' then 'Pay Simple Recurring Payment' else '' end,
	GLFamilyHTML =
	isnull(
		(select Access +' Login '''+ p.GLCreatingUserID + ''' on behalf of: ' + @CRNL 
		from Accounts where AccountID = p.GLCreatingUserID
		and Access in ('Admin','Principal')), '') +
	case 
	when P.GLPaymentContext in ('Tuition', 'ReEnrollment', 'TuitionAutoPay') then
		-- Assumes GLXrefID is the Gradelink StudentID
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
		StudentID = P.GLXrefID
		)
	when P.GLPaymentContext = 'NewEnrollment' then
		-- Assumes GLXrefID is the Gradelink EnrollFamilyID
		(
		Select
		case
			when ltrim(rtrim(max(isnull(FatherFname,'')))) = '' and ltrim(rtrim(max(isnull(MotherFname,'')))) = '' then ltrim(rtrim(max(isnull(Lname,''))))
			when ltrim(rtrim(max(isnull(FatherFname,'')))) = '' and ltrim(rtrim(max(isnull(MotherFname,'')))) != ''	
				then ltrim(rtrim(max(isnull(MotherFname,'')))) + ' ' + ltrim(rtrim(max(isnull(Lname,''))))
			when ltrim(rtrim(max(isnull(FatherFname,'')))) != '' and ltrim(rtrim(max(isnull(MotherFname,'')))) = ''	
				then ltrim(rtrim(max(isnull(FatherFname,'')))) + ' ' + ltrim(rtrim(max(isnull(Lname,''))))
			else ltrim(rtrim(max(isnull(FatherFname,'')))) + ' & ' + ltrim(rtrim(max(isnull(MotherFname,'')))) + ' ' + ltrim(rtrim(max(isnull(Lname,''))))
		end 
		+
		(	-- get Sibling Students Info
			Select
			  (	Select @CRNL + N' - ' + ltrim(rtrim(Fname)) + ' (' + convert(nvarchar(10),GradeLevelOptionID) + ')' 
				From EnrollmentStudent
				Where EnrollFamilyID = ES.EnrollFamilyID
				FOR XML PATH(''),TYPE)
			  .value('text()[1]','nvarchar(max)')
		)	
		+ @CRNL +
		max(isnull(EF.Email,''))
		From 
		EnrollmentStudent ES
			inner join
		EnrollmentNewFamily EF
			on ES.EnrollFamilyID = EF.EnrollFamilyID
		where 
		ES.EnrollFamilyID = ( select top 1 EnrollFamilyID 
			from EnrollmentStudent where StudentID = P.GLXrefID )
		and 
		ES.FormStatus is not null 
		and 
		ES.FormStatus<>'Started'
		group by ES.EnrollFamilyID	
		)	
	end
	From 
	PSPayments P
		inner join
	Inserted I
		on P.PSPaymentID = I.PSPaymentID


	-- Update null GLXrefID from PSCustomers if possible
	Update PSPayments
	Set GLXrefID = x.StudentID
	From
	PSPayments P
		inner join
	(
		Select
		I.PSPaymentID,
		C.StudentID
		From 
		Inserted I
			inner join
		PSCustomers C
			on I.PSCustomerID = C.PSCustomerID
		Where
		I.GLXrefID is null
		and
		C.StudentID is not null
	) x
		on x.PSPaymentID = P.PSPaymentID;



END
GO
ALTER TABLE [dbo].[PSPayments] ADD CONSTRAINT [PK_PSPayments] PRIMARY KEY CLUSTERED ([PSPaymentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
