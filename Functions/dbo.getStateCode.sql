SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Matt Ford
-- Create date: 1/29/2019
-- Description:	Returns ISO code for US State Names
-- =============================================
CREATE FUNCTION [dbo].[getStateCode] 
(
	-- Add the parameters for the function here
	@StateName nvarchar(30)
)
RETURNS nchar(3)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @StateCode nchar(3)

	-- Add the T-SQL statements to compute the return value here
	Set @StateCode = (Select 
	case
		when LTRIM(RTRIM(@StateName)) = 'Alabama' then 'AL'
		when LTRIM(RTRIM(@StateName)) = 'Alaska' then 'AK'
		when LTRIM(RTRIM(@StateName)) = 'American Samoa' then 'AS'
		when LTRIM(RTRIM(@StateName)) = 'Arizona' then 'AZ'
		when LTRIM(RTRIM(@StateName)) = 'Arkansas' then 'AR'
		when LTRIM(RTRIM(@StateName)) = 'Armed Forces Americas' then 'AA'
		when LTRIM(RTRIM(@StateName)) = 'Armed Forces Africa, Canada, Europe, Middle East' then 'AE'
		when LTRIM(RTRIM(@StateName)) = 'Armed Forces Pacific' then 'AP'
		when LTRIM(RTRIM(@StateName)) = 'California' then 'CA'
		when LTRIM(RTRIM(@StateName)) = 'Colorado' then 'CO'
		when LTRIM(RTRIM(@StateName)) = 'Connecticut' then 'CT'
		when LTRIM(RTRIM(@StateName)) = 'Delaware' then 'DE'
		when LTRIM(RTRIM(@StateName)) = 'District of Columbia' then 'DC'
		when LTRIM(RTRIM(@StateName)) = 'Florida' then 'FL'
		when LTRIM(RTRIM(@StateName)) = 'Federated States of Micronesia' then 'FM'
		when LTRIM(RTRIM(@StateName)) = 'Georgia' then 'GA'
		when LTRIM(RTRIM(@StateName)) = 'Guam' then 'GU'
		when LTRIM(RTRIM(@StateName)) = 'Hawaii' then 'HI'
		when LTRIM(RTRIM(@StateName)) = 'Idaho' then 'ID'
		when LTRIM(RTRIM(@StateName)) = 'Illinois' then 'IL'
		when LTRIM(RTRIM(@StateName)) = 'Indiana' then 'IN'
		when LTRIM(RTRIM(@StateName)) = 'Iowa' then 'IA'
		when LTRIM(RTRIM(@StateName)) = 'Kansas' then 'KS'
		when LTRIM(RTRIM(@StateName)) = 'Kentucky' then 'KY'
		when LTRIM(RTRIM(@StateName)) = 'Louisiana' then 'LA'
		when LTRIM(RTRIM(@StateName)) = 'Maine' then 'ME'
		when LTRIM(RTRIM(@StateName)) = 'Marshall Islands' then 'MH'
		when LTRIM(RTRIM(@StateName)) = 'Maryland' then 'MD'
		when LTRIM(RTRIM(@StateName)) = 'Massachusetts' then 'MA'
		when LTRIM(RTRIM(@StateName)) = 'Michigan' then 'MI'
		when LTRIM(RTRIM(@StateName)) = 'Minnesota' then 'MS'
		when LTRIM(RTRIM(@StateName)) = 'Mississippi' then 'MS'
		when LTRIM(RTRIM(@StateName)) = 'Missouri' then 'MO'
		when LTRIM(RTRIM(@StateName)) = 'Montana' then 'MT'
		when LTRIM(RTRIM(@StateName)) = 'Nebraska' then 'NE'
		when LTRIM(RTRIM(@StateName)) = 'Nevada' then 'NV'
		when LTRIM(RTRIM(@StateName)) = 'New Hampshire' then 'NH'
		when LTRIM(RTRIM(@StateName)) = 'New Jersey' then 'NJ'
		when LTRIM(RTRIM(@StateName)) = 'New Mexico' then 'NM'
		when LTRIM(RTRIM(@StateName)) = 'New York' then 'NY'
		when LTRIM(RTRIM(@StateName)) = 'North Carolina' then 'NC'
		when LTRIM(RTRIM(@StateName)) = 'North Dakota' then 'ND'
		when LTRIM(RTRIM(@StateName)) = 'Northern Mariana Islands' then 'MP'
		when LTRIM(RTRIM(@StateName)) = 'Ohio' then 'OH'
		when LTRIM(RTRIM(@StateName)) = 'Oklahoma' then 'OK'
		when LTRIM(RTRIM(@StateName)) = 'Oregon' then 'OR'
		when LTRIM(RTRIM(@StateName)) = 'Pennsylvania' then 'PA'
		when LTRIM(RTRIM(@StateName)) = 'Palau' then 'PW'
		when LTRIM(RTRIM(@StateName)) = 'Puerto Rico' then 'PR'
		when LTRIM(RTRIM(@StateName)) = 'Rhode Island' then 'RI'
		when LTRIM(RTRIM(@StateName)) = 'South Carolina' then 'SC'
		when LTRIM(RTRIM(@StateName)) = 'South Dakota' then 'SD'
		when LTRIM(RTRIM(@StateName)) = 'Tennessee' then 'TN'
		when LTRIM(RTRIM(@StateName)) = 'Texas' then 'TX'
		when LTRIM(RTRIM(@StateName)) = 'Utah' then 'UT'
		when LTRIM(RTRIM(@StateName)) = 'Vermont' then 'VT'
		when LTRIM(RTRIM(@StateName)) = 'Virginia' then 'VA'
		when LTRIM(RTRIM(@StateName)) = 'Virgin Islands' then 'VI'
		when LTRIM(RTRIM(@StateName)) = 'Washington' then 'WA'
		when LTRIM(RTRIM(@StateName)) = 'West Virginia' then 'WV'
		when LTRIM(RTRIM(@StateName)) = 'Wisconsin' then 'WI'
		when LTRIM(RTRIM(@StateName)) = 'Wyoming' then 'WY'
	End)

	-- Return the result of the function
	RETURN @StateCode

END
GO
