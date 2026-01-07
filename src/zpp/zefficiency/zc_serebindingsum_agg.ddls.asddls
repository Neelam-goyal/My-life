@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'sum cds for no of ocuurence and causes in 1st screen'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_SEREBINDINGSUM_AGG
  as select from ZCDSSEREBINDINGSUM
{
key  BreakdownDate,
key  ManufacturingOrder,
     WorkCenter,
     Shift,
     Plant,
     sum(NoOfOccurence) as NoOfOccurence,
     sum(BreakdowndurationINmin) as TotalTimeMins
}
group by BreakdownDate,
         ManufacturingOrder,
         WorkCenter,
         Shift,
         Plant
