@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View forzmatdistlines'
define view entity ZI_matdistlinesTPBRD
  as projection on ZR_matdistlinesTPBRD as zmatdistlines
{
  key Bukrs,
  key Plantcode,
  key Declarecdate,
  key Shiftnumber,
  key Distlineno,
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
      Varianceposted,
      Entryuom,
      Variancepostlinedate,
      /* Associations */
      _materialdist : redirected to parent ZI_materialdist01TPbrd
}
