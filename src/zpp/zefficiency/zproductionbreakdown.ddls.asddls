@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for production break down data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zproductionbreakdown as select from zprodbreakdown as a
{
//   key case 
//        when a.shift = '1' then 'DAY'   
//        when a.shift = '2' then 'NIGHT'
//        else ''
//     end as shift,
   key cast(
        case 
            when a.shift = '1' then 'DAY'   
            when a.shift = '2' then 'NIGHT'
            else ''
        end as abap.char(10)
    ) as shift,
    key a.brkdndate,
   key a.prodordcode,
    a.comp_code,
    a.reasoncode,
    a.reasondesc,
    a.subreasoncode,
    a.subreasondesc,
    a.remarks,
    a.brkdnstarttime,
    a.brkdnendtime,
    a.breakdownpercentage
   
}
