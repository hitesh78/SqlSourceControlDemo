SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[funcEnrollmeMergeFields](@htmlField nvarchar(MAX),@EnrollmentStudentID int)
returns nvarchar(MAX) as
begin
	if CHARINDEX('{{', @htmlField) <> 0
	begin

		DECLARE @UDF_value_1 nvarchar(32)
		DECLARE @UDF_value_2 nvarchar(32)
		DECLARE @UDF_value_3 nvarchar(32)
		DECLARE @UDF_value_4 nvarchar(32)
		DECLARE @UDF_value_5 nvarchar(32)
		DECLARE @UDF_value_6 date
		DECLARE @UDF_value_7 date
		DECLARE @UDF_value_8 date
		DECLARE @UDF_value_9 date
		DECLARE @School_Name nvarchar(100)
		DECLARE @School_Address nvarchar(200)
		DECLARE @School_City nvarchar(100)
		DECLARE @School_State nvarchar(100)
		DECLARE @School_Zip nvarchar(15)
		DECLARE @School_Code nvarchar(50)
		DECLARE @School_Phone nvarchar(50)
		DECLARE @School_FAX nvarchar(50)
		DECLARE @School_Administrator nvarchar(50)
		DECLARE @School_Contact nvarchar(50)
		DECLARE @School_Email nvarchar(100)
		DECLARE @School_Website nvarchar(1000)
		DECLARE @School_Session nvarchar(50)
		DECLARE @Fname nvarchar(30) = ''
		DECLARE @Mname nvarchar(30) = ''
		DECLARE @Lname nvarchar(30) = ''
		DECLARE @Suffix nvarchar(20) = ''
		DECLARE @Nickname nvarchar(32) = ''   

		if CHARINDEX('{{UDF', @htmlField) <> 0
		begin
			select 
				@UDF_value_1 = isnull(UDF_value_1,''),
				@UDF_value_2 = isnull(UDF_value_2,''),
				@UDF_value_3 = isnull(UDF_value_3,''),
				@UDF_value_4 = isnull(UDF_value_4,''),
				@UDF_value_5 = isnull(UDF_value_5,''),
				@UDF_value_6 = isnull(UDF_value_6,''),
				@UDF_value_7 = isnull(UDF_value_7,''),
				@UDF_value_8 = isnull(UDF_value_8,''),
				@UDF_value_9 = isnull(UDF_value_9,'')
			from EnrollmentFormSettings

			set @htmlField = replace(@htmlField,'{{UDF1}}',@UDF_value_1);
			set @htmlField = replace(@htmlField,'{{UDF2}}',@UDF_value_2);
			set @htmlField = replace(@htmlField,'{{UDF3}}',@UDF_value_3);
			set @htmlField = replace(@htmlField,'{{UDF4}}',@UDF_value_4);
			set @htmlField = replace(@htmlField,'{{UDF5}}',@UDF_value_5);
			set @htmlField = replace(@htmlField,'{{UDF6}}',@UDF_value_6);
			set @htmlField = replace(@htmlField,'{{UDF7}}',@UDF_value_7);
			set @htmlField = replace(@htmlField,'{{UDF8}}',@UDF_value_8);
			set @htmlField = replace(@htmlField,'{{UDF9}}',@UDF_value_9);
		end

		if CHARINDEX('{{Year_Session', @htmlField) <> 0
		begin
			select @School_Session = s.Title
				from Session s
				where s.SessionID = (select SessionID from EnrollmentFormSettings)

			set @htmlField = replace(@htmlField,'{{Year_Session}}',@School_Session);
		end

		if CHARINDEX('{{School_', @htmlField) <> 0
		begin
			select 
				@School_Name = isnull(SchoolName,''),
				@School_Address = isnull(SchoolStreet,''),
				@School_City = isnull(SchoolCity,''),
				@School_State = isnull(SchoolState,''),
				@School_Zip = isnull(SchoolZip,''),
				@School_Phone = isnull(SchoolPhone,''),
				@School_Code = isnull(SchoolCode,''),
				@School_FAX = isnull(SchoolFax,''),
				@School_Administrator = isnull(SchoolPrincipal,''),
				@School_Contact = isnull(SchoolContact,''),
				@School_Email = isnull(SchoolEmailAddress,''),
				@School_Website = isnull(SchoolWebSite,'')
			from Settings 

			set @htmlField = replace(@htmlField,'{{School_Name}}', @School_Name);
			set @htmlField = replace(@htmlField,'{{School_Address}}', @School_Address);
			set @htmlField = replace(@htmlField,'{{School_City}}', @School_City);
			set @htmlField = replace(@htmlField,'{{School_State}}', @School_State);
			set @htmlField = replace(@htmlField,'{{School_Zip}}', @School_Zip);
			set @htmlField = replace(@htmlField,'{{School_Phone}}', @School_Phone);
			set @htmlField = replace(@htmlField,'{{School_Code}}', @School_Code);
			set @htmlField = replace(@htmlField,'{{School_FAX}}', @School_FAX);
			set @htmlField = replace(@htmlField,'{{School_Administrator}}', @School_Administrator);
			set @htmlField = replace(@htmlField,'{{School_Contact}}', @School_Contact);
			set @htmlField = replace(@htmlField,'{{School_Email}}', @School_Email);
			set @htmlField = replace(@htmlField,'{{School_Website}}', @School_Website);
		end


		if CHARINDEX('{{Lname}}', @htmlField) <> 0 OR  CHARINDEX('{{Fname}}', @htmlField) <> 0
		begin
			select 
				@Fname = isnull(Fname,''),
				@Mname = isnull(Mname,''),
				@Lname = isnull(Lname,''),
				@Suffix = isnull(Suffix,''),
				@Nickname = ISNULL(Nickname, '')
			from EnrollmentStudent
			where EnrollmentStudentID = @EnrollmentStudentID 

			set @htmlField = replace(@htmlField,'{{Fname}}', @Fname);
			set @htmlField = replace(@htmlField,'{{Mname}}', @Mname);
			set @htmlField = replace(@htmlField,'{{Lname}}', @Lname);
			set @htmlField = replace(@htmlField,'{{Suffix}}', @Suffix);
			set @htmlField = replace(@htmlField,'{{Nickname}}', @Nickname);
		end

	end

	return @htmlField
end

GO
