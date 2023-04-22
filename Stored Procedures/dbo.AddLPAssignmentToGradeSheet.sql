SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Don Puls
-- Create date: 2/24/2016
-- Description:	Adds a LessonPlan Assingment to the GradeSheet
-- =============================================
CREATE Procedure [dbo].[AddLPAssignmentToGradeSheet] 
	@ClassID int,
	@ACID int
	
AS
BEGIN
	SET NOCOUNT ON;


    Insert into Assignments 
    (
    ClassID, 
    AssignmentTitle, 
    ADescription, 
    DateAssigned, 
    DueDate, 
    EC, 
    GradeStyle, 
    OutOf, 
    TypeID,
    NongradedAssignment
    )
    Select
    @ClassID,
    AC.AssignmentTitle,
    AC.Description,
    AC.DateAssigned,
    AC.DateDue,
    AT.TypeEC,
    AC.GradeStyle,
    AC.OutOf,
    AT.TypeID,
    AC.NongradedAssignment
    From 
    AssignmentCollections AC
	    inner join
    AssignmentType AT
	    on	AC.AssignmentTypeName = AT.TypeTitle
		    and
		    AT.ClassID = @ClassID
    Where 
    AC.ACID = @ACID

    Declare @AssignmentID int = (Select IDENT_CURRENT('Assignments'))

    -- Add/Copy AssignmentStandards if the Class has those standards
    Insert into AssignmentStandards(AssignmentID, StandardID)
    Select
    @AssignmentID,
    StandardID
    From
    AssignmentCollectionStandards
    Where
    ACID = @ACID


    -- Use this SQL to add files when adding an assignment
    Declare @FetchID int
    Declare @LatestInsertedFileID int
    Declare AddAssignmentFileCursor Cursor For
    Select FileID
    From AssignmentCollectionBinFiles
    Where ACID = @ACID

    Open  AddAssignmentFileCursor
    FETCH NEXT FROM AddAssignmentFileCursor INTO @FetchID
    WHILE (@@FETCH_STATUS != -1)
    BEGIN

        Insert into BinFiles
        Select
        [FileName],
        FileSize,
        FileData,
        FileSource,
        FileDescription,
        dbo.GLgetdatetime(),
        EnrollSessionID
        From
        BinFiles
        Where
        FileID = @FetchID

        Set @LatestInsertedFileID = (Select IDENT_CURRENT('BinFiles'))

        Insert into AssignmentBinFiles (AssignmentID, FileID)
        Values
        (
        @AssignmentID,
        @LatestInsertedFileID
        )

    FETCH NEXT FROM AddAssignmentFileCursor INTO @FetchID
    End

    Close AddAssignmentFileCursor
    Deallocate AddAssignmentFileCursor

    Update LPAssignmentCollections
    Set AssignmentID = @AssignmentID
    Where
    ACID = @ACID
    
END

GO
