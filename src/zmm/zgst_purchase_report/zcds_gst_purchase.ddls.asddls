@EndUserText.label: 'GST PURCHASE REPORT'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_GST_PURCHASE_REPORT'
@UI.headerInfo: {typeName: 'GST PURCHASE REPORT' , typeNamePlural : 'GST PURCHASE REPORT' }
define custom entity ZCDS_GST_PURCHASE
{

      @UI.identification: [ { position: 20 , label: 'MRN Number' } ]
      @EndUserText.label    : 'MRN Number'
      //      @UI.selectionField    : [{ position:20 }]
      @UI.lineItem   : [{ position:40, label:'MRN Number' }]
  key mrn_no         : abap.numc(10);

      @UI.identification: [ { position: 50 , label: 'Supplier Invoice' } ]
      @EndUserText.label    : 'Supplier Invoice'
      //      @UI.selectionField    : [{ position:50 }]
      @UI.hidden: true
      @UI.lineItem   : [{ position:61, label:'Supplier Invoice' }]
      key supplier_inv  : abap.numc(10);

      @UI.identification: [ { position: 50 , label: 'Supplier Line Item' } ]
      @EndUserText.label    : 'Supplier Line Item'
      //      @UI.selectionField    : [{ position:50 }]
      @UI.lineItem   : [{ position:61, label:'Supplier Line Item' }]
      @UI.hidden: true
     key  supplier_item  : abap.numc(10);

      @UI.identification: [ { position: 40 , label: 'Bill Number' } ]
      @EndUserText.label    : 'Bill Number'
      //      @UI.selectionField    : [{ position:40 }]
      @UI.lineItem   : [{ position:60, label:'Bill Number' }]
      bill_no        : abap.char(20);

      @UI.facet      : [ {
         id          : 'idgstpurchasereport',
         purpose     : #STANDARD,
         type        : #IDENTIFICATION_REFERENCE,
         label       : 'GST_PURCHASE_REPORT',
         position    : 10
       } ]
      @UI.identification: [ { position: 10 , label: 'Document TYPE' } ]
      @EndUserText.label    : 'Document Type'
      @UI.selectionField    : [{ position:10 }]
      @UI.lineItem   : [{ position:30, label:'Document Type' }]
      @Consumption.valueHelpDefinition : [{ entity : { name : 'ZCDS_DOCTYPEVALUEHELP' , element : 'purchaseordertype' } }]
      doc_type       : abap.char(4);

      @UI.identification: [ { position: 30 , label: 'HSN/SAC Code' } ]
      @EndUserText.label    : 'HSN/SAC Code'
      //      @UI.selectionField    : [{ position:30 }]
      @UI.lineItem   : [{ position:50, label:'HSN/SAC Code' }]
      hsn_code       : abap.numc(10);

      @UI.identification: [ { position: 50 , label: 'Supplier Code' } ]
      @EndUserText.label    : 'Supplier Code'
      //      @UI.selectionField    : [{ position:50 }]
      @UI.lineItem   : [{ position:61, label:'Supplier Code' }]
      supplier_code  : abap.numc(10);

      //      @UI.selectionField    : [{ position:90 }]
      @UI.identification: [ { position: 60 , label: 'MRN Date' } ]
      @EndUserText.label    : 'MRN Date'
      @UI.lineItem   : [{ position:70, label:'MRN Date' }]
      mrn_date       : abap.dats;

      @UI.selectionField    : [{ position:60 }]
      @UI.identification: [ { position: 70 , label: 'Bill Date' } ]
      @EndUserText.label    : 'Bill Date'
      @UI.lineItem   : [{ position:80, label:'Bill Date' }]
      //     @Consumption.valueHelpDefinition: [{ entity: { name: 'ZR_purchaselineTP2', element: 'Postingdate' } }]
      bill_date      : abap.dats;

      @UI.selectionField    : [{ position:01 }]
      @UI.identification: [ { position: 71 , label: 'Company Code' } ]
      @EndUserText.label    : 'Company Code'
      @UI.lineItem   : [{ position:81, label:'Company Code' }]
      @Consumption.valueHelpDefinition : [{ entity : { name : 'I_CompanyCodeStdVH' , element : 'CompanyCode' } }]
      company_code   : abap.char(4);


      @UI.selectionField    : [{ position:02 }]
      @UI.identification: [ { position: 72 , label: 'Plant Code' } ]
      @EndUserText.label    : 'Plant Code'
      @UI.lineItem   : [{ position:82, label:'Plant Code' }]
      @Consumption.valueHelpDefinition : [{ entity : { name : 'ZPlantValueHelp' , element : 'plant_code' } }]
      plant_code     : abap.char(4);


      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 80 , label: 'Pass Tag' } ]
      @EndUserText.label    : 'Pass Tag'
      @UI.lineItem   : [{ position:90, label:'Pass Tag' }]
      pass_tag       : abap.char(4);

      //     @UI.selectionField    : [{ position:80 }]
      @UI.identification: [ { position: 90 , label: 'Location' } ]
      @EndUserText.label    : 'Location'
      @UI.lineItem   : [{ position:100, label:'Location' }]
      location       : abap.char(30);

      //     @UI.selectionField    : [{ position:100 }]
      @UI.identification: [ { position: 100 , label: 'Product Name' } ]
      @EndUserText.label    : 'Product Name'
      @UI.lineItem   : [{ position:120, label:'Product Name' }]
      productname    : abap.char(40);

      //     @UI.selectionField    : [{ position:140 }]
      @UI.identification: [ { position: 110 , label: 'Supplier Name' } ]
      @EndUserText.label    : 'Supplier Name'
      @UI.lineItem   : [{ position:130, label:'Supplier Name' }]
      suppliername   : abap.char(50);

      //    @UI.selectionField    : [{ position:130 }]
      @UI.identification: [ { position: 120 , label: 'Supplier GST Number' } ]
      @EndUserText.label    : 'Supplier GST Number'
      @UI.lineItem   : [{ position:140, label:'Supplier GST Number' }]
      suppliergstno  : abap.char(15);

      //      @UI.selectionField    : [{ position:70 }]
      @UI.identification: [ { position: 130 , label: 'Local Centre' } ]
      @EndUserText.label    : 'Local Centre'
      @UI.lineItem   : [{ position:150, label:'Local Centre' }]
      localcentre    : abap.char(6);

      //     @UI.selectionField    : [{ position:150 }]
      @UI.identification: [ { position: 140 , label: 'Supplier State' } ]
      @EndUserText.label    : 'Supplier State'
      @UI.lineItem   : [{ position:160, label:'Supplier State' }]
      supplierstate  : abap.char(30);

      //     @UI.selectionField    : [{ position:110 }]
      @UI.identification: [ { position: 150 , label: 'Purposting Code' } ]
      @EndUserText.label    : 'Purposting Code'
      @UI.lineItem   : [{ position:170, label:'Purposting Code' }]
      purpostingcode : abap.numc(10);

      //     @UI.selectionField    : [{ position:120 }]
      @UI.identification: [ { position: 160 , label: 'Purposting Head' } ]
      @EndUserText.label    : 'Purposting Head'
      @UI.lineItem   : [{ position:180, label:'Purposting Head' }]
      purpostinghead : abap.char(50);

      //     @UI.selectionField    : [{ position:160 }]
      @UI.identification: [ { position: 170 , label: 'Tax Code' } ]
      @EndUserText.label    : 'Tax Code'
      @UI.lineItem   : [{ position:190, label:'Tax Code' }]
      taxcode        : abap.char(50);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 180 , label: 'GST Rate' } ]
      @EndUserText.label    : 'GST Rate'
      @UI.lineItem   : [{ position:200, label:'GST Rate' }]
      gstrate        : abap.dec(7,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 210 , label: 'Quantity' } ]
      @EndUserText.label    : 'Quantity'
      @UI.lineItem   : [{ position:210, label:'Quantity' }]
      qty            : abap.dec(15,3);

      //     @UI.selectionField    : [{ position:170 }]
      @UI.identification: [ { position: 220 , label: 'UOM' } ]
      @EndUserText.label    : 'UOM'
      @UI.lineItem   : [{ position:220, label:'UOM' }]
      uom            : abap.char(5);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 230 , label: 'RATE' } ]
      @EndUserText.label    : 'Rate'
      @UI.lineItem   : [{ position:230, label:'Rate' }]
      rate           : abap.dec(15,3);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 240 , label: 'Amount' } ]
      @EndUserText.label    : 'Amount'
      @UI.lineItem   : [{ position:240, label:'Amount' }]
      amount         : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 240 , label: 'Taxable Amount' } ]
      @EndUserText.label    : 'Taxable Amount'
      @UI.lineItem   : [{ position:240, label:'Taxable Amount' }]
      Taxableamount  : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 250 , label: 'IGST Amount' } ]
      @EndUserText.label    : 'IGST Amount'
      @UI.lineItem   : [{ position:250, label:'IGST Amount' }]
      igstamount     : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 260 , label: 'CGST Amount' } ]
      @EndUserText.label    : 'CGST Amount'
      @UI.lineItem   : [{ position:260, label:'CGST Amount' }]
      cgstamount     : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 270 , label: 'SGST Amount' } ]
      @EndUserText.label    : 'SGST Amount'
      @UI.lineItem   : [{ position:270, label:'SGST Amount' }]
      sgstamount     : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 250 , label: 'ND IGST Amount' } ]
      @EndUserText.label    : 'ND IGST Amount'
      @UI.lineItem   : [{ position:250, label:'ND IGST Amount' }]
      ndigstamount   : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 260 , label: 'ND CGST Amount' } ]
      @EndUserText.label    : 'ND CGST Amount'
      @UI.lineItem   : [{ position:260, label:'ND CGST Amount' }]
      ndcgstamount   : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 270 , label: 'ND SGST Amount' } ]
      @EndUserText.label    : 'ND SGST Amount'
      @UI.lineItem   : [{ position:270, label:'ND SGST Amount' }]
      ndsgstamount   : abap.dec(15,2);


      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 280 , label: 'GST Cess' } ]
      @EndUserText.label    : 'GST Cess'
      @UI.lineItem   : [{ position:280, label:'GST Cess' }]
      gstcess        : abap.dec(15,2);

      @Consumption.filter.hidden: true
      @UI.identification: [ { position: 281 , label: 'Is Reversed' } ]
      @EndUserText.label    : 'Is Reversed'
      @UI.lineItem   : [{ position:280, label:'Is Reversed' }]
      isreversed     : abap.char(1);
}
