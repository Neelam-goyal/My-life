@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'View - Mapping of Bank with GL Accounts'
define root view entity ZR_TBL_BNK_GL_MAP
  as select from ztbl_bnk_gl_map
{
  key chartofaccounts as Chartofaccounts,
  key glaccount as Glaccount,
  key bankaccountinternalid as Bankaccountinternalid,
  isactive as Isactive,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
  
  
}
