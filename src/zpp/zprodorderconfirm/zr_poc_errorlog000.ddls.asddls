@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
//@ObjectModel.sapObjectNodeType.name: 'ZPOC_ERRORLOG000'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_POC_ERRORLOG000
  as select from zpoc_errorlog
{
  key plant as Plant,
  key manufacturingorder as Manufacturingorder,
  key errortimestamp as Errortimestamp,
  yieldquantity as Yieldquantity,
  errormessage as Errormessage,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
