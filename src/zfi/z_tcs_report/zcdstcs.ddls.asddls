@EndUserText.label: 'ZCDSTCS'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TCS'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI.headerInfo: {
  typeName: 'COUNT',
  typeNamePlural : 'COUNT'
}

define custom entity ZCDSTCS
{
  @UI.lineItem: [{ position: 10, label: 'Date'}]
  @UI.selectionField: [{ position: 10 }]
  @EndUserText.label: 'From Date'
  @Consumption.filter.selectionType: #SINGLE
 @Consumption.filter.mandatory: true
  key sale_date  : abap.dats;
 
  @UI.lineItem: [{ position: 20 , hidden: true}]
  @UI.selectionField: [{ position: 20 }]
  @EndUserText.label: 'To Date'
  @Consumption.filter.selectionType: #SINGLE
 @Consumption.filter.mandatory: true
  key sale_date_to: abap.dats;

  @UI.lineItem: [{ position: 30 }]  
  @UI.selectionField: [{ position: 30 }]
  @EndUserText.label: 'Sale Bill Number'
  @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSSALESBILLVH', element: 'DocumentReferenceID' }
  }
  ]
  key Sale_Bill_No: abap.char(14);

  @UI.lineItem: [{ position: 50 }]  
  @UI.selectionField: [{ position: 50 }]
  @EndUserText.label: 'Plant Code'
  @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSLOCATIONVH', element: 'Plant' }
  }]
  key Plant_code: abap.char(5);

  @UI.lineItem: [{ position: 40 }]  
  @UI.selectionField: [{ position: 40 }]
  @EndUserText.label: 'Company Code'
  @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'zcompcodevh', element: 'CompanyCode' }
  }]
  key comp_code : abap.char(4);

  @UI.lineItem: [{ position: 60 }]  
  @UI.selectionField: [{ position: 60 }]
  @EndUserText.label: 'Location'
  @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSLOCATIONVH', element: 'PlantName' }
  }]
  key LOCATION: abap.char(40);

  @UI.lineItem: [{ position: 70 }]  
  @UI.selectionField: [{ position: 70 }]
  @EndUserText.label: 'Account Code'
  @Consumption.valueHelpDefinition: [
  {
    entity: { name: 'ZCDSACCOUNTCOODEVH', element: 'PayerParty' }
  }]
  key ACCOUNT_CODE: abap.char(18);
  

  @UI.lineItem: [{ position: 110 }]  
  @Consumption.filter: { hidden: true }
  @EndUserText.label: 'TCS Deduction Rate'
  key TCS_Deduction_Rate: abap.dec(7,4);

  @UI.lineItem: [{ position: 120 }]  
  @Consumption.filter: { hidden: true }
  @EndUserText.label: 'TCS Base Amount'
  key TCS_Base_Amount: abap.dec(23,2);

  @UI.lineItem: [{ position: 130 }] 
  @Consumption.filter: { hidden: true }
  @EndUserText.label: 'TCS Amount'
  key TCS_Amount: abap.dec(23,2);

  @UI.lineItem: [{ position: 80 }]  
  @Consumption.filter: { hidden: true }
  @EndUserText.label: 'PAN Number'
  Pan_No: abap.char(18);
  
  @UI.lineItem: [{ position: 100 }]  
  @Consumption.filter: { hidden: true }
  @EndUserText.label: 'TCS Section Code'
  TCS_Code: abap.char(18);

  @UI.lineItem: [{ position: 90 }]  
  @EndUserText.label: 'Customer Name or Party Name'
  @Consumption.filter: { hidden: true }
//  @Consumption.valueHelpDefinition: [
//  {
//    entity: { name: 'ZCDSCUSTOMERNAMEVH', element: 'PayerPartyName' }
//  }]
  partyname: abap.char(100);


}
