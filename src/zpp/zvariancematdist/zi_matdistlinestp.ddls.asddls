@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forzmatdistlines'
define view entity ZI_matdistlinesTP
  as projection on ZR_matdistlinesTP as zmatdistlines
{
  key Bukrs,
  key Plantcode,
  key Declarecdate,
  key Shiftnumber,
  key Distlineno,
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
      /* Associations */
      _materialdist : redirected to parent ZI_materialdist01TP
}
