@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Cause Detail Union'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDSRebindingCauseDetail as

select from ZCDS_FINALCAUSEDETAILS as a
{
    key a.SHIFT               as Shift,
    key a.CompanyCode        as Companycode,
    key a.BreakdownDate      as BreakdownDate,
    key a.ManufacturingOrder as ManufacturingOrder,
        a.Reasoncode         as Reasoncode,
        a.ReasonDescription  as ReasonDescription,
        sum(a.BrkDownTimeInMINS)       as Breakdown_Percentage,
        sum(a.BrkDwnInMinPercentage )    as BrkDownTimeInMINS,
        a.NoOfOccurrence as NOOFOCCURRENCE
//        sum(a.NoOfOccurrence * a.BrkDownTimeInMINS) as TotalTimeMins
}
group by
 a.SHIFT ,
 a.CompanyCode,  
 a.BreakdownDate,
 a.ManufacturingOrder,
 a.Reasoncode,
 a.ReasonDescription,
 a.NoOfOccurrence
 