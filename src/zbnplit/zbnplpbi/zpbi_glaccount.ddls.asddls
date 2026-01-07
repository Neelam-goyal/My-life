@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Accounts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPBI_GLAccount
  as select from I_GLAccount as gl
  association [0..1] to I_Reconciliationaccttype as _Reconciliationaccttype on $projection.ReconciliationAccountType = _Reconciliationaccttype.ReconciliationAccountType

{
  key GLAccount,
  key CompanyCode,
      CompanyCodeName,

      _Text[1: Language=$session.system_language].GLAccountName,
      _Text[1: Language=$session.system_language].GLAccountLongName,

      ChartOfAccounts,
      _ChartOfAccountsText[1: Language=$session.system_language].ChartOfAccountsName,

      _GLAccountInChartOfAccounts.GLAccountGroup,
      _GLAccountInChartOfAccounts._GLAccountGroupText[1: Language=$session.system_language].AccountGroupName,

      _GLAccountInChartOfAccounts.GLAccountType,
      _GLAccountInChartOfAccounts._GLAccountType._GLAccountTypeText[1: Language=$session.system_language].GLAccountTypeName,

      _GLAccountInChartOfAccounts.GLAccountSubtype,
      case _GLAccountInChartOfAccounts.GLAccountSubtype
      when 'B' then 'Bank Reconciliation Account'
      when 'P' then 'Petty Cash'
      when 'S' then 'Bank Subaccount'
      end as GLAccountSubtypeName,

      FunctionalArea,
      _FunctionalArea._Text[1: Language=$session.system_language].FunctionalAreaName,

      IsBalanceSheetAccount,
      IsProfitLossAccount,
      ProfitLossAccountType,

      ReconciliationAccountType,
      _Reconciliationaccttype._Text[1: Language=$session.system_language].ReconciliationAccountTypeName,

      AccountIsBlockedForPosting,
      AccountIsBlockedForPlanning,
      AccountIsBlockedForCreation,
      AccountIsMarkedForDeletion,

      LineItemDisplayIsEnabled,
      IsOpenItemManaged,
      IsAutomaticallyPosted,
      AcctgDocItmDisplaySequenceRule,

      CorporateGroupAccount,
      PartnerCompany,
      SampleGLAccount,
      AlternativeGLAccount,
      GLAccountExternal,
      CountryChartOfAccounts,
      AuthorizationGroup,
      TaxCategory,

      CreatedByUser,
      CreationDate

}
