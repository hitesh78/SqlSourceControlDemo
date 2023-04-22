SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 09-20-2021
-- Description:	Updates the Extension column in the in the PhoneNunbers if they are empty - needed for Family Directory Report
-- =============================================
CREATE   PROCEDURE [dbo].[UpdatePhoneNumberExtensionColumn] 
AS
BEGIN


	Declare @StudentPhoneNumbers table (StudentID int INDEX IX1 CLUSTERED, Phone nvarchar(100), FirstPart nchar(3), SecondPart nchar(3), ThirdPart nchar(4))
	insert into @StudentPhoneNumbers
	Select distinct
	StudentID,
	phone,
	substring(Phone, 1, 3) FirstPart,
	substring(Phone, 4, 3) SecondPart,
	substring(Phone, 7, 4) ThirdPart
	From
	PhoneNumbers
	Where 
	StudentID is not null

	--**********************************************************************************************************
	--******************************************* Get Home PHoneNumbers ****************************************
	--**********************************************************************************************************
	Declare @HomePhoneNumbers table (Phone nvarchar(100) PRIMARY KEY)
	Insert into @HomePhoneNumbers
	select distinct 
	Phone
	From
	(
		Select
		phone,
		(
			Select top 1
			value
			From
			string_split
				(
				(Select Phone1 From Students Where StudentID = S.StudentID)
				,
				';'
				)
			Where 
			(value like '%home%' or value like '%hm%')
			and
			value like '%' + P.FirstPart + '%' 
			and
			value like '%' + P.SecondPart + '%' 
			and
			value like '%' + p.ThirdPart + '%' 
		) as PHome
		From 
		Students S
			inner join
		@StudentPhoneNumbers P
			on 
		P.StudentID = S.StudentID
	) x
	Where
	PHome is not null

	Union

	select distinct 
	Phone
	From
	(
		Select
		phone,
		(
			Select top 1
			value
			From
			string_split
				(
				(Select Phone2 From Students Where StudentID = S.StudentID)
				,
				';'
				)
			Where 
			(value like '%home%' or value like '%hm%')
			and
			value like '%' + P.FirstPart + '%' 
			and
			value like '%' + P.SecondPart + '%' 
			and
			value like '%' + p.ThirdPart + '%' 
		) as PHome
		From 
		Students S
			inner join
		@StudentPhoneNumbers P
			on 
		P.StudentID = S.StudentID
	) x
	Where
	PHome is not null

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(SC.Phone1Num like '%home%' or SC.Phone1Desc like '%home%' or SC.Phone1Num like '%hm%' or SC.Phone1Desc like '%hm%')

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(SC.Phone2Num like '%home%' or SC.Phone2Desc like '%home%' or SC.Phone2Num like '%hm%' or SC.Phone2Desc like '%hm%')

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(SC.Phone3Num like '%home%' or SC.Phone3Desc like '%home%' or SC.Phone3Num like '%hm%' or SC.Phone3Desc like '%hm%');



	--**********************************************************************************************************
	--************************************ Get Cell/Mobile PHoneNumbers ****************************************
	--**********************************************************************************************************
	Declare @CellPhoneNumbers table (Phone nvarchar(100) PRIMARY KEY)
	Insert into @CellPhoneNumbers
	select distinct 
	Phone
	From
	(
		Select
		phone,
		(
			Select top 1
			value
			From
			string_split
				(
				(Select Phone1 From Students Where StudentID = S.StudentID)
				,
				';'
				)
			Where 
			(value like '%cell%' or value like '%mobile%')
			and
			value like '%' + P.FirstPart + '%' 
			and
			value like '%' + P.SecondPart + '%' 
			and
			value like '%' + p.ThirdPart + '%' 
		) as PCell
		From 
		Students S
			inner join
		@StudentPhoneNumbers P
			on 
		P.StudentID = S.StudentID
	) x
	Where
	PCell is not null

	Union

	select distinct 
	Phone
	From
	(
		Select
		phone,
		(
			Select top 1
			value
			From
			string_split
				(
				(Select Phone2 From Students Where StudentID = S.StudentID)
				,
				';'
				)
			Where 
			(value like '%cell%' or value like '%mobile%')
			and
			value like '%' + P.FirstPart + '%' 
			and
			value like '%' + P.SecondPart + '%' 
			and
			value like '%' + p.ThirdPart + '%' 
		) as PCell
		From 
		Students S
			inner join
		@StudentPhoneNumbers P
			on 
		P.StudentID = S.StudentID
	) x
	Where
	PCell is not null

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(SC.Phone1Num like '%cell%' or SC.Phone1Desc like '%cell%' or SC.Phone1Num like '%mobile%' or SC.Phone1Desc like '%mobile%')

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(SC.Phone2Num like '%cell%' or SC.Phone2Desc like '%cell%' or SC.Phone2Num like '%mobile%' or SC.Phone2Desc like '%mobile%')

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(SC.Phone3Num like '%cell%' or SC.Phone3Desc like '%cell%' or SC.Phone3Num like '%mobile%' or SC.Phone3Desc like '%mobile%');



	--**********************************************************************************************************
	--******************************************* Get Work PHoneNumbers ****************************************
	--**********************************************************************************************************
	Declare @WorkPhoneNumbers table (Phone nvarchar(100) PRIMARY KEY)
	Insert into @WorkPhoneNumbers
	select distinct 
	Phone
	From
	(
		Select
		phone,
		(
			Select top 1
			value
			From
			string_split
				(
				(Select Phone1 From Students Where StudentID = S.StudentID)
				,
				';'
				)
			Where 
			(value like '%work%' or value like '%wrk%' or value like '%wk%')
			and
			value like '%' + P.FirstPart + '%' 
			and
			value like '%' + P.SecondPart + '%' 
			and
			value like '%' + p.ThirdPart + '%' 
		) as PCell
		From 
		Students S
			inner join
		@StudentPhoneNumbers P
			on 
		P.StudentID = S.StudentID
	) x
	Where
	PCell is not null

	Union

	select distinct 
	Phone
	From
	(
		Select
		phone,
		(
			Select top 1
			value
			From
			string_split
				(
				(Select Phone2 From Students Where StudentID = S.StudentID)
				,
				';'
				)
			Where 
			(value like '%work%' or value like '%wrk%' or value like '%wk%')
			and
			value like '%' + P.FirstPart + '%' 
			and
			value like '%' + P.SecondPart + '%' 
			and
			value like '%' + p.ThirdPart + '%' 
		) as PCell
		From 
		Students S
			inner join
		@StudentPhoneNumbers P
			on 
		P.StudentID = S.StudentID
	) x
	Where
	PCell is not null

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone1Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(	
				SC.Phone1Num like '%work%' or 
				SC.Phone1Desc like '%work%' or 
				SC.Phone1Num like '%wrk%' or 
				SC.Phone1Desc like '%wrk%' or
				SC.Phone1Num like '%wk%' or 
				SC.Phone1Desc like '%wk%'
			)

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone2Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(	
				SC.Phone2Num like '%work%' or 
				SC.Phone2Desc like '%work%' or 
				SC.Phone2Num like '%wrk%' or 
				SC.Phone2Desc like '%wrk%' or
				SC.Phone2Num like '%wk%' or 
				SC.Phone2Desc like '%wk%'
			)

	Union

	Select distinct
	P.Phone
	From
	StudentContacts SC
		inner join
	PhoneNumbers P
		on 
			SC.ContactID = P.ContactID
			--and
			--isnull(Extension, '') = '' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 1, 3) + '%' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 4, 3)  + '%' 
			and
			SC.Phone3Num like '%' + substring(P.Phone, 7, 4)  + '%' 
			and
			(	
				SC.Phone3Num like '%work%' or 
				SC.Phone3Desc like '%work%' or 
				SC.Phone3Num like '%wrk%' or 
				SC.Phone3Desc like '%wrk%' or
				SC.Phone3Num like '%wk%' or 
				SC.Phone3Desc like '%wk%'
			);




	--**********************************************************************************************************
	--************************ Update Extension Column in  PHoneNumbers ****************************************
	--**********************************************************************************************************
	Update PhoneNumbers
	set Extension = x2.ExtDescription
	From
	PhoneNumbers P
		inner join
	(
		Select 
		x.Phone,
		case when exists (Select Phone From @HomePhoneNumbers where Phone = x.Phone) then 'Home/' else '' end +
		case when exists (Select Phone From @CellPhoneNumbers where Phone = x.Phone) then 'Cell/' else '' end +
		case when exists (Select Phone From @WorkPhoneNumbers where Phone = x.Phone) then 'Work' else '' end as ExtDescription
		From
		(
		Select Phone From @HomePhoneNumbers
		Union
		Select Phone From @CellPhoneNumbers
		Union
		Select Phone From @WorkPhoneNumbers
		) x
	) x2 
		on P.Phone = x2.Phone --and isnull(P.Extension, '') = '';

END
GO
