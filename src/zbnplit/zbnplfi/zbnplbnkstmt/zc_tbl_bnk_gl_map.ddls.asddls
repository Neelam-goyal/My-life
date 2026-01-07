@Metadata.allowExtensions: true
@EndUserText.label: 'Mapping of Bank with GL Accounts'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TBL_BNK_GL_MAP
  provider contract transactional_query
  as projection on ZR_TBL_BNK_GL_MAP
{
  key Chartofaccounts,
  key Glaccount,
  key Bankaccountinternalid,
  Isactive,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
