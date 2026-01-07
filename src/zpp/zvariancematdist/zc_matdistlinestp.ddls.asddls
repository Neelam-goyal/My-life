@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Consumption Proj View for zmatdistlines'
@ObjectModel.semanticKey: [ 'Distlineno' ]
@Search.searchable: true
define view entity ZC_matdistlinesTP
  as projection on ZR_matdistlinesTP as matdistlines
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Bukrs,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Plantcode,
  key Declarecdate,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Shiftnumber,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Distlineno,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      Declaredate,
      Productionorder,
      Productionorderline,
      Orderconfirmationgroup,
      Ordersequence,
      Storagelocation,
      Productcode,
      Batchno,
      Productdesc,
      Consumedqty,
      Varianceqty,
      Varianceposted,
      Entryuom,
      Shiftgroup,
      Variancepostlinedate,
      _materialdist : redirected to parent ZC_materialdist01TP
}
