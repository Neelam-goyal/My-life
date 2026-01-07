@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GL Account Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_GLACCOUNTVH as select from I_GLAccount
{
    key GLAccount,
    key CompanyCode,
    _Text.GLAccountName,
    ChartOfAccounts,
    GLAccountType
   
}
