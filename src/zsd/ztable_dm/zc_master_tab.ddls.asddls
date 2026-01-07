@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_MASTER_TAB
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_MASTER_TAB
{
  key Brandcode,
  Brandtag,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
