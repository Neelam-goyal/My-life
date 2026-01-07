@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'materia variance data for display'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zc_customvariance as select from zmaterialdecl

{
    
//       @UI.selectionField: [{ position: 10 }]
//      @EndUserText.label: 'Company'
//      @Consumption.filter : { mandatory: true }
//      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
//      @UI.lineItem    : [{ position: 40 ,label: 'Company' }]
//        key Bukrs as Company;
     
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Plant'
//      @Consumption.filter : { mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
      @UI.lineItem    : [{ position: 40 ,label: 'Plant' }]
      key bukrs as company ,     
//
     @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Plant'
//      @Consumption.filter : { mandatory: true }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
      @UI.lineItem    : [{ position: 50 ,label: 'Plant Code' }]
      key plantcode         as Plantcode,
  
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Declare Date'
      @UI.lineItem: [{ position: 60 ,label: 'Declare Date' }]
      key declaredate as Declaredate,
      
      @UI.selectionField: [{ position:50 }]
      @EndUserText.label: 'Declare number'
      @UI.lineItem: [{ position: 70 ,label: 'Declare number' }]
      key declareno as DeclareNo,
      
      @UI.selectionField: [{ position:60 }]
      @EndUserText.label: 'Product Code'
      @UI.lineItem: [{ position: 80 ,label: 'Product Code' }]
      key productcode as Productcode,
      
      @UI.selectionField: [{ position:70 }]
      @EndUserText.label: 'Batch number'
      @UI.lineItem: [{ position: 80 ,label: 'Batch number' }]
      key batchno as Batchno
//  
//  @UI.selectionField: [{ position: 40 }]
//      @EndUserText.label: 'Plant'
//      @Consumption.filter : { mandatory: true }
//      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' } }]
//      @UI.lineItem    : [{ position: 60 ,label: 'Plant' }]
//  key         as Plant; 
  
  
//        @Search.defaultSearchElement: true
//        @Search.fuzzinessThreshold: 0.90
//        @EndUserText.label: 'Company'
//  key   Bukrs,
//        @Search.defaultSearchElement: true
//        @Search.fuzzinessThreshold: 0.90
//        @EndUserText.label: 'Plant'
//  key   Plantcode,
//        @Search.defaultSearchElement: true
//        @Search.fuzzinessThreshold: 0.90
//        @EndUserText.label: 'Declaration Date'
//  key   Declaredate,
//  key   Declareno,
//        @Search.defaultSearchElement: true
//        @Search.fuzzinessThreshold: 0.90
//        @EndUserText.label: 'Product'
//  key   Productcode,
//        @EndUserText.label: 'Batch'
//  key   Batchno,
//        Productdesc,
////        @Semantics.unitOfMeasure: true
////        Uom,
//        Stockquantity
      
  
  
  
     
     
    
        
}
