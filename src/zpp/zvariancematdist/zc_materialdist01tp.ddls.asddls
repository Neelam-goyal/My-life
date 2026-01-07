@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption Proj view for zmaterialdist'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'Bukrs' ]
@Search.searchable: true
define root view entity ZC_materialdist01TP
  provider contract transactional_query
  as projection on ZR_materialdist01TP as materialdist
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Bukrs,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Plantcode,
  key Declarecdate,
      Variancepostdate,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      Declaredate,
      Variancecalculated,
      Varianceposted,
      Varianceclosed,
      Totaljobrun,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _matdistlines : redirected to composition child ZC_matdistlinesTP

}
