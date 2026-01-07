@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for CRUD operations'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_matdistlinebrd
  as select from zmatdistlinebrd
{
  key bukrs                  as Bukrs,
  key plantcode              as Plantcode,
  key declarecdate           as Declarecdate,
  key shiftnumber            as Shiftnumber,
  key distlineno             as Distlineno,
  key productcode            as Productcode,
      orderconfirmationgroup as Orderconfirmationgroup,
      confirmationcount      as Confirmationcount,
      varianceconfirmationcount as Varianceconfirmationcount,
      shiftgroup             as Shiftgroup,
      declaredate            as Declaredate,
      productionorder        as Productionorder,
      productionorderline    as Productionorderline,
      storagelocation        as Storagelocation,
      batchno                as Batchno,
      productdesc            as Productdesc,
      consumedqty            as Consumedqty,
      varianceqty            as Varianceqty,
      entryuom               as Entryuom,
      varianceposted         as Varianceposted,
      variancepostlinedate   as Variancepostlinedate
//       @Semantics.user.createdBy: true
//      created_by            as CreatedBy,
//      @Semantics.systemDateTime.createdAt: true
//      created_at            as CreatedAt,
//      last_changed_by       as LastChangedBy,
//      @Semantics.systemDateTime.localInstanceLastChangedAt: true
//      last_changed_at       as LastChangedAt,
//      @Semantics.systemDateTime.lastChangedAt: true
//      local_last_changed_at as LocalLastChangedAt
}
