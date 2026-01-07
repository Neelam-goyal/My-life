@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DIM CDS for Plant'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #DIMENSION
@ObjectModel.representativeKey: 'Plant'
define view entity ZDIM_Plant
  as select from ZI_PlantTable
{
      @ObjectModel.text.element: ['PlantName']
  key PlantCode as Plant,
      
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @Semantics.text: true
      PlantName2 as PlantName,
      
      @EndUserText.label: 'PlantCompany'
      CompCode as PlantCompany,
      
      @Semantics.text: true
      @EndUserText.label: 'PlantCity'
      City as PlantCity,
      
      @Semantics.text: true
      @EndUserText.label: 'PlantDistrict'
      District as PlantDistrict,
      
      @Semantics.text: true
      @EndUserText.label: 'PlantAddress'
      Address1 as PlantAddress
}
