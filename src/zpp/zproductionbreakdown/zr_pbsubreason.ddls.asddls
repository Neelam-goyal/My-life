@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Sub-Reason'
define root view entity ZR_PBSUBREASON
  as select from zpbsubreason
{
 @EndUserText.label: 'Sub-Reason Code'
  key subreasoncode as Subreasoncode,
   @EndUserText.label: 'Sub-Reason Description'
  subreasondesc as Subreasondesc,
   @EndUserText.label: 'Reason Code'
  reasoncode as Reasoncode,
   @EndUserText.label: 'Reason Description'
  reasondesc as Reasondesc,
  @Semantics.user.createdBy: true
  @Consumption.hidden: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  @Consumption.hidden: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  @Consumption.hidden: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  last_changed_at as LastChangedAt
  
}
