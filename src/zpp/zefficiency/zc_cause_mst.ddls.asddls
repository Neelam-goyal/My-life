@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_CAUSE_MST
  provider contract transactional_query
  as projection on ZR_CAUSE_MST
{
  key CDesc,
  key CCode,
  key StdTime,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
