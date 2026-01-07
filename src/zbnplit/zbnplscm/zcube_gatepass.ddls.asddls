@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube for Gate Pass Records'

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

define view entity ZCUBE_GatePass
  with parameters
    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_from : sydate,

    @AnalyticsDetails.query.variableSequence: 2
    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_to   : sydate
  as select from ZR_GatePassData(p_date_from: $parameters.p_date_from, p_date_to: $parameters.p_date_to) as item
  association to I_FiscalCalendarDate as _TimeDim on  _TimeDim.CalendarDate      = item.OutDate
                                                  and _TimeDim.FiscalYearVariant = 'V3'
{

  key GatePass,
      GatePassDate,
      @EndUserText.label: 'Year'
      @Semantics.fiscal.year: true
      _TimeDim.FiscalYear              as GPYear,

      @EndUserText.label: 'Quarter'
      @Semantics.fiscal.quarter: true
      _TimeDim.FiscalQuarter           as GPQuarter,

      @EndUserText.label: 'YearMonth'
      @Semantics.calendar.yearMonth
      _TimeDim._CalendarDate.YearMonth as GPYearMonth,

      PrimaryGatePass,
      Plant,

      SalesmanName,
      VehicleNumber,
      DriverName,
      DriverCode,
      RouteName,
      Remarks,
      VehOutRemarks,
      Cmcrate1,
      Cmcrate2,
      Cmcrate3,
      Cmcrate4,
      OutDate,
      OutTime,
      OutMeterReading,
      IsVehicleOut,
      IsCancelled,

      DistributionChannel,
      InvoiceNo,
      InvoiceDate,
      DocumentType,
      SoldToPartyName,
      @Semantics.amount.currencyCode: 'Currency'
      @Aggregation.default: #SUM
      Amount,
      @Aggregation.default: #SUM
      Quantity,
      Currency,
      @Semantics.systemDateTime.createdAt: true
      GPCreatedOn
}
