@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_DEALER_TABLE
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_DEALER_TABLE
{
  key DealerDeviceId,
  Dlradvpymttag,
  Dealerift,
  Dealerbctag,
  Dealerstation,
  Creditdays,
  Dealersmdtag,
  Sshqcode,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
