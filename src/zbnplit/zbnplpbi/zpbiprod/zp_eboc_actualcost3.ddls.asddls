@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ACTUAL COST PBI V3'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZP_EBOC_ActualCost3
  as select from ZP_EBOC_ActualCost2
{
  key CompanyCode,
  key Plant,
  key ControllingArea,
      //  key ControllingKeySubNumber,
  key CostElement,
  key BusinessTransactionCategory,
  key ControllingDebitCreditCode,
  key OriginSenderObject,
  key CtrlgOriginClassification,
  key OrderID,
  key OrderItem,
  key AccountAssignmentType,
  key PartnerAccountAssignment,
  key PartnerAccountAssignmentType,
  key PartnerCostCenter,
  key PartnerCostCtrActivityType,
  key PartnerBusinessProcess,
  key PartnerOrder,
  key UnitOfMeasure,
  key Material,
  key CostOriginGroup,
  key OriginCostCenter,
  key OriginCostCtrActivityType,
  key cast('04' as abap.char(2) )                                                                                        as ControllingValueType,
      PostingDate,
      FiscalYear,
      FiscalPeriod,
      FiscalYearPeriod,
      FiscalYearVariant,
      CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      AmountInCompanyCodeCurrency,

      cast(round(CostRateFixedAmount * cast(AmountInCompanyCodeCurrency as abap.dec( 23, 2 )), 2) as abap.dec( 23, 2 ) ) as FixedAmountInCompCodeCurrency,

      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      Quantity,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      FixedQuantity
}
