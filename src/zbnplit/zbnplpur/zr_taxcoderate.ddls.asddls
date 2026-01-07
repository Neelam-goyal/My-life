@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tax Rate'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TaxCodeRate
  as select from I_TaxCodeRate
{

  key TaxCalculationProcedure,
  key TaxCode,
  key CndnRecordValidityStartDate,
      sum(ConditionRateRatio)                                                   as TaxRate,
      sum(case when AccountKeyForGLAccount = 'JIS' then ConditionRateRatio end) as SGSTRate,
      sum(case when AccountKeyForGLAccount = 'JIC' then ConditionRateRatio end) as CGSTRate,
      sum(case when AccountKeyForGLAccount = 'JII' then ConditionRateRatio end) as IGSTRate

}
where
       Country                = 'IN'

  and(
       AccountKeyForGLAccount = 'JIC'
    or AccountKeyForGLAccount = 'JIS'
    or AccountKeyForGLAccount = 'JII'
  )
group by
  TaxCalculationProcedure,
  TaxCode,
  CndnRecordValidityStartDate
