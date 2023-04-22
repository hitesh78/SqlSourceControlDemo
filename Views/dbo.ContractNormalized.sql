SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[ContractNormalized] as
select '1' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date1 as date,Desc1 as descr,Amount1 as amnt from Contract
--where Date1 is not null
union all 
select '2' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date2 as date,Desc2 as descr,Amount2 as amnt from Contract
where Date2 is not null
union all 
select '3' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date3 as date,Desc3 as descr,Amount3 as amnt from Contract
where Date3 is not null
union all 
select '4' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date4 as date,Desc4 as descr,Amount4 as amnt from Contract
where Date4 is not null
union all 
select '5' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date5 as date,Desc5 as descr,Amount5 as amnt from Contract
where Date5 is not null
union all 
select '6' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date6 as date,Desc6 as descr,Amount6 as amnt from Contract
where Date6 is not null
union all 
select '7' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date7 as date,Desc7 as descr,Amount7 as amnt from Contract
where Date7 is not null
union all 
select '8' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date8 as date,Desc8 as descr,Amount8 as amnt from Contract
where Date8 is not null --or isnull(Desc8,'')!='' or Amount8 is not null
union all 
select '9' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date9 as date,Desc9 as descr,Amount9 as amnt from Contract
where Date9 is not null --or isnull(Desc9,'')!='' or Amount9 is not null
union all 
select '10' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date10 as date,Desc10 as descr,Amount10 as amnt from Contract
where Date10 is not null --or isnull(Desc10,'')!='' or Amount10 is not null
union all 
select '11' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date11 as date,Desc11 as descr,Amount11 as amnt from Contract
where Date11 is not null --or isnull(Desc11,'')!='' or Amount11 is not null
union all 
select '12' as LineNum,ContractID,SessionID,StudentID,TransactionTypeID,Status,Date12 as date,Desc12 as descr,Amount12 as amnt from Contract
where Date12 is not null --or isnull(Desc12,'')!='' or Amount12 is not null



GO
