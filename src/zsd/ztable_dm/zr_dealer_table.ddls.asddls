@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_DEALER_TABLE
  as select from ZDEALER_TABLE
{
  key dealer_device_id as DealerDeviceId,
  dlradvpymttag as Dlradvpymttag,
  dealerift as Dealerift,
  dealerbctag as Dealerbctag,
  dealerstation as Dealerstation,
  creditdays as Creditdays,
  dealersmdtag as Dealersmdtag,
  sshqcode as Sshqcode,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt
  
}
