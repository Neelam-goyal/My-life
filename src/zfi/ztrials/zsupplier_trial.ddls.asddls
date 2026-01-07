@EndUserText.label: 'Supplier Trial Balance'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SUPPLIERTRIAL'
@UI.headerInfo: {typeName: 'Supplier Balances', typeNamePlural: 'Supplier'}
define custom entity ZSupplier_Trial
  with parameters
    p_fromdate : vdm_v_start_date,
    p_todate   : vdm_v_end_date
{
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:10 }]
      @UI.lineItem         : [{ position:10, label:'Company Code' }]
      @Consumption.filter  : { mandatory: true }
//      @Consumption.valueHelpDefinition: [{ entity: { element: 'companycode', name: 'I_SUPPLIERCOMPANY'} }]
  key companycode          : bukrs;
      @UI.selectionField   : [{ position:40 }]
      @Consumption.valueHelpDefinition: [{ entity: { element: 'Supplier', name: 'I_Supplier_VH'} }]
      @UI.lineItem         : [{ position:40, label:'Supplier Code' }]
  key vendorcode           : lifnr;
      @EndUserText         : { label            : 'Supplier Account Group' }
      @UI.selectionField   : [{ position:20 }]
      @UI.lineItem         : [{ position:20, label:'Account Group' }]
      supplieraccountgroup : abap.char(4);
      @UI.selectionField   : [{ position:30 }]
      @UI.lineItem         : [{ position:30, label:'Region' }]
      region               : abap.char(3);
      @UI.lineItem         : [{ position:45, label:'Supplier Name' }]
      vendorname           : abap.char(80);
      @UI.lineItem         : [{ position:70, label:'Opening Balance' }]
      openingbalance       : abap.dec(15,2);
      @UI.lineItem         : [{ position:75, label:'Debit' }]
      debitbalance         : abap.dec(15,2);
      @UI.lineItem         : [{ position:80, label:'Credit' }]
      creditbalance        : abap.dec(15,2);
      @UI.lineItem         : [{ position:90, label:'Closing Balance' }]
      closingbalance       : abap.dec(15,2);

}
