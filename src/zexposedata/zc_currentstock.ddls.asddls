@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_CURRENTSTOCK
  as select from  ZR_CURRENTSTOCK
{
  key Plant,
  key Product,
  
  @Consumption.filter.mandatory: true
  key InsertedDate,
  key InsertedTime,
  PlantName,
  ProductType,
  ProductName,
  MaterialBaseUnit,
  OpeningStock,
  ProductionStock,
  PostedStock,
  PostedReturnStock,
  PurchaseStock,
  UnpostedInvStock,
  UnpostedUnsoldStock,
  AdjustmentStock,
  CalculateStock,
  MatlWrhsStkQtyInMatlBaseUnit ,
  UnpostedUpto,
  AdjustedMvtStock
}
//where 
//    (
//        InsertedDate = $session.system_date and 
//        InsertedTime >= cast('01:25:00' as abap.tims)
//    )
//    or 
//    (
//        InsertedDate = dats_add_days($session.system_date, 1, 'INITIAL') and 
//        InsertedTime < cast('01:25:00' as abap.tims)
//    )
