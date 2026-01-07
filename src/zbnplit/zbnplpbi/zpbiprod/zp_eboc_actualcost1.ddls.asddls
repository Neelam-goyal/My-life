@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ACTUAL COST PBI V1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZP_EBOC_ActualCost1
  as select from I_GLAccountLineItemRawData
{
  key CompanyCode,
  key Plant,
  key ControllingArea,
      -- key ControllingKeySubNumber,
  key GLAccount                        as CostElement,
  key BusinessTransactionType          as BusinessTransactionCategory,
  key OriginCtrlgDebitCreditCode       as ControllingDebitCreditCode,
  key OriginSenderObject,
  key GLAccountType                    as CtrlgOriginClassification,
  key OrderID,
  key OrderItem,
  key AccountAssignmentType,
  key PartnerAccountAssignment,
  key PartnerAccountAssignmentType,
  key PartnerCostCenter,
  key PartnerCostCtrActivityType,
  key PartnerBusinessProcess,
  key PartnerOrder,
  key CostSourceUnit                   as UnitOfMeasure,
  key Product                          as Material,
  key CostOriginGroup,
  key OriginCostCenter,
  key OriginCostCtrActivityType,
      PostingDate,
      FiscalYear,
      FiscalPeriod,
      FiscalYearPeriod,
      FiscalYearVariant,
      CompanyCodeCurrency,
      GlobalCurrency,

      // Actual Amounts from ACDOCA
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum(AmountInCompanyCodeCurrency) as AmountInCompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
      sum(AmountInGlobalCurrency)      as AmountInGlobalCurrency,
      @Semantics: { amount : {currencyCode: 'GlobalCurrency'} }
      sum(FixedAmountInGlobalCrcy)     as FixedAmountInGlobalCrcy,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      sum(ValuationQuantity)           as Quantity,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      sum(ValuationFixedQuantity)      as FixedQuantity
}
where
          SourceLedger              =  '0L'
  and     ControllingObject         <> ''
  and(
          AccountAssignmentType     =  'OR'
    or    AccountAssignmentType     =  'OP'
  )
  and     SubLedgerAcctLineItemType <> '09101'
  and     SubLedgerAcctLineItemType <> '09111'

  and(
    (
          CompanyCode               =  'BBPL' // Burger from BBPL
      and Plant                     =  'BB03'
    )
    or(
          CompanyCode               =  'BNPL' // Bread from BNPL, BIPL, CAPL
      or  CompanyCode               =  'BIPL'
      or  CompanyCode               =  'CAPL'
    )
  )

group by
  CompanyCode,
  Plant,
  ControllingArea,
  GLAccount,
  BusinessTransactionType,
  OriginCtrlgDebitCreditCode,
  OriginSenderObject,
  GLAccountType,
  OrderID,
  OrderItem,
  AccountAssignmentType,
  PartnerAccountAssignment,
  PartnerAccountAssignmentType,
  PartnerCostCenter,
  PartnerCostCtrActivityType,
  PartnerBusinessProcess,
  PartnerOrder,
  CostSourceUnit,
  Product,
  CostOriginGroup,
  OriginCostCenter,
  OriginCostCtrActivityType,
  CompanyCodeCurrency,
  GlobalCurrency,
  PostingDate,
  FiscalYear,
  FiscalPeriod,
  FiscalYearPeriod,
  FiscalYearVariant
