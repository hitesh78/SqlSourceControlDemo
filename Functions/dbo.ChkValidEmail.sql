SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create   function [dbo].[ChkValidEmail](@EMAIL varchar(100)) 
returns bit as
begin
declare @bitEmailVal bit
declare @EmailText varchar(100)
declare @atposition int
set @EMAIL=ltrim(rtrim(isnull(@EMAIL,'')))
if @EMAIL=''
set @bitEmailVal=0
else
set @bitEmailVal=1
while @bitEmailVal=1 and len(@EMAIL)>0
begin
while charindex(';',@EMAIL)=1 and len(@EMAIL)>1
set @EMAIL=right(@EMAIL,len(@EMAIL)-1)
if charindex(';',@EMAIL)=0
begin
set @EmailText=@EMAIL
set @EMAIL=''
end
else
begin
set @EmailText=left(@EMAIL,charindex(';', @EMAIL)-1)
set @EMAIL=right(@EMAIL, len(@EMAIL)-charindex(';',@EMAIL))
end
set @atposition=charindex('@',@EmailText)
set @bitEmailVal = case
when @atposition=0 then 0
when @EmailText = '' then 0
when @EmailText like '% %' then 0
when @EmailText like ('%["(),:;<>\]%') then 0
when substring(@EmailText,charindex('@',@EmailText),len(@EmailText)) like ('%[!#$%&*+/=?^`_{|]%') then 0
when (left(@EmailText,1) like ('[-_.+]') or right(@EmailText,1) like ('[-_.+]') or left(@EmailText,charindex('@',@EmailText)-1) like ('[-_.+]')) then 0
when (@EmailText like '%[%' or @EmailText like '%]%') then 0
when @EmailText LIKE '%@%@%' then 0
when @EmailText NOT LIKE '_%@_%.__%' then 0
when @EmailText NOT LIKE '%_@__%.__%' then 0
else 1
end
end
return @bitEmailVal
end
GO
