@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube for Production Variance'
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
define view entity ZCUBE_MaterialVariance
  with parameters
    @EndUserText.label: 'Company'
    pCompany   : bukrs,
    @EndUserText.label: 'Production Plant'
    pPrdnPlant : werks_d,
    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    pFromDate  : datum,
    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    pToDate    : datum
  as select from ZR_MaterialVarianceRep
                 (
                     pCompany : $parameters.pCompany,
                     pFromDate:$parameters.pFromDate,
                     pToDate:$parameters.pToDate,
                     pPrdnPlant:$parameters.pPrdnPlant
                 ) as item
  association        to I_FiscalCalendarDate as _TimeDim           on _TimeDim.CalendarDate = $projection.MfgOrderDate
                                                                        and _TimeDim.FiscalYearVariant = 'V3'
  association [1..1] to ZDIM_Company         as _CompanyCode       on $projection.CompanyCode = _CompanyCode.CompanyCode
  association [1..1] to ZDIM_Plant           as _Plant             on $projection.ProductionPlant = _Plant.Plant
  association [1..1] to ZDIM_MfgOrderType    as _OrderType         on $projection.ManufacturingOrderType = _OrderType.ManufacturingOrderType
  association [1..1] to ZDIM_Product         as _MfgProduct        on $projection.MfgProduct = _MfgProduct.Product
  association [1..1] to ZDIM_Product         as _Product           on $projection.Material = _Product.Product
  association [1..1] to ZDIM_ProductType     as _ProductType       on $projection.producttype = _ProductType.ProductType
  association [1..1] to I_MfgOrderCategory   as _MfgOrderCategory  on $projection.ManufacturingOrderCategory = _MfgOrderCategory.ManufacturingOrderCategory
  //  association [1..1] to ZDIM_ProductGroup    as _ProductGroup      on $projection.productgroup = _ProductGroup.ProductGroup
  association [1..1] to I_GoodsMovementType  as _GoodsMovementType on $projection.GoodsMovementType = _GoodsMovementType.GoodsMovementType

{
      
  key RId,

      @EndUserText.label: 'Year'
      @Semantics.fiscal.year: true
      _TimeDim.FiscalYear              as OrdYear,

      @EndUserText.label: 'Quarter'
      @Semantics.fiscal.quarter: true
      _TimeDim.FiscalQuarter           as OrdQuarter,

      @EndUserText.label: 'YearMonth'
      @Semantics.calendar.yearMonth
      _TimeDim._CalendarDate.YearMonth as OrdYearMonth,

      @EndUserText.label: 'Order No.'
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_MfgOrderStdVH', element: 'ManufacturingOrder' } } ]
      ManufacturingOrder,

      @ObjectModel.foreignKey.association: '_CompanyCode'
      @EndUserText.label: 'Company'
      CompanyCode,

      @ObjectModel.foreignKey.association: '_Plant'
      @EndUserText.label: 'Production Plant'
      ProductionPlant,

      @EndUserText.label: 'Order Date'
      MfgOrderDate,

      @EndUserText.label: 'Order Category'
      @ObjectModel.foreignKey.association: '_MfgOrderCategory'
      ManufacturingOrderCategory,

      @ObjectModel.foreignKey.association: '_OrderType'
      @EndUserText.label: 'Order Type'
      ManufacturingOrderType,

      @EndUserText.label: 'Produced Product'
      @ObjectModel.text.element: [ 'MfgProductName' ]
      @ObjectModel.foreignKey.association: '_MfgProduct'
      MfgProduct,

      @Semantics.text: true
      MfgProductName,

      @EndUserText.label: 'BOM'
      BOM,

      @EndUserText.label: 'BusinessArea'
      BusinessArea,

      @EndUserText.label: 'Controlling Area'
      ControllingArea,

      @EndUserText.label: 'Profit Center'
      ProfitCenter,

      @EndUserText.label: 'Costing Sheet'
      CostingSheet,

      @EndUserText.label: 'Production UOM'
      ProductionUnit,

      @EndUserText.label: 'MfgOrderPlannedTotalQty'
      @Aggregation.default: #NONE
      MfgOrderPlannedTotalQty,

      @EndUserText.label: 'MfgOrderConfirmedYieldQty'
      @Aggregation.default: #NONE
      MfgOrderConfirmedYieldQty,

      @EndUserText.label: 'ActualDeliveredQuantity'
      @Aggregation.default: #NONE
      ActualDeliveredQuantity,

      @EndUserText.label: 'Confirmation No.'
      MfgOrderConfirmationGroup,

      @EndUserText.label: 'Confirmation No.'
      MfgOrderConfirmation,

      @EndUserText.label: 'Line Id'
      @ObjectModel.text.element: ['WorkCenterText']
      WorkCenterInternalID,

      @EndUserText.label: 'Line'
      @Semantics.text: true
      WorkCenterText,

      @EndUserText.label: 'Material Issue No.'
      MaterialDocument,
      @EndUserText.label: 'Material Issue Year'
      MaterialDocumentYear,
      @EndUserText.label: 'Material Issue Date'
      MaterialDocumentDate,

      @EndUserText.label: 'Confirmation Date'
      PostingDate,

      @EndUserText.label: 'ConfYieldQty'
      @Aggregation.default: #NONE
      ConfirmationYieldQuantity,

      @EndUserText.label: 'ConfScrapQty'
      @Aggregation.default: #NONE
      ConfirmationScrapQuantity,

      @EndUserText.label: 'ConfReworkQty'
      @Aggregation.default: #NONE
      ConfirmationReworkQuantity,

      @EndUserText.label: 'ConfTotalQty'
      @Aggregation.default: #NONE
      ConfirmationTotalQuantity,

      //  @EndUserText.label: 'ConfTotalQty'
      //  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      //  @Aggregation.default: #NONE
      //  ConfYieldQtyInProductionUnit,

      @ObjectModel.foreignKey.association: '_ProductType'
      @EndUserText.label: 'Product Type'
      _Product.ProductType,

      @EndUserText.label: 'Product Group'
      _Product.ProductGroupName,

      @EndUserText.label: 'Product Sub Group'
      _Product.ProductSubGroupName,

      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_ProductStdVH',
                 element: 'Product' }
      }]
      @ObjectModel.foreignKey.association: '_Product'
      @EndUserText.label: 'Component'
      @Consumption.semanticObject: 'Material'
      Material,

      @EndUserText.label: 'GoodsMovementType'
      @ObjectModel.foreignKey.association: '_GoodsMovementType'
      GoodsMovementType,

      @EndUserText.label: '_UnitOfMeasurement'
      UnitOfMeasurement,

      @EndUserText.label: 'RequiredQty'
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasurement'
      @Aggregation.default: #SUM
      RequiredQty,

      @EndUserText.label: 'ActualQty'
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasurement'
      @Aggregation.default: #SUM
      ActualQty,

      @EndUserText.label: 'DiffQty'
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasurement'
      @Aggregation.default: #SUM
      DiffQty,

      @EndUserText.label: '_Currency'
      Currency,

      @EndUserText.label: 'RequiredAmt'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      RequiredAmt,

      @EndUserText.label: 'ActualAmt'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      ActualAmt,

      @EndUserText.label: 'DiffAmt'
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      DiffAmt,

      _OrderType,
      _MfgOrderCategory,
      _CompanyCode,
      _Product,
      _MfgProduct,
      _ProductType,

      _GoodsMovementType,
      _Plant
}
