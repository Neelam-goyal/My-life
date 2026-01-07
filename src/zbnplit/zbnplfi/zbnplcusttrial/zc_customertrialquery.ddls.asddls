@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Customized Customer Trial Query'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_CustomerTrialQuery
  provider contract analytical_query
  with parameters
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    @EndUserText.label: 'From (Posting Date)'
    @Consumption.defaultValue: '20250401'
    pFromDate    : budat,

    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    pToDate      : budat
  as projection on ZC_CustomerTrial(
                   pCompanyCode : $parameters.pCompanyCode,
                   pFromDate:$parameters.pFromDate,
                   pToDate:$parameters.pToDate
                   )
{
  @UI.hidden: true
  CompanyCode,
  PostingDate,
  FinYear,
  Quarter,
  YearMonth,

  @UI.textArrangement: #TEXT_ONLY
  AccountingDocumentType,
  @UI.textArrangement: #TEXT_ONLY
  BusinessTransactionType,
  @UI.textArrangement: #TEXT_ONLY
  @AnalyticsDetails.query.axis: #FREE
  @AnalyticsDetails.query.totals: #HIDE
  ProfitCenter,
  @UI.textArrangement: #TEXT_ONLY
  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #HIDE
  BusinessPlace,
  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #HIDE
  PartyCode,
  @AnalyticsDetails.query.axis: #ROWS
  @AnalyticsDetails.query.totals: #HIDE
  PartyName,

  @UI.hidden: true
  GLAccount,

  @AnalyticsDetails.query.axis: #COLUMNS
  @AnalyticsDetails.query.totals: #HIDE
  Tag,

  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:2,
  totals: #SHOW
  }
  Amount,

  @UI.hidden: true
  CompanyCodeCurrency,
  _GLAccount,
  _BusinessTransactionType,
  _AccountingDocumentType
}
