@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Region'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'Region'

define view entity ZDIM_Region
  as select from I_RegionText
    association [0..1] to I_Region   as _Region   on  $projection.Region  = _Region.Region
                                                and $projection.Country = _Region.Country
  association [0..1] to I_Country  as _Country  on  $projection.Country = _Country.Country
  
{
      @ObjectModel.text.element: ['RegionName']
  key Region,
      @ObjectModel.foreignKey.association: '_Country'
  key Country,  
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @Semantics.text: true
      RegionName,
      _Country,
      _Region

}
where
  Language = 'E' 
  
