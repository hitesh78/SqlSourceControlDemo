SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE     VIEW [dbo].[vStudentMiscFields]
AS
--
-- NOTE: After adding new fields, make sure to edit computed flags to determine when forms are in use.
--
SELECT s.StudentID, s.xStudentID, s.FamilyID,  s.GradeLev, s._Status, s.FullName,
	BaptismDate,
	CommunionDate,
	ReconciliationDate,
	ConfirmationDate,
	WeddingDate,
	dbo.ConcatWithDelimiter(
		dbo.ConcatWithDelimiter(
			dbo.ConcatWithDelimiter(BirthCity,BirthState,', '),
			BirthZip,' '),
		BirthCounty,'<br/>') as BirthPlace,
	BirthCity,
	BirthState,
	BirthZip,
	BirthCounty,
	StandTestID,
	BusOrCarpoolGroup,
	Religion,
	ReligionChurch,
	ReligionConversionDate,
	ReligionUpdated,
	REPLACE(FamStat,'; ','<br />') as FamStatHTML,
	FamStat,
	FamStatNotes,
	FamStatUpdated,
	REPLACE(MedAlert,'; ','<br />') as MedAlertHTML,
	MedAlert,
	MedAlertNotes,
	MedAlertUpdated,
	MedicalInsurance,
	IEPorDisabled,
	REPLACE(IEPCodes,'; ','<br />') as IEPCodesHTML,
	IEPCodes,
	IEPNotes,
	PrimaryLanguage,
	SecondaryLanguage,
	dbo.ConcatWithDelimiter(PrimaryLanguage,SecondaryLanguage,'<br/>') as Languages,
	EnglishFluency,
	REPLACE(Forms,'; ','<br />') as FormsHTML,
	Forms,
	FormsUpdated,
	REPLACE(FinAid,'; ','<br />') as FinAidHTML,
	FinAid,
	FinAidNotes,
	FinAidUpdated,
	SchoolDistrict,
	FormerSchool,
	(case when MedAlert>'' OR MedAlertNotes IS not null OR MedicalInsurance is not null then 1 else 0 end) AS formMedical, 
    (case when FinAid>'' OR FinAidNotes IS not null OR FinAidUpdated IS not null then 1 else 0 end) AS  formAssistance, 
    (case when IEPCodes>'' OR IEPNotes IS not null then 1 else 0 end) AS  formIEP, 
    (case when FamStat>'' OR FamStatNotes IS not null then 1 else 0 end) AS  formFamily, 
    (case when BirthCity>'' OR BirthState>'' OR BirthZip>'' OR BirthCounty>'' then 1 else 0 end) AS  formBirhplace, 
    (case when Religion>'' OR ReligionChurch>'' 
		OR BaptismDate is not null 
		OR CommunionDate is not null 
		OR ConfirmationDate is not null 
		OR ReconciliationDate is not null 
		OR WeddingDate is not null 
		OR ReligionConversionDate IS not null 
		then 1 else 0 end) AS  formReligion, 
    (case when StandTestID>'' 
		or CONVERT(nvarchar, DecryptByKey(GOVid_encrypted)) is not null 
		
		-- Default 'card' on if history of any usage among active students...
		or (select distinct 1 
			from FACTSCustomers smf
			where FamilyID in (
				select FamilyID from Students
				where active = 1
			)
			and CustomerID is not null 	
			and Username is not null
			) is not null
		then 1 else 0 end) AS  formTest, 

    (case when BusOrCarpoolGroup>'' then 1 else 0 end) AS  formCarpool, 
    (case when PrimaryLanguage>'' OR EnglishFluency>'' or isnull(SecondaryLanguage,'')>'' then 1 else 0 end) AS  formLanguage,
	CONVERT(nvarchar, DecryptByKey(GOVid_encrypted)) AS GOVid_plaintext,
	fc.CustomerID as FACTS_CustomerID, 
	fc.Username as FACTS_Username,
	fc2.CustomerID as FACTS_CustomerID2, 
	fc2.Username as FACTS_Username2,
	s.Family2ID,
	CorpNumberIndiana_DOE_MV,	
	StudentCountyID,
	Virtual_Due_To_Covid19,
	PrimaryEdSchool,
	m.USEntryDate,
	m.EdfiLanguageCodeValue,
	m.EdfiBirthCountryCodeValue,
	m.ELLInstrument
FROM
	dbo.StudentMiscFields m
INNER JOIN vStudents_orig s on s.StudentID = m.StudentID
LEFT JOIN (
	select FamilyID,max(customerid) customerid,max(username) username
	from FACTSCustomers
	group by familyid
	) fc
on s.FamilyID = fc.FamilyID
LEFT JOIN (
	select FamilyID,max(customerid) customerid,max(username) username
	from FACTSCustomers
	group by familyid
	) fc2
on s.Family2ID = fc2.FamilyID
WHERE s.StudentID>-1
GO
