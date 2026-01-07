@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube for Burger Production Order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@ObjectModel: {
  supportedCapabilities: [ #ANALYTICAL_PROVIDER ],
  modelingPattern: #ANALYTICAL_CUBE
}

define view entity ZCUBE_BurgerProductionOrder
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
  as select from ZFACT_BurgerProductionOrder(pCompany: $parameters.pCompany, pPrdnPlant: $parameters.pPrdnPlant, p_date_from: $parameters.p_date_from, p_date_to: $parameters.p_date_to) as item
  association        to I_FiscalCalendarDate as _TimeDim             on  _TimeDim.CalendarDate      = $projection.PostingDate
                                                                     and _TimeDim.FiscalYearVariant = 'V3'
  association [1..1] to ZDIM_Company         as _CompanyCode         on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [1..1] to ZDIM_Plant           as _Plant               on  $projection.ProductionPlant = _Plant.Plant
  association [1..1] to ZDIM_MfgOrderType    as _OrderType           on  $projection.ManufacturingOrderType = _OrderType.ManufacturingOrderType
  association [1..1] to ZDIM_Product         as _Product             on  $projection.Product = _Product.Product
  association [1..1] to ZDIM_ProductType     as _ProductType         on  $projection.producttype = _ProductType.ProductType

  //  association [1..1] to ZDIM_ProductGroup    as _ProductGroup        on  $projection.ProductGroup = _ProductGroup.ProductGroup
  association [1..1] to ZDIM_StorageLocation as _StorageLocationText on  $projection.ProductionPlant = _StorageLocationText.Plant
                                                                     and $projection.StorageLocation = _StorageLocationText.StorageLocation

{


  @EndUserText.label: 'Year'
  @Semantics.fiscal.year: true
  _TimeDim.FiscalYear                                                                                              as ProdYear,

  @EndUserText.label: 'Quarter'
  @Semantics.fiscal.quarter: true
  _TimeDim.FiscalQuarter                                                                                           as ProdQuarter,

  @EndUserText.label: 'YearMonth'
  @Semantics.calendar.yearMonth
  _TimeDim._CalendarDate.YearMonth                                                                                 as ProdYearMonth,

  // Organization
  @ObjectModel.foreignKey.association: '_CompanyCode'
  @EndUserText.label: 'Company'
  item.CompanyCode,

  @EndUserText.label: 'Order No.'
  item.ManufacturingOrder,

  @EndUserText.label: 'Order Line Item'
  item.ManufacturingOrderItem,

  @EndUserText.label: 'Order Category'
  case
  item.ManufacturingOrderCategory
  when '40' then 'Process Order'
  when '10' then 'Production Order'
  else 'NA'
  end                                                                                                              as ManufacturingOrderCategory,

  @ObjectModel.foreignKey.association: '_OrderType'
  @EndUserText.label: 'Order Type'
  item.ManufacturingOrderType,

  @EndUserText.label: 'Order Enty Date'
  item.OrderCreationDate,

  item.ProductGroup,

  @EndUserText.label: 'Product Group'
  _Product.ProductGroupName,

  @EndUserText.label: 'Product Sub Group'
  _Product.ProductSubGroupName,

  @ObjectModel.foreignKey.association: '_ProductType'
  @EndUserText.label: 'Product Type'
  _Product.ProductType,

  @Consumption.valueHelpDefinition: [
  { entity:  { name:    'I_ProductStdVH',
               element: 'Product' }
  }]
  @ObjectModel.foreignKey.association: '_Product'
  @EndUserText.label: 'SFG Item'
  @Consumption.semanticObject: 'Material'
  item.Product,

  @ObjectModel.foreignKey.association: '_Plant'
  @EndUserText.label: 'Production Plant'
  item.ProductionPlant,
  //  PlanningPlant,

  @EndUserText.label: 'BOM'
  item.BOM,

  @EndUserText.label: 'Controlling Area'
  item.ControllingArea,

  @EndUserText.label: 'Profit Center'
  item.ProfitCenter,

  @EndUserText.label: 'Costing Sheet'
  item.CostingSheet,

  @EndUserText.label: 'Storage Location'
  @ObjectModel.text.element: [ 'StorageLocationName' ]
  item.StorageLocation,
  @Semantics.text: true
  _StorageLocationText.StorageLocationName,

  @EndUserText.label: 'Production Start Date'
  item.MfgOrderActualStartDate,

  @EndUserText.label: 'Production End Date'
  item.MfgOrderItemActualDeliveryDate,

  @EndUserText.label: 'Production Date'
  item.PostingDate,

  @EndUserText.label: 'Movement No.'
  item.GoodsMovement,

  @EndUserText.label: 'Confirmation No.'
  MfgOrderConfirmation,

  @EndUserText.label: 'Line'
  WorkCenterText,

  @EndUserText.label: 'Shift'
  ShiftDefinition,

  @EndUserText.label: 'SPBUnit'
  SPBUnit,

  @EndUserText.label: 'SFG Std. Qty'
  @Semantics.quantity.unitOfMeasure: 'SPBUnit'
  @Aggregation.default: #SUM
  SFGStdSPB * item.BagsConsumedQty                                                                                 as SFgStdSPB,

  @EndUserText.label: 'SFG. UOM'
  item.SFGUnit,

  @Semantics.quantity.unitOfMeasure: 'SFGUnit'
  @EndUserText.label: 'SFG Produced Qty'
  @Aggregation.default: #SUM
  item.SFGProducedQty,

  @Semantics.quantity.unitOfMeasure: 'WstgUnit'
  @EndUserText.label: 'SFG Std. Kg.'
  @Aggregation.default: #SUM
  cast(cast((item.SFGStdSPB * item.BagsConsumedQty) as abap.quan(19,6)) * _Product.GrossWeight as abap.quan(31,6)) as SFGStdQtyKg,

  @Semantics.quantity.unitOfMeasure: 'SFGUnit'
  @EndUserText.label: 'Wstg. Produced Qty'
  @Aggregation.default: #SUM
  case when _Product.GrossWeight = 0 then  item.WstgProducedQty
  else (item.WstgProducedQty / _Product.GrossWeight) end                                                           as WstgProducedQtyinSFGUnit,

  @EndUserText.label: 'RM UOM'
  item.RMUnit,

  @Semantics.quantity.unitOfMeasure: 'RMUnit'
  @EndUserText.label: 'RM Consumed Qty'
  @Aggregation.default: #SUM
  item.RMConsumedQty,

  @Aggregation.default: #SUM
  @EndUserText.label: 'Bags Consumed'
  item.BagsConsumedQty,

  @EndUserText.label: 'Wstg. UOM'
  item.WstgUnit,

  @Semantics.quantity.unitOfMeasure: 'WstgUnit'
  @EndUserText.label: 'SFG Produced Kg.'
  @Aggregation.default: #SUM
  (item.SFGProducedQty * _Product.GrossWeight)                                                                     as SFGProducedQtyKg,


  @Semantics.quantity.unitOfMeasure: 'WstgUnit'
  @EndUserText.label: 'Wstg. Produced Kg.'
  @Aggregation.default: #SUM
  item.WstgProducedQty,

  //  @EndUserText.label: 'Production Unit'
  //  ProductionUnit,
  //  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
  //  @EndUserText.label: 'Total Planned Qty'
  //  @DefaultAggregation: #NONE
  //  TotalPlannedQty,
  //
  //  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
  //  @EndUserText.label: 'Total Planned Scrap Qty'
  //  TotalPlannedScrapQty,
  //
  //  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
  //  @EndUserText.label: 'Total Delivered Qty'
  //  TotalActualDeliveredQty,

  _CompanyCode,
  _TimeDim,
  _Plant,
  _Product,
  _ProductType,

  _OrderType
}
