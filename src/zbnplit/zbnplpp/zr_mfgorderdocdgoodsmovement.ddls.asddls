@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Issue (Goods Movement)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MfgOrderDocdGoodsMovement
  as select from    I_MfgOrderConfMatlDocItem     as A

    inner join      I_ManufacturingOrder          as Ordr       on A.ManufacturingOrder = Ordr.ManufacturingOrder

    inner join      ZR_USER_CMPY_ACCESS           as _cmpAccess on  _cmpAccess.CompCode = Ordr.CompanyCode
                                                                and _cmpAccess.userid   = $session.user
    left outer join ZR_MfgOrderConfirmationHeader as B          on  A.ManufacturingOrder        = B.ManufacturingOrder
                                                                and A.MfgOrderConfirmationGroup = B.MfgOrderConfirmationGroup
                                                                and A.MfgOrderConfirmation      = B.MfgOrderConfirmation
                                                                and A.MaterialDocument          = B.MaterialDocument
                                                                and A.MaterialDocumentYear      = B.MaterialDocumentYear
    left outer join I_MfgOrderDocdGoodsMovement   as X          on  A.ManufacturingOrder   = X.ManufacturingOrder
                                                                and A.MaterialDocument     = X.GoodsMovement
                                                                and A.MaterialDocumentYear = X.GoodsMovementYear
                                                                and A.MaterialDocumentItem = X.GoodsMovementItem
  //    left outer join I_MfgOrderConfirmation      as B          on  A.GoodsMovement     = B.MaterialDocument
  //                                                              and A.GoodsMovementYear = B.MaterialDocumentYear
{
  key A.MaterialDocument     as MaterialDocument,
  key A.MaterialDocumentYear as MaterialDocumentYear,
  key A.MaterialDocumentItem as MaterialDocumentItem,
  key A.ManufacturingOrder,
  key B.MfgOrderConfirmationGroup,
  key B.MfgOrderConfirmation,

      Ordr.CompanyCode,
      Ordr.ProfitCenter,
      Ordr.CreationDate      as OrderCreationDate,


      B.MfgOrderConfirmationEntryDate,
      B.MfgOrderConfirmationEntryTime,
      B.ConfirmationUnit,
      B.OrderActualReleaseDate,

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

      A.ManufacturingOrderCategory,
      A.ManufacturingOrderType,
      A.Plant                as Plant,
      A.Material,
      A.ConfirmationPlant    as GoodsMovementPlant,

      A.Reservation,
      A.ReservationItem,
      A.ReservationRecordType,
      A.ReservationIsFinallyIssued,

      A.StorageLocation,
      A.Batch,
      A.InventoryValuationType,
      A.DebitCreditCode,
      A.GoodsMovementType,
      A.GoodsMovementRefDocType,
      A.InventorySpecialStockType,

      A.WBSElementInternalID_2 as WBSElementInternalID,

      X.ControllingArea,
      X.GLAccount,
      A.PostingDate,
      A.DocumentDate         as MaterialDocumentDate,
      A.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      A.QuantityInBaseUnit,
      A.EntryUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      A.QuantityInEntryUnit,
      X.CompanyCodeCurrency,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      X.TotalGoodsMvtAmtInCCCrcy

}
where
  (
       A.ManufacturingOrderType = 'Z111'
    or A.ManufacturingOrderType = 'Z112'
  ) //only Production and Packing Entries
//  and(
//    (
//          B.IsReversed             is initial // Exclude Reversed Entries
//      and B.IsReversal             is initial
//    )
//    or(
//          B.IsReversed             is null // Adjusted Entries
//      and B.IsReversal             is null
//    )
//  )
