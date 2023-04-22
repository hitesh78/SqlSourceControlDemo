SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[getFamilyPayments]
(
	@StudentID bigint, @Filter nvarchar(1000) = '%' 
)
RETURNS nvarchar(MAX)
AS
BEGIN

	declare @xml_var xml
	
	set @xml_var = 
	(
		select * 
		from (
		-- NOTE: "PS_" is required on all output fields and this prefix is removed from replace, below
			select 
				pmt.PSPaymentDate PS_PaymentDate,
				cust.PSFirstName PS_FirstName,
				cust.PSLastName PS_LastName,
				PSAmount PS_Amount,
                '$'+cast(cast(isnull(pmt.ConvenienceAmount, 0.00) as numeric(10,2)) as nvarchar(20)) as PS_ConvenienceAmount,
                '$'+cast(cast(isnull(pmt.StatementAmount,pmt.PSAmount) as numeric(10,2)) as nvarchar(20)) as PS_StatementAmount, 
				PSPaymentType PS_PaymentType,
				PSStatus PS_Status,
				PSDescription PS_Description,
				pmt.GLPaymentPurpose PS_GLPaymentPurpose,
				pmt.GLPaymentContext PS_GLPaymentContext,
				pmt.GLXrefID PS_GLXrefID
			from vpspayments pmt
			inner join PSCustomers cust
			on pmt.PSCustomerID = cust.PSCustomerID
			where
				(pmt.GLPaymentContext like @Filter)
				AND
				(
					(pmt.GLXrefID < 1000000000 and
					(select FamilyID from Students where StudentID = @StudentID)
					= (select FamilyID from Students where StudentID = pmt.GLXrefID))
					or (pmt.GLXrefID >= 1000000000 and
					(select top 1 EnrollFamilyID from EnrollmentStudent where StudentID = @StudentID)
					= (select top 1 EnrollFamilyID from EnrollmentStudent where StudentID = pmt.GLXrefID))
				)
				AND -- Just show receipts for payments since the start of the current session
					pmt.PSPaymentDate >= 
						(select SUBSTRING(UpdateDatetime,1,10) from
						(select MIN(UpdateDateTime) UpdateDatetime
						from EnrollStudentStatusDates essd
						inner join EnrollmentStudent es
						on essd.EnrollmentStudentID = es.EnrollmentStudentID
						and es.SessionID = (select SessionID from EnrollmentFormSettings)) xx)
		) x
		for xml auto
	)

	RETURN
		'['+
		replace(
		replace(
		replace(
		replace(
		replace(
		replace(
		cast(@xml_var as nvarchar(MAX))
		,'="',':"')
		,'<x ','{')
		,' PS_',',')
		,'/>','}')
		,'}{','},{')
		,'{PS_','{')
		+']'

END

GO
