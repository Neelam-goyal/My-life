@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For Tracking Ref. of Payment Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PaymentDocumentRef
  as select from I_GLAccountLineItemRawData
{
  key SourceLedger,
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument,

      AccountingDocumentType,
      AccountingDocumentItem,
      GLAccount,
      Supplier,
      Customer,
      OffsettingAccount,
      BusinessTransactionType,
      AssignmentReference,
      AccountingDocumentCategory,
      JournalEntryItemCategory,
      _OffsettingAccount.OffsettingAccountName
}
where
       SourceLedger           =  '0L'
  and  OffsettingAccount      <> Supplier
  and  OffsettingAccount      <> Customer
  and(
       AccountingDocumentType =  'DZ'
    or AccountingDocumentType =  'KG'
    or AccountingDocumentType =  'KR'
    or AccountingDocumentType =  'EZ'
    or AccountingDocumentType =  'KZ'
  )
group by
  SourceLedger,
  CompanyCode,
  FiscalYear,
  AccountingDocument,

  AccountingDocumentType,
  AccountingDocumentItem,
  GLAccount,
  Supplier,
  Customer,
  OffsettingAccount,
  BusinessTransactionType,
  AssignmentReference,
  AccountingDocumentCategory,
  JournalEntryItemCategory,
  _OffsettingAccount.OffsettingAccountName
