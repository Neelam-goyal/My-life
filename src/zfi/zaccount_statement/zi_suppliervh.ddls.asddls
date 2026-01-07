@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'supplier value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_suppliervh as select from I_Supplier as a
left outer join I_SupplierCompany as b on a.Supplier = b.Supplier
{
    key a.Supplier,
    a.SupplierFullName,
    b.CompanyCode
    
}
