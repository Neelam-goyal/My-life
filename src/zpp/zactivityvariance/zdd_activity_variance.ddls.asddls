@EndUserText.label: 'Activity Variance'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_ACTIVITY_VARIANCE'
@UI.headerInfo: {
typeName: 'Count',
typeNamePlural: 'Count'
}
define custom entity zdd_activity_variance
{

  @UI.selectionField : [{ position: 1 }] 
  @UI.lineItem       : [{ position:1, label:'Company Code' }]
  @EndUserText.label: 'Company Code'
  @Consumption.filter:{ mandatory: true }
  @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode', name: 'I_CompanyCode' }}]
//  @UI.identification: [{ position:1, label:'Company Code'  }]
  key comp_code : abap.char(4);

  @UI.selectionField : [{ position: 2 }] 
  @UI.lineItem       : [{ position:2, label:'Plant' }]
  @EndUserText.label: 'Plant' 
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPLANTVALUEHELP', element: 'plant_code' },
  additionalBinding: [{ localElement: 'comp_code',    element: 'comp_code',  usage:#FILTER }]
   }]
  key plant_code : abap.char(4);
  
  @UI.hidden: true
  key ConfirmationGroup : abap.numc(10);
  @UI.hidden: true
  key ConfirmationCount : abap.numc(8);
 
   @UI.selectionField : [{ position: 9 }] 
   @EndUserText.label: 'Activity Name'
   @UI.lineItem       : [{ position:9, label: 'Activity Name' }]
   @Consumption.valueHelpDefinition: [{ entity: { name: 'ZACTIVITYNAMEVALUEHELP', element: 'value_low' } }]
  key  Activity : abap.char(20);
 
   @UI.lineItem       : [{ position:12, label:'Actual Consumption' }]
   @EndUserText.label: 'Standard Consumption'
    @Semantics.quantity.unitOfMeasure: 'ActConsUnit'
   key  ActualConsumption : abap.dec(13,3);
   @UI.hidden: true
   key   ActConsUnit : abap.unit(3);
  
   @UI.selectionField : [{ position: 3 }] 
   @UI.lineItem       : [{ position:3, label:'Work Center' }]
   @EndUserText.label: 'Work Center'
   @Consumption.valueHelpDefinition: [{ entity: { name: 'zworcenter_vh', element: 'WorkCenter' } }]
   work_center : abap.char(8);
   
   @UI.selectionField : [{ position: 4 }] 
   @UI.lineItem       : [{ position:4, label:'Posting Date' }]
   @EndUserText.label: 'Posting Date'
   PostingDate : abap.dats(8);
   
   @UI.selectionField : [{ position: 5 }] 
   @UI.lineItem       : [{ position:5, label:'Shift' }]
   @EndUserText.label: 'Shift'
   @Consumption.valueHelpDefinition: [{ entity: { name: 'zshift_vh', element: 'value_low' } }]
   Shift : abap.char(5);
   
   @UI.selectionField : [{ position: 6 }] 
   @UI.lineItem       : [{ position:6, label:'Production Order' }]
   @EndUserText.label: 'Production Order'
//    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPLANTVALUEHELP', element: 'manufacturing_order' },
//  additionalBinding: [{ localElement: 'plant_code',    element: 'plant_code',  usage:#FILTER_AND_RESULT }]
//   }]
   ProductionOrder : abap.char(12);
   
   
   @UI.lineItem       : [{ position:6.2, label:'Yield Quantity' }]
   @Semantics.quantity.unitOfMeasure: 'yieldunit'
   YieldQuantity : abap.dec(13,3);
    @UI.hidden: true
   yieldunit : abap.unit(3);
   
   
   @UI.selectionField : [{ position: 7 }] 
   @UI.lineItem       : [{ position:7, label:'Product' }]
   @EndUserText.label: 'Product'
//  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPLANTVALUEHELP', element: 'Material' },
//  additionalBinding: [{ localElement: 'plant_code',    element: 'plant_code',  usage:#FILTER_AND_RESULT }]
//   }]
   Product : abap.char(20);
   
   @UI.lineItem       : [{ position:8, label:'Product Description' }]
   ProductDesc : abap.char(40);
   
   @UI.lineItem       : [{ position:10, label:'Standard Consumption' }]
   @Semantics.quantity.unitOfMeasure: 'standardunit'
   StandardConsumption : abap.dec(13,3);
    @UI.hidden: true
   standardunit : abap.unit(3);
   
    @UI.lineItem       : [{ position:11, label:'Standard Cost' }]
   @Semantics.amount.currencyCode: 'scostunit'
   scost : abap.curr(13,2);
    @UI.hidden: true
   scostunit : abap.cuky(5);
   
    @UI.lineItem       : [{ position:13, label:'Actual Cost' }]
   @Semantics.amount.currencyCode: 'acostunit'
   acost : abap.curr(13,2);
    @UI.hidden: true
   acostunit : abap.cuky(5);
   
   
    @UI.lineItem       : [{ position:15, label:'Quantity Diff' }]
     @Semantics.quantity.unitOfMeasure: 'diff_unit'
   Qty_diff : abap.dec(13,3);
    @UI.hidden: true
   diff_unit : abap.unit(3);
   
      @UI.lineItem       : [{ position:16, label:'Amount Diff' }]
     @Semantics.quantity.unitOfMeasure: 'amtdiff_unit'
   amt_diff : abap.dec(13,2);
    @UI.hidden: true
   amtdiff_unit : abap.unit(3);
   
   
   
}
