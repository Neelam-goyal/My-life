@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BBPL Mfg Order Goods Movement'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MfgOrderDocdGoodsMovementV2
  as select from    I_ManufacturingOrder          as Ordr
    inner join      ZR_USER_CMPY_ACCESS           as _cmpAccess on  _cmpAccess.CompCode = Ordr.CompanyCode
                                                                and _cmpAccess.userid   = $session.user
    inner join      I_MfgOrderDocdGoodsMovement   as X          on Ordr.ManufacturingOrder = X.ManufacturingOrder
    left outer join I_MfgOrderConfMatlDocItem     as A          on  A.ManufacturingOrder   = X.ManufacturingOrder
                                                                and A.MaterialDocument     = X.GoodsMovement
                                                                and A.MaterialDocumentYear = X.GoodsMovementYear
                                                                and A.MaterialDocumentItem = X.GoodsMovementItem
    left outer join ZR_MfgOrderConfirmationHeader as B          on  A.ManufacturingOrder        = B.ManufacturingOrder
                                                                and A.MfgOrderConfirmationGroup = B.MfgOrderConfirmationGroup
                                                                and A.MfgOrderConfirmation      = B.MfgOrderConfirmation
                                                                and A.MaterialDocument          = B.MaterialDocument
                                                                and A.MaterialDocumentYear      = B.MaterialDocumentYear
{
  key X.GoodsMovement          as MaterialDocument,
  key X.GoodsMovementYear      as MaterialDocumentYear,
  key X.GoodsMovementItem      as MaterialDocumentItem,
  key Ordr.ManufacturingOrder,
      B.MfgOrderConfirmationGroup,
      B.MfgOrderConfirmation,

      Ordr.CompanyCode,
      Ordr.ProfitCenter,
      Ordr.CreationDate        as OrderCreationDate,


      B.MfgOrderConfirmationEntryDate,
      B.MfgOrderConfirmationEntryTime,
      B.ConfirmationUnit,
      B.OrderActualReleaseDate,
      B.WorkCenterText,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationYieldQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationScrapQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationReworkQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      B.ConfirmationTotalQuantity,

      B.ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      B.ConfYieldQtyInProductionUnit,
      B.OperationUnit,
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      B.OpPlannedTotalQuantity,

      Ordr.ManufacturingOrderCategory,
      Ordr.ManufacturingOrderType,
      Ordr.ProductionPlant     as Plant,
      X.Material,
      A.ConfirmationPlant      as GoodsMovementPlant,

      X.Reservation,
      X.ReservationItem,
      X.ReservationRecordType,
      X.ReservationIsFinallyIssued,

      X.StorageLocation,
      X.Batch,
      X.InventoryValuationType,
      X.DebitCreditCode,
      X.GoodsMovementType,
      X.GoodsMovementRefDocType,
      X.InventorySpecialStockType,

      A.WBSElementInternalID_2 as WBSElementInternalID,

      X.ControllingArea,
      X.GLAccount,
      X.PostingDate,
      X.DocumentDate           as MaterialDocumentDate,
      X.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      X.QuantityInBaseUnit,
      X.EntryUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      X.QuantityInEntryUnit,
      X.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      X.TotalGoodsMvtAmtInCCCrcy

}
where
(
  (
       Ordr.ManufacturingOrderType = 'Z111'
    or Ordr.ManufacturingOrderType = 'Z112'
  )
  and(
       Ordr.CompanyCode            = 'BBPL'
    or Ordr.CompanyCode            = 'BIPL'
    or Ordr.CompanyCode            = 'BNPL'
    or Ordr.CompanyCode            = 'CAPL'
  )
) or
(
  (
       Ordr.ManufacturingOrderType = 'Z111'
    or Ordr.ManufacturingOrderType = 'Z112'
    or Ordr.ManufacturingOrderType = 'Z116'
  )
  and(
       Ordr.CompanyCode            = 'HOVL'
    
  )
)
