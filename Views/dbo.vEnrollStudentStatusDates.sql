SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[vEnrollStudentStatusDates]
as 
select 
-- 
-- This view used from EnrollMe Import tab
--
	e1.EnrollmentStudentID, 
	
	-- Useful for updating any Import Plan information or results...
	ei.EnrollStudentStatusDateID, 

	-- just a dummy behind a UI button, can probably factor out at some point...	
	e1.AutoImportYN, 

	case when es.FormStatus='Approved' and e1.FormStatus!='Imported'
		then 1 else 0 end OkToPlanImport, 

	case when es.FormStatus='Approved' 
			and e1.AutoImportCode is not null and ei.AutoImportErrors is null
		then 1 else 0 end OkToImport, 
		
	(Select max(UpdateDate) from EnrollStudentStatusDates e
		where e.EnrollmentStudentID = e1.EnrollmentStudentID
			and FormStatus='Imported') LastImportDate,

	case when ei.AutoImportNotes IS NULL 
		then '<br/><h2 style="margin-left: 15px">' + dbo.T(0,'You may Create Import plans for Approved enrollments.') + '<h2/>' 
		else ei.AutoImportNotes end AutoImportNotes, 

	case when ei.AutoImportExclusions IS NULL 
		then '<br/><h2 style="margin-left: 15px">' + dbo.T(0,'You may Create Import plans for Approved enrollments.') + '<h2/>' 
		else ei.AutoImportExclusions end AutoImportExclusions, 
		
	ei.AutoImportErrors, 
	
	case when ei.AutoImportCode IS NULL 
		then '<br/><h2 style="margin-left: 15px">' + dbo.T(0,'You may Create Import plans for Approved enrollments.') + '<h2/>' 
		else '<pre>'+ei.AutoImportCode+'</pre>' end AutoImportCode, 
		
	case when ei.AutoImportErrors is null then 'Plan' else 'Code' end as PlanOrCode
	
from EnrollStudentStatusDates e1
	-- code to pull most recent record for benefit of OkToImport computation above
	inner join  EnrollStudentStatusDates e2
	on e1.EnrollStudentStatusDateID = e2.EnrollStudentStatusDateID
	and e1.UpdateDate = (Select MAX(UpdateDate) 
		from EnrollStudentStatusDates e 
		where e.EnrollmentStudentID = e2.EnrollmentStudentID)
		
	inner join EnrollmentStudent es
	on es.EnrollmentStudentID = e1.EnrollmentStudentID

	-- code to pull most recent record that contains import computation information
	left join  EnrollStudentStatusDates ei
	on	e1.EnrollmentStudentID = ei.EnrollmentStudentID
		and
		ei.UpdateDate = (Select MAX(UpdateDate) 
		from EnrollStudentStatusDates e 
		where e.EnrollmentStudentID = e1.EnrollmentStudentID
			and e.AutoImportNotes is not null)


GO
