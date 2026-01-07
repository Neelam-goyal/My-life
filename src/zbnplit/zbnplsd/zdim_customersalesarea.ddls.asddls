@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Customer Sales Area'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDIM_CustomerSalesArea
  as select from I_CustomerSalesArea
{
  key Customer,
  key SalesOrganization,
  key DistributionChannel,
  key Division,
    RecordCreatedDate
}
where
      SalesBlockForCustomer     is initial
  and OrderIsBlockedForCustomer is initial
