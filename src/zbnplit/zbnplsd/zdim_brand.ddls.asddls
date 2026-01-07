@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Brand'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'Brandcode'
define view entity ZDIM_Brand
  as select from zmaster_tab
{
      @EndUserText.label: 'Brand'
      @ObjectModel.text.element: [ 'Brandtag' ]
  key brandcode as Brandcode,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #MEDIUM
      @EndUserText.label: 'Product Brand'
      brandtag  as Brandtag
}
