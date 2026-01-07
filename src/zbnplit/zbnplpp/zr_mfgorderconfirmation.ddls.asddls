@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS to Provide Mfg Order Conf. Entries'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MfgOrderConfirmation
  as select from I_MfgOrderConfirmation    as Mst
    inner join   I_ProductionOrder         as PrdnOrdr   on Mst.ManufacturingOrder = PrdnOrdr.ProductionOrder
    inner join   ZR_USER_CMPY_ACCESS       as _cmpAccess on  _cmpAccess.CompCode = Mst.CompanyCode
                                                         and _cmpAccess.userid   = $session.user

    inner join   I_MfgOrderConfMatlDocItem as Data       on  Mst.MfgOrderConfirmationGroup = Data.MfgOrderConfirmationGroup
                                                         and Mst.MfgOrderConfirmation      = Data.MfgOrderConfirmation
{
  key Mst.ManufacturingOrder,
  key Mst.MfgOrderConfirmationGroup,
  key Mst.MfgOrderConfirmation,
  key Data.MaterialDocument,
  key Data.MaterialDocumentYear,
  key Data.MaterialDocumentItem,

      Mst.ManufacturingOrderCategory,
      Mst.ManufacturingOrderType,
      Mst.OrderInternalID,

      Mst.MfgOrderConfirmationEntryDate,
      Mst.MfgOrderConfirmationEntryTime,

      Mst.Plant,
      Mst.CompanyCode,
      Mst.ControllingArea,
      Mst.ProfitCenter,
      Mst._WorkCenterText.WorkCenterText,
      Mst.ShiftDefinition,
      Mst.PostingDate,
      PrdnOrdr.OrderActualReleaseDate,
      PrdnOrdr.CreationDate as OrderCreationDate,
      Mst.ConfirmationUnit,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      Mst.ConfirmationYieldQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      Mst.ConfirmationScrapQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      Mst.ConfirmationReworkQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      Mst.ConfirmationTotalQuantity,

      Mst.ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      Mst.ConfYieldQtyInProductionUnit,
      Mst.OperationUnit,
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      Mst.OpPlannedTotalQuantity,

      Data.DocumentDate     as MaterialDocumentDate,

      Data.Material,
      Data.Reservation,
      Data.ReservationItem,
      Data.StorageLocation,
      Data.Batch,
      Data.DebitCreditCode,
      Data.GoodsMovementType,
      Data.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Data.QuantityInBaseUnit,
      Data.EntryUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      Data.QuantityInEntryUnit

}
where
  (
        Mst.ManufacturingOrderType = 'Z111'
    or  Mst.ManufacturingOrderType = 'Z112'
  ) //only Production and Packing Entries
  and(
        Mst.IsReversed             is initial // Exclude Reversed Entries
    and Mst.IsReversal             is initial
  )
