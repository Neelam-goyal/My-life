@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Goods Mov. Entries Without Order Conf.'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MfgOrderDocdGoodsMovWCNF
  as select from ZR_GoodsMovWithoutOrderConf as A
    inner join   I_MfgOrderDocdGoodsMovement as B on  A.ManufacturingOrder   = B.ManufacturingOrder
                                                  and A.MaterialDocument     = B.GoodsMovement
                                                  and A.MaterialDocumentYear = B.GoodsMovementYear
{
  key B.ManufacturingOrder,
  key B.GoodsMovement,
  key B.GoodsMovementYear,
  key B.GoodsMovementItem,
  B.ManufacturingOrderCategory,
  B.ManufacturingOrderType,
  B.ProductionPlant,
  B.Material,
  B.Reservation,
  B.ReservationItem,
  B.StorageLocation,
  B.Batch,
  B.DebitCreditCode,
  B.GoodsMovementType,
  B.ControllingArea,
  B.GLAccount,
  B.PostingDate,
  B.DocumentDate,
  
  B.BaseUnit,
  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  B.QuantityInBaseUnit,
  
  B.EntryUnit,
  @Semantics.quantity.unitOfMeasure: 'EntryUnit'
  B.QuantityInEntryUnit,
  
  B.CompanyCodeCurrency,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  B.TotalGoodsMvtAmtInCCCrcy
}
where
     B.ManufacturingOrderType = 'Z111'
  or B.ManufacturingOrderType = 'Z112'
