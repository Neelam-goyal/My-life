@EndUserText.label: 'BRS REPORT'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BRSREPORT'
@UI.headerInfo: {
typeName: 'Count',
typeNamePlural: 'Count'
}
define custom entity zdd_brs_report

{

  @UI.lineItem       : [{ position:7, label:'Document No' }]
  @EndUserText.label: 'Docuemnt No'
  key doc : abap.char(10);
  
  @UI.hidden: true
  key AccountingDocument: abap.char(10);   
   @UI.hidden: true 
  key Ledger : abap.char(2);
   @UI.hidden: true
  key FiscalYear : abap.numc(4);
   @UI.hidden: true
  key LedgerGLLineItem : abap.char(6);
  
    @UI.lineItem       : [{ position:2, label:'GL Account' }]
  @EndUserText.label: 'GL Account'
   key gl_acc : abap.char(10);

  @UI.selectionField : [{ position: 1 }] 
  @Consumption.filter:{ mandatory: true }
  @EndUserText.label: 'Company Code'   
  @Consumption.valueHelpDefinition: [{ entity: { name: 'zdd_valuehelp_brs', element: 'CompanyCode' }}]
  comp_code : abap.char(4);
  
   @UI.selectionField : [{ position: 2 }] 
   @Consumption.filter:{ mandatory: true }
   @UI.lineItem       : [{ position:3, label:'House Bank' }]
   @EndUserText.label: 'House Bank'   
     @Consumption.valueHelpDefinition: [{ entity: { name: 'zhousebank_vh', element: 'HouseBank' },
      additionalBinding: [{ localElement: 'comp_code',    element: 'CompanyCode',  usage:#FILTER_AND_RESULT }] }]
  house_bank : abap.char(5);
  
   @UI.selectionField : [{ position: 3 }] 
   @Consumption.filter:{ mandatory: true }
//   @Consumption.filter.defaultValue: '123'
   @EndUserText.label: 'Account Id'    
//   @Consumption.valueHelpDefinition: [{ entity: { name: 'zaccid_vh', element: 'AccId' },
//   additionalBinding: [{ localElement: 'comp_code',    element: 'CompanyCode',  usage:#FILTER_AND_RESULT }] }] 
  acc_id : abap.char(5);
  
  
  @UI.selectionField : [{ position: 4 }] 
    @Consumption.filter:{ mandatory: true }
  @UI.lineItem       : [{ position:1, label:'Actual Posting Date' }]
  @EndUserText.label: 'Posting Date'
//  @Consumption.filter.defaultValue:  '20250519'
  actual_posting : abap.dats(8);
  
   @UI.selectionField : [{ position: 5 }] 
    @Consumption.filter:{ mandatory: true }
  @EndUserText.label: 'BRS Posting Date'
  brs_posting : abap.dats(8);
  
  
   @UI.lineItem       : [{ position:4, label:'Assignment' }]
  @EndUserText.label: 'Reference'
  ref : abap.char(50);
  
    @UI.lineItem       : [{ position:6, label:'Doc Header Text' }]
   @EndUserText.label: 'Doc Header Text'
   header_text : abap.char(25);

 
  @UI.lineItem       : [{ position:8, label:'Profit Center' }]
  @EndUserText.label: 'Profit Center'
  profit : abap.char(10);
  
  @UI.lineItem       : [{ position:9, label:'Accounting Type' }]
  @EndUserText.label: 'Accounting Type'
  acc_type : abap.char(2);
  
  @UI.lineItem       : [{ position:10, label:'Document Date' }]
  @EndUserText.label: 'Document Date'
  doc_date : abap.dats(8);
  
  @UI.lineItem       : [{ position:11, label:'Posting Date' }]
  @EndUserText.label: 'Posting Date'
  posting_date : abap.dats(8);
  
    @UI.lineItem       : [{ position:12, label:'Posting Key' }]
  @EndUserText.label: 'Posting Key'
  posting_key : abap.char(2);
   
  @UI.lineItem       : [{ position:13, label:'Amt in Loc Curr ' }]
  @EndUserText.label: 'AMT.IN LOCAL CURRENCY '
  @Semantics.amount.currencyCode: 'loc_curr'
  loc_amt : abap.curr(13,2);
//  @UI.hidden: true
   loc_curr : abap.cuky(5);
   
    @UI.lineItem       : [{ position:13, label:'Amt in Doc Curr' }]
  @Semantics.amount.currencyCode: 'doc_curr'
  doc_amt : abap.curr(13,2);
//  @UI.hidden: true
   doc_curr : abap.cuky(5);
}
