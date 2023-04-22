SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[splitSISphones] (
	@phone_str nvarchar(100),
	@instance int -- instance: 1, 2 or 3, etc.
) 
returns nvarchar(100) as
begin
	-- trim leading or trailing space off of phones field before starting...
	set @phone_str = rtrim(ltrim(@phone_str))

	declare @orig_instance int = @instance;

	declare @lenPhone int = datalength(@phone_str)/2

	-- Mark the start of phone numbers and the start of delimiters
	-- using 'N' and 'D' at the positions where we find them in a break point array of chars:
	declare @breakPoints nvarchar(100) = space(datalength(@phone_str)/2)

	--
	-- The following patterns represent the possible/likely START of phone numbers.
	-- NOTE: The subroutine called assumes that the chacter (if any) prior to the start
	-- of a phone number is something other than a digit.
	--
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','###/#'); -- poss. start of area code
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','(###)  #'); -- poss. start of area code; allow extra space
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','(###) #'); -- poss. start of area code
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','(###)#'); -- poss. start of area code
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','###)'); -- poss. start of area code
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','###-'); -- poss. start of prefix or area code
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','###.'); -- poss. start of prefix or area code
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','#######'); -- poss. start of 7 or 10 digit number with no punctuation
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','### ### ####'); -- poss. start of 7 or 10 digit number with no punctuation
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'N','### ####'); -- poss. start of 7 or 10 digit number with no punctuation

	--
	-- Some common delimiters between phone numbers are simply delimiters and
	-- serve no purpose other than to separate two numbers.  Examples are '/', ';', and ','.
	-- TODO: These delimiters can be removed from the parsed information returned...
	--
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'X','/'); -- slash is a common delimiter between numbers (area code delimiter usage checked above already)
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'X',';'); -- a simicolon may delimit phone numbers
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'X',','); -- a comma may delimit phone numbers (typically not used with US phone number formatting)

	--
	-- Other patterns we leverage as delimiters are annotations that describe a phone
	-- number as work, home or cell.  We'll retain these annotations and try to store them
	-- with the phone number the describe.  The last section of rules below try to recognize
	-- how to match annotation with numbers.  Sometimes admins prepend a number with an annotation
	-- and sometimes they append the annotation on the end.  For example "h 909-555-1212 w 909-444-2222"
	-- is essentially the same as "909-555-1212 h 909-444-2222 w" and in both cases we should
	-- recognize two phone numbers as a home number followed by a work number and the 'h' and 'w'
	-- annotation should pair with the numbers correctly.  Other obsered orderings are represented
	-- in the final parsing rules below.  
	-- Note: Adam previously recognized that cell numbers are also called 'mobile' numbers but
	-- I have not found examples of this annotation yet.  If I do, then we can add 'm' as an
	-- annotation/delimiter, but we'll also need to exclude the exception case when 'm' is simply
	-- part of an annotation of "mother".  
	-- Note: We are not worrying about "mother" and "father" as delimiters because, although they do
	-- appear on occasion, they are redundant information in most cases because the GL Student face sheet
	-- already has separate prompts for mother and father phone fields so we shouldn't see examples
	-- of both mixed within one field...
	--
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'D','(w'); -- "(w" may annotate a number as a work phone, and hence may seperate numbers too
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'D','(h'); -- "(h" may annotate a number as a home phone, and hence may seperate numbers too
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'D','(c'); -- "(c" may annotate a number as a cell phone, and hence may seperate numbers too
	-- punctuated versions of work/home/cell check first above so that break includes parenthesis punctuation...
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'D','w'); -- "w" may annotate a number as a work phone, and hence may seperate numbers too
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'D','h'); -- "h" may annotate a number as a home phone, and hence may seperate numbers too
	set @breakPoints = dbo.splitSISphones_markNumberOrDelimiterStart(
		@breakPoints,@phone_str,'D','c'); -- "c" may annotate a number as a cell phone, and hence may seperate numbers too

	--
	-- Remove underscores break break points now as they were only used
	-- to avoid marking mulitiple possible token-starts that may overlap...
	--
	set @breakPoints = replace(@breakPoints,'_',' ');

	--
	-- If we detect the potential start of two phone numbers within 7 positions from one another,
	-- then trust the first occurence and erase the 2nd...
	--
	declare @posPhone int = 1;
	while @posPhone <= @lenPhone
	begin
		if substring(@breakPoints,@posPhone,1) = 'N'
		begin
			declare @posPhone2 int = @posPhone + 1
			while @posPhone <= @lenPhone and @posPhone2-@posPhone<7
			begin
				if substring(@breakPoints,@posPhone2,1) = 'N'
					set @breakPoints = stuff(@breakPoints,@posPhone2,1,' ');
				set @posPhone2 = @posPhone2 + 1
			end
		end
		set @posPhone = @posPhone + 1
	end


