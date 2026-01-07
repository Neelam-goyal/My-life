@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forZACTIVITYDIST'
define root view entity ZR_ZACTIVITYDIST01TP
  as select from zactivitydist as ZACTIVITYDIST
  composition [0..*] of ZR_zactdistlinesTP as _zactdistlines
{
  key bukrs as Bukrs,
  key plantcode as Plantcode,
  key declarecdate as Declarecdate,
  declaredate as Declaredate,
  variancecalculated as Variancecalculated,
  varianceposted as Varianceposted,
  varianceclosed as Varianceclosed,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  _zactdistlines
  
}
