SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Joey
-- Create date: 10/25/2022
-- Modified dt: 10/25/2022
-- Description:	bulk upsert ps customer data
-- =============================================
CREATE     PROCEDURE [dbo].[UpsertBulkCustomers]
@CustomerData dbo.PSCustomersTableType READONLY
AS
BEGIN
	SET NOCOUNT ON;

	MERGE INTO PSCustomers as _target
	USING @CustomerData as _source
	ON _target.PSCustomerID = _source.PSCustomerID
	WHEN MATCHED THEN 
		UPDATE SET
			_target.PSFirstName = _source.PSFirstName,
			_target.PSLastName = _source.PSLastName
	WHEN NOT MATCHED THEN
		INSERT (
			PSCustomerID,
			PSFirstName,
			PSLastName
		) VALUES (
			_source.PSCustomerID,
			_source.PSFirstName,
			_source.PSLastName
		);

END
GO
