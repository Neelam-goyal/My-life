@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FB 60 RCM PURCHASE DOCS DETAILS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_RCMPURCHASEDOCSDTLS
  as select from ZR_RCMPURCHASEDOCS as Mst
    inner join   ZR_FB60_Records    as Data on  Mst.AccountingDocument = Data.AccountingDocument
                                            and Mst.CompanyCode        = Data.CompanyCode
                                            and Mst.FiscalYear         = Data.FiscalYear

{
  key Data.AccountingDocument,
  key Data.CompanyCode,
  key Data.FiscalYear,
  key Data.AccountingDocumentItem,

      Data.DocumentReferenceID,
      Data.DocumentReferenceDate,
      Data.AccountingDocumentItemType,
      Data.FinancialAccountType,
      Data.DebitCreditCode,
      Data.TaxCode,
      Data.TaxCodeName,
      Data.TaxRate,
      Data.SGSTRate,
      Data.CGSTRate,
      Data.IGSTRate,
      Data.TaxRateValidityStartDate,
      Data.WithholdingTaxCode,
      Data.TaxType,
      Data.TaxItemGroup,
      Data.TransactionTypeDetermination,
      Data.ValueDate,
      Data.AssignmentReference,
      Data.DocumentItemText,
      Data.IsOpenItemManaged,
      Data.IsAutomaticallyCreated,
      Data.OperationalGLAccount,
      Data.GLAccount,
      Data.GLAccountName,
      Data.Supplier,
      Data.SupplierName,
      Data.Region,
      Data.GSTNumber,
      Data.PaymentTerms,
      Data.ProfitCenter,
      Data.Reference3IDByBusinessPartner,
      Data.TaxDeterminationDate,
      Data.BusinessPlace,
      Data.BusinessPlaceName,
      Data.BusinessPlaceGSTStateCode,
      Data.BusinessPlaceStateCode,
      Data.Local_Centre,
      Data.TaxSection,
      Data.TaxItemAcctgDocItemRef,
      Data.ReferenceDocumentType,
      Data.OriginalReferenceDocument,
      Data.AccountingDocumentItemRef,
      Data.FiscalPeriod,
      Data.PostingDate,
      Data.DocumentDate,
      Data.AccountingDocumentType,
      Data.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      Data.AmountInCompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      Data.TaxBaseAmountInCoCodeCrcy,
      Data.TransactionCurrency,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      Data.AmountInTransactionCurrency,
      @Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
      Data.TaxBaseAmountInTransCrcy,
      Data.IN_GSTPartner,
      Data.IN_GSTPlaceOfSupply,
      Data.IN_HSNOrSACCode
}
