@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'material consumption REP'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_materialconsuptionREP
  as select from zrepmaterials
{
      @EndUserText.label   : 'Plant'
      @UI.selectionField   : [{ position: 40 }]
      @Consumption.filter  : { mandatory: true  }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
      @UI.lineItem: [{ position: 10 ,label: 'Plant' }]
  key plant           as Plant,

      @EndUserText.label   : 'Material'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
      @Consumption.filter  : { mandatory: true  }
  key material        as Material,

      @EndUserText.label   : 'Date'
      @Consumption.filter  : { mandatory: true  }
  key rangedate       as From_Date,
      todate          as To_Date,
      shift           as Shift,
      quantity        as Quantity,
      um              as Um,
      actual_qty      as Actual_Qty,
      difference      as Difference,
      batch           as Batch,
      storagelocation as Storagelocation,
      movementtype    as Movementtype

}
