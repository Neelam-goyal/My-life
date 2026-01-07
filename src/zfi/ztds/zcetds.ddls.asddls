@EndUserText.label: 'ZCETDS'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define custom entity ZCETDS
{
     @UI.lineItem: [{ position: 10 }]
  @UI.selectionField: [{ position: 10 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'i_productplantintltrd', element: 'HSN' } }]
  @Consumption.filter: { mandatory: false }
  key Voucher_date: abap.dats;
  
  @UI.lineItem: [{ position: 20 }]  
  @UI.selectionField: [{ position: 20 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  VOUCHER_NO: abap.char(18);
  
  @UI.lineItem: [{ position: 30 }]  
  @UI.selectionField: [{ position: 30 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  LOCATION: abap.char(18);
  
  @UI.lineItem: [{ position: 40 }]  
  @UI.selectionField: [{ position: 40 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  ACCOUNT_CODE: abap.char(18);
  
  @UI.lineItem: [{ position: 50 }]  
  @UI.selectionField: [{ position: 50 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  Supplier_Account_Name: abap.char(18);
  
  @UI.lineItem: [{ position: 60 }]  
  @UI.selectionField: [{ position: 60 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  Pan_No: abap.char(18);
  
  @UI.lineItem: [{ position: 70 }]  
  @UI.selectionField: [{ position: 70 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  TDS_Code: abap.char(18);
  
  @UI.lineItem: [{ position: 80 }]  
  @UI.selectionField: [{ position: 80 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  TDS_Deduction_Rate: abap.char(18);
  
  @UI.lineItem: [{ position: 90 }]  
  @UI.selectionField: [{ position: 90 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  TDS_Base_Amount: abap.char(18);
  
  @UI.lineItem: [{ position: 100 }]  
  @UI.selectionField: [{ position: 100 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  TDS_Amount: abap.char(18);
  
  @UI.lineItem: [{ position: 110 }]  
  @UI.selectionField: [{ position: 110 }]
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_EquipmentStdVH', element: 'Equipment' } }]
  @Consumption.filter: { mandatory: false }
  Lower_Deduction_No: abap.char(18);
}
