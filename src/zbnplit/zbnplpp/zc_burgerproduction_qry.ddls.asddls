@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Burger Production Report'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_BURGERPRODUCTION_QRY
  provider contract analytical_query
  with parameters
    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompany    : bukrs,

    @AnalyticsDetails.query.variableSequence: 2
    @Consumption.semanticObject: 'ZDIM_Plant'
    @EndUserText.label: 'Production Plant'
    @Consumption.valueHelpDefinition: [{entity.name: 'ZDIM_Plant', entity.element: 'Plant',
     additionalBinding: [{usage: #FILTER_AND_RESULT, localParameter: 'pCompany', element: 'PlantCompany'}]}]
    pPrdnPlant  : werks_d,

    @AnalyticsDetails.query.variableSequence: 3
    @EndUserText.label: 'From Date'
    @Consumption.derivation: { lookupEntity: 'I_CalendarDate',
    resultElement: 'FirstDayofMonthDate',
    binding: [
    { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'p_date_to' } ]
    }
    p_date_from : datum,

    @AnalyticsDetails.query.variableSequence: 4
    @EndUserText.label: 'To Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    p_date_to   : datum
  as projection on ZCUBE_BurgerProductionOrder(pCompany: $parameters.pCompany, pPrdnPlant: $parameters.pPrdnPlant, p_date_from:$parameters.p_date_from, p_date_to:$parameters.p_date_to)
{
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  ProdYear,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  ProdQuarter,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  ProdYearMonth,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #HIDE
    }
  @UI.textArrangement: #TEXT_ONLY
  CompanyCode,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      sortDirection: #ASC,
      variableSequence: 11
  }
  ManufacturingOrder,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  ManufacturingOrderItem,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ManufacturingOrderCategory,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ManufacturingOrderType,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  OrderCreationDate,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ProductType,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ProductGroupName,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ProductSubGroupName,

  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      sortDirection: #ASC,
      variableSequence: 30
  }
  @UI.textArrangement: #TEXT_FIRST
  Product,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ProductionPlant,
  //  PlanningPlant,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  BOM,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ControllingArea,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ProfitCenter,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  CostingSheet,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  StorageLocation,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  MfgOrderActualStartDate,
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  MfgOrderItemActualDeliveryDate,
  @AnalyticsDetails.query:
  {
      variableSequence: 10,
      axis: #ROWS,
      totals: #HIDE
  }
  PostingDate,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #HIDE
    }
  GoodsMovement,

  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      sortDirection: #ASC,
      variableSequence: 12
  }
  MfgOrderConfirmation,

  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      sortDirection: #ASC
  }
  WorkCenterText,

  @AnalyticsDetails.query: {
        axis: #ROWS,
        totals: #HIDE,
        sortDirection: #ASC,
        variableSequence: 13
    }
  ShiftDefinition,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  SPBUnit,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE,
      decimals:2,
      variableSequence: 40
  }
  SFgStdSPB,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  SFGUnit,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE,
      decimals:2,
      variableSequence: 50
  }
  SFGProducedQty,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE,
      decimals:2,
      variableSequence: 51,
      hidden: true
  }
  WstgProducedQtyinSFGUnit,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  RMUnit,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE,
      decimals: 3,
      variableSequence: 60
  }
  RMConsumedQty,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE,
      decimals: 3,
      variableSequence: 70
  }
  BagsConsumedQty,

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #HIDE
    }
  WstgUnit,

  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE,
      decimals: 3,
      variableSequence: 81
  }
  WstgProducedQty,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE,
      decimals: 3,
      variableSequence: 80,
      hidden: true
  }
  SFGStdQtyKg,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE,
      decimals: 3,
      variableSequence: 80,
      hidden: true
  }
  SFGProducedQtyKg,



  @EndUserText.label: 'Std. SPB'
  @Semantics.quantity.unitOfMeasure: 'SPBUnit'
  @Aggregation.default: #FORMULA
  @AnalyticsDetails.query.variableSequence: 90
  case when BagsConsumedQty = cast(0.000 as abap.dec(13,3)) then SFgStdSPB else SFgStdSPB / BagsConsumedQty  end          as StdSPB,


  @EndUserText.label: 'Act. SPB'
  @Semantics.quantity.unitOfMeasure: 'SFGUnit'
  @AnalyticsDetails.query.variableSequence: 100
  @Aggregation.default: #FORMULA
  case when BagsConsumedQty = cast(0.000 as abap.dec(13,3)) then SFGProducedQty else SFGProducedQty / BagsConsumedQty end as ActSPB,


  //  ProductionUnit,
  //
  //  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
  //  @UI.hidden: true
  //  TotalPlannedQty,
  //
  //  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
  //  @UI.hidden: true
  //  TotalPlannedScrapQty,
  //
  //  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
  //  @UI.hidden: true
  //  TotalActualDeliveredQty,
  /* Associations */
  _CompanyCode,
  _OrderType,
  _Plant,
  _Product,
  
  _TimeDim
}
