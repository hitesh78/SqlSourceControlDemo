SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[ReceivableStudents] AS
SELECT DISTINCT 
	st.StudentID as ID,
	st.glName + ' - ' + s.title as Title
FROM Receivables r
inner join TransactionTypes tt on tt.TransactionTypeID = r.TransactionTypeID
inner join Session s on s.SessionID = tt.SessionID
inner join Students st on r.StudentID = st.StudentID
GO
