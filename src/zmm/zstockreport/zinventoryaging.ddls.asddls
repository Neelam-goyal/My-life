@EndUserText.label: 'Inventory Aging'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_INVENTORYAGING'
@UI.headerInfo: {typeName: 'Inventory Aging'}
define custom entity ZInventoryAging
{
  @UI.selectionField: [{ position: 10 }]
  @Consumption.valueHelpDefinition: [{ entity: {name:'I_CompanyCodeVH', element: 'CompanyCode' } }]
  @Consumption.filter: {mandatory: true}
  @UI.lineItem         : [{ position:10, label:'Company Code' }]
  key companycode : bukrs;
  
  @UI.selectionField: [{ position: 20 }]
  @Consumption.valueHelpDefinition: [{ entity: {name:'I_PlantStdVH', element: 'Plant' } }]
  @Consumption.filter: {mandatory: true}
  @UI.lineItem         : [{ position:20, label:'Plant' }]
  key plantcode : werks_d;
  
  @UI.selectionField: [{ position: 30 }]
  @Consumption.valueHelpDefinition: [{ entity: {name:'I_StorageLocationStdVH', element: 'StorageLocation' } }]
  @Consumption.valueHelpDefinition: [{ additionalBinding: [{ element: 'Plant', localElement: 'plantcode' }]  }]
  @UI.lineItem         : [{ position:30, label:'Storage Location' }]
  key StorageLocation : abap.char( 4 );
  
  @UI.selectionField: [{ position: 35 }]
  @Consumption.valueHelpDefinition: [{ entity: {name:'I_ProductType', element: 'ProductType' } }]
  @UI.lineItem         : [{ position:45, label:'Product Type' }]
  key Producttype : abap.char( 4 );
  
  @UI.selectionField: [{ position: 40 }]
  @Consumption.valueHelpDefinition: [{ entity: {name:'I_ProductStdVH', element: 'Product' } }]
  @UI.lineItem         : [{ position:40, label:'Product' }]
  key product : abap.char( 40 );
  
  @UI.lineItem         : [{ position:50, label:'Product name' }]
  productname : abap.char( 80 );
  
  @UI.lineItem         : [{ position:60, label:'Current Stock' }]
  currentstock : abap.dec( 12, 3 );
  
  @UI.lineItem         : [{ position:70, label:'Current Value' }]
  currentvalue : abap.dec( 12, 2 );
  
  @UI.lineItem         : [{ position:80, label:'0-30 Days Quantity' }]
  period1stock : abap.dec( 12, 3 );

  @UI.lineItem         : [{ position:90, label:'0-30 Days Value' }]
  period1value : abap.dec( 12, 2 );

  @UI.lineItem         : [{ position:100, label:'30-60 Days Quantity' }]
  period2stock : abap.dec( 12, 3 );

  @UI.lineItem         : [{ position:110, label:'30-60 Days Value' }]
  period2value : abap.dec( 12, 2 );

  @UI.lineItem         : [{ position:120, label:'60-90 Days Quantity' }]
  period3stock : abap.dec( 12, 3 );

  @UI.lineItem         : [{ position:130, label:'60-90 Days Value' }]
  period3value : abap.dec( 12, 2 );

  @UI.lineItem         : [{ position:140, label:'>90 Days Quantity' }]
  period4stock : abap.dec( 12, 3 );

  @UI.lineItem         : [{ position:150, label:'>90 Days Value' }]
  period4value : abap.dec( 12, 2 );
  
}
