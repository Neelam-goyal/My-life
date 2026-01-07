@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fact CDS for Burger Production Order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFACT_BurgerProductionOrder
  with parameters
    @EndUserText.label: 'Company'
    pCompany    : bukrs,

    @EndUserText.label: 'Production Plant'
    pPrdnPlant  : werks_d,

    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_from : sydate,

    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_to   : sydate
  as select from ZR_BurgerProductionOrder
  //  as select from ZTBLF_BurgerProductionOrder(pCompany: $parameters.pCompany, pPrdnPlant: $parameters.pPrdnPlant, pFromDate:  $parameters.p_date_from, pToDate:$parameters.p_date_to )
{
  ManufacturingOrder,
  ManufacturingOrderItem,
  ManufacturingOrderCategory,
  ManufacturingOrderType,
  OrderCreationDate,

  ProductGroup,
  Product,
  ProductionPlant,

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
      CompanyCode                                                     = $parameters.pCompany
  and ProductionPlant                                                 = $parameters.pPrdnPlant
  and OrderCreationDate                                               >= $parameters.p_date_from
  and OrderCreationDate                                               <= $parameters.p_date_to
  and abs(SFGProducedQty) + abs(RMConsumedQty) + abs(WstgProducedQty) <> 0;
