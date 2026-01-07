@EndUserText.label: 'Material Variance Paramater'
define abstract entity Z_I_MATVARPARM
{
  @EndUserText.label: 'Plant'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]
  PlantNo         : abap.char( 4 );

  @EndUserText.label: 'Production Date'
  prodorderdate   : abap.dats;

  @EndUserText.label: 'Production To Date'
  prodordertodate : abap.datn;

}
