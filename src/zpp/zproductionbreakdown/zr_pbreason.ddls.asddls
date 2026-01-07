@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Reason'
define root view entity ZR_PBREASON
  as select from zpbreason
{
  @EndUserText.label: 'Reason Code'
  key reasoncode as Reasoncode,
   @EndUserText.label: 'Reason Description'
  reasondesc as Reasondesc,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @EndUserText.label: 'Last Changed At'  
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt

  
}
