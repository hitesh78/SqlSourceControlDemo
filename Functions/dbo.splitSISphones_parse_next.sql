SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[splitSISphones_parse_next](
	@phone_str nvarchar(100),
	@breakPoints nvarchar(100),
	@pattern nvarchar(10)
)
returns nvarchar(100) as
begin
	declare @matchTest nvarchar(10);
	declare @coreBreaks nvarchar(100);
	declare @paddingToPreserveOriginalParameterLengths nvarchar(100) = '';

	declare @lenBreakPoints int = datalength(@breakPoints)/2; -- t-sql does not count trailing spaces with LEN()!!!

	--
	-- If we are starting out with a hard delimiter(s) ('X')
	-- in the first position and we have more than one character
	-- of data remaining to parse then just trim this one "token" 
	-- off up front and continue to look for more phone numbers...
	--
	while @lenBreakPoints>1 and substring(ltrim(@breakPoints),1,1)='X'
	begin
		set @phone_str = right(@phone_str, @lenBreakPoints - 1);
		set @breakPoints = right(@breakPoints, @lenBreakPoints - 1);
		set @lenBreakPoints = @lenBreakPoints - 1;
		set @paddingToPreserveOriginalParameterLengths = @paddingToPreserveOriginalParameterLengths + ' ';
	end

	--
	-- If are leading tokens are a soft/annotative delimiter followed by 
	-- a hard delimiter, then downgrade the hard delimiter to a soft one
	-- since it isn't separating two numbers at this point...
	--
	while replace(@breakPoints,' ','') like 'DX%'
	begin
		set @breakPoints = stuff(@breakPoints,charindex('X',@breakPoints),1,'D');
	end

	declare @posBreakPoints int = 1;
	declare @posPattern int = 1;
	declare @lenPattern int = datalength(@pattern)/2;

	-- Quick test to see if we might match pattern before parsing out actual phone number instance...
	-- NOTE: This is not a definitive test because "%" can skip extra 'X' and 'N' tokens...
	set @matchTest = replace(@pattern,'|','');
	set @coreBreaks = replace(@breakPoints,' ','');
/*
if @pattern = '%N%|X' 
begin
declare @err nvarchar(1000) = @matchTest+'~'+@coreBreaks;
declare @sErr nvarchar(1000) = 
	'echo '+@err
	+' >> c:\temp\debuginfo.txt';
exec xp_cmdshell @sErr
end
*/
	if (select 1 where '~'+@coreBreaks like '~'+@matchTest+'%') is not null -- use '~' to start from beginning
	begin
		--
		-- Process pattern against break-points to find actual extent of
		-- phone number information to parse and then return that segment
		-- of the phone_str...
		-- 

		declare @flagNextTokenAsBreak bit = 0;
		declare @sizeOfToken int = 0;

		declare @s varchar(100);
		declare @pos int;

		while @posPattern<=@lenPattern and @posBreakPoints<=@lenBreakPoints
		begin
			declare @charBreakPoint nchar(1) = substring(@breakPoints,@posBreakPoints,1);
			declare @charPattern nchar(1) = substring(@pattern,@posPattern,1);

			if @charPattern = '%' 
			-- scan forward until an 'X' or 'N' or end of phone string
			begin
				while @posPattern<=@lenPattern and @posBreakPoints<=@lenBreakPoints
						and substring(@breakPoints,@posBreakPoints,1) not in ('X','N')
				begin
					-- Gobble white space and delimiters but only
					-- until we confirm a match with remaining pattern.
					-- NOTE: The quick SQL pattern match is probably adequate 
					-- for this purpose and we'll start with that.  If we need
					-- more sophistication we can package the this function itself
					-- for recursive calls...
					if @posPattern<@lenPattern
					begin
						set @matchTest 
							= replace(substring(@pattern,@posPattern+1,100/*to end*/),'|','');
						set @coreBreaks 
							= replace(substring(@breakPoints,@posBreakPoints,100/*to end*/),' ','');
						if (select 1 where '~'+@coreBreaks like '~'+@matchTest) is not null -- use '~' to start from beginning
							break;
					end
					set @posBreakPoints = @posBreakPoints + 1; 
				end
			end

			else if @charPattern in ('N','D','X') 
			-- make sure @charPattern is next non-space token!
			begin
				set @pos = charindex(@charPattern,@breakPoints,@posBreakPoints);
				if @pos=0 or ltrim(substring(@breakPoints,@posBreakPoints,@pos-@posBreakPoints+1))
						<>@charPattern
					return ''; -- no match even though quick test passed!

				set @posBreakPoints = @pos + 1;

				if @flagNextTokenAsBreak=1
				begin
					set @sizeOfToken = @posBreakPoints-2; --TODO: WHY??????
					set @flagNextTokenAsBreak = 0;
--set @s = 'echo @sizeOfToken='+cast(@sizeOfToken as nvarchar(10))+', @charPattern='+@charPattern+' >> c:\temp\debuginfo.txt';
--exec xp_cmdshell @s
				end

			end

			else if @charPattern = '|' 
			begin
			-- mark the size/end of our token even as we confirm pattern...
				set @flagNextTokenAsBreak = 1;
			end

			else
			-- There may be cases where no pattern matches and we just want to fall through,
			-- but for now I am trapping these cases for further review...
				declare @fault int = 1/0;

			set @posPattern = @posPattern + 1;
		end
	end

	-- If pattern didn't complete but last pattern symbol is wildcard, then match it
	--if (@posPattern=@lenPattern and substring(@pattern,@lenPattern,1)<>'%')
--if @pattern = '%N%|X' declare @halt2 int = 1/0

	-- Do not return any token if pattern not fully satisfied
	if @posPattern<=@lenPattern
		return '';

	-- Pattern was satisfied and split point defined so return token...
	if @sizeOfToken>0
		return @paddingToPreserveOriginalParameterLengths + substring(@phone_str,1,@sizeOfToken);

	-- Pattern was satisfied without split point, so just return portion of 
	-- token identified...
	return @paddingToPreserveOriginalParameterLengths + substring(@phone_str,1,@posBreakPoints-1);
end
GO
