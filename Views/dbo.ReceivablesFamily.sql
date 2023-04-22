SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--
-- This view is basically a NOOP now that we've added Family ID to Receivables
-- Deprecate later...
--
CREATE view [dbo].[ReceivablesFamily]
as 
SELECT 
ReceivableID,
StudentID,
Date,
SortOrder,
TransactionTypeID,
ContractID,
TransactionMethod,
ReferenceNumber,
Amount,
Notes,
UniqueContractID,
PaymentID,
AccountingCodeID,
FamilyID,
FamilyID as FamilyOrTempID
FROM [dbo].[Receivables]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[DeleteReceivablesFamilyRow] 
   ON  [dbo].[ReceivablesFamily] 
   INSTEAD OF DELETE
AS 
BEGIN
	SET NOCOUNT ON;

	delete from Receivables
	where ReceivableID in (select ReceivableID from deleted)
END
GO
