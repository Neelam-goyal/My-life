@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Voucher Analysis Report'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_GLLineItemAnalysis
  provider contract analytical_query
  with parameters

    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'Upto Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    P_ToDate : datum

  as projection on ZC_GLAcctBalance( P_ToDate: $parameters.P_ToDate ) as GLAcctBalance
{
  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true, mandatory: true}
  @UI.lineItem: [{ position: 2 }]
  @AnalyticsDetails.query.variableSequence : 1
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #SHOW
    }
  @UI.textArrangement: #TEXT_ONLY
  CompanyCode,
  @AnalyticsDetails.query.variableSequence : 2
  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_LAST
  DocumentType,
  
  // Time Related Columns
  @Consumption.filter: {selectionType: #SINGLE, multipleSelections: false, mandatory: true}
  @AnalyticsDetails.query.variableSequence : 3
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #HIDE
    }
  FiscalYear,
  
  @AnalyticsDetails.query.variableSequence : 4
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  FisQuarter,

  @AnalyticsDetails.query.variableSequence : 5
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  FiscalYearPeriod,

  @AnalyticsDetails.query.variableSequence : 6
  PostingDate,
  @AnalyticsDetails.query.variableSequence : 7
  DocumentDate,
 
  @AnalyticsDetails.query.variableSequence : 11
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N0,
  @AnalyticsDetails.query.variableSequence : 12
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N1,
  @AnalyticsDetails.query.variableSequence : 13
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N2,
  @AnalyticsDetails.query.variableSequence : 14
  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  N3,
  @AnalyticsDetails.query.variableSequence : 15
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N4,
  @AnalyticsDetails.query.variableSequence : 8
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  GLAccountGroup,

  @AnalyticsDetails.query.variableSequence : 9
  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  GLAccount,

  @AnalyticsDetails.query.variableSequence : 10
  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  SubCode,
  
  // Document Related


  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  SourceLedger,

  @AnalyticsDetails.query.variableSequence : 16
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW
    }
  @UI.textArrangement: #TEXT_ONLY
  ProfitCenter,

  @AnalyticsDetails.query.variableSequence : 17
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  SpecialGLCode,

  AccountingDocument,

  //Measures

  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    decimals:2,
    variableSequence: 50
  }
  AmountInCompanyCodeCurrency,

  @UI.hidden: true
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    decimals:2,
    variableSequence: 51
  }
  DebitAmountInCoCodeCrcy,

  @UI.hidden: true
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    decimals:2,
    variableSequence: 52
  }
  CreditAmountInCoCodeCrcy,



  _CompanyCode,
  _BusinessPartner,
  _GLAccountGroup,
  _GLAccount,
  _GLAccountInChartOfAccounts
}
