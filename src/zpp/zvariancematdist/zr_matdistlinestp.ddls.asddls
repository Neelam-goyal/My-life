@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forzmatdistlines'
define view entity ZR_matdistlinesTP
  as select from zmatdistlines as zmatdistlines
  association to parent ZR_materialdist01TP as _materialdist on  $projection.Bukrs        = _materialdist.Bukrs
                                                             and $projection.Plantcode    = _materialdist.Plantcode
                                                             and $projection.Declarecdate = _materialdist.Declarecdate
{
  key bukrs                  as Bukrs,
  key plantcode              as Plantcode,
  key declarecdate           as Declarecdate,
  key shiftnumber            as Shiftnumber,
  key distlineno             as Distlineno,
      declaredate            as Declaredate,
      productionorder        as Productionorder,
      productionorderline    as Productionorderline,
      orderconfirmationgroup as Orderconfirmationgroup,
      ordersequence          as Ordersequence,
      storagelocation        as Storagelocation,
      productcode            as Productcode,
      batchno                as Batchno,
      productdesc            as Productdesc,
      consumedqty            as Consumedqty,
      varianceqty            as Varianceqty,
      varianceposted         as Varianceposted,
      entryuom               as Entryuom,
      shiftgroup             as Shiftgroup,
      variancepostlinedate   as Variancepostlinedate,
      _materialdist

}
