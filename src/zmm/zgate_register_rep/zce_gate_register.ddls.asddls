@EndUserText.label: 'Gate Purchase Register'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_GATE_PURREG'
@UI.headerInfo: {typeName: 'Gate Purchase Register', typeNamePlural: 'Gate Purchase Register'}
define custom entity ZCE_GATE_REGISTER
{
      @UI.selectionField        : [{ position: 15 }]
      @EndUserText.label        : 'Gate Entry Number'
      @UI.lineItem              : [{ position:30, label:'Gate Entry Number' }]

  key gate_entry_num            : abap.char(15);
      @EndUserText.label        : 'Gate Item Number'
      @UI.lineItem              : [{ position: 130, label:'Gate Item Number' }]
      @Consumption.filter.hidden: true
  key gate_entryline            : abap.numc(6);

      @EndUserText.label        : 'Gate Cancelled'
      @UI.lineItem              : [{ position:40, label:'Gate Cancelled' }]
      @Consumption.filter.hidden: true
      gatecancelled             : abap.char(5);

      @UI.selectionField        : [{ position: 20 }]
      @EndUserText.label        : 'Gate In Date'
      @UI.lineItem              : [{ position:20, label: 'Gate In Date' }]
      gateindate                : datn;

      @EndUserText.label        : 'Gate Entry type'
      @UI.lineItem              : [{ position:10, label: 'Gate Entry type' }]
      @Consumption.filter.hidden: true
      gateentrytype             : abap.char(10);

      @EndUserText.label        : 'Gate Bill Number'
      @UI.lineItem              : [{ position: 100, label: 'Gate Bill Number' }]
      @Consumption.filter.hidden: true
      gebillno                  : abap.char(20);

      @EndUserText.label        : 'Gate Bill Date'
      @UI.lineItem              : [{ position: 90, label: 'Gate Bill Date' }]
      @Consumption.filter.hidden: true
      gebilldate                : datn;

      @EndUserText.label        : 'Bill Amount'
      @UI.lineItem              : [{ position: 95, label: 'Bill Amount' }]
      @Consumption.filter.hidden: true
      billamt                   : abap.dec(15,2);

      @EndUserText.label        : 'Vehicle Number'
      @UI.lineItem              : [{ position:520, label: 'Vehicle Number' }]
      @Consumption.filter.hidden: true
      vehicleno                 : abap.char(15);

      @EndUserText.label        : 'Invoicing Party'
      @UI.lineItem              : [{ position: 70, label: 'Invoicing Party' }]
      @Consumption.filter.hidden: true
      invoiceparty              : abap.char(15);

      @EndUserText.label        : 'Invoicing Party Name'
      @UI.lineItem              : [{ position:540, label: 'Invoicing Party Name' }]
      @Consumption.filter.hidden: true
      invoicepartyname          : abap.char(50);

      @EndUserText.label        : 'Invoicing Party GST'
      @UI.lineItem              : [{ position:550, label: 'Invoicing Party GST' }]
      @Consumption.filter.hidden: true
      invoicepartygst           : abap.char(15);

      @EndUserText.label        : 'Gate Quantity'
      @UI.lineItem              : [{ position:560, label: 'Gate Quantity' }]
      @Consumption.filter.hidden: true
      gateqty                   : abap.dec(15,2);

      @EndUserText.label        : 'Company Code'
      @UI.lineItem              : [{ position:570, label: 'Company Code' }]
      @Consumption.filter.hidden: true
      companycode               : abap.char(4);

      @EndUserText.label        : 'Invoice Posting Date'
      @UI.lineItem              : [{ position:580, label: 'Invoice Posting Date' }]
      @Consumption.filter.hidden: true
      invpostingdate            : datn;

      @EndUserText.label        : 'Fiscal Year'
      @UI.lineItem              : [{ position:590, label: 'Fiscal Year' }]
      @Consumption.filter.hidden: true
      fiscalyear                : abap.char(4);

      @EndUserText.label        : 'Transaction Type'
      @UI.lineItem              : [{ position:600, label: 'Transaction Type' }]
      @Consumption.filter.hidden: true
      transactiontype           : abap.char(2);

      @EndUserText.label        : 'Is Reversed'
      @UI.lineItem              : [{ position:610, label: 'Is Reversed' }]
      @Consumption.filter.hidden: true
      isreversed                : abap.char(1);

      @EndUserText.label        : 'Invoice Reference Number'
      @UI.lineItem              : [{ position:620, label: 'Invoice Reference Number' }]
      @Consumption.filter.hidden: true
      refinvno                  : abap.char(10);

      @EndUserText.label        : 'MIRO Number'
      @UI.lineItem              : [{ position:630, label: 'MIRO Number' }]
      @Consumption.filter.hidden: true
      supplierinvoice           : abap.char(10);

      @EndUserText.label        : 'MIRO Item Number'
      @UI.lineItem              : [{ position:640, label: 'MIRO Item Number' }]
      @Consumption.filter.hidden: true
      supplierinvoiceitem       : abap.numc(6);

      @EndUserText.label        : 'MIRO Qty'
      @UI.lineItem              : [{ position:640, label: 'MIRO Qty' }]
      @UI.selectionField        : [{ position: 51 }]
      supplierqty               : abap.dec(13,3);

      @UI.selectionField        : [{ position: 50 }]
      @EndUserText.label        : 'PO Supplier'
      @UI.lineItem              : [{ position: 50, label: 'PO Supplier' }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_Supplier_VH', element: 'Supplier' } }]
      supplier                  : abap.char(10);

      @EndUserText.label        : 'PO Supplier Name'
      @UI.lineItem              : [{ position: 60, label: 'PO Supplier Name' }]
      @Consumption.filter.hidden: true
      suppliername              : abap.char(40);

      @EndUserText.label        : 'PO Supplier GST'
      @UI.lineItem              : [{ position:670, label: 'PO Supplier GST' }]
      @Consumption.filter.hidden: true
      supp_gst                  : abap.char(16);

      @Consumption.filter       : {mandatory: true}
      @UI.selectionField        : [{ position: 10 }]
      @EndUserText.label        : 'Plant'
      @UI.lineItem              : [{ position:680, label: 'Plant' }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_PlantStdVH', element: 'Plant' } }]
      plant                     : abap.char(4);

      @EndUserText.label        : 'Plant Name'
      @UI.lineItem              : [{ position:690, label: 'Plant Name' }]
      @Consumption.filter.hidden: true
      plantname                 : abap.char(40);

      @EndUserText.label        : 'Plant GST'
      @UI.lineItem              : [{ position:700, label: 'Plant GST' }]
      @Consumption.filter.hidden: true
      plantgst                  : abap.char(15);

      @EndUserText.label        : 'PO Date'
      @UI.lineItem              : [{ position:710, label: 'PO Date' }]
      @Consumption.filter.hidden: true
      podate                    : datn;

      @EndUserText.label        : 'PO Type'
      @UI.lineItem              : [{ position:720, label: 'PO Type' }]
      @Consumption.filter.hidden: true
      potype                    : abap.char(4);

      @EndUserText.label        : 'Purchase Organisation'
      @UI.lineItem              : [{ position:730, label: 'Purchase Organisation' }]
      @Consumption.filter.hidden: true
      pur_org                   : abap.char(4);

      @EndUserText.label        : 'Purchase Group'
      @UI.lineItem              : [{ position:740, label: 'Purchase Group' }]
      @Consumption.filter.hidden: true
      pur_group                 : abap.char(3);

      @UI.selectionField        : [{ position: 100 }]
      @EndUserText.label        : 'PO Number'
      @UI.lineItem              : [{ position: 80, label: 'PO Number' }]
      ponum                     : abap.char(10);

      @EndUserText.label        : 'PO Item'
      @UI.lineItem              : [{ position:760, label: 'PO Item' }]
      @Consumption.filter.hidden: true
      poitem                    : abap.numc(5);

      @EndUserText.label        : 'PO UOM'
      @UI.lineItem              : [{ position:770, label: 'PO UOM' }]
      @Consumption.filter.hidden: true
      pouom                     : abap.char(3);

      @EndUserText.label        : 'PO Rate'
      @UI.lineItem              : [{ position:780, label: 'PO Rate' }]
      @Consumption.filter.hidden: true
      porate                    : abap.dec(13,2);

      @EndUserText.label        : 'GRN Date'
      @UI.lineItem              : [{ position:790, label: 'GRN Date' }]
      @Consumption.filter.hidden: true
      grndate                   : datn;

      @EndUserText.label        : 'GRN Number'
      @UI.lineItem              : [{ position: 110, label: 'GRN Number' }]
      @Consumption.filter.hidden: true
      grnnum                    : abap.char(10);

      @EndUserText.label        : 'GRN Item'
      @UI.lineItem              : [{ position:810, label: 'GRN Item' }]
      @Consumption.filter.hidden: true
      grnitem                   : abap.char(6);

      @EndUserText.label        : 'GRN Year'
      @UI.lineItem              : [{ position:820, label: 'GRN Year' }]
      @Consumption.filter.hidden: true
      grnyear                   : abap.char(4);

      @EndUserText.label        : 'GRN Quantity'
      @UI.lineItem              : [{ position:830, label: 'GRN Quantity' }]
      @Consumption.filter.hidden: true
      grnqty                    : abap.dec(15,2);

      @UI.selectionField        : [{ position: 60 }]
      @EndUserText.label        : 'Product'
      @UI.lineItem              : [{ position:840, label: 'Product' }]
      @Consumption.valueHelpDefinition: [{ entity: {name:'I_ProductStdVH', element: 'Product' } }]
      product                   : abap.char(40);

      @EndUserText.label        : 'Product Name'
      @UI.lineItem              : [{ position:850, label: 'Product Name' }]
      @Consumption.filter.hidden: true
      productname               : abap.char(40);

      @EndUserText.label        : 'Profit Center'
      @UI.lineItem              : [{ position:860, label: 'Profit Center' }]
      @Consumption.filter.hidden: true
      profitcenter              : abap.char(4);

      @EndUserText.label        : 'HSN Code'
      @UI.lineItem              : [{ position:870, label: 'HSN Code' }]
      @Consumption.filter.hidden: true
      hsncode                   : abap.char(16);

      @UI.hidden                : true
      @Consumption.filter.hidden: true
      taxcode                   : abap.char(50);
      @EndUserText.label        : 'Tax Code Name'
      @UI.lineItem              : [{ position:880, label: 'Tax Code Name' }]
      @Consumption.filter.hidden: true
      taxcodename               : abap.char(50);

      @EndUserText.label        : 'Original Ref. Document'
      @UI.lineItem              : [{ position:890, label: 'Original Ref. Document' }]
      @Consumption.filter.hidden: true
      originalreferencedocument : abap.char(20);

      @EndUserText.label        : 'IGST'
      @UI.lineItem              : [{ position:900, label: 'IGST' }]
      @Consumption.filter.hidden: true
      igst                      : abap.dec(13,2);

      @EndUserText.label        : 'SGST'
      @UI.lineItem              : [{ position:910, label: 'SGST' }]
      @Consumption.filter.hidden: true
      sgst                      : abap.dec(13,2);

      @EndUserText.label        : 'CGST'
      @UI.lineItem              : [{ position:920, label: 'CGST' }]
      @Consumption.filter.hidden: true
      cgst                      : abap.dec(13,2);

      @EndUserText.label        : 'Rate IGST'
      @UI.lineItem              : [{ position:930, label: 'Rate IGST' }]
      @Consumption.filter.hidden: true
      rateigst                  : abap.dec(13,2);

      @EndUserText.label        : 'Rate CGST'
      @UI.lineItem              : [{ position:940, label: 'Rate CGST' }]
      @Consumption.filter.hidden: true
      ratecgst                  : abap.dec(13,2);

      @EndUserText.label        : 'Rate SGST'
      @UI.lineItem              : [{ position:950, label: 'Rate SGST' }]
      @Consumption.filter.hidden: true
      ratesgst                  : abap.dec(13,2);

      @EndUserText.label        : 'Net Amount'
      @UI.lineItem              : [{ position: 960, label: 'Net Amount' }]
      @Consumption.filter.hidden: true
      netamount                 : abap.dec(13,2);

      @EndUserText.label        : 'Tax Amount'
      @UI.lineItem              : [{ position: 970, label: 'Tax Amount' }]
      @Consumption.filter.hidden: true
      taxamount                 : abap.dec(13,2);

      @EndUserText.label        : 'Total Amount'
      @UI.lineItem              : [{ position: 980, label: 'Total Amount' }]
      @Consumption.filter.hidden: true
      totalamount               : abap.dec(13,2);

}
