SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vEnrollmentStudent]
as

SELECT

glo.GradeLevelOption, glo.GradeLevel, ep.EnrollmentProgram,

-- note: any custom page HTML that may have live SQL database fields, must go into this view 

(select top 1 

REPLACE(
'<style type="text/css">'
  + 
--case when es.FormStatus not in ('','Started') then
  '#Registration_tab > ul.ui-widget-header > li { visibility: hidden !important; display: none !important; } '
--else '' end
+ 'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Intro,'
-- + '#Registration_tab > ul.ui-widget-header > li.Page-Intro,' -- pending: restore
+ case when CHARINDEX('Page-Student;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Student,' else '' end
+ case when CHARINDEX('Page-Mother;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Mother,' else '' end
+ case when CHARINDEX('Page-Father;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Father,' else '' end
+ case when CHARINDEX('Page-Guardian1;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Guardian1,' else '' end
+ case when CHARINDEX('Page-Guardian2;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Guardian2,' else '' end
+ case when CHARINDEX('Page-Family;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Family,' else '' end
+ case when CHARINDEX('Page-Contacts;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Contacts,' else '' end
+ case when CHARINDEX('Page-Medical;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Medical,' else '' end
+ case when CHARINDEX('Page-Info;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Info,' else '' end
+ case when CHARINDEX('Page-Attachments;', es.Hide_Show_CSS_Classes+';')>0 then -- pending: remove case
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Attachments,' else '' end
+ case when CHARINDEX('Page-Info2;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Info2,' else '' end
+ case when CHARINDEX('Page-Schools;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Schools,' else '' end
+ case when CHARINDEX('Page-Tuition;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Tuition,' else '' end
+ case when CHARINDEX('Page-Worship;', es.Hide_Show_CSS_Classes+';')>0 then 
'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Worship,' else '' end
+ 'body.theBody2 #Registration_tab > ul.ui-widget-header > li.Page-Submit
{ visibility: visible !important; display: inline !important; } '
+ case when es.FormStatus not in ('','Started') then
'#Registration_tab.notTestMode input.WizardNext, 
 #Registration_tab.notTestMode input.WizardPrior,
 #Registration_tab.notTestMode button.WizardNext, 
 #Registration_tab.notTestMode button.WizardPrior 
' else '' end +
'{ visibility: hidden !important; }
</style>'
, case 
    when isnull((select EnrollMeDemo from EnrollmentFormSettings),0) = 1 
       or es.FormStatus in ('','Started')
    then '.theBody2' else '.notTestMode' end, '')
from OnlineFormPages ofp
/* .theBody2 only appears under Admin interface, where we want page buttons to show (if included in settings)
   .notTestMode is just a dummy classed used here to always show buttons in test mode */
 where ofp.FormName='Enroll' and ofp.WizardPage='Start' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
 ) as EnrollFormCssHTML,
 
isnull((select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID) 
 from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Start' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(
		(case when es.FormStatus = '' then 'Started' else es.FormStatus end) -- may need elsewhere: FormStatus is blank instead of null!
		,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
and (isnull(es.FormStatus,'') in ('','Started') or ofp.FormStatus!='Started') -- 2/7/2005 - block pages specific to started once submitted now that we have Payment pages. Duke
)
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
 ),'<span></span>') as EnrollFormIntroHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Submit' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormSubmitHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Tuition' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormTuitionHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Info' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormInfoHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Attachments' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormAttachmentsHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Info2' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormInfo2HTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Contacts Prefix' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormContactsPrefixHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Contacts Suffix' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormContactsSuffixHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Medical Prefix' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormMedicalPrefixHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Medical Suffix' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormMedicalSuffixHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Worship Prefix' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormWorshipPrefixHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Worship Suffix' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormWorshipSuffixHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Report' 
 and (isnull(ofp.FormType,'')='' or ofp.FormType = es.formtype)
 and ( ofp.GradeLevelFrom is null or ofp.GradeLevelOptionID is not null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  >= CHARINDEX(GradeLevelFrom,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.GradeLevelThru is null or
 CHARINDEX(glo.GradeLevel,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20')
  <= CHARINDEX(GradeLevelThru,'PS,PK,K,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20'))
 and ( ofp.EnrollmentProgramID is null 
		-- programs in EnrollmentStudent may match if not a language
		-- or if a language for New Enrollments (where session_context isn't set to language yet)
 		or (ofp.EnrollmentProgramID = es.EnrollmentProgramID 
		 	and ((select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) not in (select distinct language from LKG.dbo.i18n_languages) 
		 		or session_context(N'UserLanguage') is null))
		-- or ofp program may match language for re-enroll (session_context) case
		-- or for EM Admin interface (another session_context) case...
 		or (select EnrollmentProgram from EnrollmentPrograms where EnrollmentProgramID=ofp.EnrollmentProgramID) = isnull(session_context(N'UserLanguage'),N'English') )
 and ( ofp.GradeLevelOptionID is null or ofp.GradeLevelOptionID = es.GradeLevelOptionID )
 and ( ofp.FormStatus is null 
	or CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/')
		<= CHARINDEX(isnull(es.FormStatus,'Started'),
				'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/') )
 order by 
- 1000000*es.SessionID 
+ case when ofp.FormType is not null then -100000 else 0 end
+ case when ofp.EnrollmentProgramID is not null then -20000 else 0 end
+ case when ofp.GradeLevelOptionID is not null then -10000 else 0 end
+ case when ofp.GradeLevelFrom is not null then -1000 else 0 end
+ case when ofp.GradeLevelThru is not null then -1000 else 0 end
+ case when ofp.FormStatus is not null then 
	-1 * (100-CHARINDEX(ofp.FormStatus,
			'/Started/Submitted/In-Process/Pending/Cancelled/Approved/Not Approved/'))  else 0 end
) as EnrollFormReportHTML,

( select top 1 dbo.funcEnrollmeMergeFields(cast(PageHTML as nvarchar(MAX)),es.EnrollmentStudentID)
from OnlineFormPages ofp
 where ofp.FormName='Enroll' and ofp.WizardPage='Payment' 
 order by 
- 1000000*es.SessionID 
) as EnrollFormPaymentHTML,

case when (
Select max(convert(varchar,UpdateDate,21)+FormStatus) from EnrollStudentStatusDates e
			where e.EnrollmentStudentID = es.EnrollmentStudentID
				and FormStatus in ('Imported','Import deleted','Started') ) like '%Imported'
				and (Select 1 from Students where StudentID = es.ImportStudentID) is not null
then 1
else 0
end Imported,
'{'
+ 'Gradelevel:"'+replace(isnull(glo.GradeLevelOption,''),'"','')+'",'
+ 'FormType:"'+es.FormType+'",'
+ 'Payments:'
+ isnull(dbo.getFamilyPayments(StudentID,'%nrollment%'),'{}')
+ '}'
	submittedPaymentsJSON,

glName AS FullName,

case when ISNULL(es.NoFather,0) = 1 then N'' else
    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then RTRIM(LTRIM(ISNULL([FatherLname],N'')))
		+ RTRIM(LTRIM(ISNULL([FatherFname],N'')))
	else RTRIM(LTRIM(ISNULL([FatherLname],N'')))
		+ RTRIM(LTRIM(ISNULL(N', '+[FatherFname],N''))) 
		+ ISNULL(N' ' + es.FatherMname, N'')
	end
end AS FatherFullName,

case when ISNULL(es.NoMother,0) = 1 then N'' else
    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then RTRIM(LTRIM(ISNULL([MotherLname],N'')))
		+ RTRIM(LTRIM(ISNULL([MotherFname],N'')))
	else RTRIM(LTRIM(ISNULL([MotherLname],N'')))
		+ RTRIM(LTRIM(ISNULL(N', '+[MotherFname],N''))) 
		+ ISNULL(N' ' + es.MotherMname, N'')
	end
end AS MotherFullName,

dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(es.BirthCity,es.BirthState,', '),es.BirthCountry,', ') Birthplace,

dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	es.AddressLine1,es.AddressLine2,'<br/>'),
	dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	es.City,es.State,', '),es.Zip,' '),'<br/>') StudentAddress,

case when ISNULL(es.NoFather,0) = 1 then '' else
dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	es.FatherAddressLine1,es.FatherAddressLine2,'<br/>'),
	dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	es.FatherCity,es.FatherState,', '),es.FatherZip,' '),'<br/>') 
end FatherAddress,

case when SUBSTRING(DB_NAME(),1,4)='1081' then -- CSUSM - ACLI special case
	es.StudentHomePhone 
else
	case when ISNULL(es.NoFather,0) = 1 then '' else
		dbo.ConcatWithDelimiter(
			dbo.ConcatWithDelimiter(
				dbo.ConcatIfBoth(es.FatherHomePhone,' (home/primary)') ,
				dbo.ConcatIfBoth(es.FatherCellPhone,' (cell)') ,
			'<br/>'),
			dbo.ConcatIfBoth(
				dbo.ConcatWithDelimiter(es.FatherWorkPhone, es.FatherWorkExtension, 'x'),' (work)'), 
		'<br/>')
	end
end FatherPhones,

case when SUBSTRING(DB_NAME(),1,4)='1081' then -- CSUSM - ACLI special case
	es.StudentCellPhone 
else
	case when ISNULL(es.NoMother,0) = 1 then '' else
	dbo.ConcatWithDelimiter(
			dbo.ConcatWithDelimiter(
				dbo.ConcatIfBoth(es.MotherHomePhone,' (home/primary)') ,
				dbo.ConcatIfBoth(es.MotherCellPhone,' (cell)') ,
			'<br/>'),
			dbo.ConcatIfBoth(
				dbo.ConcatWithDelimiter(es.MotherWorkPhone, es.MotherWorkExtension, 'x'),' (work)'), 
		'<br/>')
	end
end MotherPhones,

dbo.ConcatWithDelimiter(es.FatherOccupation,
	dbo.ConcatWithDelimiter(es.FatherEmployer,es.FatherEmployerAddr,'<br/>'), '<br/>') FatherWork,

dbo.ConcatWithDelimiter(es.MotherOccupation,
	dbo.ConcatWithDelimiter(es.MotherEmployer,es.MotherEmployerAddr,'<br/>'), '<br/>') MotherWork,

case when ISNULL(es.NoMother,0) = 1 then '' else
dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	es.MotherAddressLine1,es.MotherAddressLine2,'<br/>'),
	dbo.ConcatWithDelimiter(dbo.ConcatWithDelimiter(
	es.MotherCity,es.MotherState,', '),es.MotherZip,' '),'<br/>') end MotherAddress,

case when isnull(es.BaptismChurch,'')='' then es.StudentBaptized else es.BaptismChurch end xBaptismChurch,
case when isnull(es.MotherChurch,'')='' then es.MotherChurchMember else es.MotherChurch end xMotherChurch,
case when isnull(es.FatherChurch,'')='' then es.FatherChurchMember else es.FatherChurch end xFatherChurch,

-- Used for import to new federally compatible ethnicity field...
case when es.HispanicLatino is null then null 
	else (case when es.HispanicLatino = 'Yes' then 1 else 0 end) end isHispanicLatino,

REPLACE(
REPLACE(
dbo.ConcatIfBoth(case when es.StudentLivesWithFather=1 then 'Father' else '' end,', ')
+ dbo.ConcatIfBoth(case when es.StudentLivesWithMother=1 then 'Mother' else '' end,', ')
+ dbo.ConcatIfBoth(case when es.StudentLivesWithStepfather=1 then 'Stepfather' else '' end,', ')
+ dbo.ConcatIfBoth(case when es.StudentLivesWithStepmother=1 then 'Stepmother' else '' end,', ')
+ dbo.ConcatIfBoth(case when es.StudentLivesWithGuardian1=1 
then rtrim(es.Guardian1Relationship) else '' end,', ')
+ dbo.ConcatIfBoth(case when es.StudentLivesWithGuardian2=1 
then rtrim(es.Guardian2Relationship) else '' end,', ')
+ dbo.ConcatIfBoth(case when es.StudentLivesWithOther=1 then es.StudentLivesWithDesc else '' end,', ') + '|',
 ',|',''),'|','') StudentLivesWith,

dbo.ConcatWithDelimiter(
REPLACE(
case when 
cast(isnull(es.StudentLivesWithFather,0) as int) +
cast(isnull(es.StudentLivesWithMother,0) as int) +
cast(isnull(es.StudentLivesWithStepfather,0) as int) +
cast(isnull(es.StudentLivesWithStepmother,0) as int) +
cast(isnull(es.StudentLivesWithGuardian1,0) as int) +
cast(isnull(es.StudentLivesWithGuardian2,0) as int) +
cast(isnull(es.StudentLivesWithOther,0) as int) > 0 then 'Lives with ' +
	case when es.StudentLivesWithFather=1 
		then ', Father' else '' end +
	case when es.StudentLivesWithMother=1 
		then ', Mother' else '' end +
	case when es.StudentLivesWithStepfather=1 
		then ', Stepfather' else '' end +
	case when es.StudentLivesWithStepmother=1 
		then ', Stepmother' else '' end +
	case when es.StudentLivesWithStepmother=1 
		then ', '+rtrim(Guardian1Relationship) else '' end +
	case when es.StudentLivesWithStepmother=1 
		then ', '+rtrim(Guardian2Relationship) else '' end +
	case when es.StudentLivesWithOther=1 
		then isnull(', '+es.StudentLivesWithDesc,'') else '' end 
else null end, ' , ',' '),
case when ISNULL(es.divorced,'No')='Yes'
	then 'Divorced, ' 
		+ case when es.Custody='Joint Custody' then '' 
		else 'Custody with ' end + es.Custody 
	else '' end, '; ') as _FamilyStatus,

dbo.ConcatWithDelimiter(es.StudentHomePhone+' (home)' ,es.StudentCellPhone+' (st.cell)' ,' / ') StudentPhones,

-- Create fields to use with EnrollMe import to encapsulate rules for importing US vs. non-US addresses	
CASE WHEN SUBSTRING(DB_NAME(),1,4)='1081' THEN -- CSUSM - ACLI special case
	''	
	ELSE 
		CASE WHEN isUsAddress = 1
		THEN LEFT(dbo.ConcatWithDelimiter(es.AddressLine1,es.AddressLine2,', '), 100)
		ELSE es.AddressLine1 END
	END	as ImportStreet,

CASE WHEN SUBSTRING(DB_NAME(),1,4)='1081' THEN '' ELSE -- CSUSM - ACLI special case
	CASE WHEN isUsAddress = 1
		THEN es.City ELSE es.AddressLine2 END 
END	as ImportCity, 

CASE WHEN 
	isUsAddress = 1
	THEN es.State ELSE '' END ImportState, 
CASE WHEN 
	isUsAddress = 1
	THEN es.Zip ELSE '' END ImportZip, 
CASE WHEN 
	isUsAddress = 1
	THEN es.Country ELSE '' END ImportCountry, 	

CASE WHEN SUBSTRING(DB_NAME(),1,4)='1081' THEN -- CSUSM - ACLI special case
	es.AddressLine1 else '' end
		as ImportStreet2,
CASE WHEN SUBSTRING(DB_NAME(),1,4)='1081' THEN -- CSUSM - ACLI special case
	es.AddressLine2 ELSE '' END 
		as ImportCity2, 

case when ISNULL(es.NoGuardian1,0) = 1 then N'' else
    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then RTRIM(LTRIM(ISNULL([Guardian1Lname],N'')))
		+ RTRIM(LTRIM(ISNULL([Guardian1Fname],N'')))
	else RTRIM(LTRIM(ISNULL([Guardian1Lname],N'')))
		+ RTRIM(LTRIM(ISNULL(N', '+[Guardian1Fname],N''))) 
		+ ISNULL(N' ' + es.Guardian1Mname, N'')
	end
end AS Guardian1FullName,

case when ISNULL(es.NoGuardian2,0) = 1 then N'' else
    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then RTRIM(LTRIM(ISNULL([Guardian2Lname],N'')))
		+ RTRIM(LTRIM(ISNULL([Guardian2Fname],N'')))
	else RTRIM(LTRIM(ISNULL([Guardian2Lname],N'')))
		+ RTRIM(LTRIM(ISNULL(N', '+[Guardian2Fname],N''))) 
		+ ISNULL(N' ' + es.Guardian2Mname, N'')
	end
end AS Guardian2FullName,

case when (select AdultSchool from settings) = 1 
then es.StudentHomePhone+' (home)'
else
	case when ISNULL(es.NoFather,0) = 1 then '' else
	dbo.ConcatWithDelimiter(
		dbo.ConcatWithDelimiter(
			dbo.ConcatIfBoth(es.FatherHomePhone,' (home/primary)') ,
			dbo.ConcatIfBoth(es.FatherCellPhone,' (cell)') ,
		' / '),
		dbo.ConcatIfBoth(
			dbo.ConcatWithDelimiter(es.FatherWorkPhone, es.FatherWorkExtension, 'x'),' (work)'), 
	' / ')
	end
 end
	as Phones1,

case when (select AdultSchool from settings) = 1 
then es.StudentCellPhone+' (st.cell)'
else
	case when ISNULL(es.NoMother,0) = 1 then '' else
	dbo.ConcatWithDelimiter(
		dbo.ConcatWithDelimiter(
			dbo.ConcatIfBoth(es.MotherHomePhone,' (home/primary)') ,
			dbo.ConcatIfBoth(es.MotherCellPhone,' (cell)') ,
		' / '),
		dbo.ConcatIfBoth(
			dbo.ConcatWithDelimiter(es.MotherWorkPhone, es.MotherWorkExtension, 'x'),' (work)'), 
	' / ')
	end 
end
	as Phones2,

case when (select AdultSchool from settings) = 1 
then ''
else	dbo.ConcatWithDelimiter(es.StudentHomePhone+' (home)' ,es.StudentCellPhone+' (st.cell)' ,' / ') 
end
	as Phones3,

case when (es.FatherCellPhone is not null or es.FatherHomePhone is not null or es.FatherWorkPhone is not null) then 1 else 0 end as Phone1OptIn,
case when (es.MotherCellPhone is not null or es.MotherHomePhone is not null or es.MotherWorkPhone is not null) then 1 else 0 end as Phone2OptIn,
case when (es.StudentCellPhone is not null or es.StudentHomePhone is not null or es.StudentWorkPhone is not null) then 1 else 0 end as Phone3OptIn,
case when ((ISNULL(es.NoGuardian1, 0) = 0 and (ISNULL(Guardian1CellPhone, '') <> '' OR ISNULL(Guardian1HomePhone, '') <> '' OR ISNULL(Guardian1WorkPhone, '') <> ''))) then 1 else 0 end as Family2Phone1OptIn,
case when ((ISNULL(es.NoGuardian2, 0) = 0 and (ISNULL(Guardian2CellPhone, '') <> '' OR ISNULL(Guardian2HomePhone, '') <> '' OR ISNULL(Guardian2WorkPhone, '') <> ''))) Then 1 else 0 end as Family2Phone2OptIn,
case when (select AdultSchool from settings) = 1 
	then 
		case when SUBSTRING(DB_NAME(),1,4)='1081' -- CSUSM - ACLI special case
		then ''
		else es.StudentEmail 
		end
	else es.FatherEmail 
	end as Email1,

case when (select AdultSchool from settings) = 1 
	then 
		case when SUBSTRING(DB_NAME(),1,4)='1081' -- CSUSM - ACLI special case
		then es.StudentEmail 
		else ''
		end
	else es.MotherEmail 
	end as Email2,

--case when (select AdultSchool from settings) = 1  -- deprecate sometime after family update
--	then '' else es.StudentEmail end as Email3,

case when (select AdultSchool from settings) = 1 -- supports family update
	then '' else es.StudentEmail end as Email8,

isnull(es.FamilyChurchDenomination, case when es.CatholicYN='Yes' then 'Catholic' else '' end) Religion,

dbo.ConcatWithDelimiter(
	isnull(es.InsuranceCompany,''),
	isnull(es.InsurancePolicyNumber,''),
	CHAR(13)+CHAR(10)) 
		as MedicalInsurance,

es.*, 

(select Title from Session xSess where es.SessionID = xSess.SessionID) as SessionTitle,
case when ep.EnrollmentProgram='Spanish' then
dbo.funcEnrollmeMergeFields('Favor de indicar clase/programa para {{Year_Session}}',es.EnrollmentStudentID)
else
dbo.funcEnrollmeMergeFields('Please specify incoming grade levels for {{Year_Session}}',es.EnrollmentStudentID) 
end 
as SiblingGradeMessage,

case when es.StudentID>999999999 and ImportStudentID is null
	then 'New Enrollment' 
	else 
		case when es.StudentID<1000000000
		then 'Active'	-- or Reenrollment would be fine too but either way this is computed in SIS
						-- I chose Active in case a schools doesn't continue with enrollme so they won't be left with reenroll statuses
		else
			-- Assign Reenrollment status to new enrolls mapped as reenrolls since these are not computed,
			-- but retain existing status, i.e. like new enrollment, since this could be a re-import of a new enroll
			-- rather than a new enroll mapped as a reenroll...
			isnull(
				(Select Status from Students 
					where StudentID = es.ImportStudentID
					and es.StudentID>999999999),
				'Reenrollment') 
		end
	end as SIS_Import_Status,
    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Contact1Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Contact1Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Contact1Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Contact1Fname],N''))) 
	end as Contact1FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Contact2Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Contact2Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Contact2Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Contact2Fname],N''))) 
	end as Contact2FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Contact3Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Contact3Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Contact3Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Contact3Fname],N''))) 
	end as Contact3FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Contact4Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Contact4Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Contact4Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Contact4Fname],N''))) 
	end as Contact4FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([DoctorLname],N'')))
		+ LTRIM(RTRIM(ISNULL([DoctorFname],N'')))
	else LTRIM(RTRIM(ISNULL([DoctorLname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[DoctorFname],N''))) 
	end as DoctorFullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([DentistLname],N'')))
		+ LTRIM(RTRIM(ISNULL([DentistFname],N'')))
	else LTRIM(RTRIM(ISNULL([DentistLname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[DentistFname],N''))) 
	end as DentistFullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling1Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling1Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling1Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling1Fname],N''))) 
	end as Sibling1FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling2Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling2Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling2Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling2Fname],N''))) 
	end as Sibling2FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling3Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling3Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling3Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling3Fname],N''))) 
	end as Sibling3FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling4Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling4Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling4Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling4Fname],N''))) 
	end as Sibling4FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling5Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling5Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling5Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling5Fname],N''))) 
	end as Sibling5FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling6Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling6Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling6Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling6Fname],N''))) 
	end as Sibling6FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling7Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling7Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling7Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling7Fname],N''))) 
	end as Sibling7FullName,

    case isnull(session_context(N'AdminLanguage'),N'English') 
	when N'Chinese' 
	then LTRIM(RTRIM(ISNULL([Sibling8Lname],N'')))
		+ LTRIM(RTRIM(ISNULL([Sibling8Fname],N'')))
	else LTRIM(RTRIM(ISNULL([Sibling8Lname],N'')))
		+ LTRIM(RTRIM(ISNULL(N', '+[Sibling8Fname],N''))) 
	end as Sibling8FullName

from EnrollmentStudentDefaults es
left join GradeLevelOptions glo on es.GradeLevelOptionID = glo.GradeLevelOptionID
left join EnrollmentPrograms ep on es.EnrollmentProgramID = ep.EnrollmentProgramID
GO