if @instance=100
	return @breakPoints

	-- 
	-- Rules about how to split patterns of numbers and delimiters:
	-- (Legend: d=one delimiter, D=any # of delimiters but at least one, n=one number, |=where to split)
	--
	declare @rv nvarchar(100);

declare @rvTest nvarchar(100) = '';

	declare @i int;


	while @instance>0 and datalength(@phone_str)>0
	begin
		--
		-- An ordered heirarchy of rules regarding the next delimiter/number patterns 
		-- that we may encounter to allow us to define break rules for these patterns.
		-- In general, more complex patterns are tested first as they may specify or
		-- more refined break point than simpler rules that might also match...
		--

		----------------------------------------------------------------------
		-- Throw away as many leading hard delimiters as we find 
		-- if no numbers are present before the hard delimiter...
		----------------------------------------------------------------------
		while 1=1
		begin
			set @i = charindex('X',@breakPoints)
			if @i>0 and rtrim(replace(substring(@breakPoints,1,@i),'D',''))=''
			begin
				set @phone_str = right(@phone_str,datalength(@phone_str)/2-@i);
				set @breakPoints = right(@breakPoints,datalength(@phone_str)/2-@i);
			end
			else
				break;
		end

		----------------------------------------------------------------------
		-- Following are exclusive and in priority order for each iteration...
		----------------------------------------------------------------------
		-- LEGEND: * = any number of D's OR SPACES BUT NO X's and NO N's... (including none)

		while 1=1
		begin
			-- Match any delimiter(s) followed by number followed by any delimiter(s)
			-- folled by hard delimiter...
			-- (hard delimiter will not be included in parsed value)
			set @rv = dbo.splitSISphones_parse_next(@phone_str,@breakPoints,'%N%|X');
			if @rv>'' and @instance>190 
				set @rvTest = @rvTest + '  ' + '%N%|X'; -- show pattern hit if test instance 200
			if @rv>'' break;

			-- If there are two numbers with delimiters between numbers
			-- then always group just the first interspersed delimiter with the 
			-- first phone number...
			set @rv = dbo.splitSISphones_parse_next(@phone_str,@breakPoints,'%ND|D%N');
			if @rv>'' and @instance>190 
				set @rvTest = @rvTest + '  ' + '%ND|D%N'; -- show pattern hit if test instance 200
			if @rv>'' break;

			-- If only one delimiter follows the first number and another number follows
			-- then group the one delimiter with the first number...
			set @rv = dbo.splitSISphones_parse_next(@phone_str,@breakPoints,'ND|N');
			if @rv>'' and @instance>190 
				set @rvTest = @rvTest + '  ' + 'ND|N'; -- show pattern hit if test instance 200
			if @rv>'' break;

			-- if there are two numbers with only one interspersed delimiter
			-- group the interspersed delimiter with the second number 
			-- if and only if there is at least one delimiter in front of the
			-- first number...
			set @rv = dbo.splitSISphones_parse_next(@phone_str,@breakPoints,'D%N|DN');
			if @rv>'' and @instance>190 
				set @rvTest = @rvTest + '  ' + 'D%N|DN'; -- show pattern hit if test instance 200
			if @rv>'' break;

			-- if there are two numbers back-to-back, split them...
			set @rv = dbo.splitSISphones_parse_next(@phone_str,@breakPoints,'%N|N');
			if @rv>'' and @instance>190 
				set @rvTest = @rvTest + '  ' + '%N|N'; -- show pattern hit if test instance 200
			if @rv>'' break;

			-- We've checked all the possible two-number scenarios, so if there
			-- if just one number left take it now...
			set @rv = dbo.splitSISphones_parse_next(@phone_str,@breakPoints,'%N%');
			if @rv>'' and @instance>190 
				set @rvTest = @rvTest + '  ' + '%N%'; -- show pattern hit if test instance 200
			else if @instance>190 set @rv='No Pattern Match';

			break;
		end

		-- If on desired instance, or no more numbers found, then return...
		if @rv='' and @instance>1 break
		if @instance=1 
		begin 
			if @rv<>'' break;

			set @rv = @phone_str
			break;
		end

		-- ok, we parsed off an instance we don't care about; 
		-- remove it from our phone_str source and iterate...
		set @phone_str = right(@phone_str,dbo.MaxVal(datalength(@phone_str)/2 - datalength(@rv)/2,0));
		set @breakPoints = right(@breakPoints,dbo.MaxVal(datalength(@breakPoints)/2 - datalength(@rv)/2,0));

		set @rv = '';
		set @instance = @instance - 1;
	end

	if @instance > 190
		return ltrim(rtrim(@rvTest));

	return ltrim(rtrim(@rv)) --@rv --@rvTest just for testing, otherwise return @rv
end
GO
