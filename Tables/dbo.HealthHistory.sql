CREATE TABLE [dbo].[HealthHistory]
(
[StudentID] [int] NOT NULL,
[allergies_epipen] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asthma_Inhailer] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diabetes_Care] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HearingLoss_HearingAid] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concerns_SpeakToNurse] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADD_ADHD] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADD_ADHD_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergies] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergies_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asthma] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asthma_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoneOrMuscleCond] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoneOrMuscleCond_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diabetes] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diabetes_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EarThroatInf] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EarThroatInf_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmotionalProb] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmotionalProb_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fainting] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fainting_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Headaches] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Headaches_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MajorInjury] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MajorInjury_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HeartBlood] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HeartBlood_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HearingLoss] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HearingLoss_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalHandicap] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalHandicap_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seizures] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seizures_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkinProb] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SkinProb_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UrinaryBowel] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UrinaryBowel_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vision] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vision_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HospOper] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HospOper_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concerns] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concerns_Comments] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allergies_food] [bit] NULL,
[allergies_insects] [bit] NULL,
[allergies_pollens] [bit] NULL,
[allergies_animals] [bit] NULL,
[allergies_medications] [bit] NULL,
[Vision_Glasses] [bit] NULL,
[Vision_Contacts] [bit] NULL,
[Vision_Wears_always] [bit] NULL,
[Vision_Wears_sometimes] [bit] NULL,
[Vision_Surgery] [bit] NULL,
[NurseNotesInternal] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NurseNotesPublic] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Allergies_attribs] AS (replace(rtrim(((((case  when isnull([allergies_epipen],'')='Yes' then 'Epi-Pen at school  ' else '' end+case  when [allergies_food]=(1) then 'Food  ' else '' end)+case  when [allergies_insects]=(1) then 'Insect bites and stings  ' else '' end)+case  when [allergies_pollens]=(1) then 'Pollens  ' else '' end)+case  when [allergies_animals]=(1) then 'Animals  ' else '' end)+case  when [allergies_medications]=(1) then 'Medications  ' else '' end),'  ','; ')),
[Asthma_attribs] AS (case  when isnull([Asthma_Inhailer],'')='Yes' then 'Inhaler at school  ' else '' end),
[Diabetes_attribs] AS (case  when isnull([Diabetes_Care],'')='Yes' then 'Insulin and glucometer at school' else '' end),
[HearingLoss_attribs] AS (case  when isnull([HearingLoss_HearingAid],'')='Yes' then 'Wears hearing aid' else '' end),
[Concerns_attribs] AS (case  when isnull([Concerns_SpeakToNurse],'')='Yes' then 'Requests Nurse call' else '' end),
[Vision_attribs] AS (replace(rtrim((((case  when [Vision_Glasses]=(1) then 'Wears glasses  ' else '' end+case  when [Vision_Contacts]=(1) then 'Wears contacts  ' else '' end)+case  when [Vision_Wears_always]=(1) then 'Wears all the time  ' else '' end)+case  when [Vision_Wears_sometimes]=(1) then 'Wears some of the time  ' else '' end)+case  when [Vision_Surgery]=(1) then 'Eye surgery history  ' else '' end),'  ','; '))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HealthHistory] ADD CONSTRAINT [PK_HealthHistory] PRIMARY KEY CLUSTERED ([StudentID]) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HealthHistory] ADD CONSTRAINT [FK_HealthHistory_Students] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]) ON DELETE CASCADE
GO