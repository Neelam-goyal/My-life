@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VAlue help for voucher number'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDSVouchernoVH as select distinct from I_OperationalAcctgDocItem
{
//  key CompanyCode,
  key AccountingDocument
//  key FiscalYear
//  key AccountingDocumentItem
//  key WithholdingTaxType
//    AccountingDocument,
//    CompanyCode
}
