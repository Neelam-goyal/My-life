@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bread Account Statment'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_BREADACData
  as select from ZR_AccountStatement
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,
  key AccountingDocumentItem,
      PartyCode,
      PartyName,
      GLAccount,
      GLAccountName,
      PostingDate,
      DocumentDate,
      NetDueDate,
      AccountingDocumentType,
      DocumentReferenceID,
      ReferenceDocumentType,
      OriginalReferenceDocument,
      PaymentReference,
      InvoiceReference,
      SalesDocument,
      PurchasingDocument,
      DocumentItemText,
      BusinessTransactionType,
      CostCenter,
      ProfitCenter,
      FunctionalArea,
      BusinessArea,
      BusinessPlace,
      Segment,
      Plant,
      IsExcSplGL,
      SpecialGLCode,
      SpecialGLTransactionType,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      TDSAmtinCmpCodeCurr,
      ControllingArea,
      ReversalReason,
      IsReversal,
      IsReversed,
      IsRevDoc,
      ReversedReferenceDocument,
      ReversalReferenceDocument,
      ReversedDocument,
      ReverseDocument,
      IsSalesRelated,
      DebitCreditCode,
      CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      AmountInCompanyCodeCurrency,
      JournalEntryLastChangeDateTime
}
where
       AccountingDocumentType <> 'RV'
  and(
       CompanyCode            =  'BNPL'
    or CompanyCode            =  'BIPL'
    or CompanyCode            =  'CAPL'
  )
