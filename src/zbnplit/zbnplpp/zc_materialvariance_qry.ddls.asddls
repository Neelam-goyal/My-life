@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Material Variance Analytical Query'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_MaterialVariance_QRY
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
  as projection on ZCUBE_MaterialVariance(pCompany: $parameters.pCompany, pPrdnPlant: $parameters.pPrdnPlant, pFromDate:$parameters.p_date_from, pToDate:$parameters.p_date_to)
{

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  OrdYear,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  OrdQuarter,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  OrdYearMonth,

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
      variableSequence: 10
  }
  ManufacturingOrder,

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
  @UI.textArrangement: #TEXT_ONLY
  WorkCenterText,

  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  MfgOrderDate,

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  ProductionPlant,

  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #HIDE,
    sortDirection: #ASC,
    variableSequence: 20
  }
  @UI.textArrangement: #TEXT_FIRST
  MfgProduct,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 30
  }
  BOM,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 40
  }
  ProductionUnit,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 50
  }
  MfgOrderPlannedTotalQty,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 60
  }
  MfgOrderConfirmedYieldQty,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 70
  }
  ActualDeliveredQuantity,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 80
  }
  MaterialDocument,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 90
  }
  MaterialDocumentDate,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 100
  }
  ConfirmationYieldQuantity,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 110
  }
  @UI.textArrangement: #TEXT_FIRST
  ProductGroupName,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 111
  }
  @UI.textArrangement: #TEXT_FIRST
  ProductSubGroupName,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE,
  sortDirection: #ASC,
  variableSequence: 120
  }
  @UI.textArrangement: #TEXT_FIRST
  Material,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  totals: #HIDE,
  sortDirection: #ASC,
  decimals: 3,
  variableSequence: 130
  }
  RequiredQty,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  totals: #HIDE,
  sortDirection: #ASC,
  decimals: 3,
  variableSequence: 140
  }
  ActualQty,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  totals: #HIDE,
  sortDirection: #ASC,
  decimals: 3,
  variableSequence: 150
  }
  DiffQty,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  totals: #HIDE,
  sortDirection: #ASC,
  decimals: 2,
  variableSequence: 160
  }
  @UI.hidden: true
  RequiredAmt,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  totals: #HIDE,
  sortDirection: #ASC,
  decimals: 2,
  variableSequence: 170
  }
  @UI.hidden: true
  ActualAmt,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  totals: #HIDE,
  sortDirection: #ASC,
  decimals: 2,
  variableSequence: 180
  }
  @UI.hidden: true
  DiffAmt,

  UnitOfMeasurement,
  Currency


}
