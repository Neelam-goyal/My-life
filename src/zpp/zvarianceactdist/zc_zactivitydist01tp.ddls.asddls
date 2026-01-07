@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forZACTIVITYDIST'
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_ZACTIVITYDIST01TP
  provider contract transactional_query
  as projection on ZR_ZACTIVITYDIST01TP as ZACTIVITYDIST
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Bukrs,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Plantcode,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
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
  _zactdistlines : redirected to composition child ZC_zactdistlinesTP
  
}
