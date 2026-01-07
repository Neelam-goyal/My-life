@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_MATDISTLINEBRD'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_MATDISTLINEBRD
provider contract transactional_query
  as projection on ZR_matdistlinebrd
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
    Entryuom,
    Varianceposted,
    Variancepostlinedate
//    CreatedBy,
//    CreatedAt,
//    LastChangedBy,
//    LastChangedAt
}
