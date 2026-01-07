@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Planning Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_ManufacturingOrderPlanCost
  as select from I_FinancialPlanningEntryItem
{
  key CompanyCode,
  key Plant,
  key ControllingArea,
  key PlanningCategory,
  key cast(GLAccount as saknr)         as CostElement,
  key BusinessTransactionCategory,
//  key ControllingDebitCreditCode,
  key case
         when BusinessTransactionCategory = 'KPPP' then 'P'
         else 'S'
       end                             as CtrlgOriginClassification,
  key OrderID,
  key PostingDate,
  key cast(
        case AccountAssignmentType
          when 'OR' then '0000'
          else OrderItem
        end
      as co_posnr)                     as OrderItem,
  key AccountAssignmentType,
  key PartnerAccountAssignmentType,
  key PartnerCostCenter,
  key PartnerCostCtrActivityType,
  key PartnerOrder_2                   as PartnerOrder,
  key CostSourceUnit                   as UnitOfMeasure,
  key Material,
  key IsLotSizeIndependent,
  key CostOriginGroup,
  key OriginCostCenter,
  key OriginCostCtrActivityType,
      CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum(AmountInCompanyCodeCurrency) as AmountInCompanyCodeCurrency,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      sum(ValuationQuantity)           as Quantity
}
where
  (
       AccountAssignmentType = 'OR'
    or AccountAssignmentType = 'OP'
  )
group by
  CompanyCode,
  Plant,
  ControllingArea,
  PlanningCategory,
  GLAccount,
  BusinessTransactionCategory,
//  ControllingDebitCreditCode,
  OrderID,
  PostingDate,
  AccountAssignmentType,
  OrderItem,
  PartnerAccountAssignmentType,
  PartnerCostCenter,
  PartnerCostCtrActivityType,
  PartnerOrder_2,
  CostSourceUnit,
  Material,
  IsLotSizeIndependent,
  CostOriginGroup,
  OriginCostCenter,
  OriginCostCtrActivityType,
  CompanyCodeCurrency
