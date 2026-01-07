@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PRODUCT HSN'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPBI_ProductHSN
  as select from I_ProductPlantIntlTrd
{
  key Product,
      ConsumptionTaxCtrlCode as HSN
}
group by
  Product,
  ConsumptionTaxCtrlCode
