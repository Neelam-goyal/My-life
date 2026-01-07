@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_COMPANYCODE
  as select from I_CompanyCode
{
  key CompanyCode,
  CompanyCodeName
}
