@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'COGM Order and Item Cost'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZP_EBOC_COGM_OrderAndItemCosts
  as select from ZP_EBOCCOGM_OrderAndItemCosts1 as cost
  association [0..1] to ZDIM_Product                 as _Material                    on  $projection.Material = _Material.Product

  association [0..*] to I_GLAccountText              as _GLAccountTxt                on  _GLAccountTxt.ChartOfAccounts = 'YCOA'
                                                                                     and $projection.CostElement       = _GLAccountTxt.GLAccount
                                                                                     and _GLAccountTxt.Language        = $session.system_language
  association [0..*] to I_CostCenterText             as _PartnerCostCenterText       on  $projection.PartnerCostCenter   = _PartnerCostCenterText.CostCenter
                                                                                     and $projection.ControllingArea     = _PartnerCostCenterText.ControllingArea
                                                                                     and _PartnerCostCenterText.Language = $session.system_language
  association [0..*] to I_CostCenterActivityTypeText as _PrtrCostCenterActvtTypeText on  $projection.ControllingArea            = _PrtrCostCenterActvtTypeText.ControllingArea
                                                                                     and $projection.PartnerCostCtrActivityType = _PrtrCostCenterActvtTypeText.CostCtrActivityType
                                                                                     and _PrtrCostCenterActvtTypeText.Language  = $session.system_language


{
  key cost.CompanyCode,
  key cost.ControllingArea,
  key cost.ControllingValueType,
  key cost.CostElement,

  key cost.OriginSenderObject,
  key cost.CtrlgOriginClassification,
  key cost.OrderType,
  key cost.OrderCategory,
  key cost.OrderID,
  key cost.OrderItem,
  key cost.MfgOrderHasMultipleItems,
  key cost.AccountAssignmentType,
  key cost.PartnerAccountAssignment,
  key cost.PartnerObjectType,
  key cost.PartnerCostCenter,
  key cost.PartnerCostCtrActivityType,
  key cost.PartnerBusinessProcess,
  key cost.PartnerOrder,
  key cost.UnitOfMeasure,
  key cost.Material,
  key cost.Plant,
  key cost.CostOriginGroup,
      cost.OutProduct,
      cost.CompanyCodeCurrency,
      cost.PostingDate,
      cost.FiscalYear,
      cost.FiscalPeriod,
      cost.FiscalYearPeriod,
      cost.FiscalYearVariant,

      cost.SystemDate,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      cost.AmountInCompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      cost.FixedAmountInCompCodeCurrency,
      @Semantics: { quantity : {unitOfMeasure: 'UnitOfMeasure'} }
      cost.TotalQuantity,
      _Material.Product,
      _Material.ProductName,
      _Material.ProductType,
      _Material.ProductGroup,
      _Material.ProductGroupName,
      _Material.ProductSubGroupName,
      _Material.ProductCategory,
      _Material.Brand,
      _Material.GrossWeight,
      _Material.NetWeight,
      _Material.BaseUnit,
      _GLAccountTxt.GLAccountName,
      _PartnerCostCenterText.CostCenterName,
      _PrtrCostCenterActvtTypeText.CostCtrActivityTypeDesc
}
