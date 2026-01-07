@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'value help fot glaccount'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity z_glaccountvh as select distinct from I_OperationalAcctgDocItem
{
//  key CompanyCode,
  key GLAccount
//  key FiscalYear
//  key AccountingDocumentItem
//  key WithholdingTaxType
//    AccountingDocument,
//    CompanyCode
}
