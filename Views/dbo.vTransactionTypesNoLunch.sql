SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vTransactionTypesNoLunch] AS
SELECT 
	tt.TransactionTypeID ID, 
	tt.SessionID, 
	tt.Title, 
	tt.ReceivableCategory, 
	tt.DB_CR_Code, 
	cast(tt.Amount as money) as Amount, 
	cast(tt.Notes as nvarchar(MAX)) as Notes,
	s.title as SessionTitle,
	s._title as _SessionTitle,
	tt.Title
		+ ' (' + case when isnull(tt.Amount,0)=0 then '' else +'$'+convert(nvarchar(16),tt.Amount,1)+' ' end + rtrim(tt.DB_CR_Code)+')'
		+ ' - ' + s.title 
		+ case when tt.AttendanceCode is null and tt.balanceTransferType != 1
		  then '' else ' *' /* filter out of UI drop down */
		  end as TitleWithSession
FROM TransactionTypes tt
INNER JOIN vSession s on s.SessionID = tt.SessionID
--where tt.AttendanceCode is null

GO
