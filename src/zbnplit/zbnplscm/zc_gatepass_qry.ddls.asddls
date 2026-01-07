@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Gate Pass Report'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
@Analytics.settings.maxProcessingEffort: #HIGH
define transient view entity ZC_GATEPASS_QRY
  provider contract analytical_query
  with parameters
    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'From Date'
    @Consumption.derivation: { lookupEntity: 'I_CalendarDate',
    resultElement: 'FirstDayofMonthDate',
    binding: [
    { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'p_date_to' } ]
    }
    p_date_from : datum,

    @AnalyticsDetails.query.variableSequence: 2
    @EndUserText.label: 'To Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    p_date_to   : datum
  as projection on ZCUBE_GatePass(p_date_from: $parameters.p_date_from, p_date_to: $parameters.p_date_to)
{

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  GPYear,

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  GPQuarter,

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  GPYearMonth,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #SHOW,
  sortDirection: #ASC,
  variableSequence: 10
  }
  @UI.textArrangement: #TEXT_FIRST
  GatePassDate,

  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 11
  }
  @UI.textArrangement: #TEXT_FIRST
  OutDate,

  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 20
  }
  @UI.textArrangement: #TEXT_FIRST
  PrimaryGatePass,

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  @UI.textArrangement: #TEXT_FIRST
  GatePass,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  Plant,
  @AnalyticsDetails.query: {
          axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 30
    }
  SalesmanName,
  @AnalyticsDetails.query: {
          axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 40
  }
  VehicleNumber,
  @AnalyticsDetails.query: {
          axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 50
  }
  DriverName,
  @AnalyticsDetails.query: {
          axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 60
  }
  RouteName,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  Remarks,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  VehOutRemarks,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  Cmcrate1,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  Cmcrate2,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  Cmcrate3,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
  }
  Cmcrate4,
  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 21
  }
  OutTime,
  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 22
  }
  OutMeterReading,
  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 23
  }
  IsVehicleOut,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 24
  }
  IsCancelled,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC
    }
  DistributionChannel,
  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 71
  }
  InvoiceNo,
  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 70
  }
  InvoiceDate,
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW,
    sortDirection: #ASC,
    variableSequence: 72
  }
  DocumentType,
  @AnalyticsDetails.query: {
     axis: #FREE,
     totals: #SHOW,
     sortDirection: #ASC
   }
  SoldToPartyName,

  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #SHOW
  }
  Quantity,

  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #SHOW
  }
  @Semantics.amount.currencyCode: 'Currency'
  Amount,
  Currency,
  @AnalyticsDetails.query: {
   axis: #ROWS,
   totals: #SHOW,
   sortDirection: #ASC
  }
  GPCreatedOn

}
