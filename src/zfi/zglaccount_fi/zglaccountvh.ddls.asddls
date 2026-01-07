@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GLACCOUNT Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGLACCOUNTVH as select distinct from I_GLAccountInCompanyCode as a
left outer join I_GLAccountTextRawData as b on a.GLAccount = b.GLAccount
{
    key a.GLAccount,
    key a.CompanyCode,
    b.GLAccountLongName
}
