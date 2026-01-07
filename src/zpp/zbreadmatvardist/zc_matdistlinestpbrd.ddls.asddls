@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Consumption Proj View for zmatdistlines'
@ObjectModel.semanticKey: [ 'Distlineno' ]
@Search.searchable: true
define view entity ZC_matdistlinesTPBRD
  as projection on ZR_matdistlinesTPBRD as matdistlines
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
  key Productcode,
      Declaredate,
      Orderconfirmationgroup,
      Confirmationcount,
      Varianceconfirmationcount,    
      Shiftgroup,
      Productionorder,
      Productionorderline,
      Storagelocation,
      Batchno,
      Productdesc,
      Consumedqty,
      Varianceqty,
      Varianceposted,
      Entryuom,
      Variancepostlinedate,
//       CreatedBy,
//      CreatedAt,
//      LastChangedBy,
//      LastChangedAt,
//      LocalLastChangedAt,
      _materialdist : redirected to parent ZC_materialdist01TPBRD
}
