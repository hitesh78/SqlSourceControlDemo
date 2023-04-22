SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vHealthHistory]
as
with
HealthHx(StudentID, LineNum, Health_Condition, Present, Details, Comments)
as (
	select StudentID, 1, 'Allergies', Allergies, Allergies_attribs, Allergies_Comments
	from HealthHistory
	union
	select StudentID, 2, 'Asthma', Asthma, Asthma_attribs, Asthma_Comments
	from HealthHistory
	union
	select StudentID, 3, 'Attention Deficit Disorder (ADD/ADHD)', ADD_ADHD, '', ADD_ADHD_Comments
	from HealthHistory
	union
	select StudentID, 4, 'Bone/Muscle Condition', BoneOrMuscleCond, '', BoneOrMuscleCond_Comments
	from HealthHistory
	union
	select StudentID, 5, 'Diabetes', Diabetes, Diabetes_attribs, Diabetes_Comments
	from HealthHistory
	union
	select StudentID, 6, 'Chronic Ear or Throat Infections', EarThroatInf, '', EarThroatInf_Comments
	from HealthHistory
	union
	select StudentID, 7, 'Emotional Problems', EmotionalProb, '', EmotionalProb_Comments
	from HealthHistory
	union
	select StudentID, 8, 'Fainting / sudden loss of consciousness', Fainting, '', Fainting_Comments
	from HealthHistory
	union
	select StudentID, 9, 'Frequent Headaches or Migraines', Headaches, '', Headaches_Comments
	from HealthHistory
	union
	select StudentID, 10, 'Head Injuries or Any Major Accidents', MajorInjury, '', MajorInjury_Comments
	from HealthHistory
	union
	select StudentID, 11, 'Heart, Blood Disease or High Blood Pressure', HeartBlood, '', HeartBlood_Comments
	from HealthHistory
	union
	select StudentID, 12, 'Hearing Loss', HearingLoss, HearingLoss_attribs, HearingLoss_Comments
	from HealthHistory
	union
	select StudentID, 13, 'Physical Handicap', PhysicalHandicap, '', PhysicalHandicap_Comments
	from HealthHistory
	union
	select StudentID, 14, 'Seizure Disorder', Seizures, '', Seizures_Comments
	from HealthHistory
	union
	select StudentID, 15, 'Skin Problems', SkinProb, '', SkinProb_Comments
	from HealthHistory
	union
	select StudentID, 16, 'Urinary/Bowel Condition', UrinaryBowel, '', UrinaryBowel_Comments
	from HealthHistory
	union
	select StudentID, 17, 'Vision Problems', Vision, Vision_attribs, Vision_Comments
	from HealthHistory
	union
	select StudentID, 18, 'Hospitalizations & Operations', HospOper, '', HospOper_Comments
	from HealthHistory
	union
	select StudentID, 19, 'Other concerns', Concerns, Concerns_attribs, Concerns_Comments
	from HealthHistory	
	union
	-- Include medications everywhere that health history is presented....
	select 
		StudentID,
		ROW_NUMBER() OVER (PARTITION BY StudentID ORDER BY StartDate)+19 LineNum, -- any unique # after 19
		Medication 
		+ ISNULL(
			CASE WHEN ISNULL(OTCorRx,'')+ISNULL(TakenAtSchool,'')>'' THEN ' (' ELSE '' END 
			+ dbo.ConcatWithDelimiter(OTCorRx,case 
				when TakenAtSchool='Yes' then 'Taken at school'
				when TakenAtSchool='No' then 'Not taken at school'
				else null end, ', ')
			+ CASE WHEN ISNULL(OTCorRx,'')+ISNULL(TakenAtSchool,'')>'' THEN ')' ELSE '' END, 
		''),
		'Yes',
		dbo.ConcatWithDelimiter('Start '+dbo.GLformatdate(StartDate),
			dbo.ConcatWithDelimiter('Stop '+dbo.GLformatdate(StopDate),
				DoseAndFreq,', '),', '),
		dbo.ConcatWithDelimiter(ReasonTaken, cast(Notes as nvarchar(max)), ' - ')
	from vMedications
	union
	select StudentID, 21, case when NurseNotesPublic !='' then 'Nurse Notes' else null end, case when NurseNotesPublic !='' then 'Yes' else 'No' end,'', NurseNotesPublic
	from HealthHistory
)
select 
	(s.xStudentID*100 + h.LineNum) as HealthHistoryID,
	s.xStudentID, 
	s.FullName, 
	s.GradeLevel, 
	s.GradeLevX,
	s._Status as Status,
	s._Status as _Status_no_export, 
	h.*,
	REPLACE(h.Details,'; ','<br />') as DetailsHTML_no_export
from HealthHx h
inner join vstudents s 
on h.StudentID = s.StudentID
and Present is not null
GO
