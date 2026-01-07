@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Consumption Proj View for zmatdistlines'
@ObjectModel.semanticKey: [ 'Distlineno' ]
@Search.searchable: true
define root view entity ZC_MATDISTLINESBRD 
 provider contract transactional_query
  as projection on ZR_matdistlinesbrd as matdistlines
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
    key Shiftnumber,
    @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
    key Distlineno,
    @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
    key Productcode,
    Orderconfirmationgroup,
    Confirmationcount,
    Varianceconfirmationcount,
    Shiftgroup,
    Declaredate,
    Productionorder,
    Productionorderline,
    Storagelocation,
    Batchno,
    Productdesc,
    Consumedqty,
    Varianceqty,
    Entryuom,
    Varianceposted,
    Variancepostlinedate
}
