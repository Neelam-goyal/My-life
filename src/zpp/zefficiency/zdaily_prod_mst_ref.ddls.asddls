@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reference of prod mst'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDAILY_PROD_MST_REF as select from  zproduction_mst as a
    left outer join zproduct_details as b on a.posting_date = b.PostingDate 
                                         and a.work_center = b.WorkCenter 
                                         and a.shift = b.ShiftDescription
                                         and a.plant = b.Plant

    {
     @EndUserText.label: 'Posting Date'
     key a.posting_date as PostingDate,
      @EndUserText.label: 'Work Center'
     key a.work_center as WorkCenter,
     @EndUserText.label: 'Shift Definition'
     key a.shift as ShiftDefinition,
      @EndUserText.label: 'Plant'
     key a.plant as Plant,
     key min( b.ManufacturingOrder ) as ManufacturingOrder,
     
      @EndUserText.label: 'Order Type'
     a.order_type as OrderType,
 
     @EndUserText.label: 'Total Actual Runtime'    
     sum( cast( b.CalculatedActualRuntime as abap.dec(15,2) ) ) as CalculatedActualRuntime,
     @EndUserText.label: 'Total Plant Runtime'    
     ( cast( b.plant_runtime as abap.dec(15,2) ) ) as Plant_runtime,
     @EndUserText.label: 'Difference In Runtime'
     sum( cast( b.difference_runtime as abap.dec(15,2) ) ) as difference_runtime
     

     
 }where b.plant_runtime is not initial
 group by
     a.posting_date,
     a.work_center,
     a.shift,
     a.plant,
     a.order_type,
     b.plant_runtime
//    b.ManufacturingOrder

