@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'material consumption REP'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZR_MATERIALCONSUP_REP as select from zrepmaterials
{
    @EndUserText.label   : 'Plant'
      @UI.selectionField   : [{ position: 40 }]
      @Consumption.filter  : { mandatory: true  }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
      @UI.lineItem: [{ position: 10 ,label: 'Plant' }]
    key plant as Plant
    
//    @UI.selectionField   : [{ position: 30 }]
//      @EndUserText.label   : 'Material'
//      @Consumption.filter  : { mandatory: true }
//    key material as Material,
//    
//     @UI.selectionField   : [{ position: 50 }]
//      @EndUserText.label   : 'Date'
//      @Consumption.filter  : { mandatory: true }
//    key rangedate as Rangedate,
//    quantity as Quantity,
//    um as Um,
//    actual_qty as ActualQty,
//    difference as Difference,
//    batch as Batch,
//    storagelocation as Storagelocation
}
