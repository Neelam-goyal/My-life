@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Customer With Sales Area'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'Customer'
define view entity ZDIM_CustomerWithSalesArea
  as select from ZTBLF_CUSTOMERSALESAREA as A
  association to ZDIM_DistributionChannel   as _DistributionChannel on  $projection.DistChannel = _DistributionChannel.DistributionChannel
  association [0..1] to I_SalesOrganization            as _SalesOrganization             on  $projection.SalesOrg = _SalesOrganization.SalesOrganization
{
   
    @ObjectModel.text.element: ['CustomerName']
 key A.Customer,
 
  @Semantics.text:true
  A.CustomerName,
  
  @Semantics.text:true
  @EndUserText.label: 'GSTIN'
  A.GSTIN,
  
  @Semantics.text:true
  @EndUserText.label: 'City'
  A.City,
  
  @Semantics.text:true
  @EndUserText.label: 'State'
  State,
  
  @Semantics.text:true
  @EndUserText.label: 'Country'
  A.Country,
  
   @Semantics.text:true
   @EndUserText.label: 'SalesOrg.'
   @ObjectModel.foreignKey.association: '_SalesOrganization'
  SalesOrg,
  _SalesOrganization.CompanyCode,
  
  @Semantics.text:true
  @EndUserText.label: 'Dist.Channel'
  A.DistChannel,
  
  @Semantics.text:true
  @EndUserText.label: 'Division'
  A.Division,
  
  @Semantics.text:true
  @EndUserText.label: 'SSCode'
  A.SSCode,
  
  _DistributionChannel,
  _SalesOrganization
}
