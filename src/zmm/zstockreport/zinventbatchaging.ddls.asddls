@EndUserText.label: 'Inventory Aging - Batch wise'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_INVENTBATCHAGING'
@UI.headerInfo: {typeName: 'Inventory Aging - Batch wise', typeNamePlural: 'Inventory Aging - Batch wise'}
define custom entity ZInventBatchAging
{
      @UI.selectionField: [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_PlantStdVH', element: 'Plant' } }]
      @Consumption.filter: {mandatory: true}
      @UI.lineItem    : [{ position:20, label:'Plant' }]
  key plantcode       : werks_d;

      @UI.selectionField: [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_StorageLocationStdVH', element: 'StorageLocation' } }]
      @Consumption.valueHelpDefinition: [{ additionalBinding: [{ element: 'Plant', localElement: 'plantcode' }]  }]
      @UI.lineItem    : [{ position:30, label:'Storage Location' }]
  key StorageLocation : abap.char( 4 );

      @UI.selectionField: [{ position: 40 }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_ProductStdVH', element: 'Product' } }]
      @UI.lineItem    : [{ position:40, label:'Product' }]
  key Product         : abap.char( 40 );

      @Consumption.valueHelpDefinition: [{ entity: {name:'I_BatchStdVH', element: 'Batch' } }]
      @Consumption.valueHelpDefinition: [{ additionalBinding: [{ element: 'Product', localElement: 'product' }]  }]
      @UI.lineItem    : [{ position:50, label:'Batch' }]
  key Batch           : abap.char( 10 );

      @UI.selectionField: [{ position: 45 }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_ProductType', element: 'ProductType' } }]
      @UI.lineItem    : [{ position:45, label:'Product Type' }]
      @Consumption.filter.hidden: true
      Producttype     : abap.char( 4 );

      @UI.lineItem    : [{ position: 51, label: 'Product Group' }]
      @Consumption.filter.hidden: true
      productgroup    : abap.char(9);
      

      @UI.lineItem    : [{ position: 53, label: 'Product Group2' }]
      @Consumption.filter.hidden: true
      productgroup2    : abap.char(9);      

      @UI.selectionField: [{ position: 10 }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_CompanyCodeVH', element: 'CompanyCode' } }]
      //  @Consumption.filter: {mandatory: true}
      @UI.lineItem    : [{ position:10, label:'Company Code' }]
      @Consumption.filter.hidden: true
      companycode     : bukrs;

      @UI.lineItem    : [{ position:45, label:'Product name' }]
      @Consumption.filter.hidden: true
      productname     : abap.char( 80 );
      
      

      @UI.lineItem    : [{ position:46, label:'Product Brand Name' }]
      @Consumption.filter.hidden: true
      brandname       : abap.char( 40 );

      @UI.lineItem    : [{ position:60, label:'Batch Mfg Dt.' }]
      @Consumption.filter.hidden: true
      batchmfgdate    : abap.dats;

      @UI.lineItem    : [{ position:70, label:'Shelf Expiry Dt.' }]
      @Consumption.filter.hidden: true
      shelfexpirydate : abap.dats;

      @UI.lineItem    : [{ position:72, label:'MonthYear' }]
      @Consumption.filter.hidden: true
      monthyear       : abap.char(7);

      @UI.lineItem    : [{ position:80, label:'Current Stock' }]
      @Consumption.filter.hidden: true
      currentstock    : abap.dec( 20, 3 );

      @UI.lineItem    : [{ position:90, label:'Current Value' }]
      @Consumption.filter.hidden: true
      currentvalue    : abap.dec( 20, 2 );

      @UI.lineItem    : [{ position:100, label:'Age Days' }]
      @Consumption.filter.hidden: true
      agedays         : abap.int2;

      @UI.lineItem    : [{ position:110, label:'Prd Shelf Days' }]
      @Consumption.filter.hidden: true
      prd_shelf_days  : abap.char(4);

      @UI.lineItem    : [{ position:120, label:'Left Days' }]
      @Consumption.filter.hidden: true
      left_shelfdays  : abap.char(8);

      @UI.lineItem    : [{ position:130, label:'Remaining Life%' }]
      @Consumption.filter.hidden: true
      rem_life        : abap.dec(10,2);

}
