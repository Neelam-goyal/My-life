@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Freight Component of Billing Document Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_BillingDocumentItemFreight
  as select from I_BillingDocumentItemPrcgElmnt
{
  key BillingDocument,
  key BillingDocumentItem,
  ConditionType,
  TransactionCurrency,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  sum(ConditionAmount) as FreightValue
}
where
  ConditionType = 'ZFRT' //Freight
group by
  BillingDocument,
  BillingDocumentItem,
  ConditionType,
  TransactionCurrency
