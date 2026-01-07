@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS to collect required data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_CustomerRecords
  as select from I_OperationalAcctgDocItem as item
    inner join   I_JournalEntry            as _JournalEntry on  item.CompanyCode        = _JournalEntry.CompanyCode
                                                            and item.FiscalYear         = _JournalEntry.FiscalYear
                                                            and item.AccountingDocument = _JournalEntry.AccountingDocument
    inner join   I_Customer                as _Customer     on item.Customer = _Customer.Customer
                                                            or item.Supplier = _Customer.Customer

{

  key item.CompanyCode,
  key item.AccountingDocument,
  key item.FiscalYear,
  key item.AccountingDocumentItem,

      item.PostingDate,
      item.AccountingDocumentType,
      item._JournalEntry.BusinessTransactionType,


      _Customer.Customer              as PartyCode,
      _Customer.CustomerFullName as PartyName,
      case
        when item.GLAccount = '0012100000'

        or item.GLAccount = '0012215000'
        or item.GLAccount = '0012210000'
        or item.GLAccount = '0012200000'
        or item.GLAccount = '0012211000'
        or item.GLAccount = '0012214000'

        or item.GLAccount = '0012212000'
        then '0012100000'
        else item.GLAccount
        end                      as GLAccount,


      //      item.CostCenter,
      item.ProfitCenter,
      //      item.FunctionalArea,
      //      item.BusinessArea,
      item.BusinessPlace,
      //      item.Segment,
      //      item.Plant,
      //      item.ControllingArea,

      item.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @Aggregation.default: #SUM
      item.AmountInCompanyCodeCurrency
}
where
       item.FiscalPeriod                >  '000'
  and  item.AmountInTransactionCurrency <> 0
  and  _JournalEntry.IsReversal         <> 'X'
  and  _JournalEntry.IsReversed         <> 'X'
  and(
       item.GLAccount                   =  '0012100000'
    or item.GLAccount                   =  '0012215000'
    or item.GLAccount                   =  '0012210000'
    or item.GLAccount                   =  '0012200000'
    or item.GLAccount                   =  '0012211000'
    or item.GLAccount                   =  '0012214000'
    or item.GLAccount                   =  '0012212000'
    or item.GLAccount                   =  '0012216300' //BUSINESS LOAN
    or item.GLAccount                   =  '0021101400' //S CRD - DOM- OTHER
    or item.GLAccount                   =  '0021101910' // 9327 Eq GL
    or item.GLAccount                   =  '0021101920' // Incentive Payable
    or item.GLAccount                   =  '0021101930' // Crate Security Payable
    or item.GLAccount                   =  '0021101940' // Freight Payable
    or item.GLAccount                   =  '0012216100' // Crate Loan
    or item.GLAccount                   =  '0012216000' // Security Rcvbls
  )
