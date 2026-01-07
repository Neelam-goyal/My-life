@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ACTUAL COST PBI V2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZP_EBOC_ActualCost2
  as select from ZP_EBOC_ActualCost1 as _Costs

{
  key _Costs.CompanyCode,
  key _Costs.Plant,
  key _Costs.ControllingArea,
      //  key ControllingKeySubNumber,
  key _Costs.CostElement,
  key _Costs.BusinessTransactionCategory,
  key _Costs.ControllingDebitCreditCode,
  key _Costs.OriginSenderObject,
  key _Costs.CtrlgOriginClassification,
  key _Costs.OrderID,
  key _Costs.OrderItem,
  key _Costs.AccountAssignmentType,
  key _Costs.PartnerAccountAssignment,
  key _Costs.PartnerAccountAssignmentType,
  key _Costs.PartnerCostCenter,
  key _Costs.PartnerCostCtrActivityType,
  key _Costs.PartnerBusinessProcess,
  key _Costs.PartnerOrder,
  key _Costs.UnitOfMeasure,
  key _Costs.Material,
  key _Costs.CostOriginGroup,
  key _Costs.OriginCostCenter,
  key _Costs.OriginCostCtrActivityType,
      _Costs.PostingDate,
      _Costs.FiscalYear,
      _Costs.FiscalPeriod,
      _Costs.FiscalYearPeriod,
      _Costs.FiscalYearVariant,
      _Costs.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _Costs.AmountInCompanyCodeCurrency,

      // Cost Rate for Fixed Amount
      cast(
        case
           when _Costs.AmountInGlobalCurrency <> 0
             then division( cast(_Costs.FixedAmountInGlobalCrcy as abap.dec(23,2)), cast(_Costs.AmountInGlobalCurrency as abap.dec(23,2)), 8)
           else 0
         end as abap.dec(14, 8)
      ) as CostRateFixedAmount,

      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      _Costs.Quantity,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      _Costs.FixedQuantity
}
