SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Joey
-- Create date: 04/11/2022
-- Modified dt: 07/29/2022
-- Description:	
-- =============================================
CREATE   PROCEDURE [dbo].[HandleWebhookEventCustomers]
@EventLogID bigint,
@EventType nvarchar(50),
@CreatedAt datetime,
@CustomerID int,
@FirstName nvarchar(256),
@LastName nvarchar(256),
@Email nvarchar(128),
@Deleted bit
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION;

	DECLARE @glStatus nvarchar(20);
	DECLARE @glNotes nvarchar(100);	

	UPDATE [dbo].PSCustomers WITH (UPDLOCK, SERIALIZABLE)
	SET PSFirstName = isnull(@FirstName, PSFirstName),
		PSLastName = isnull(@LastName, PSLastName),
		PSEmail = ISNULL(@Email, PSEmail),
		GLDeletedFromPS = ISNULL(@Deleted, 0),
		@glStatus = 'OK',
		@glNotes = 'Updated'
	WHERE PSCustomerID = @CustomerID;

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO [dbo].PSCustomers (PSCustomerID, PSFirstName, PSLastName, PSEmail, GLDeletedFromPS)
		VALUES (@CustomerID, @FirstName, @LastName, @Email, ISNULL(@Deleted, 0));
		
		SELECT @glStatus = 'OK', @glNotes = 'Inserted';
	END
	
	UPDATE [LKG].[dbo].WebhookEventLogPaySimple WITH (UPDLOCK, SERIALIZABLE)
	SET glStatus = ISNULL(@glStatus, 'Error'),
		ModifiedUtc = GETUTCDATE(),
		glInfo = (
			SELECT DB_NAME() as [db], 
			@CustomerID as [customerId], 
			COALESCE(@glNotes, @glStatus, '') as [notes] 
			FOR JSON PATH)
	WHERE ID = @EventLogID;

	COMMIT TRANSACTION;

END
GO
