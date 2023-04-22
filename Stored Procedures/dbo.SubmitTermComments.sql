SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SubmitTermComments] 
@INFO nvarchar(max),
@ClassID int, 
@EK decimal(15,15), 
@Admin tinyint,
@StudentIDRecord int  /*change*/

AS

Declare @CSID int
Declare @StrLength int
Declare @StartPosition int
Declare @EndPosition int
Declare @Comments nvarchar(max)
Declare @savedComment nvarchar(max)  /*change*/
DECLARE @position int

While (LEN(@INFO) > 0)
Begin

    --Get CSID
    Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
    Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
    Set @CSID = SUBSTRING (@INFO, 1, @EndPosition)
    Set @StrLength = LEN(@INFO)
    Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)
    --Get Comments
    Set @EndPosition = PATINDEX ('%[@%]%', @INFO) - 2
    Set @StartPosition = PATINDEX ('%[@%]%', @INFO) + 3
    Set @Comments = SUBSTRING (@INFO, 1, @EndPosition)
    Set @Comments = replace(@Comments, '=atSymbol=', '@') -- Translate =atSymbol= back to @
    Set @Comments = replace(@Comments, '=PercentageSymbol=', '%')  -- Translate =PercentageSymbol= back to %
    
    ------------------------ Clean up Junk Text -----------------------------------
    
    Set @Comments = replace(@Comments, 'ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢', char(39)) -- replace with a single apostophe
    Set @Comments = replace(@Comments, 'Ã‚Â', ' ') -- remove
    Set @Comments = replace(@Comments, char(10), ' ') -- replace with a space
    Set @Comments = replace(@Comments, '&nbsp;', ' ') -- remove
    Set @Comments = replace(@Comments, '''''', ' ')-- remove double quote "''"
    Set @Comments = replace(@Comments, '.''', '.')-- remove ".'"
    Set @Comments = replace(@Comments, CHAR(16), '')-- remove Data Line Escape special character
        
    Set @Comments =  
    case
        when charindex('<meta name="ProgId" content="Word', @Comments) > 0 
            then replace (@Comments, substring(@Comments, charindex('<meta name="ProgId" content="Word', @Comments), 6000), '') -- remove Junk Text By Word
        else @Comments
    end

    Set @Comments =  
    case
        when charindex('<meta http-equiv="Content-Type"', @Comments) > 0 
            then replace (@Comments, substring(@Comments, charindex('<meta http-equiv="Content-Type"', @Comments), 6000), '') -- remove other Junk Text
        else @Comments
    end
    
--SET @position = 127
--WHILE @position <= 255
--     BEGIN
--     IF @position not in (193,225,201,233,205,237,209,241,211,243,218,250,220,252,171,187,191,161,128)
--     BEGIN
--       SET @Comments = replace (@Comments, char(@position), ' ') -- remove all chars above Decimal 128
--       SET @position = @position + 1
--     END
-- SET @position = @position + 1
--END

SET @Comments = dbo.RemoveInvalidSQLXMLCharacters(@Comments);

    ------------------------------------------------------------------------------------
    
    Set @StrLength = LEN(@INFO)
    Set @INFO = SUBSTRING (@INFO, @StartPosition, @StrLength)

    -- set comment to '' if only carriage returns and spaces
    if len(ltrim(rtrim(REPLACE(@Comments, '<p style=''margin: 0px; padding: 0px;''> </p>', '')))) = 0
    Set @Comments = ''


    Update ClassesStudents
    Set 
    TermComment = @Comments,
    InUseBy = null
    Where CSID = @CSID

End





Declare @TermTitle nvarchar(100)

Set @TermTitle = 
(
Select T.TermTitle
From 
Terms T
    inner join
Classes C
    on C.TermID = T.TermID
Where C.ClassID = @ClassID
)

/*change*/
IF (@StudentIDRecord IS NOT NULL)
BEGIN
    Set @savedComment = 
    (
    Select TermComment
    From ClassesStudents
    Where CSID = @StudentIDRecord
    )

    Select 
    @Admin as Admin,
    @TermTitle as TermTitle,
    @ClassID as ClassID,
    @EK as EK,
    'yes' as Saved,
    @savedComment as SavedComment /*change*/
    FOR XML RAW
END
ELSE
BEGIN
    Select 
    @Admin as Admin,
    @TermTitle as TermTitle,
    @ClassID as ClassID,
    @EK as EK,
    'yes' as Saved
    FOR XML RAW
END
/*change*/
GO
