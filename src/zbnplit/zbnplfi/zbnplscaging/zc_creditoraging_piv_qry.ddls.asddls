@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Creditor Aging Analytical Query'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_CreditorAging_PIV_QRY
  provider contract analytical_query
  with parameters

    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompany  : bukrs,

    @EndUserText.label: 'As On Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    pAsOnDate : budat,

    @EndUserText.label: 'Date Range Bins'
    @Consumption.defaultValue: '15,30,45,60,90'
    pDaysStr  : z_daysrange

  as projection on ZCUBE_CreditorAging(pCompany:$parameters.pCompany,
                   pAsOnDate:$parameters.pAsOnDate,
                   pDaysStr:$parameters.pDaysStr)
{
  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true}
  @UI.textArrangement: #TEXT_FIRST
  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #SHOW
  Supplier,

  @AnalyticsDetails.query.axis: #FREE
  @AnalyticsDetails.query.totals: #HIDE
  City,

  @AnalyticsDetails.query.axis: #FREE
  @AnalyticsDetails.query.totals: #HIDE
  Region,

  @AnalyticsDetails.query.axis: #FREE
  @AnalyticsDetails.query.totals: #HIDE
  Country,

  @AnalyticsDetails.query.axis: #FREE
  @AnalyticsDetails.query.totals: #HIDE
  BusinessPartnerTypeDesc,

  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #SHOW
  ClosingBal,

  PostingDate,

  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #HIDE
  AccountingDocument,

  @AnalyticsDetails.query.axis: #FREE
  @AnalyticsDetails.query.totals: #HIDE
  DocType,

  @AnalyticsDetails.query.axis: #FREE
  @AnalyticsDetails.query.totals: #HIDE
  DocumentReferenceID,

  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #HIDE
  NetDueDate,

  @UI.hidden: true
  DocAmt,

  @AnalyticsDetails.query: {
  axis: #FREE,
  decimals:2,
  totals: #SHOW
  }
  @UI.hidden: true
  VutRefRcptAmt,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:2,
  totals: #SHOW
  }
  DueAmt,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:2,
  totals: #SHOW
  }
  NoDueAmt,

  @AnalyticsDetails.query.axis: #FREE
  DueDays,

  @AnalyticsDetails.query.axis: #COLUMNS
  Range,

  CompanyCode,
  FiscalYear

}
