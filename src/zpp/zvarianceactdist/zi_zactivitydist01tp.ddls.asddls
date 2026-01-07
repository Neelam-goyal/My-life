@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZACTIVITYDIST'
define root view entity ZI_ZACTIVITYDIST01TP
  provider contract transactional_interface
  as projection on ZR_ZACTIVITYDIST01TP as ZACTIVITYDIST
{
  key Bukrs,
  key Plantcode,
  key Declarecdate,
  Declaredate,
  Variancecalculated,
  Varianceposted,
  Varianceclosed,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _zactdistlines : redirected to composition child ZI_zactdistlinesTP
  
}
