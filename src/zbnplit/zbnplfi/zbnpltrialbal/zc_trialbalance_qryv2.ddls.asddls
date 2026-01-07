@EndUserText.label: 'ZC_TrialBalance_QRY for Varun Makkar'
@AccessControl.authorizationCheck: #NOT_ALLOWED
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_TrialBalance_QRYV2
  provider contract analytical_query
  with parameters

    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'Upto Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    P_ToDate : datum

  as projection on ZC_GLAcctBalanceV2( P_ToDate: $parameters.P_ToDate ) as GLAcctBalance
{

  @Consumption.filter: {selectionType: #RANGE, multipleSelections: true, mandatory: true}
  @UI.lineItem: [{ position: 2 }]
  @AnalyticsDetails.query.variableSequence : 1
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE
    }
  @UI.textArrangement: #TEXT_ONLY
  CompanyCode,

  // Time Related Columns
  @Consumption.filter: {selectionType: #SINGLE, multipleSelections: false, mandatory: true}
  @AnalyticsDetails.query.variableSequence : 3
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #HIDE
    }
  FiscalYear,
  @AnalyticsDetails.query.variableSequence : 12
  @AnalyticsDetails.query: {
      axis: #FREE,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  FisQuarter,
  
  @AnalyticsDetails.query.variableSequence : 14
  @AnalyticsDetails.query: {
      axis: #COLUMNS,
      totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  FiscalYearPeriod,
  
  @AnalyticsDetails.query.variableSequence : 15
  PostingDate,
  @AnalyticsDetails.query.variableSequence : 16
  DocumentDate,

  //Organisational Structure


  @AnalyticsDetails.query.variableSequence : 22
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW
    }
  @UI.textArrangement: #TEXT_ONLY
  FinancialAccountType,

  @AnalyticsDetails.query.variableSequence : 23
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  GLAccountGroup,

  @AnalyticsDetails.query.variableSequence : 24
  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  @AnalyticsDetails.query.displayHierarchy: #ON
  @AnalyticsDetails.query.hierarchyBinding: [{
    type: #CONSTANT,
    value: 'BONN'
  }]
  @AnalyticsDetails.query.hierarchyInitialLevel:4
  GLAccount,
  
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  Supplier,
  
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  Customer,
  
  @AnalyticsDetails.query.variableSequence : 25
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  SubCode,
  @AnalyticsDetails.query.variableSequence : 26
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N0,
  @AnalyticsDetails.query.variableSequence : 27
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N1,
  @AnalyticsDetails.query.variableSequence : 28
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N2,
  @AnalyticsDetails.query.variableSequence : 29
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N3,
  @AnalyticsDetails.query.variableSequence : 30
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  N4,
  // Document Related


  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  SourceLedger,

  @AnalyticsDetails.query.variableSequence : 31
  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW
    }
  @UI.textArrangement: #TEXT_ONLY
  ProfitCenter,


  @AnalyticsDetails.query.variableSequence : 32
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  BusinessTransactionType,

  @AnalyticsDetails.query.variableSequence : 33
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  DocumentType,

  @AnalyticsDetails.query.variableSequence : 34
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_ONLY
  SpecialGLCode,

  AccountingDocument,
//  LedgerGLLineItem,
//  AccountingDocumentCategory,

  //Measures

  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    decimals:2,
    variableSequence: 50
  }
  AmountInCompanyCodeCurrency,

  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    decimals:2,
    variableSequence: 51
  }
  RTotalAmtInCompanyCodeCurrency,

  @UI.hidden: true
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    decimals:2,
    variableSequence: 52
  }
  DebitAmountInCoCodeCrcy,

  @UI.hidden: true
  @AnalyticsDetails.query: {
    axis: #COLUMNS,
    totals: #HIDE,
    decimals:2,
    variableSequence: 53
  }
  CreditAmountInCoCodeCrcy,



  _CompanyCode,
  _BusinessPartner,
  _GLAccountGroup,
  _BusinessTransactionType,
  _GLAccount,
  _GLAccountInChartOfAccounts
}
