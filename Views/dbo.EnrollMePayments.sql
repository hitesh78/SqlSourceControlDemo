SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[EnrollMePayments]
as select 
	PSPaymentID,
	es.EnrollmentStudentID,
	pmt.PSPaymentDate,
	cust.PSFirstName,
	cust.PSLastName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then RTRIM(LTRIM(ISNULL(cust.PSLastName,N'')))
		+ RTRIM(LTRIM(ISNULL(cust.PSFirstName,N'')))
	else RTRIM(LTRIM(ISNULL(cust.PSLastName,N'')))
		+ RTRIM(LTRIM(ISNULL(N', '+cust.PSFirstName,N''))) 
	end
	AS PSName,

	PSAmount,
	PSPaymentType,
	PSStatus,
	PSDescription
		+ case when RTRIM(isnull(PSDescription,''))='' then '' else '<br/><br/>' end
		+ case when pmt.PSPaymentDate >= 
			(select SUBSTRING(UpdateDatetime,1,10) from
			(select MIN(UpdateDateTime) UpdateDatetime
			from EnrollStudentStatusDates essd
			inner join EnrollmentStudent es
			on essd.EnrollmentStudentID = es.EnrollmentStudentID
			and es.SessionID = (select SessionID from EnrollmentFormSettings)
			and essd.SessionID = es.SessionID) xx)
		then '**Paid During Current Session**' 
		else '**Paid During Prior Session**' 
		end as PSDescription,
	pmt.GLPaymentPurpose,
	pmt.GLPaymentContext,
	pmt.GLXrefID,
	pmt.GLFamilyHTML
from pspayments pmt
inner join PSCustomers cust
on pmt.PSCustomerID = cust.PSCustomerID
inner join EnrollmentStudent es
on 
(pmt.GLXrefID<0 and 
(select top 1 EnrollFamilyID from EnrollmentStudent where StudentID = es.StudentID)
= pmt.GLXrefID)
or
(pmt.GLXrefID between 0 and 1000000000 and
(select FamilyID from Students where StudentID = es.StudentID)
= (select FamilyID from Students where StudentID = pmt.GLXrefID))
or (pmt.GLXrefID >= 1000000000 and
(select top 1 EnrollFamilyID from EnrollmentStudent where StudentID = es.StudentID)
= (select top 1 EnrollFamilyID from EnrollmentStudent where StudentID = pmt.GLXrefID))
where pmt.GLPaymentContext like '%nrollment%' or pmt.GLPaymentContext = 'LearningCenter'

GO
