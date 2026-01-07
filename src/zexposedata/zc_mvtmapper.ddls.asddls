@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_MVTMAPPER
  provider contract transactional_query
  as projection on ZR_MVTMAPPER
{
  key Movementtype,
  Multiplier,
  DebitCreditIndicator,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
