@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BREAD BURGER PRODUCTION ORDER V2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZP_BREADBRG_PRODORDRV2
  as select from ZR_BurgerProductionOrderV2
{
  key ManufacturingOrder,
      ManufacturingOrderItem,
      ManufacturingOrderCategory,
      ManufacturingOrderType,
      OrderCreationDate,
      ProductGroupName,
      ProductGroup,
      Product,
      ProductName,
      Batch,
      MfgOrderInternalID,
      ProductionPlant,
      PlanningPlant,
      Reservation,
      BOM,
      CompanyCode,
      ControllingArea,
      ProfitCenter,
      CostingSheet,
      StorageLocation,
      MfgOrderActualStartDate,
      MfgOrderItemActualDeliveryDate,
      PostingDate,
      GoodsMovement,
      GoodsMovementYear,
      MfgOrderConfirmationGroup,
      MfgOrderConfirmation,
      WorkCenterText,
      ShiftDescription             as ShiftDefinition,

      BOMHeaderBaseUnit            as SPBUnit,
      @Semantics.quantity.unitOfMeasure: 'SPBUnit'
      BOMHeaderQuantityInBaseUnit  as SFGStdSPB,

      EntryUnit                    as SFGUnit,
      @Semantics.quantity.unitOfMeasure: 'SFGUnit'
      SFGProducedQty,
      EntryUnit                    as RMUnit,
      @Semantics.quantity.unitOfMeasure: 'RMUnit'
      RMConsumedQty,
      cast(
        cast (
          case
              when RMConsumedQty is null
                  then 0.000
                  else RMConsumedQty
              end
              as abap.dec(13,3)) / cast(90.000 as abap.dec (13,3))

               as abap.dec (13,3)) as BagsConsumedQty,

      EntryUnit                    as WstgUnit,
      @Semantics.quantity.unitOfMeasure: 'WstgUnit'
      WstgProducedQty
}
where
  (cast(SFGProducedQty as abap.dec(13,3))
  + cast(RMConsumedQty as abap.dec(13,3))
  + cast(WstgProducedQty as abap.dec(13,3))) <> 0
