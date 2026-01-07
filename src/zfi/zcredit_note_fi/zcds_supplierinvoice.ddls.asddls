@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS For supplier invoice value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zcds_supplierInvoice as select from I_SupplierInvoiceAPI01
{
    key SupplierInvoice,
    key  CompanyCode,
    key FiscalYear
}
