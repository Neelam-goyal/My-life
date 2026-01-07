@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Mfg Order Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION

@Search.searchable: true
@ObjectModel: {
  supportedCapabilities: [ #ANALYTICAL_DIMENSION ],
  modelingPattern: #ANALYTICAL_DIMENSION,
  representativeKey: 'ManufacturingOrderType'
}

define view entity ZDIM_MfgOrderType
  as select from I_MfgOrderTypeText
{
      @EndUserText.quickInfo: 'Mfg. Order Type'
      @ObjectModel.text.element: [ 'ManufacturingOrderTypeName' ]
  key ManufacturingOrderType,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #MEDIUM
      ManufacturingOrderTypeName

}
where
  Language = 'E'
