@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FB60 RCM PURCHASE DOCS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_RCMPURCHASEDOCS
  as select from I_OperationalAcctgDocItem as _OperationalAcctgDocItem
    inner join   I_JournalEntry            as _JournalEntry on  _OperationalAcctgDocItem.AccountingDocument = _JournalEntry.AccountingDocument
                                                            and _OperationalAcctgDocItem.CompanyCode        = _JournalEntry.CompanyCode
                                                            and _OperationalAcctgDocItem.FiscalYear         = _JournalEntry.FiscalYear
{

  key _JournalEntry.AccountingDocument,
  key _JournalEntry.CompanyCode,
  key _JournalEntry.FiscalYear
}
where
       _JournalEntry.IsReversal                              <> 'X'
  and  _JournalEntry.IsReversed                              <> 'X'
  and  _JournalEntry.TransactionCode                         =  'FB60'
  and(
       _OperationalAcctgDocItem.TransactionTypeDetermination =  'JRC'
    or _OperationalAcctgDocItem.TransactionTypeDetermination =  'JRS'
    or _OperationalAcctgDocItem.TransactionTypeDetermination =  'JRI'
  )
group by
  _JournalEntry.AccountingDocument,
  _JournalEntry.CompanyCode,
  _JournalEntry.FiscalYear
