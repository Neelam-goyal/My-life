@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fiscal Calendar for Running Total'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZRT_FiscalCalendarDate
  as select from ZR_FiscalYearPeriodForVariant as A
    inner join   ZR_FiscalYearPeriodForVariant as B on A.FiscalYear = B.FiscalYear
    and A.FiscalPeriod <= B.FiscalPeriod
{

  B.FiscalYear,
  A.FiscalYearPeriod,  
  B.FiscalYearPeriod as AsOnFiscalYearPeriod,
  case when A.FiscalYearPeriod = B.FiscalYearPeriod
   then 1 else 0 end as MULTIPLIERTAG
}

     
