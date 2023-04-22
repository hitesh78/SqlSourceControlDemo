SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[splitSISphones_markNumberOrDelimiterStart] (
	@breakPoints nvarchar(100),	-- previously marked break points
	@phone_str nvarchar(100),	-- phone numbers
	@tokenType nchar(1),		-- D - delimiter(s) or N - phone number
	@pattern nvarchar(10)		-- # - digit; Everything else should be a literal match
)
returns nvarchar(100) as 
begin
	declare @lenPattern int = datalength(@pattern)/2
	declare @lenPhone int = datalength(@phone_str)/2
	declare @posPattern int = 1;
	declare @posPhone int = 1;

	--
	-- Main loop: Scan for all possible matches to the current number or delimiter pattern.
	-- Keep searching for patterns as long as there is the possibility
	-- of another phone number to be found (minimum 7 consequetive digits remaining)
	-- regardless of whether we are currently scanning for phone numbers or delimiters...
	--
	-- Note: Our algorithm doesn't really care about trailing delimiter tokens if there
	-- are no more possible phone numbers, hence "@lenPhone-6" is sufficient for scanning
	-- in several of the loops below.  However, if we ever do want to look for ALL possible
	-- delimiter tokens, we could replace this with something like
	-- "@posPhone < @lenPattern + @posPattern-1"...
	-- 
	while @posPhone <= @lenPhone -- - 5 TODO: Don't add 'N' near end unless 7 digits/spaces available???
	begin

		declare @match bit = 0;
		declare @oldPosPhone int = @posPhone;
		set @posPattern = 1;

		-- Match test loop: Keep testing for a pattern match until we confirm no match
		-- for the current pattern...
		while @posPattern <= @lenPattern 
			and @posPhone <= @lenPhone
		begin

			declare @charPattern nchar(1) = substring(@pattern,@posPattern,1);
			declare @charPhone nchar(1) = substring(@phone_str,@posPhone,1);

			-- See if the current character we are scanning in phone numbers
			-- matches the current pattern we are testing...
			set @match = 
				case when @charPattern = '#' 
				then case when @charPhone between '0' and '9' then 1 else 0 end
				else case when @charPattern = @charPhone then 1 else 0 end
				end;

			-- If not match, break from further match checking at this position
			-- and reset phone position back to where we were.  The main loop
			-- should continue to check for a match at the next location... 
			if @match = 0
			begin
				set @posPhone = @oldPosPhone + 1;
				break;
			end

			-- Continue to work on verifying a match...
			set @posPhone = @posPhone + 1;
			set @posPattern = @posPattern + 1;
		end

		-- Do we have a "real" match that reached to the end of the pattern?
		if @match = 1 and @posPattern > @lenPattern
		begin
			--
			-- If we are marking phone number tokens, then check for extension exception.
			-- An 'x' may not precede the start of a phone number within the prior four
			-- character postions.  This will rule out interpreting "ext. 234" as a phone #.
			-- WAIT TO IMPLEMENT, PROBABLY NOT NEEDED BECAUSE PHONE START PATTERNS ARE NOT
			-- CONSISTENT WITH EXTENSIONS ANYWAY...

			-- If we are marking delimiter tokens and find '(h' or 'h' (home phone) 
			-- then check for 'motHer', 'fatHer' exception
			-- TODO: It may be better to introduce a "whitespace" token character
			-- And add that before 'h' (as well as 'c' and 'w') to require home, work and cell
			-- labels to not start mid-word...
			if (@tokenType<>'D' or @posPhone<3 or lower(substring(@phone_str,@posPhone-2,2))<>'th')
			--
			-- If we are marking delimiter tokens and a phone # has started within the prior 4
			-- positions, then the delimiter will be considered a valid part of the phone number
			-- rather than a delimiter.  (May occur with '/' at the present time).
			-- Note: Works because all phone start patterns require a pattern of at least 4 chacters... 
			and (@tokenType<>'X' or charindex('N',substring(@breakPoints,dbo.MaxVal(@posPhone-5,1),dbo.MinVal(4,@posPhone-1)))<1)
			--
			-- If we are marking number tokens then make sure the chacter prior to the start
			-- of the phone number is not a digit...
			and (@tokenType<>'N' or @oldPosPhone-1 < 1
					or not substring(@phone_str,@oldPosPhone-1,1) between '0' and '9')
			begin
/*
if (@tokenType='N')
begin
declare @s nvarchar(1000) = 
	'echo @posPhone='+cast(@posPhone as nvarchar(10))
	+', @pattern='+@pattern
	+', @phone_str='+@phone_str
	+', TEST='+substring(@phone_str,@posPhone-1-@lenPattern,1)
	+' >> c:\temp\debuginfo.txt';
exec xp_cmdshell @s
end
*/
				-- Make sure are that current pattern match has not already been identified
				-- as a token or the start of a token.  
				-- Note: The patterns should be in a priority order where more complex
				-- patterns that may contain other token matching patterns should be 
				-- tested first; i.e. more to less complex patterns should be presented.
				if rtrim(substring(@breakPoints,@oldPosPhone,@lenPattern))=''
				begin
					-- yes, a real match, mark it in breakPoints...
					-- Note: If pattern is more than one chacter than take up additional placeholders
					-- in break points with underscores to avoid additional token starts being
					-- overlapping with a token already identified...
					set @breakPoints = stuff(@breakPoints,@oldPosPhone,@lenPattern,
						@tokenType + replicate('_',@lenPattern-1));

					-- Advance position for phone string scanning that is likely to be past the current 'token'...
					if (@tokenType = 'N')
						-- Phone numbers are a minimum of 7 digits, so if we just found one than
						-- our minimum amount to advance for another phone number is 7 characters forward...
						set @posPhone = @oldPosPhone + 7;
					else
						set @posPhone = @posPhone + @posPattern-1 - 1/* since posPattern>posLength when match loop done*/;
				end
			end
		end
	end

	return @breakPoints
end
GO
