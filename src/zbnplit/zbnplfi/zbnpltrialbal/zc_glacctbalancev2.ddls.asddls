@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_GLAcctBalance for Varun Makkar'
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
define view entity ZC_GLAcctBalanceV2

  with parameters
    @AnalyticsDetails.query.variableSequence: 3
    @EndUserText.label: 'Upto Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    P_ToDate : datum
  as select from ZR_GLAccountLineItem
                  (P_ToDate: $parameters.P_ToDate ) as GLAcctBalance

    inner join   ZRT_FiscalCalendarDate             as RTCal on  RTCal.FiscalYear       = GLAcctBalance.FiscalYear
                                                             and RTCal.FiscalYearPeriod = GLAcctBalance.FiscalYearPeriod
  association [1]    to I_CompanyCode                as _CompanyCode                on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to I_GLAccountInChartOfAccounts as _GLAccountInChartOfAccounts on  _GLAccountInChartOfAccounts.ChartOfAccounts = 'YCOA'
                                                                                    and $projection.GLAccount                       = _GLAccountInChartOfAccounts.GLAccount
  association [0..1] to I_GLAccount                  as _GLAccount                  on  $projection.CompanyCode = _GLAccount.CompanyCode
                                                                                    and $projection.GLAccount   = _GLAccount.GLAccount
  association [0..1] to I_GLAccountGroup             as _GLAccountGroup             on  $projection.glaccountgroup      = _GLAccountGroup.GLAccountGroup
                                                                                    and _GLAccountGroup.ChartOfAccounts = 'YCOA'
  association [0..1] to I_BusinessTransactionType    as _BusinessTransactionType    on  $projection.BusinessTransactionType = _BusinessTransactionType.BusinessTransactionType
  association [0..1] to I_AccountingDocumentType     as _AccountingDocumentType     on  $projection.DocumentType = _AccountingDocumentType.AccountingDocumentType
  association [0..1] to I_FiscalYearForVariant       as _LedgerFiscalYearForVariant on  $projection.LedgerFiscalYear  = _LedgerFiscalYearForVariant.FiscalYear
                                                                                    and $projection.FiscalYearVariant = _LedgerFiscalYearForVariant.FiscalYearVariant
  association [0..*] to I_ProfitCenter               as _ProfitCenter               on  _ProfitCenter.ControllingArea = 'A000'
                                                                                    and $projection.ProfitCenter      = _ProfitCenter.ProfitCenter
  association [0..1] to ZDIM_BusinessPartner         as _BusinessPartner            on  $projection.SubCode = _BusinessPartner.BusinessPartner
  association        to I_FiscalCalendarDate         as _TimeDim                    on  _TimeDim.CalendarDate      = GLAcctBalance.PostingDate
                                                                                    and _TimeDim.FiscalYearVariant = GLAcctBalance.FiscalYearVariant
{
  key GLAcctBalance.SourceLedger,

      @ObjectModel.foreignKey.association: '_CompanyCode'
  key GLAcctBalance.CompanyCode,
  key GLAcctBalance.FiscalYear,
  key GLAcctBalance.AccountingDocument,
  key GLAcctBalance.LedgerGLLineItem,
  key GLAcctBalance.Ledger,

      //      @EndUserText.label: 'Fiscal Year Month'
      //      case when right(GLAcctBalance.FiscalYearPeriod,2) = '00' then
      //      concat(left(_TimeDim._CalendarDate.YearMonth,4), '00') else
      //      _TimeDim._CalendarDate.YearMonth                 end               as FisYearMonth,

      @EndUserText.label: 'Fiscal Year Qtr'
      @Semantics.fiscal.quarter: true
      _TimeDim.FiscalQuarter                                                                   as FisQuarter,

      GLAcctBalance.FiscalYearVariant,

      @Semantics.fiscal.year: true
      @ObjectModel.foreignKey.association: '_LedgerFiscalYearForVariant'
      GLAcctBalance.LedgerFiscalYear,
      GLAcctBalance.FiscalPeriod,
      RTCal.AsOnFiscalYearPeriod                                                               as FiscalYearPeriod,

      GLAcctBalance.PostingDate,
      GLAcctBalance.DocumentDate,
      @ObjectModel.foreignKey.association: '_AccountingDocumentType'
      GLAcctBalance.DocumentType,

      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_GLAccountGroupStdVH',
                   element: 'GLAccountGroup' },
        additionalBinding: [{ localElement: 'ChartOfAccounts',
                              element: 'ChartOfAccounts' }]
      }]
      @ObjectModel.foreignKey.association: '_GLAccountGroup'
      _GLAccount.GLAccountGroup,

      GLAcctBalance.ChartOfAccounts,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_GLAccountStdVH',
               element: 'GLAccount' }
      }]
      @ObjectModel.foreignKey.association: '_GLAccountInChartOfAccounts'
      GLAcctBalance.GLAccount,

      @EndUserText.label: 'L0'
      GLAcctBalance.N0,
      @EndUserText.label: 'L1'
      GLAcctBalance.N1,
      @EndUserText.label: 'L2'
      GLAcctBalance.N2,
      @EndUserText.label: 'L3'
      GLAcctBalance.N3,
      @EndUserText.label: 'L4'
      GLAcctBalance.N4,

      //      GLAcctBalance.GLRecordType,
      //      GLAcctBalance.AccountingDocumentCategory,

      GLAcctBalance.ControllingArea,

      GLAcctBalance.IsBalanceSheetAccount,
      GLAcctBalance.CostCenter,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_ProfitCenterStdVH',
               element: 'ProfitCenter' }
      }]
      @ObjectModel.foreignKey.association: '_ProfitCenter'
      GLAcctBalance.ProfitCenter,
      GLAcctBalance.FunctionalArea,
      GLAcctBalance.BusinessArea,
      GLAcctBalance.FinancialTransactionType,
      GLAcctBalance.BusinessTransactionCategory,

      @ObjectModel.foreignKey.association: '_BusinessTransactionType'
      GLAcctBalance.BusinessTransactionType,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_Customer_VH',
               element: 'Customer' }
      }]
      @ObjectModel.foreignKey.association: '_Customer'
      GLAcctBalance.Customer,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_Supplier_VH',
               element: 'Supplier' }
      }]
      @ObjectModel.foreignKey.association: '_Supplier'
      GLAcctBalance.Supplier,
      @ObjectModel.foreignKey.association: '_BusinessPartner'
      @Consumption.valueHelpDefinition: [
       { entity:  { name:    'ZDIM_BusinessPartner',
                    element: 'BusinessPartner' }
       }]
      @EndUserText.label: 'Sub-Code'
      GLAcctBalance. SubCode,

      GLAcctBalance.FinancialAccountType,
      GLAcctBalance.SpecialGLCode,

      @Aggregation.default: #SUM
      @EndUserText.label: 'Debit Amount'
      cast(GLAcctBalance.DebitAmountInCoCodeCrcy as abap.dec( 23,2)) * RTCal.MULTIPLIERTAG     as DebitAmountInCoCodeCrcy,

      @Aggregation.default: #SUM
      @EndUserText.label: 'Credit Amount'
      cast(GLAcctBalance.CreditAmountInCoCodeCrcy as abap.dec( 23,2)) * RTCal.MULTIPLIERTAG    as CreditAmountInCoCodeCrcy,

      @Aggregation.default: #SUM
      @EndUserText.label: 'Amount'
      cast(GLAcctBalance.AmountInCompanyCodeCurrency as abap.dec( 23,2)) * RTCal.MULTIPLIERTAG as AmountInCompanyCodeCurrency,

      @Aggregation.default: #SUM
      @EndUserText.label: 'RTAmount'
      cast(GLAcctBalance.AmountInCompanyCodeCurrency as abap.dec( 23,2))                       as RTotalAmtInCompanyCodeCurrency,

      _CompanyCode,
      GLAcctBalance._FiscalYear,
      _BusinessPartner,
      _GLAccountGroup,
      _BusinessTransactionType,
      _GLAccount,
      GLAcctBalance._Supplier,
      GLAcctBalance._Customer,
      _ProfitCenter,
      _GLAccountInChartOfAccounts,
      _LedgerFiscalYearForVariant,
      _AccountingDocumentType
}
