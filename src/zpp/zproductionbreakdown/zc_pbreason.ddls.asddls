@Metadata.allowExtensions: true
@EndUserText.label: 'Reason'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_PBREASON
  provider contract transactional_query
  as projection on ZR_PBREASON
{
  key Reasoncode,
  Reasondesc,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
