@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds for calculation of causes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
        serviceQuality: #X,
        sizeCategory: #S,
        dataClass: #MIXED
}
define view entity zcds_calculationcauses as select from zproduction_mst as a
// join ZCDSRebindingCauseDetail as b on a.posting_date = b.BreakdownDate
////                                        and a.work_center = b.WorkCenter
//                                        and a.shift = b.Shift
//                                        and a.plant = b.Plant
{
a.posting_date as Postingdate,
a.work_center as WorkCenter,
a.shift as Shift,
a.plant as Plant

// @EndUserText.label: 'No Of Causes Occure'
//     sum(b.NoOfOccurence) as NoofCausesoccurrence,
// @EndUserText.label: 'Total Causes Time'
//     sum( b.TotalTimeMins ) as TotalCausesTime    
 }group by a.posting_date,a.work_center,a.shift,a.plant
     

