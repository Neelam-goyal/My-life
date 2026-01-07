@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Employees Selected GL Query'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]

define transient view entity ZC_EMPSelGLQuery
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
  as projection on ZC_EMPSelGLLineItems(
                   pCompanyCode : $parameters.pCompanyCode,
                   pFromDate:$parameters.pFromDate,
                   pToDate:$parameters.pToDate
                   )
{
  @AnalyticsDetails.query.variableSequence : 1
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE
    }
  @UI.textArrangement: #TEXT_FIRST
  GLAccount,
  @AnalyticsDetails.query.variableSequence : 2
  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #HIDE
    }
  @UI.textArrangement: #TEXT_LAST
  EmpCode,
  CompanyCodeCurrency,
  @AnalyticsDetails.query.variableSequence : 3
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE
    }
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  OpeningAmt,
  @AnalyticsDetails.query.variableSequence : 4
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE
    }
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  CreditAmt,
  @AnalyticsDetails.query.variableSequence : 5
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE
    }
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  DebitAmt,
  @AnalyticsDetails.query.variableSequence : 6
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE
    }
  @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
  ClosingAmt,
  /* Associations */
  _Employee,
  _GLAccount
}
