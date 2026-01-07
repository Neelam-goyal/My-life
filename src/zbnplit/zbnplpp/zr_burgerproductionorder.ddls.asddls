@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Burger Producution Orders'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_BurgerProductionOrder
  as select from    I_ManufacturingOrder        as A

    inner join      ZR_USER_CMPY_ACCESS         as _cmpAccess on  _cmpAccess.CompCode = A.CompanyCode
                                                              and _cmpAccess.userid   = $session.user


  //  inner join      I_MfgOrderDocdGoodsMovement   as B          on A.ManufacturingOrder = B.ManufacturingOrder
    inner join      I_MfgOrderConfMatlDocItem   as Conf       on A.ManufacturingOrder = Conf.ManufacturingOrder
                                                              and(
                                                                    Conf.IsReversed       is initial // Exclude Reversed Entries
                                                                    and Conf.IsReversal   is initial
                                                                  )
  //                                                                and B.GoodsMovement      = Conf.MaterialDocument
  //                                                                and B.GoodsMovementYear  = Conf.MaterialDocumentYear

    inner join      I_BillOfMaterialHeaderDEX_2 as C          on  A.BillOfMaterialInternalID = C.BillOfMaterial
                                                              and A.BillOfMaterialCategory   = C.BillOfMaterialCategory
                                                              and A.BillOfMaterialVariant    = C.BillOfMaterialVariant

    inner join      ZDIM_Product                as prd        on A.Product = prd.Product
    inner join      ZDIM_ProductGroup           as grp        on prd.ProductGroup = grp.ProductGroup
    left outer join zcustomtableprod            as configtbl  on Conf.Material = lpad(
      configtbl.product, 18, '0'
    )

{
  key A.ManufacturingOrder,
      A.ManufacturingOrderItem,
      A.ManufacturingOrderCategory,
      A.ManufacturingOrderType,
      A.CreationDate                 as OrderCreationDate,

      grp.ProductGroupName,
      prd.ProductGroup,
      A.Product,
      prd.ProductName,
      Conf.Batch,

      A.MfgOrderInternalID,

      A.ProductionPlant,
      A.PlanningPlant,

      A.Reservation,

      concat(
            concat(
                concat(
                    concat(A.BillOfMaterialCategory ,'-'),
                    A.BillOfMaterialInternalID)
                ,'-'
                ),
            A.BillOfMaterialVariant) as BOM,

      A.CompanyCode,
      A.ControllingArea,
      A.ProfitCenter,
      A.CostingSheet,
      Conf.StorageLocation,

      A.MfgOrderActualStartDate,
      A.MfgOrderItemActualDeliveryDate,

      Conf.PostingDate,
      Conf.MaterialDocument          as GoodsMovement,
      Conf.MaterialDocumentYear      as GoodsMovementYear,
      Conf.MfgOrderConfirmationGroup,
      Conf.MfgOrderConfirmation,
      Conf._MfgOrderConfirmation._WorkCenterText.WorkCenterText,
      case Conf._MfgOrderConfirmation.ShiftDefinition
      when '1' then 'Day'
      when '2' then 'Night'
      else ''
      end                            as ShiftDescription,
      C.BOMHeaderBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BOMHeaderBaseUnit'
      C.BOMHeaderQuantityInBaseUnit,

      Conf.EntryUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      sum(case when (Conf.GoodsMovementType = '101' or Conf.GoodsMovementType = '102' )
      then case Conf.DebitCreditCode when 'H' then  -Conf.QuantityInEntryUnit when 'S' then Conf.QuantityInEntryUnit end
      else cast( 0.000 as abap.quan(13,3))
      end )                          as SFGProducedQty,

      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      sum(case when (Conf.GoodsMovementType = '261' or Conf.GoodsMovementType = '262')
                    and configtbl.type = 'ZROH'
      then case Conf.DebitCreditCode when 'H' then  Conf.QuantityInEntryUnit when 'S' then -Conf.QuantityInEntryUnit end
      else cast( 0.000 as abap.quan(13,3))
      end )                          as RMConsumedQty,

      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      sum(case when (Conf.GoodsMovementType = '261' or Conf.GoodsMovementType = '262' or Conf.GoodsMovementType = '531')
                    and configtbl.type = 'ZWST'
      then case Conf.DebitCreditCode when 'H' then  -Conf.QuantityInEntryUnit when 'S' then Conf.QuantityInEntryUnit end
      else cast( 0.000 as abap.quan(13,3))
      end )                          as WstgProducedQty,


      A.ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      A.MfgOrderPlannedTotalQty      as TotalPlannedQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      A.MfgOrderPlannedScrapQty      as TotalPlannedScrapQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      A.ActualDeliveredQuantity      as TotalActualDeliveredQty


}
where
    (A._Product.ProductType = 'ZSFG' or A._Product.ProductType = 'ZSFB') //User is selecting wrong Production Order Type 
//          A.ManufacturingOrderType = 'Z111' // Production Order Only
  and (
    (
          A.CompanyCode            = 'BBPL' // Burger from BBPL
      and A.ProductionPlant        = 'BB03'
    )
    or(
          A.CompanyCode            = 'BNPL' // Bread from BNPL, BIPL, CAPL
      or  A.CompanyCode            = 'BIPL'
      or  A.CompanyCode            = 'CAPL'
    )
  )


//  and left( grp.ProductGroupName,5 )       = 'BREAD'
//  and cast( A.ManufacturingOrder as int4 ) < 200000

//  and B.IsReversal                         is initial
//  and B.IsReversed                         is initial
group by
  A.ManufacturingOrder,
  A.ManufacturingOrderItem,
  A.ManufacturingOrderCategory,
  A.ManufacturingOrderType,
  A.CreationDate,
  grp.ProductGroupName,
  prd.ProductGroup,
  A.Product,
  prd.ProductName,
  Conf.Batch,
  A.MfgOrderInternalID,
  A.ProductionPlant,
  A.PlanningPlant,
  A.Reservation,
  A.BillOfMaterialCategory,
  A.BillOfMaterialInternalID,
  A.BillOfMaterialVariant,
  A.CompanyCode,
  A.ControllingArea,
  A.ProfitCenter,
  A.CostingSheet,
  Conf.StorageLocation,
  A.MfgOrderActualStartDate,
  A.MfgOrderItemActualDeliveryDate,
  Conf.PostingDate,
  Conf.MaterialDocument,
  Conf.MaterialDocumentYear,
  A.ProductionUnit,
  A.MfgOrderPlannedTotalQty,
  A.MfgOrderPlannedScrapQty,
  A.ActualDeliveredQuantity,
  Conf.EntryUnit,
  Conf.MfgOrderConfirmationGroup,
  Conf.MfgOrderConfirmation,
  Conf._MfgOrderConfirmation._WorkCenterText.WorkCenterText,
  Conf._MfgOrderConfirmation.ShiftDefinition,
  C.BOMHeaderBaseUnit,
  C.BOMHeaderQuantityInBaseUnit
