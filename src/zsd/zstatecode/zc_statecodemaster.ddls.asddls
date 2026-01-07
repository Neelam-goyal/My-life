@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_STATECODEMASTER
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_STATECODEMASTER
{
  key Statecode,
  Statecodenum,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
