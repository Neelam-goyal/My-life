@EndUserText.label: 'CUSTOM ENTITY iInvoice Series Report'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_INV_SERIES_REP'
@UI.headerInfo: {
typeName: 'Lines',
typeNamePlural: 'Lines'
}
define custom entity ZCE_INV_SERIES_REP
{
      @UI.selectionField : [{ position: 1 }]
      @UI.lineItem    : [{ position: 45, label:'Company Code' }]
      @EndUserText.label   : 'Company Code'
      //      @Consumption.filter:{ mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode', name: 'I_CompanyCodeStdVH' }}]
  key comp_code       : abap.char(4);

      @UI.selectionField : [{ position: 2 }]
      @UI.lineItem    : [{ position: 46, label:'Unit' }]
      @EndUserText.label   : 'Unit'
      //      @Consumption.filter:{ mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity:{ element: 'plant_code', name: 'ZPlantValueHelp' }}]
  key plant_code      : abap.char(4);

      //      @UI.selectionField : [{ position: 11 }]
      @UI.lineItem    : [{ position: 47, label:'Unit Series' }]
      @EndUserText.label   : 'Unit Series'
      //      @Consumption.filter:{ mandatory: true }
  key unit_series     : abap.char(2);

      @UI.selectionField : [{ position: 3}]
      @UI.lineItem    : [{ position: 48, label:'Bill Type' }]
      @EndUserText.label   : 'Bill Type'
      //      @UI.hidden      : true
  key billtype        : abap.char(4);

      //      @UI.selectionField : [{ position: 13 }]
      @UI.lineItem    : [{ position: 47, label:'Bill No' }]
      @EndUserText.label   : 'Bill No'
      @UI.hidden      : true
  key Bill_no         : abap.char(12);

      //      @UI.selectionField : [{ position: 13 }]
      @UI.lineItem    : [{ position: 47, label:'Start No' }]
      @UI.hidden : true
      @EndUserText.label   : 'Start No'
      bill4       : abap.char(6);


      //      @UI.selectionField : [{ position: 13 }]
      @UI.lineItem    : [{ position: 50, label:'Start No' }]
      @EndUserText.label   : 'Start No'
      start_no        : abap.char(12);

      @UI.lineItem    : [{ position: 51, label:'End No' }]
      @EndUserText.label   : 'Invoice Line Item'
      end_no          : abap.char(12);

      @UI.lineItem    : [{ position: 49, label:'SDoc' }]
      @EndUserText.label   : 'SDoc'
      sdoc            : abap.char(20);

      @UI.lineItem    : [{ position: 52, label:'Count' }]
      @EndUserText.label   : 'Count'
      total_count     : abap.char(10);

      @UI.lineItem    : [{ position: 53, label:'Cancelled Count' }]
      @EndUserText.label   : 'Cancelled Count'
      cancelled_count : abap.char(10);

}
