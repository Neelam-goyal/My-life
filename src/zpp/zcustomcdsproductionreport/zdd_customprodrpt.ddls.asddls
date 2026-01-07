@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production Order Report - Distinct Keys'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_customProdRpt
  as select distinct from I_MfgOrderConfirmation      as a
    inner join            I_ManufacturingOrder        as b  on a.ManufacturingOrder = b.ManufacturingOrder
    inner join            I_ProductDescription_2      as d  on  b.Product  = d.Product
                                                            and d.Language = 'E'
    inner join            I_WorkCenter                as e  on a.WorkCenterInternalID = e.WorkCenterInternalID
    inner join            I_MfgOrderConfMatlDocItem   as f  on  a.ManufacturingOrder        = f.ManufacturingOrder
                                                            and a.MfgOrderConfirmation      = f.MfgOrderConfirmation
                                                            and a.MfgOrderConfirmationGroup = f.MfgOrderConfirmationGroup
//                                                            and a.MaterialDocument          = f.MaterialDocument
//                                                            and a.MaterialDocumentYear      = f.MaterialDocumentYear
                                                            and f.GoodsMovementType         = '101'
    inner join            I_MaterialBOMLink           as g  on  f.Material = g.Material
                                                            and f.Plant    = g.Plant
    inner join            I_BillOfMaterialHeaderDEX_2 as h  on  g.BillOfMaterial        = h.BillOfMaterial
                                                            and g.BillOfMaterialVariant = h.BillOfMaterialVariant


//    inner join            I_MfgOrderDocdGoodsMovement as i1 on  a.ManufacturingOrder = i1.ManufacturingOrder
////                                                            and a.MaterialDocument   = i1.GoodsMovement
//                                                            and i1.GoodsMovementType = '261'
  //inner join zcustomtableprod as j1
  //  on i1.Material = lpad(cast(j1.product as abap.char(18)), 18, '0')
  //  and j1.type = 'ZROH'
  //  inner join
    inner join            zdd_new_sum                 as i3 on  a.ManufacturingOrder        = i3.ManufacturingOrder
                                                            and a.MfgOrderConfirmationGroup = i3.MfgOrderConfirmationGroup
                                                            and a.MfgOrderConfirmation      = i3.MfgOrderConfirmation
  //   on a.ManufacturingOrder = i3.ManufacturingOrder and a.MfgOrderConfirmation = i3.MfgOrderConfirmation and
  //a.MfgOrderConfirmationGroup = i3.MfgOrderConfirmationGroup
    left outer join       zdd_newcustom               as i2 on  i3.ManufacturingOrder        = i2.ManufacturingOrder
                                                            and i3.MfgOrderConfirmation      = i2.MfgOrderConfirmation
                                                            and i3.MfgOrderConfirmationGroup = i2.MfgOrderConfirmationGroup

{
  key a.ManufacturingOrder,
  key a.MfgOrderConfirmationGroup,
  key a.MfgOrderConfirmation,

  key d.ProductDescription,
      a.Plant,
      a.PostingDate,
      a.IsReversal,
      a.IsReversed,
      b.Product,
      e.WorkCenter,

      case a.ShiftDefinition
        when '1' then 'Day'
        when '2' then 'Night'
        else ''
      end                          as ShiftDescription,

      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      b.MfgOrderPlannedTotalQty,
      b.ProductionUnit,

      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      f.QuantityInEntryUnit,
      f.EntryUnit,

      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      a.ConfirmationReworkQuantity,

      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      a.ConfirmationScrapQuantity,
      a.OperationUnit,

      @Semantics.quantity.unitOfMeasure: 'unit'
      //      a.ConfirmationYieldQuantity,
      a.ConfirmationYieldQuantity +
      a.ConfirmationScrapQuantity +
      a.ConfirmationReworkQuantity as ConfirmationYieldQuantity,
      a.OperationUnit              as unit,

      @Semantics.quantity.unitOfMeasure: 'BOMHeaderBaseUnit'
      h.BOMHeaderQuantityInBaseUnit,
      h.BOMHeaderBaseUnit,

      //  // Separate ZROH and ZWST
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      //  i1.QuantityInEntryUnit as TotalQty_ZROH,
      i3.TotalQty_ZROH,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit1'
      //  i2.QuantityInEntryUnit as TotalQty_ZWST,
      i2.TotalQty_ZWST,
      //    i3.TotalQty_ZWST,
      i3.BaseUnit,
      i2.BaseUnit1

}
where
      a.IsReversal is initial
  and a.IsReversed is initial
