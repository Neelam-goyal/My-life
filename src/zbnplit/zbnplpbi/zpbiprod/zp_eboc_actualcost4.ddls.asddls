@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ACTUAL COST PBI V4'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZP_EBOC_ActualCost4
  as select from ZP_EBOC_ActualCost3
{
  key CompanyCode,
  key ControllingValueType,
  key CostElement,
      //  key ControllingKeySubNumber,
  key ControllingDebitCreditCode,
  key AccountAssignmentType,
  key OrderID,
  key OrderItem,
  key PartnerAccountAssignment,
  key PartnerAccountAssignmentType,
  key PartnerCostCenter,
  key PartnerCostCtrActivityType,
  key PartnerBusinessProcess,
  key PartnerOrder,
  key OriginSenderObject,
  key 'A'      as CtrlgOriginClassification, //Origin Indicator
  key UnitOfMeasure,
  key Material,
  key CostOriginGroup,

  key ControllingArea,
      PostingDate,
      FiscalYear,
      FiscalPeriod,
      FiscalYearPeriod,
      FiscalYearVariant,
      CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      AmountInCompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      FixedAmountInCompCodeCurrency,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      Quantity as TotalQuantity
}
where
     ControllingDebitCreditCode = 'H'
  or ControllingDebitCreditCode = 'S'
