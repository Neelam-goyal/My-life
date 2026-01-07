@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'COGM Order and Item Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZP_EBOCCOGM_OrderAndItemCosts1
  as select from I_ManufacturingOrder as OrderHeader
    inner join   ZP_EBOC_ActualCost4  as Costs on OrderHeader.ManufacturingOrder = Costs.OrderID
{
  key OrderHeader.CompanyCode,
  key OrderHeader.ControllingArea              as ControllingArea, //Better to take it from Order
  key Costs.ControllingValueType,
  key cast(Costs.CostElement as  saknr)        as CostElement,
      //  key ControllingKeySubNumber,
  key Costs.ControllingDebitCreditCode,
  key Costs.OriginSenderObject,
  key Costs.CtrlgOriginClassification, //Origin Indicator
  key OrderHeader.ManufacturingOrderCategory   as OrderCategory,
  key OrderHeader.ManufacturingOrderType       as OrderType,
  key OrderHeader.ManufacturingOrder           as OrderID,
  key Costs.OrderItem,
  key OrderHeader.MfgOrderHasMultipleItems,
  key Costs.AccountAssignmentType,
  key Costs.PartnerAccountAssignment,
  key Costs.PartnerAccountAssignmentType       as PartnerObjectType,
  key Costs.PartnerCostCenter,
  key Costs.PartnerCostCtrActivityType,
  key Costs.PartnerBusinessProcess,
  key Costs.PartnerOrder,
  key Costs.UnitOfMeasure,
  key Costs.Material,
  key OrderHeader.PlanningPlant                as Plant,
  key Costs.CostOriginGroup,
      OrderHeader.Product                      as OutProduct,
      Costs.CompanyCodeCurrency,
      Costs.PostingDate,
      Costs.FiscalYear,
      Costs.FiscalPeriod,
      Costs.FiscalYearPeriod,
      Costs.FiscalYearVariant,
      $session.system_date                     as SystemDate,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum(Costs.AmountInCompanyCodeCurrency)   as AmountInCompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum(Costs.FixedAmountInCompCodeCurrency) as FixedAmountInCompCodeCurrency,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      sum(Costs.TotalQuantity)                 as TotalQuantity
}
where
       OrderHeader.OrderIsEventBasedPosting   = 'X'
  and(
       OrderHeader.ManufacturingOrderCategory = '10'
    or OrderHeader.ManufacturingOrderCategory = '40'
  )
group by
  OrderHeader.CompanyCode,
  OrderHeader.ControllingArea,
  Costs.ControllingValueType,
  Costs.CostElement,
  //  ControllingKeySubNumber,
  Costs.ControllingDebitCreditCode,
  Costs.OriginSenderObject,
  Costs.CtrlgOriginClassification, //Origin Indicator
  OrderHeader.ManufacturingOrderType,
  OrderHeader.ManufacturingOrderCategory,
  OrderHeader.ManufacturingOrder,
  Costs.OrderItem,
  OrderHeader.MfgOrderHasMultipleItems,
  Costs.AccountAssignmentType,
  Costs.PartnerAccountAssignment,
  Costs.PartnerAccountAssignmentType,
  Costs.PartnerCostCenter,
  Costs.PartnerCostCtrActivityType,
  Costs.PartnerBusinessProcess,
  Costs.PartnerOrder,
  Costs.UnitOfMeasure,
  Costs.Material,
  OrderHeader.PlanningPlant,
  Costs.CostOriginGroup,
  OrderHeader.Product,
  Costs.CompanyCodeCurrency,
  Costs.PostingDate,
  Costs.FiscalYear,
  Costs.FiscalPeriod,
  Costs.FiscalYearPeriod,
  Costs.FiscalYearVariant
