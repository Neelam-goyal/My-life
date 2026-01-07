@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forzmatdistlines'
define view entity ZR_matdistlinesTPBRD
  as select from zmatdistlinesbrd as zmatdistlines
  association to parent ZR_materialdist01TPbrd as _materialdist on  $projection.Bukrs        = _materialdist.Bukrs
                                                             and $projection.Plantcode    = _materialdist.Plantcode
                                                             and $projection.Declarecdate = _materialdist.Declarecdate
{
  key bukrs                  as Bukrs,
  key plantcode              as Plantcode,
  key declarecdate           as Declarecdate,
  key shiftnumber            as Shiftnumber,
  key distlineno             as Distlineno,
  key productcode            as Productcode,
      orderconfirmationgroup as Orderconfirmationgroup,
      shiftgroup             as Shiftgroup,
      confirmationcount      as Confirmationcount,
      varianceconfirmationcount as Varianceconfirmationcount,
      declaredate            as Declaredate,
      productionorder        as Productionorder,
      productionorderline    as Productionorderline,
      storagelocation        as Storagelocation,
      batchno                as Batchno,
      productdesc            as Productdesc,
      consumedqty            as Consumedqty,
      varianceqty            as Varianceqty,
      varianceposted         as Varianceposted,
      entryuom               as Entryuom,
      variancepostlinedate   as Variancepostlinedate,
//       @Semantics.user.createdBy: true
//      created_by            as CreatedBy,
//      @Semantics.systemDateTime.createdAt: true
//      created_at            as CreatedAt,
//      last_changed_by       as LastChangedBy,
//      @Semantics.systemDateTime.localInstanceLastChangedAt: true
//      last_changed_at       as LastChangedAt,
//      @Semantics.systemDateTime.lastChangedAt: true
//      local_last_changed_at as LocalLastChangedAt,
      _materialdist

}
