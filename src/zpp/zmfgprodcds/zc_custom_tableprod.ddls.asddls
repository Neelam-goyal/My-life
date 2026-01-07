@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_CUSTOM_TABLEPROD
  provider contract transactional_query
  as projection on ZR_CUSTOMTABLEPROD
{
  key Product,
  key Type,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
