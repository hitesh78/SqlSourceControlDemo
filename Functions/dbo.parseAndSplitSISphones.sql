SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**/
CREATE FUNCTION [dbo].[parseAndSplitSISphones] (
	@phone_str nvarchar(100),
	@instance int, -- instance: 1, 2 or 3
	@preBreakAtInstance int
) returns nvarchar(100) as
begin
/**/
	-- 
	-- We will assume that SIS phone number fields may contain up to three concatenated phone numbers
	-- and that notes may precede or follow each number.  Notes typically identify the type of phone 
	-- number and we could expect to find the letter C around cell phone numbers, W around work phones, and
	-- H around home phones.  The real-world data entry conventions that we observe sometimes place these
	-- identifying notes before and sometimes after the phone numbers, and this can vary from student
	-- to student, or (rarely) the pattern could change within a single field.  In an attempt to ferret out
	-- out the common patterns and divide lists of phone numbers into individual phone numbers we will 
	-- parse for the following pattern or a subset of the following pattern:
	--
	-- <note A><phone 1><note B><phone 2><note C><phone 3><note D>
	--
	-- If we were to find three phone numbers along with alpha content for notes A, B, and C, then it 
	-- should be clear that Note A pairs with Phone 1 and Note B pairs with Phone 2 and Note C pairs
	-- with Phone 3.  Hoever if alpha content is found at the positons of notes B, C and D, then it
	-- should be clear that Note B pairs with Phone 1 and Note C pairs with Phone 2 and Note D pairs
	-- with Phone 3.
	--
	-- Also consider that a phone may contain both a phone and an extension.  It will be difficult to 
	-- differentiate between a phone and an extension and a note but here are a couple or rules
	-- that might help with that:
	-- 
	--     a. Like notes that identify home, cell or work, an extension may contain letters and symbols like
	--        "ext." or "ext" or "ex." or "x" or "#" etc.  It would be best if we could keep any digits that 
	--        follow these well recognized extension annotations along with the annotation (e.g. "ext.") with 
	--        and following the phone number it describes.  
	--
	--     b. If we might misjudge between a phone nuber and the digits of an extension, that it may be useful
	--        to consider that a phone number must have at least 7 digits.
	--
	-- Our primary goal is to identify if there are one, two or three phone numbers in the souce field, or none,
	-- and then to split the field accordingly.
	-- Our secondary goal is to associate any notes or extension data before or after each phone number with
	-- the proper phone number.
	-- Additional cleaning is provided internally by current or upgraded versions of SQL trigger code that is run
	-- when the phone and phone-notes fields are set in the StudentContacts table, so additional cleaning can be
	-- offloaded...
	--
	-- ALGORITHM ATTEMPT #1:
	--
	-- Rule 1:
	-- I'm going to define a few characters that should never be embedded midstream within a phone number.  These
	-- charcters will be: Any letter other than "e" "x" and "t"; the punctuation symbols of comma (,),  
	-- semi-colon (;), and slash (/); and an open parenthesis "(".  This set excludes
	-- the important letters of H, C, W, and M that are often included in annotation identifying home, cell, work,
	-- and mobile (aka cell) numbers.  Opening parentheses can be found at the start of phone number fields or 
	-- to enclose annotations or extensions, so parenthesis are tricky.  But it is a safe rule that an opening
	-- parenthesis should never be embedded within a phone number after the first character.  So this "rule" should
	-- accurately split phone numbers in most cases and should also avoid extensions being split off as phone
	-- numbers in their own right.  Similarly we may sometimes see the slash symbol separating an area code from
	-- the main phone number.  We'll just need to watch for cases like this when we do these data cleanings...
	--
	-- For now, when I encounter a letter or opening parenthesis, 
	-- I'll start by assuming that it precedes the phone number it describes.
	-- And for the symbols of command, semicolon and slash, I'll assume that these are used to delimite phone numbers
	-- and I'll remove them.  
	--
	-- I think rule 1 may do a good job by iteself to separete the phone numbers "proper" from each other. But, alone, 
	-- it might do a very poor job of associating extensions and other annotations with the correct phone number. 
	-- In other words, rule 1 doesn't do a good job of finding the start or end of a complete phone field which may 
	-- include an annotation (e.g. indicating home, work or phone) as well as an extension (for work numbers).  Hence,
	-- we need more rules....
	--
	-- Rule 2:
	--  ....

/*
	--
	-- Here are some test cases and a query to browser the results for a school....
	--
	-- These cases were drawn from Previous problem cases...
	--

	print ''
	print '**(626) 795-1872 - Home Cell (626) 400-7341**'
	print dbo.[parseAndSplitSISphones]('(626) 795-1872 - Home Cell (626) 400-7341',1,0)
	print dbo.[parseAndSplitSISphones]('(626) 795-1872 - Home Cell (626) 400-7341',2,0)
	print dbo.[parseAndSplitSISphones]('(626) 795-1872 - Home Cell (626) 400-7341',3,0)

	print ''
	print '**626. 795.2118 - Home Cell 626-353-2360 Wk 818-319-**'
	print dbo.[parseAndSplitSISphones]('626. 795.2118 - Home Cell 626-353-2360 Wk 818-319-',1,0)
	print dbo.[parseAndSplitSISphones]('626. 795.2118 - Home Cell 626-353-2360 Wk 818-319-',2,0)
	print dbo.[parseAndSplitSISphones]('626. 795.2118 - Home Cell 626-353-2360 Wk 818-319-',3,0)

	print ''
	print '**818-335-7617 Work 818-891-6055**'
	print dbo.[parseAndSplitSISphones]('818-335-7617 Work 818-891-6055',1,0)
	print dbo.[parseAndSplitSISphones]('818-335-7617 Work 818-891-6055',2,0)
	print dbo.[parseAndSplitSISphones]('818-335-7617 Work 818-891-6055',3,0)

	print ''
	print '**818. 402.2154 - F.Home / 626. 798.8014 - M.Home**'
	print dbo.[parseAndSplitSISphones]('818. 402.2154 - F.Home / 626. 798.8014 - M.Home',1,0)
	print dbo.[parseAndSplitSISphones]('818. 402.2154 - F.Home / 626. 798.8014 - M.Home',2,0)
	print dbo.[parseAndSplitSISphones]('818. 402.2154 - F.Home / 626. 798.8014 - M.Home',3,0)

	select 
		xStudentID,
		phone1,
		 dbo.[parseAndSplitSISphones](phone1,1,0), 
		 dbo.[parseAndSplitSISphones](phone1,2,0), 
		 dbo.[parseAndSplitSISphones](phone1,3,0) 
	from students
*/




