@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Only Misc CDS for Fetching TDS Entries'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_AccountStatementTDS
  as select from I_OperationalAcctgDocItem as item
    inner join   I_JournalEntry            as _JournalEntry on  item.CompanyCode        = _JournalEntry.CompanyCode
                                                            and item.FiscalYear         = _JournalEntry.FiscalYear
                                                            and item.AccountingDocument = _JournalEntry.AccountingDocument
    inner join   ZR_CUST_SUPP_JV           as CustSupp      on  item.CompanyCode        = CustSupp.CompanyCode
                                                            and item.FiscalYear         = CustSupp.FiscalYear
                                                            and item.AccountingDocument = CustSupp.AccountingDocument

{

  key item.CompanyCode,
  key item.AccountingDocument,
  key item.FiscalYear,

      item.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @Aggregation.default: #SUM
      sum(item.AmountInCompanyCodeCurrency ) as TDSAmtinCmpCodeCurr
}
where
      item.FiscalPeriod                 >  '000'
  //  and _JItem.SourceLedger              =  '0L'
  and item.AmountInTransactionCurrency  <> 0
  and item.TransactionTypeDetermination =  'WIT'
group by
  item.CompanyCode,
  item.AccountingDocument,
  item.FiscalYear,
  item.CompanyCodeCurrency
