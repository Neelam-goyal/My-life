@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'customer value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_cutomervh as select from I_Customer as a
left outer join I_CustomerCompany as b on a.Customer = b.Customer
{
  key a.Customer,
   a.CustomerName,
   a.CityName,
   a.PostalCode,
   b.CompanyCode
}
