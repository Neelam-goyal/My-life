@EndUserText.label: 'ZCE_HSNSUM_B2C'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_HSN'
@UI.headerInfo: {
  typeName: 'HSN B2C Report',
  typeNamePlural : 'HSN B2C Report'
}
define custom entity ZCDS_HSN_B2C
{
 @UI.facet      : [ {
         id          : 'idHSN',
         purpose     : #STANDARD,
         type        : #IDENTIFICATION_REFERENCE,
         label       : 'HSN B2C',
         position    : 10
       } ]
  @UI.identification: [{ position: 10, label: 'HSN Code' }]
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem:       [{ position: 10 }]
  @EndUserText.label: 'HSN Code'
  @Consumption.valueHelpDefinition : [{ entity : { name : 'ZCDS_HSN_VH' , element : 'hsncode' } }]
  key hsn: abap.char(8);

  @UI.identification: [{ position: 100, label: 'plant_code' }]
  @UI.selectionField: [{ position: 100 }]
  @UI.lineItem:       [{ position: 100 }]
  @EndUserText.label: 'Plant Code'
  @Consumption.valueHelpDefinition : [{ entity : { name : 'ZPlantValueHelp' , element : 'plant_code' } }]
  key plant_code: abap.char(4);
  
  @UI.identification: [{ position: 110, label: 'Rate' }]
//  @UI.selectionField: [{ position: 110 }]
  @UI.lineItem:       [{ position: 110 }]
  @EndUserText.label: 'Rate'
//  @Consumption.valueHelpDefinition : [{ entity : { name : 'ZPlantValueHelp' , element : 'plant_code' } }]
  key Rate: abap.dec(15,2);
  
  @UI.identification: [{ position: 20, label: 'Description' }]
  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem:       [{ position: 20 }]
  @EndUserText.label: 'Description'
  @Consumption.valueHelpDefinition : [{ entity : { name : 'ZCDS_DES_VH' , element : 'ConsumptionTaxCtrlCodeText1' } }]
  key description: abap.char(40);

  @UI.identification: [{ position: 30, label: 'uqc' }]
  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem:       [{ position: 30 }]
  @EndUserText.label: 'UQC'
  @Consumption.valueHelpDefinition : [{ entity : { name : 'ZCDS_UQC_VH' , element : 'uom' } }]
  key uqc: abap.char(3);
  
  
//  @UI.identification: [{ position: 31, label: 'Date' }]
  @UI.selectionField: [{ position: 31 }]
//  @UI.lineItem:       [{ position: 31 }]
  @EndUserText.label: 'HSN Date'
  hsn_Date: abap.dats;
  

 // @UI.selectionField: [{ position: 40 }]
 @UI.identification: [{ position: 40, label: 'total_quantity' }]
  @UI.lineItem:       [{ position: 40 }]
  @EndUserText.label: 'Total Quantity'
  total_quantity: abap.dec(15,2);

//  @UI.selectionField: [{ position: 50 }]
@UI.identification: [{ position: 50, label: 'total_value' }]
  @UI.lineItem:       [{ position: 50 }]
  @EndUserText.label: 'Total Value'
  total_value: abap.dec(15,2);

//  @UI.selectionField: [{ position: 60 }]
@UI.identification: [{ position: 60, label: 'taxable_value' }]
  @UI.lineItem:       [{ position: 60 }]
  @EndUserText.label: 'Taxable Value'
  taxable_value: abap.dec(15,2);

 // @UI.selectionField: [{ position: 70 }]
 @UI.identification: [{ position: 70, label: 'integrated_tax_amount' }]
  @UI.lineItem:       [{ position: 70 }]
  @EndUserText.label: 'Integrated Tax Amount'
  integrated_tax_amount: abap.dec(15,2);

 // @UI.selectionField: [{ position: 80 }]
 @UI.identification: [{ position: 80, label: 'central_tax_amount' }]
  @UI.lineItem:       [{ position: 80 }]
  @EndUserText.label: 'Central Tax Amount'
  central_tax_amount: abap.dec(15,2);
  
  @UI.identification: [{ position: 90, label: 'company_code' }]
  @UI.selectionField: [{ position: 90 }]
  @UI.lineItem:       [{ position: 90 }]
  @EndUserText.label: 'Company Code'
  @Consumption.valueHelpDefinition : [{ entity : { name : 'I_CompanyCodeStdVH' , element : 'CompanyCode' } }]
  company_code: abap.char(4);
   
  
  
  
  
  @UI.identification: [{ position: 120, label: 'StateUT_Tax_Amount' }]
//  @UI.selectionField: [{ position: 120 }]
  @UI.lineItem:       [{ position: 120 }]
  @EndUserText.label: 'StateUT_Tax_Amount'
//  @Consumption.valueHelpDefinition : [{ entity : { name : 'ZPlantValueHelp' , element : 'plant_code' } }]
  StateUT_Tax_Amount: abap.char(4);
  
}
