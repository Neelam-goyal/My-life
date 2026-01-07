@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Please Don''t Use Don''t delete'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_FiscalYearPeriodForVariant 
as select from I_FiscalYearPeriodForVariant
{
    key FiscalYearPeriod,
    FiscalYear,
    FiscalPeriod,
    FiscalPeriodStartDate,
    FiscalPeriodEndDate,
    IsSpecialPeriod,
    FiscalYearStartDate,
    FiscalYearEndDate,
    NextFiscalPeriod,
    NextFiscalPeriodFiscalYear
}
where FiscalYearVariant = 'V3'
union
 select from I_FiscalYearPeriodForVariant
{
    key concat(FiscalYear,'000')  as FiscalYearPeriod,
    FiscalYear,
    '000' as FiscalPeriod,
    FiscalPeriodStartDate,
    FiscalPeriodEndDate,
    IsSpecialPeriod,
    FiscalYearStartDate,
    FiscalYearEndDate,
    NextFiscalPeriod,
    NextFiscalPeriodFiscalYear
}
where FiscalYearVariant = 'V3'
and FiscalPeriod = '001'
