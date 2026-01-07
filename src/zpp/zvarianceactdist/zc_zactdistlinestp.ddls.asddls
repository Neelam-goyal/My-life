@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forzactdistlines'
@ObjectModel.semanticKey: [ 'Distlineno' ]
@Search.searchable: true
define view entity ZC_zactdistlinesTP
  as projection on ZR_zactdistlinesTP as zactdistlines
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
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key Distlineno,  
  Shiftnumber,
  Workcenterid,
  Workcenter,
  Declaredate,
  Productionorder,
  Productionorderline,
  Orderconfirmationgroup,
  Ordersequence,
  Clabour,
  Cpower,
  Cfuel,
  Crepair,
  Coverheads,
  Vlabour,
  Vpower,
  Vfuel,
  Vrepair,
  Voverheads,
  Varianceposted,
  Shiftgroup,
  _ZACTIVITYDIST : redirected to parent ZC_ZACTIVITYDIST01TP
  
}
