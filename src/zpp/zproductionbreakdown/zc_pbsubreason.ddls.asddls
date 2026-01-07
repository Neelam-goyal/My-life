@Metadata.allowExtensions: true
@EndUserText.label: 'Sub-Reason'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_PBSUBREASON
  provider contract transactional_query
  as projection on ZR_PBSUBREASON
{
  key Subreasoncode,
  Subreasondesc,
  Reasoncode,
  Reasondesc,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt
  
}
