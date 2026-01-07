@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Company'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'CompanyCode'

define view entity ZDIM_Company
  as select from I_CompanyCode
{
      @ObjectModel.text.element: ['CompanyCodeName']
  key CompanyCode,
      @Semantics.text:true
      CompanyCodeName
}
