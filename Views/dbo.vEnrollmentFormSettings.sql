SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vEnrollmentFormSettings] as
select sess.title as SessionTitle, 
null as Profiles_SchoolID,
1 as Profiles_Import_Settings,
1 as Profiles_Import_HTML,
1 as Profiles_Clear_HTML,
1 as Profiles_Add_Grade_Options,
1 as Profiles_Import_Programs,
1 as Profiles_Clear_Programs,
efs.ID	, efs.SessionID	, efs.RelegiousFields	,
 efs.EnrollFormCSS	, efs.EnrollSiteBannerHTML	, efs.EnrollSiteBannerOption	, 
 efs.HomeChurch	, efs.Configurable_Fields_To_Incl	, efs.New_Enroll_Fields_To_Incl	
 , efs.EnrollFormCSS_use	, efs.EnrollFormCSS_new_enroll_use	, efs.EnrollMeDemo	
 , efs.StartedStatusMsg	, efs.SubmittedStatusMsg	, efs.InProcessStatusMsg	
 , efs.PendingStatusMsg	, efs.CancelledStatusMsg	, efs.ApprovedStatusMsg	
 , efs.NotApprovedStatusMsg	, efs.EnableStartedStatusEmail	, efs.EnableSubmittedStatusEmail	
, efs.EnableInProcessStatusEmail	, efs.EnablePendingStatusEmail	
, efs.EnableCancelledStatusEmail	, efs.EnableApprovedStatusEmail	, 
efs.EnableNotApprovedStatusEmail	, efs.SubscriptionRenewal	, efs.UDF_Title_1	
, efs.UDF_value_1	, efs.UDF_Title_2	, efs.UDF_value_2	, efs.UDF_Title_3	
, efs.UDF_value_3	, efs.UDF_Title_4	, efs.UDF_value_4	, efs.UDF_Title_5	
, efs.UDF_value_5	, efs.UDF_Title_6	, efs.UDF_value_6	, efs.UDF_Title_7	
, efs.UDF_value_7	, efs.UDF_Title_8	, efs.UDF_value_8	, efs.UDF_Title_9	
, efs.UDF_value_9	, efs.EnableUserAccessToPageHTML, PromoteReenrollsToActive, EnableSpanishEnrollme,
EnableEnrollMeContract, CustomFieldDefaultExcludes
from EnrollmentFormSettings efs
inner join Session sess
on efs.SessionID = sess.SessionID



GO
