SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vOnlineFormPages] as
select 
	ofp.OnlineFormPageID, 
	ofp.FormName, 
	ofp.WizardPage, 
	ofp.SessionID, 
	case when ofp.GradeLevelOptionID is not null then '' else ofp.GradeLevelFrom end as GradeLevelFrom,
	case when ofp.GradeLevelOptionID is not null then '' else ofp.GradeLevelThru end as GradeLevelThru,
	ofp.Grades, 
	ofp.FormType, 
	ofp.FormStatus, 
	case when ofp.ShowOrHidePage is null or ofp.ShowOrHidePage='' then 'Show' else ofp.ShowOrHidePage end  as ShowOrHidePage, 
	ofp.PageHtml, 
	ofp.GradeLevelOptionID,
	s.title as SessionTitle, 
	glo.GradeLevelOption as GradeLevelOption,
	ep.EnrollmentProgram,
	ep.EnrollmentProgramID
 from [OnlineFormPages] ofp
LEFT JOIN Session s on s.SessionID = ofp.SessionID
LEFT JOIN GradeLevelOptions glo on glo.GradeLevelOptionID = ofp.GradeLevelOptionID
LEFT JOIN EnrollmentPrograms ep on ep.EnrollmentProgramID = ofp.EnrollmentProgramID

GO
