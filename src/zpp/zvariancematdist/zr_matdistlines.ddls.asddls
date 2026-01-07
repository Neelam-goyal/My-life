@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for CRUD operations'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_matdistlines
  as select from zmatdistlines
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
      entryuom               as Entryuom,
      shiftgroup             as Shiftgroup,
      varianceposted         as Varianceposted,
      variancepostlinedate   as Variancepostlinedate
}
