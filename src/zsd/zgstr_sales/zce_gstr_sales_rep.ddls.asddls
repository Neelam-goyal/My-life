@EndUserText.label: 'CUSTOM ENTITY GSTR SALES REPORT'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_GSTR_SALES_REP'
@UI.headerInfo: {
typeName: 'Lines',
typeNamePlural: 'Lines'
}
define custom entity ZCE_GSTR_SALES_REP
{

      @UI.selectionField : [{ position: 10 }]
      @UI.lineItem : [{ position: 45, label:'Company Code' }]
      @EndUserText.label   : 'Company Code'
      @Consumption.filter:{ mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode', name: 'I_CompanyCodeStdVH' }}]
  key comp_code    : abap.char(4);


      @UI.selectionField : [{ position: 12 }]
      @UI.lineItem : [{ position: 50, label:'Invoice Date' }]
      @EndUserText.label   : 'Invoice Date'
      @Consumption.filter:{ mandatory: true }
  key Invoice_Date : abap.datn;

      @UI.selectionField : [{ position: 11 }]
      @UI.lineItem : [{ position: 46, label:'Plant' }]
      @EndUserText.label   : 'Plant'
      @Consumption.filter:{ mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity:{ element: 'plant_code', name: 'ZPlantValueHelp' }}]
  key plant_code   : abap.char(4);

      @UI.selectionField : [{ position: 13 }]
      @UI.lineItem : [{ position: 47, label:'Invoice No' }]
      @EndUserText.label   : 'Invoice No'
      @UI.hidden   : true
  key invoice      : abap.char(12);


      @UI.selectionField : [{ position: 13 }]
      @UI.lineItem : [{ position: 47, label:'Bill No' }]
      @EndUserText.label   : 'Bill No'
  key bill_no      : abap.char(12);

      @UI.lineItem : [{ position: 51, label:'Invoice Line Item' }]
      @EndUserText.label   : 'Invoice Line Item'
  key Line_Item    : abap.char(12);

      @UI.lineItem : [{ position: 52, label:'Doc Type' }]
      @EndUserText.label   : 'Doc Type'
      doc_type     : abap.char(4);

      @UI.lineItem : [{ position: 53, label:'Nature' }]
      @EndUserText.label   : 'Nature'
      nature       : abap.char(3);

      @UI.lineItem : [{ position: 54, label:'Location' }]
      @EndUserText.label   : 'Location'
      Location     : abap.char(60);

      @UI.lineItem : [{ position: 55, label:'Party Name' }]
      @EndUserText.label   : 'Party Name'
      Party_name   : abap.char(100);

      @UI.lineItem : [{ position: 56, label:'Party GSTIN' }]
      @EndUserText.label   : 'Party GSTIN'
      Party_gst    : abap.char(16);

      @UI.lineItem : [{ position: 57, label:'Party State' }]
      @EndUserText.label   : 'Party State'
      Party_state  : abap.char(20);

      @UI.lineItem : [{ position: 58, label:'Local Centre' }]
      @EndUserText.label   : 'Local Centre'
      Local_centre : abap.char(20);

      @UI.lineItem : [{ position: 59, label:'HSN' }]
      @EndUserText.label   : 'HSN'
      hsn_code     : abap.char(10);

      @UI.lineItem : [{ position: 59, label:'Material' }]
      @EndUserText.label   : 'Material'
      @UI.hidden: true
      matnr    : abap.char(10);

      @UI.lineItem : [{ position: 59, label:'Item' }]
      @EndUserText.label   : 'Item'
      item         : abap.char(50);

      @UI.lineItem : [{ position: 60, label:'GST Rate' }]
      @EndUserText.label   : 'GST Rate'
      gst_rate     : abap.char(3);

      @UI.lineItem : [{ position: 61, label:'QTY' }]
      @EndUserText.label   : 'QTY'
      qty          : abap.dec(13,3);

      @UI.lineItem : [{ position: 62, label:'UOM' }]
      @EndUserText.label   : 'UOM'
      uom          : abap.unit(3);

      @UI.lineItem : [{ position: 63, label:'Rate' }]
      @EndUserText.label   : 'Rate'
      rate         : abap.dec(13,2);

      @UI.lineItem : [{ position: 64, label:'Amount' }]
      @EndUserText.label   : 'Amount'
      amnt         : abap.dec(10,2);

      @UI.lineItem : [{ position: 64, label:'Total Taxable Amount' }]
      @EndUserText.label   : 'Total Taxable Amount'
      taxableamnt  : abap.dec(10,2);

      @UI.lineItem : [{ position: 64, label:'Total Invoice Value' }]
      @EndUserText.label   : 'Total Invoice Value'
      totamnt      : abap.dec(10,2);

      @UI.lineItem : [{ position: 65, label:'TCS' }]
      @EndUserText.label   : 'TCS'
      //      @UI.hidden: true
      tcs          : abap.dec(10,2);


      @UI.lineItem : [{ position: 65, label:'IGST' }]
      @EndUserText.label   : 'IGST'
      igst         : abap.dec(10,2);

      @UI.lineItem : [{ position: 65, label:'SGST' }]
      @EndUserText.label   : 'SGST'
      sgst         : abap.dec(10,2);

      @UI.lineItem : [{ position: 66, label:'CGST' }]
      @EndUserText.label   : 'CGST'
      cgst         : abap.dec(10,2);

      @UI.lineItem : [{ position: 67, label:'IRN ACK.' }]
      @EndUserText.label   : 'IRN ACK.'
      irnACK       : abap.char(64);

      @UI.lineItem : [{ position: 67, label:'IRN No.' }]
      @EndUserText.label   : 'IRN No.'
      irn          : abap.char(64);

      @UI.lineItem : [{ position: 68, label:'IRN Date' }]
      @EndUserText.label   : 'IRN Date'
      irn_date     : abap.char(21);

      @UI.lineItem : [{ position: 69, label:'E-Way Bill No.' }]
      @EndUserText.label   : 'E-Way Bill No.'
      eway_bill    : abap.char(10);

      @UI.lineItem : [{ position: 70, label:'E-Way Bill Date' }]
      @EndUserText.label   : 'E-Way Bill Date'
      eway_date    : abap.dec(21);





}
