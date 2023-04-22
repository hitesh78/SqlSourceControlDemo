SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[parsePhoneE164] (
	@phone_str nvarchar(100),
	@part nvarchar(10) -- either 'phone' or 'extension'
) returns nvarchar(100) as
begin
	declare @rv nvarchar(100) = '';
	declare @i integer = 1;
	declare @c nchar(1);
	declare @s nvarchar(100);
	declare @firstDigitPos integer = 0;
	declare @lastNonDigitPos integer = 0;
	declare @firstExtensionPos integer = 0;

	-- replace #160 nbsp; with regular spaces recognized in parsing...
	set @phone_str = replace(@phone_str,CHAR(0xA0),CHAR(0x20))

	while @i <= len(@phone_str) 
	begin
		set @c = substring(@phone_str,@i,1);

		-- only capture leading digits for E164 phone...
		if (charindex(@c,'0123456789')>0)
		begin
			set @rv = @rv + @c
			set @lastNonDigitPos = 0
			if @firstDigitPos = 0
				set @firstDigitPos = @i;
		end
		else
		-- phone number punctionation may be discarded...
		if (charindex(@c,'-()./ ')>0)
			set @lastNonDigitPos = @i
		else 
			if @firstDigitPos <> 0
			begin
				set @firstExtensionPos = @i
				break
			end

		set @i = @i + 1
	end

	if @part='extension'
	begin
		set @rv = ''
		if @firstExtensionPos <> 0
		begin
			if @lastNonDigitPos <> 0 and @lastNonDigitPos<@firstExtensionPos
				set @rv = ltrim(substring(@phone_str,@lastNonDigitPos,100))
			else
				set @rv = ltrim(substring(@phone_str,@firstExtensionPos,100))

			-- Add preface content to extension field (in parens) to help with 
			-- automatic identification of work phone numbers (may require view tweak)
			if @firstDigitPos > 1
			begin
				set @s = rtrim(ltrim(substring(@phone_str,1,@firstDigitPos-1)));
				if charindex(')',@s) = 0
				begin
					-- an "orphan" open parenthesis is probably the start of an area code
					-- and we'll remove these....
					set @s = rtrim(replace(@s,'(',''));
				end
				if @s > ''
				begin
					set @rv = @rv + ' (' + @s + ')';
				end
			end

		end
	end

	set @rv = rtrim(@rv);
	if @rv = ''
		set @rv = null

	return rtrim(@rv);
end
GO
