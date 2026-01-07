    @AbapCatalog.viewEnhancementCategory: [#NONE]
    @AccessControl.authorizationCheck: #NOT_REQUIRED
    @EndUserText.label: 'Daily Production Master'
    @Metadata.ignorePropagatedAnnotations: true
    @ObjectModel.usageType:{
        serviceQuality: #X,
        sizeCategory: #S,
        dataClass: #MIXED
    }
    @UI.presentationVariant: [
  { sortOrder: [ { by: 'PostingDate', direction: #DESC } ] }]
   define root view entity zdaily_prod_mst as select from zproduction_mst as a
    left outer join zproduct_details as b on a.posting_date = b.PostingDate 
                                         and a.work_center = b.WorkCenter 
                                         and a.shift = b.ShiftDescription
                                         and a.plant = b.Plant
                                         

  left outer join ZC_SEREBINDINGSUM_AGG as c
     on b.PostingDate        = c.BreakdownDate
    and b.ManufacturingOrder = c.ManufacturingOrder
    and b.WorkCenter         = c.WorkCenter
    and b.Plant              = c.Plant
    and b.ShiftDescription   = c.Shift

    {
     @EndUserText.label: 'Posting Date'
     key a.posting_date as PostingDate,
      @EndUserText.label: 'Work Center'
     key a.work_center as WorkCenter,
     @EndUserText.label: 'Shift Definition'
     key a.shift as ShiftDefinition,
      @EndUserText.label: 'Plant'
     key a.plant as Plant,
      @EndUserText.label: 'Order Type'
     a.order_type as OrderType,

     @EndUserText.label: 'Total Actual Runtime'    
     sum( cast( b.CalculatedActualRuntime as abap.dec(15,2) ) ) as CalculatedActualRuntime,
     @EndUserText.label: 'Total Plant Runtime'    
     ( cast( b.plant_runtime as abap.dec(15,2) ) ) as Plant_runtime,
     @EndUserText.label: 'Difference In Runtime'
     sum( cast((  b.plant_runtime - b.CalculatedActualRuntime ) as abap.dec(15,2) ) ) as difference_runtime,
     @EndUserText.label: 'No Of Causes Occurence'
     max(c.NoOfOccurence )as NoofCausesoccurrence,
     @EndUserText.label: 'Total Causes Time(MIN)'
     max(c.TotalTimeMins )  as TotalCausesTime  
     
 }where b.plant_runtime is not initial
 group by
     a.posting_date,
     a.work_center,
     a.shift,
     a.plant,
     a.order_type,
     b.plant_runtime
