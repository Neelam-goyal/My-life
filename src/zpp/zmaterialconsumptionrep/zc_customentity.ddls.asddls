@EndUserText.label: 'Custom Entity for material consumption'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MATCONREP'
@UI.headerInfo: {
typeName: 'Lines',
typeNamePlural: 'Lines'
}
define custom entity ZC_CUSTOMENTITY
{


      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Plant'
      @Consumption.filter : { mandatory: true, selectionType: #SINGLE }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
      @UI.lineItem    : [{ position: 40 ,label: 'Plant' }]
  key plant           : abap.char(4);


      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Material'
      @Consumption.filter : { mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
      @UI.lineItem    : [{ position: 10 ,label: 'Material' }]
  key material        : abap.char(40);

      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'From Date'
      @Consumption.filter : { mandatory: true, selectionType: #SINGLE }
      @UI.lineItem    : [{ position: 50, label: 'From Date' }]
  key rangedate       : abap.datn;

      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'To Date'
      @Consumption.filter : { mandatory: true, selectionType: #SINGLE }
      @UI.lineItem    : [{ position: 55, label: 'To Date' }]
  key todate          : abap.datn;

      @UI.selectionField: [{ position: 45 }]
      @EndUserText.label: 'Shift'
      @UI.lineItem    : [{ position: 56, label: 'Shift' }]
  key shift           : abap.char(6);

      @UI.lineItem    : [{ position: 80,  label: 'Material Description' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'Material Description'
      matdesc         : abap.char(40);


      @UI.lineItem    : [{ position: 90,  label: 'Quantity' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'Quantity'
      quantity        : abap.dec(20,3);


      @UI.lineItem    : [{ position: 100,  label: 'UOM' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'Unit of Measure'
      um              : abap.char(3);

      @UI.lineItem    : [{ position: 110,  label: 'Actual Quantity' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'actual_qty'
      actual_qty      : abap.dec(20,3);

      @UI.lineItem    : [{ position: 120,  label: 'Difference' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'Difference'
      difference      : abap.int2;

      @UI.lineItem    : [{ position: 130,  label: 'Storage Location' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'storagelocation'
      storagelocation : abap.char(4);

      @UI.lineItem    : [{ position: 140,  label: 'Movement Type' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'movementtype'
      movementtype    : abap.numc(4);

      @UI.lineItem    : [{ position: 150, label: 'Batch' }]
      @Consumption.filter.hidden: true
      @EndUserText.label: 'Batch'
      batch           : abap.char(10);

}
