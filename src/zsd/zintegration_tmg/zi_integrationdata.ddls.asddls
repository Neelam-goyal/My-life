@EndUserText.label: 'Integration Data'
@AccessControl.authorizationCheck: #NOT_ALLOWED
@Metadata.allowExtensions: true
define view entity ZI_IntegrationData
  as select from zintegration_tmg
  association to parent ZI_IntegrationData_S as _IntegrationDataAll on $projection.SingletonID = _IntegrationDataAll.SingletonID
{
  key intgmodule as Intgmodule,
  intgpath as Intgpath,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  @Consumption.hidden: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _IntegrationDataAll
  
}
