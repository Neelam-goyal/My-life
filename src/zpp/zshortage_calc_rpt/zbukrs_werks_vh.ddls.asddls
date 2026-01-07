@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VH for Plant based on BUKRS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zbukrs_werks_vh
  as select from ztable_plant
{
  key comp_code  as bukrs,
  key plant_code as plant
}
