@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_CUSTOMTABLEPROD
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_CUSTOMTABLEPROD
{
  key Product,
  key Type,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
