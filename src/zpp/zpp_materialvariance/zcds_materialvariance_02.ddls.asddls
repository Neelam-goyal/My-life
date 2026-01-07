@EndUserText.label: 'Matrial Varience'
@Search.searchable: false
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MATERIALVARIANCE_02'
@UI: {
  headerInfo: {
   typeName: 'Count',
    typeNamePlural: 'Count',
    title: {
      type: #STANDARD,
      label: 'Material Variance',
      value: 'ProductionOrder'
    }
  }
  ,
  presentationVariant: [ {
    sortOrder: [ 
      { by: 'ProductionOrder', direction: #ASC },
      { by: 'confirmationyieldquantity', direction: #ASC },
      { by: 'Shift', direction: #ASC },
      { by: 'PostingDate', direction: #ASC }
      ],
    visualizations: [ {
      type: #AS_LINEITEM
    } ]
  } ]
}
define custom entity ZCDS_MaterialVariance_02
{
  @UI.selectionField : [{ position: 10 }] 
  @UI.lineItem       : [{ position:10, label:'Company Code' }]
  @EndUserText.label: 'Company Code'
  @Consumption.filter:{ mandatory: true }
  @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode', name: 'I_CompanyCode' }}]
  key comp_code : abap.char(4);
  
  @UI.selectionField : [{ position: 20 }] 
  @UI.lineItem       : [{ position:20, label:'Plant' }]
  @EndUserText.label: 'Plant'
  @Consumption.filter:{ mandatory: true }
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZPLANTVALUEHELP', element: 'plant_code' },
  additionalBinding: [{ localElement: 'comp_code', element: 'comp_code',  usage:#FILTER  }] 
  }] 
  key plant_code : abap.char(4);
    
   @Consumption.filter.hidden: true 
   @UI.selectionField : [{ position: 90 }] 
   @UI.lineItem       : [{ position:90, label:'Bom Component Code' }]
  key BomComponentCode : abap.char(20);
     
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:142, label:'BOM Standard Cost' }]
   key BomStdcost : abap.dec( 13,3);
 
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:140, label:'Material Document' }]
   key materialdocument : abap.char( 10);
   
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:141, label:'Actual Cost' }]
   key actualcost : abap.dec( 13,3);
   
  @UI.lineItem       : [{ position:100, label:'Bom Component Name' }]
  key BomComponentName : abap.char(40);
       
   @UI.selectionField : [{ position: 40 }] 
//   @Consumption.filter:{ mandatory: true }
   @UI.lineItem       : [{ position:40, label:'Posting Date' }]
   @EndUserText.label: 'Posting Date'
  key PostingDate : abap.dats(8);

  
    @UI.lineItem       : [{ position:110, label:'Actual Consumption' }]
   @Semantics.quantity.unitOfMeasure: 'act_unit'
  key ActualConsumption : abap.dec( 13,3);
  
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:115 , label:'Goods Movement Type' }]
   @EndUserText.label: 'Goods Movement Type'
   @Search.defaultSearchElement: true
  key GoodsMovementType : abap.char(3);
  
   @UI.selectionField : [{ position: 50 }] 
   @UI.lineItem       : [{ position:50, label:'Shift' }]
   @EndUserText.label: 'Shift'
   @Consumption.filter.hidden: true
   @Consumption.valueHelpDefinition: [{ entity: { name: 'zshift_vh', element: 'value_low' } }]
  key Shift : abap.char(6);
  
   @UI.selectionField : [{ position: 51 }] 
   @UI.lineItem       : [{ position:51}]
   @EndUserText.label: 'Confirmation Group'
   @Consumption.filter.hidden: true

  key Confirmation_group : abap.char(10);
  
   @UI.selectionField : [{ position: 52 }] 
   @UI.lineItem       : [{ position:52}]
   @EndUserText.label: 'Confirmation Count'
   @Consumption.filter.hidden: true
  key Confirmation_Count : abap.char(8);
   
  @UI.hidden: true
  @Consumption.filter.hidden: true
  key act_unit :abap.unit(3);
  
   @UI.lineItem       : [{ position:65 , label:'ConfirmationYield Quantity' }]
   @EndUserText.label: 'ConfirmationYield Quantity'
   key confirmationyieldquantity : abap.char(12);
   
   
  @Consumption.filter.hidden: true
  @UI.lineItem       : [{ position:30, label:'Work Center' }]
  work_center : abap.char(8);
   
   @UI.selectionField : [{ position: 60 }] 
   @UI.lineItem       : [{ position:60 , label:'Production Order' }]
   @EndUserText.label: 'Production Order'
   ProductionOrder : abap.char(12);
   
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:70, label:'Product' }]
   @EndUserText.label: 'Product'
   Product : abap.char(20);
   
   @UI.lineItem       : [{ position:80, label:'Product Description' }]
   ProductDesc : abap.char(40);
   
   @UI.lineItem       : [{ position:110, label:'BOM Std Consum' }]
   BomComponentRequiredQuantity : abap.dec( 13,3);
   
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:140, label:'QTY Diff' }]
   qtydiff : abap.dec( 13,3);
   
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:144, label:'AMT Diff' }]
   amtdiff : abap.dec( 13,3);
   
   @Consumption.filter.hidden: true
   @UI.lineItem       : [{ position:146, label:'AmtDiffActualRate' }]
   AmtDiffActualRate : abap.dec( 13,3);
  
 }
