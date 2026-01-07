@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Work Center Value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zwork_center_vh as select distinct from ztable_plant as a
  left outer join I_WorkCenter as b on a.plant_code = b.Plant
{
//   key  a.comp_code,
   key  a.plant_code,
   key  a.plant_name1,
   key b.WorkCenter
 }
  
