@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'value help for Document Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDocumentTypeVH as select distinct from I_OperationalAcctgDocItem
{
//  key CompanyCode,
  key  AccountingDocumentType
//  key FiscalYear
//  key AccountingDocumentItem
//  key WithholdingTaxType
//    AccountingDocument,
//    CompanyCode
}
