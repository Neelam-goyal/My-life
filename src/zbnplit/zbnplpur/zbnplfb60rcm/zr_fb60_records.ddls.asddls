@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FB 60 PURCHASE DOCS DETAILS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_FB60_Records
  as select from    I_OperationalAcctgDocItem as _OperationalAcctgDocItem
    inner join      I_JournalEntry            as _JournalEntry on  _OperationalAcctgDocItem.AccountingDocument = _JournalEntry.AccountingDocument
                                                               and _OperationalAcctgDocItem.CompanyCode        = _JournalEntry.CompanyCode
                                                               and _OperationalAcctgDocItem.FiscalYear         = _JournalEntry.FiscalYear
    inner join      I_GLAccount               as _glAccount    on  _glAccount.GLAccount   = _OperationalAcctgDocItem.GLAccount
                                                               and _glAccount.CompanyCode = _OperationalAcctgDocItem.CompanyCode
    left outer join I_Supplier                as _supplier     on _OperationalAcctgDocItem.Supplier = _supplier.Supplier
    left outer join ZDIM_TAXCode              as _Tax          on  _OperationalAcctgDocItem.TaxCode                  = _Tax.TaxCode
                                                               and _OperationalAcctgDocItem.TaxRateValidityStartDate = _Tax.CndnRecordValidityStartDate
    left outer join ZI_PlantTable             as _plant        on  _plant.CompCode  = _OperationalAcctgDocItem.CompanyCode
                                                               and _plant.PlantCode = _OperationalAcctgDocItem.BusinessPlace

{

  key _OperationalAcctgDocItem.AccountingDocument,
  key _OperationalAcctgDocItem.CompanyCode,
  key _OperationalAcctgDocItem.FiscalYear,
  key _OperationalAcctgDocItem.AccountingDocumentItem,
      _JournalEntry.DocumentReferenceID,
      _JournalEntry.DocumentDate                                                     as DocumentReferenceDate,
      _OperationalAcctgDocItem.AccountingDocumentItemType,
      _OperationalAcctgDocItem.FinancialAccountType,
      _OperationalAcctgDocItem.DebitCreditCode,
      _OperationalAcctgDocItem.TaxCode,
      _Tax.TaxCodeName,

      _Tax.TaxRate,
      _Tax.SGSTRate,
      _Tax.CGSTRate,
      _Tax.IGSTRate,

      _OperationalAcctgDocItem.TaxRateValidityStartDate,
      _OperationalAcctgDocItem.WithholdingTaxCode,
      _OperationalAcctgDocItem.TaxType,
      _OperationalAcctgDocItem.TaxItemGroup,
      _OperationalAcctgDocItem.TransactionTypeDetermination,
      _OperationalAcctgDocItem.ValueDate,
      _OperationalAcctgDocItem.AssignmentReference,
      _OperationalAcctgDocItem.DocumentItemText,
      _OperationalAcctgDocItem.IsOpenItemManaged,
      _OperationalAcctgDocItem.IsAutomaticallyCreated,
      _OperationalAcctgDocItem.OperationalGLAccount,
      _OperationalAcctgDocItem.GLAccount,
      _glAccount._Text.GLAccountName,
      _OperationalAcctgDocItem.Supplier,
      _supplier.SupplierName,
      _supplier.Region,
      _supplier.TaxNumber3                                                           as GSTNumber,
      _OperationalAcctgDocItem.PaymentTerms,
      _OperationalAcctgDocItem.ProfitCenter,
      _OperationalAcctgDocItem.Reference3IDByBusinessPartner,
      _OperationalAcctgDocItem.TaxDeterminationDate,
      _OperationalAcctgDocItem.BusinessPlace,
      _plant.PlantName2                                                              as BusinessPlaceName,
      _plant.StateCode1                                                              as BusinessPlaceGSTStateCode,
      _plant.StateCode2                                                              as BusinessPlaceStateCode,
      case when _plant.StateCode2 = _supplier.Region then 'Local' else 'Central' end as Local_Centre,

      _OperationalAcctgDocItem.TaxSection,
      _OperationalAcctgDocItem.TaxItemAcctgDocItemRef,
      _OperationalAcctgDocItem.ReferenceDocumentType,
      _OperationalAcctgDocItem.OriginalReferenceDocument,
      _OperationalAcctgDocItem.AccountingDocumentItemRef,
      _OperationalAcctgDocItem.FiscalPeriod,
      _OperationalAcctgDocItem.PostingDate,
      _OperationalAcctgDocItem.DocumentDate,
      _OperationalAcctgDocItem.AccountingDocumentType,
      _OperationalAcctgDocItem.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _OperationalAcctgDocItem.AmountInCompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _OperationalAcctgDocItem.TaxBaseAmountInCoCodeCrcy,
      _OperationalAcctgDocItem.TransactionCurrency,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      _OperationalAcctgDocItem.AmountInTransactionCurrency,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      _OperationalAcctgDocItem.TaxBaseAmountInTransCrcy,
      _OperationalAcctgDocItem.IN_GSTPartner,
      _OperationalAcctgDocItem.IN_GSTPlaceOfSupply,
      _OperationalAcctgDocItem.IN_HSNOrSACCode

}
where
      _JournalEntry.IsReversal      <> 'X'
  and _JournalEntry.IsReversed      <> 'X'
  and _JournalEntry.TransactionCode =  'FB60'