/**
	-- MOCK INPUT PARAMETERES:
	declare @phone_str nvarchar(100) = '626. 795.2118 - Home Cell 626-353-2360 Wk 818-319-'; 
	declare @instance int = 2;
**/ --set @phone_str = replace(@phone_str,'ther','tter')

	declare @rv nvarchar(100) = '';
	declare @i integer = 1;
	declare @isDelimit bit;
	declare @priorAnnotativeDelimiter bit = 0;
	declare @digitCount integer = 0;
	declare @instanceNumber integer = 1;
	declare @instanceFound bit = 0;
	declare @c nchar(1);

	-- replace #160 nbsp; with regular spaces recognized in parsing...
	set @phone_str = replace(@phone_str,CHAR(0xA0),CHAR(0x20))

	while @i <= len(@phone_str) 
	begin
	
		if @instanceNumber = @preBreakAtInstance
		begin
			set @priorAnnotativeDelimiter = 1;
		end
	
		set @c = substring(@phone_str,@i,1);

		set @isDelimit = 
			case when ( @c between 'a' and 'z' 
					 or @c between 'A' and 'Z' 
					 or charindex(@c,'(,;/')>0 )
					 and charindex(lower(@c),'ext')=0
				then 1 else 0 end;

		if @isDelimit = 0
		begin
			set @rv = @rv + @c;
			if isnumeric(@c)=1 and @c<>'.'
			begin
				set @digitCount = @digitCount + 1;
			end
		end
		else
		begin
			-- We have a candidate phone number for the current instance...
			if @digitCount >= 7
			begin
				-- Advance to hard delimiter if prior delimiter not hit
				if @priorAnnotativeDelimiter=0 
				begin
					while @i <= len(@phone_str) 
					begin
						set @c = substring(@phone_str,@i,1);

						if isnumeric(@c)=1 and @c<>'.'
						begin
							set @digitCount = @digitCount + 1;
							if @digitCount>12 and @preBreakAtInstance=0
							begin
								-- to many digits for just one number here, 
								-- go into pre-break mode
								-- starting with the present instance...
								return dbo.parseAndSplitSISphones(@phone_str,@instance,@instanceNumber);
							end
						end

						if charindex(@c,',;/')>0 -- hard return
						begin
							break;
						end
						else 
							if ( 
								-- H, C and W are recognized as likely identifiers of 
								-- home, cell and work phone numbers and we use their placement
								-- between phonenumbers as a delimiter.
								charindex(lower(@c),'hcw')>0 
								and 
								-- However, if 'h' is part of mother or father,
								-- then this was not a good delimiter for our
								-- first "Comm2 data cleaning" school, #598...
								charindex('Mot',@rv)+charindex('Fat',@rv) = 0 ) and
								charindex('h',lower(@rv))+charindex('c',lower(@rv))+charindex('w',lower(@rv)) > 0
							begin
								set @priorAnnotativeDelimiter = 1 -- parsing for prefix to next phone # now...
								break;
							end
						else
							begin
								set @rv = @rv + @c;
							end
						set @i = @i + 1;
					end
				end
			
				set @instanceFound = 1;
			end
			else 
			begin
				-- hard delimiters may be removed, otherwise append to return value...
				if charindex(@c,',;/')=1
				begin
					set @instanceFound = 1;
				end
				else
					set @rv = @rv + @c;
			end
		end

		if @instanceFound=1
		begin
			-- Do we return this instance?
			if @instance = @instanceNumber
			begin
				set @rv = rtrim(ltrim(@rv));
				--print 'DONE: '+@rv 
				return @rv;
			end
			else
			begin
				set @instanceNumber = @instanceNumber + 1;

				set @rv = '';

				-- hard delimiters may be removed, otherwise append to return value...
				if charindex(@c,',;/')=0 and @priorAnnotativeDelimiter = 1
					set @rv = @rv + @c;

				set @priorAnnotativeDelimiter = 0;
				set @isDelimit = 0;
				set @digitCount = 0;
				set @instanceFound = 0;
			end	
		end

		if @isDelimit = 1 and charindex(@c,'(,;/')=0 
		begin
			-- does not include "hard" delimiters or parenthesis which is common to the start of a phone number...
			set @priorAnnotativeDelimiter = 1;
		end

		set @i = @i + 1
	end

	if @instance <> @instanceNumber
	begin
		--print 'DONE: No Value Returned (' + cast(@instanceNumber as varchar(10)) + ')' 
		return '';
	end

	set @rv = rtrim(ltrim(@rv));

	--print 'DONE: '+@rv 
	return @rv;
/**/
end
/**/
GO
