@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Sales Organization'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'SalesOrganization'

define view entity ZDIM_SalesOrganization
  as select from I_SalesOrganizationText
{
      @ObjectModel.text.element: ['SalesOrganizationName']
  key SalesOrganization,

      @Semantics.text:true
      SalesOrganizationName

}
where
  Language = 'E'
