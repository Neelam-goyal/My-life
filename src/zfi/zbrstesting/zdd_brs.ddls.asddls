@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BRS Testing report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_brs as select distinct from I_OperationalAcctgDocItem
{
    key CompanyCode,
    key AccountingDocument,
    key FiscalYear,
    key AccountingDocumentItem,
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'  
    AmountInCompanyCodeCurrency,
    @UI.hidden: true
    CompanyCodeCurrency
}
where ( AccountingDocument = '4900000130'
   or AccountingDocument = '4900000131'
   or AccountingDocument = '4900000132' )
   and FiscalYear = '2025'
