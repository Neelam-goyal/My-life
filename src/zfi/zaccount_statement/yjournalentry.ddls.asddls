@AbapCatalog.sqlViewName: 'YJOURNALENTRY'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZJOURNALENTRY_ITEM'
define view ZJOURNALENTRY_ITEM as select from  I_JournalEntryItem
{
    key CompanyCode,
    key FiscalYear,
    key AccountingDocument,
    ProfitCenter

    }
  where  Ledger = '0L'
        and ( FinancialAccountType = 'S' or  FinancialAccountType = 'A' )
group by
     CompanyCode,
     FiscalYear,
     AccountingDocument,
     ProfitCenter
