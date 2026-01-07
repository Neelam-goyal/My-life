@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'new custom'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_newcustom as select distinct from I_MfgOrderConfirmation as a
inner join I_ManufacturingOrder as b on a.ManufacturingOrder = b.ManufacturingOrder
inner join I_ProductDescription_2 as d on b.Product = d.Product and d.Language = 'E'
inner join I_WorkCenter as e on a.WorkCenterInternalID = e.WorkCenterInternalID
//inner join I_MfgOrderConfMatlDocItem as f on a.ManufacturingOrder = f.ManufacturingOrder and a.MfgOrderConfirmation = f.MfgOrderConfirmation 
//                                         and a.MfgOrderConfirmationGroup = f.MfgOrderConfirmationGroup 
////                                         and a.MaterialDocument = f.MaterialDocument 
////                                         and a.MaterialDocumentYear = f.MaterialDocumentYear 
//                                         and f.GoodsMovementType = '101'
//inner join I_MaterialBOMLink as g on f.Material = g.Material and f.Plant = g.Plant
//inner join I_BillOfMaterialHeaderDEX_2 as h on g.BillOfMaterial = h.BillOfMaterial and g.BillOfMaterialVariant = h.BillOfMaterialVariant

inner join I_MfgOrderConfMatlDocItem as i2 on a.ManufacturingOrder = i2.ManufacturingOrder and a.MfgOrderConfirmation = i2.MfgOrderConfirmation 
                                         and a.MfgOrderConfirmationGroup = i2.MfgOrderConfirmationGroup 
                                         and i2.GoodsMovementType = '531'
//inner join I_MfgOrderDocdGoodsMovement as i2 
//  on a.ManufacturingOrder = i2.ManufacturingOrder and  a.MaterialDocument = i2.GoodsMovement and a.MaterialDocumentYear = i2.GoodsMovementYear
//   and i2.GoodsMovementType = '531'
inner join zcustomtableprod as j2 
  on i2.Material = lpad(cast(j2.product as abap.char(18)), 18, '0') 
  and j2.type = 'ZWST' 
  
{
  key a.ManufacturingOrder,
  key a.MfgOrderConfirmationGroup,
  key a.MfgOrderConfirmation,
  
//  i2.GoodsMovement,
//  i2.GoodsMovementYear,

//  key d.ProductDescription,
//  a.Plant, 
//  a.PostingDate,
//  b.Product,
//  e.WorkCenter,
//
//  case a.ShiftDefinition
//    when '1' then 'Day'
//    when '2' then 'Night'
//    else ''
//  end as ShiftDescription,
//
//  @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
//  b.MfgOrderPlannedTotalQty,
//  b.ProductionUnit,
//
//  @Semantics.quantity.unitOfMeasure: 'EntryUnit'
//  f.QuantityInEntryUnit,
//  f.EntryUnit,
//
//  @Semantics.quantity.unitOfMeasure: 'unit'
//  a.ConfirmationYieldQuantity,
//  a.OperationUnit as unit,
//
//  @Semantics.quantity.unitOfMeasure: 'BOMHeaderBaseUnit'
//  h.BOMHeaderQuantityInBaseUnit,
//  h.BOMHeaderBaseUnit,


  @Semantics.quantity.unitOfMeasure: 'BaseUnit1'
    sum ( i2.QuantityInEntryUnit )  as TotalQty_ZWST,
  
  i2.BaseUnit as BaseUnit1

}
where a.IsReversal is initial 
  and a.IsReversed is initial
group by
    a.ManufacturingOrder,
    a.MfgOrderConfirmationGroup,
    a.MfgOrderConfirmation,
    i2.BaseUnit
//    i2.GoodsMovement,
//    i2.GoodsMovementYear
//    d.ProductDescription,
//    a.Plant,
//    a.PostingDate,
//    b.Product,
//    e.WorkCenter,
////    a.ShiftDefinition,
//    b.MfgOrderPlannedTotalQty,
//    b.ProductionUnit,
//    f.QuantityInEntryUnit,
//    f.EntryUnit,
//    a.ConfirmationYieldQuantity,
//    a.OperationUnit,
//    h.BOMHeaderQuantityInBaseUnit,
//    h.BOMHeaderBaseUnit,
//    i2.BaseUnit,
//    a.Plant,
//    a.PostingDate,
//    b.Product
 

