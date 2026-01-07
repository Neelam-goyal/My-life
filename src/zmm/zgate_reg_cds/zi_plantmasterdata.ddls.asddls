@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant gate cds'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PlantMasterData as select distinct from ZI_PlantTable {
    key PlantCode as Plant,
    key CompCode as CompanyCode,
    PlantName1 as PlantName,
    GstinNo as PlantGST
};
