@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help For Plant Value'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPlantValueHelp as
  select from ztable_plant as a
//  left outer join I_MfgOrderConfirmation as b on a.plant_code = b.Plant
//  left outer join I_MfgOrderDocdGoodsMovement as c on b.MaterialDocument = c.GoodsMovement
{
   key  a.comp_code,
   key  a.plant_code
//   @UI.hidden: true
//    b.ManufacturingOrder as manufacturing_order,
//    @UI.hidden: true
//    c.Material as Material
}
//group by c.Material,
//a.plant_code,a.comp_code,b.ManufacturingOrder
