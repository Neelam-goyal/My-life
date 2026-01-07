@EndUserText.label: 'Sales Order Summary'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SUMMARY_SO'
@UI.headerInfo: {
typeName: 'Count',
typeNamePlural: 'Count'
}
define custom entity zdd_sumary_so
{
  
   @UI.hidden: true
//  @UI.lineItem       : [{ position: 6.1 }]
  key BillingDocument : abap.char(10);
  @UI.hidden: true
//  @UI.lineItem       : [{ position: 6.2 }]
  key BillingDocumentItem : abap.char(6);

  @UI.selectionField : [{ position: 3 }] 
  @UI.lineItem       : [{ position: 3 }]
  @EndUserText.label: 'Sales Order'
//  @Search.defaultSearchElement: true
  key so : abap.char(10);
  
  @UI.selectionField : [{ position: 6 }] 
  @UI.lineItem       : [{ position: 6 }]
  @EndUserText.label: 'Sales Order Item'
  key so_item : abap.numc(6);
  
    @UI.lineItem       : [{ position: 11 }]
  @EndUserText.label: 'Material'
    mat : abap.char(40);  

   
    @UI.lineItem       : [{ position: 4 }]
  @EndUserText.label: 'Order Date'
   o_date : abap.dats(8);
  
    @UI.lineItem       : [{ position: 5 }]
  @EndUserText.label: 'Time'
  @Consumption.filter.hidden: true
   o_time : abap.tims(6); 
  

  
  @UI.selectionField : [{ position: 1 }] 
  @UI.lineItem       : [{ position: 1 }]
  @EndUserText.label: 'Plant'
   plant : abap.char(4);
  
  @UI.selectionField : [{ position: 2 }] 
  @UI.lineItem       : [{ position: 2 }]
  @EndUserText.label: 'Distribution Channel'
   dc : abap.char(2);
   
//  @UI.selectionField : [{ position: 4 }] 

   
//  @UI.selectionField : [{ position: 5 }] 

//  @UI.selectionField : [{ position: 7 }] 
  @UI.lineItem       : [{ position: 7 }]
  @EndUserText.label: 'BP No'
   bp : abap.char(10); 
   
//  @UI.selectionField : [{ position: 8 }] 
  @UI.lineItem       : [{ position: 8 }]
  @EndUserText.label: 'BP Name'
//  @Search.defaultSearchElement: true
//  @Search.fuzzinessThreshold: 0.8 
   bp_name : abap.char(220);  
   
//   @UI.selectionField : [{ position: 9 }] 
  @UI.lineItem       : [{ position: 9 }]
  @EndUserText.label: 'State'
  @Consumption.filter.hidden: true
   state : abap.char(20); 
   
    @UI.lineItem       : [{ position: 9.1 }]
  @EndUserText.label: 'Fin App'
  @Consumption.filter.hidden: true
   fin : abap.char(20); 
   
   @UI.lineItem       : [{ position: 8.9 }]
  @EndUserText.label: 'Delivery'
  @Consumption.filter.hidden: true
   del : abap.char(20); 
   
   @UI.lineItem       : [{ position: 8.8 }]
  @EndUserText.label: 'PGI'
  @Consumption.filter.hidden: true
   pgi : abap.char(20); 
   
    @UI.lineItem       : [{ position: 8.7 }]
  @EndUserText.label: 'INV'
  @Consumption.filter.hidden: true
   inv : abap.char(20); 
   
//   @UI.selectionField : [{ position: 10 }] 
  @UI.lineItem       : [{ position: 10 }]
  @EndUserText.label: 'Customer Reference'
  @Consumption.filter.hidden: true
   cust_ref : abap.char(35); 
   
//   @UI.selectionField : [{ position: 11 }] 

//   @UI.selectionField : [{ position: 12 }] 
  @UI.lineItem       : [{ position: 12 }]
  @EndUserText.label: 'Material Description'
   mat_desc : abap.char(40);   
   
//  @UI.selectionField : [{ position: 13 }] 
  @UI.lineItem       : [{ position: 13 }]
  @EndUserText.label: 'Order Qty'
  @Consumption.filter.hidden: true
   o_qty : abap.dec(13,3);  
   
//   @UI.selectionField : [{ position: 14 }] 
  @UI.lineItem       : [{ position: 14 }]
  @EndUserText.label: 'Order Value'
  @Consumption.filter.hidden: true
   o_value : abap.dec(15,2); 
   
//  @UI.selectionField : [{ position: 15 }] 
  @UI.lineItem       : [{ position: 15 }]
  @EndUserText.label: 'INV Qty'
  @Consumption.filter.hidden: true
   inv_qty : abap.dec(13,3);  
   
//  @UI.selectionField : [{ position: 16 }] 
  @UI.lineItem       : [{ position: 16 }]
  @EndUserText.label: 'INV Value'
  @Consumption.filter.hidden: true
   inv_val : abap.dec(15,2);  
   
//  @UI.selectionField : [{ position: 17 }] 
  @UI.lineItem       : [{ position: 17 }]
  @EndUserText.label: 'Qty Diff'
  @Consumption.filter.hidden: true
   qty_diff : abap.dec(13,3);  
   
//  @UI.selectionField : [{ position: 18 }] 
  @UI.lineItem       : [{ position: 18 }]
  @EndUserText.label: 'Value Diff'
  @Consumption.filter.hidden: true
   val_diff : abap.dec(15,2); 
   
   @UI.selectionField : [{ position: 19 }] 
  @UI.lineItem       : [{ position: 19 }]
  @EndUserText.label: 'Status'
//   @Search.defaultSearchElement: true
   status : abap.char(50) ;
}
