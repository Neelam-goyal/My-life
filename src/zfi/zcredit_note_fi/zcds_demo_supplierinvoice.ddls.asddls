@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DEMO CDS SUPPLIER INVOICE'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
    }
define view entity ZCDS_DEMO_SUPPLIERINVOICE as select from I_SupplierInvoiceAPI01
{
    key SupplierInvoice,
    key CompanyCode,
    key FiscalYear
}
