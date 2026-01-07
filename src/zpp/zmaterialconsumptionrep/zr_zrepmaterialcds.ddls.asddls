@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FORZREPMATERIAL'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_zrepmaterialCDS
  as select from zrepmaterials

{
      @EndUserText.label   : 'Plant'
      @UI.selectionField   : [{ position: 40 }]
    //      @Consumption.filter  : { mandatory: true  }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
      @UI.lineItem: [{ position: 10 ,label: 'Plant' }]
  key plant           as Plant,

      @EndUserText.label   : 'Material'
      @UI.selectionField   : [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
      //      @Consumption.filter  : { mandatory: true  }
  key material        as Material,

      @EndUserText.label   : 'From Date'
      @UI.selectionField   : [{ position: 50 }]
      //       @Consumption.filter  : { mandatory: true  }
  key rangedate       as Fromdate,

      @EndUserText.label   : 'To Date'
      @UI.selectionField   : [{ position: 60 }]
      //       @Consumption.filter  : { mandatory: true  }
      todate          as Todate,
      shift           as Shift,
      quantity        as Quantity,
      @EndUserText.label   : 'UOM'
      um              as Um,
      @EndUserText.label   : 'Actual Qty'
      actual_qty      as ActualQty,
      difference      as Difference,
      batch           as Batch,
      @EndUserText.label   : 'Storage Location'
      storagelocation as Storagelocation,
      movementtype    as Movementtype,
      @EndUserText.label   : 'Material Description'
      matdesc         as Matdesc

}
