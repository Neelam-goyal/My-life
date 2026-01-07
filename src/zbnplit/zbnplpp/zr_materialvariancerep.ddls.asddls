@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Variance Report Query'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZR_MaterialVarianceRep
  with parameters
    pCompany   : abap.char(4),
    pPrdnPlant : abap.char(4),
    pFromDate  : abap.dats,
    pToDate    : abap.dats
  as select from ZTBLF_MaterialVarianceRep
                 (
                 pCompany : $parameters.pCompany,
                 pFromDate:$parameters.pFromDate,
                 pToDate:$parameters.pToDate,
                 pPrdnPlant:$parameters.pPrdnPlant

                 )

{
  key RId,
  ManufacturingOrder,
  CompanyCode,
  ProductionPlant,
  MfgOrderDate,
  ManufacturingOrderType,
  MfgProduct,
  MfgProductName,
  BOM,
  BusinessArea,
  ControllingArea,
  ProfitCenter,
  CostingSheet,
  ProductionUnit,

  concat_with_space(cast( MfgOrderPlannedTotalQty as abap.char(20) ) , ProductionUnit,1)      as MfgOrderPlannedTotalQty,
  concat_with_space(cast( MfgOrderConfirmedYieldQty as abap.char(20) ) , ProductionUnit,1)    as MfgOrderConfirmedYieldQty,
  concat_with_space(cast( ActualDeliveredQuantity as abap.char(20) ) , ProductionUnit,1)      as ActualDeliveredQuantity,

  MfgOrderConfirmationGroup,
  MfgOrderConfirmation,
  WorkCenterInternalID,
  WorkCenterText,
  MaterialDocument,
  MaterialDocumentYear,
  ManufacturingOrderCategory,
  PostingDate,
  ConfirmationUnit,
  concat_with_space(cast( ConfirmationYieldQuantity as abap.char(20) ) , ProductionUnit,1)    as ConfirmationYieldQuantity,
  concat_with_space(cast( ConfirmationScrapQuantity as abap.char(20) ) , ProductionUnit,1)    as ConfirmationScrapQuantity,
  concat_with_space(cast( ConfirmationReworkQuantity as abap.char(20) ) , ProductionUnit,1)   as ConfirmationReworkQuantity,
  concat_with_space(cast( ConfirmationTotalQuantity as abap.char(20) ) , ProductionUnit,1)    as ConfirmationTotalQuantity,
  concat_with_space(cast( ConfYieldQtyInProductionUnit as abap.char(20) ) , ProductionUnit,1) as ConfYieldQtyInProductionUnit,
  MaterialDocumentDate,
  Material,
  GoodsMovementType,
  UnitOfMeasurement,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasurement'
  RequiredQty,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasurement'
  ActualQty,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasurement'
  DiffQty,
  
  Currency,
  @Semantics.amount.currencyCode: 'Currency'
  RequiredAmt,
  @Semantics.amount.currencyCode: 'Currency'
  ActualAmt,
  @Semantics.amount.currencyCode: 'Currency'
  DiffAmt
}
