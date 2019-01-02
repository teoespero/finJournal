select 
	rtrim(DistrictAbbrev) 
from tblDistrict

select 
	je.Id as JournalID,
	je.ReferenceKey as JournalEntryReferenceKey,
	je.FiscalYearId as FiscalYear,
	(select DistrictID from tblDistrict) as OrgId,
	(select DistrictAbbrev from tblDistrict) as DistrictAbbrev,
	(select DistrictTitle from tblDistrict) as DistrictTitle,  
	null as DeptId,
	null as BatchId,
	CONVERT(VARCHAR(10), je.Date, 110) as DateEffective,
	jed.AccountId as Account,
	acct.AccountString,
	jet.Id as JETypeId,
	jet.[Description] as JournalEntryType,
	jed.Amount as Amount,
	null as AmtCR,
	null as AmtDR,
	(
		case	
			when je.BudgetId = 1 then 'Actual'
			when je.BudgetId = 2 then 'Encumbered'
			when je.BudgetId = 3 then 'Pre-Encumbered'
			when je.BudgetId = 4 then 'Budget'
		end
	) as Transactiontype,
	(
		case
			when gl.AccountCategoryGroupId = -1 then 'Revenue'
			when gl.AccountCategoryGroupId = -2 then 'Expense'
			when gl.AccountCategoryGroupId = -3 then 'Asset'
			when gl.AccountCategoryGroupId = -4 then 'Liability'
			when gl.AccountCategoryGroupId = -5 then 'Fund Balance'
		end
	) as AccountType,
	jed.Note as Comment
from JournalEntry je
inner join
	JournalEntryDetail jed
	on je.Id = jed.JournalEntryId
inner join
	DS_Global..JournalEntryType jet
	on je.JournalEntryTypeId = jet.Id
inner join
	tblAccount acct
	on acct.AccountID = jed.AccountId
inner join
	GeneralLedger gl
	on gl.AccountId = jed.AccountId
	and je.FiscalYearId = gl.FiscalYearId
where
	je.FiscalYearId = 2018


