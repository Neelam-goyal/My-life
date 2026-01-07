@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GROUPBY OF CDS ZCDSSERREBINDING'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDSSEREBINDINGSUM as select from ZCDSRebindingCauseDetail as A
left outer join zproduct_details  as b on A.ManufacturingOrder = b.ManufacturingOrder
                                   and A.BreakdownDate = b.PostingDate
                                   and A.Shift = b.ShiftDescription
                                   and A.Companycode = b.CompanyCode                             
{
    key b.WorkCenter           as WorkCenter,
    key A.BreakdownDate        as BreakdownDate,
    key b.Plant                as Plant,
    key A.Shift                as Shift,
    key A.Companycode          as CompanyCode,
    key A.ManufacturingOrder   as ManufacturingOrder,
        A.Reasoncode           as Reasoncode,
        A.ReasonDescription    as ReasonDescription,
        A.Breakdown_Percentage as Breakdown_Percentage,
        A.NOOFOCCURRENCE       as NoOfOccurence,
        A.BrkDownTimeInMINS    as BreakdowndurationINmin
}
//group by
//    WorkCenter,
//    Plant,
//    Shift,
//    BreakdownDate,
//    ManufacturingOrder,
//    CompanyCode,
//    Reasoncode,
//    ReasonDescription

