@EndUserText.label: 'Customer Trial Balance'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CUSTOMERTRIAL'
@UI.headerInfo: {typeName: 'Customer Balances', typeNamePlural: 'Customer'}
define custom entity ZCustomer_Trial
    with parameters
      p_fromdate : vdm_v_start_date,
      p_todate   : vdm_v_end_date
{
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:30 }]
      @UI.lineItem         : [{ position:10, label:'Company Code' }]
  key companycode          : bukrs;
      @UI.selectionField   : [{ position:40 }]
      @Consumption.valueHelpDefinition: [{ entity: { element: 'Customer', name: 'I_Customer_VH'} }]
      @UI.lineItem         : [{ position:40, label:'Customer Code' }]
  key customercode         : abap.char(10);
      @UI.selectionField   : [{ position:50 }]
      @UI.lineItem         : [{ position:20, label:'Account Group' }]
      customeraccountgroup : abap.char(4);
      @UI.selectionField   : [{ position:60 }]
      @UI.lineItem         : [{ position:30, label:'Region' }]
      region               : abap.char(3);
      @UI.selectionField   : [{ position:70 }]
      @UI.lineItem         : [{ position:35, label:'District' }]
      districtname         : abap.char(40);
      @UI.lineItem         : [{ position:45, label:'Customer Name' }]
      customername         : abap.char(80);
      @UI.lineItem         : [{ position:70, label:'Opening Balance' }]
      openingbalance       : abap.dec(15,2);
      @UI.lineItem         : [{ position:75, label:'Debit' }]
      debitbalance         : abap.dec(15,2);
      @UI.lineItem         : [{ position:80, label:'Credit' }]
      creditbalance        : abap.dec(15,2);
      @UI.lineItem         : [{ position:90, label:'Closing Balance' }]
      closingbalance       : abap.dec(15,2);
      AdjustmentDrCr       : abap.dec(15,2);
      PaymentDr            : abap.dec(15,2);
      PaymentCr            : abap.dec(15,2);
      BillingDr            : abap.dec(15,2);
      CreditMemoCr         : abap.dec(15,2);
      DirectInvoiceDr      : abap.dec(15,2);
      AdvanceAmountCr      : abap.dec(15,2);
}
