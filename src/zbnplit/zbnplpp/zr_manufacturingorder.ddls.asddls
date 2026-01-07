@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Mfg. Order (Production & Packing)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_ManufacturingOrder
  as select from I_ManufacturingOrder          as a
    inner join   ZR_USER_CMPY_ACCESS           as _cmpAccess on  _cmpAccess.CompCode = a.CompanyCode
                                                             and _cmpAccess.userid   = $session.user

    inner join   ZDIM_Product                  as prd        on a.Product = prd.Product
    inner join   I_ManufacturingOrderOperation as b          on  a.ManufacturingOrder     = b.ManufacturingOrder
                                                             and a.ManufacturingOrderType = b.ManufacturingOrderType
{
  key a.ManufacturingOrder,
      a.CompanyCode,
      a.ProductionPlant,
      a.CreationDate                                                                as MfgOrderDate,
      a.MfgOrderActualReleaseDate,
      a.ManufacturingOrderType,
      a.Product                                                                     as MfgProduct,
      prd.ProductName                                                               as MfgProductName,
      concat(
                concat(
                    concat(
                        concat(a.BillOfMaterialCategory ,'-'),
                        a.BillOfMaterialInternalID)
                    ,'-'
                    ),
                a.BillOfMaterialVariant)                                            as BOM,
      a.BusinessArea,
      a.ControllingArea,
      a.ProfitCenter,
      a.CostingSheet,
      a.ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      a.MfgOrderPlannedTotalQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      a.MfgOrderConfirmedYieldQty,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      a.ActualDeliveredQuantity,
      max(b.WorkCenterInternalID)                                                   as WorkCenterInternalID,
      max(b._WorkCenterText[1:Language = $session.system_language].WorkCenterText ) as WorkCenterText


}
where
       a.ManufacturingOrderCategory = '10'
  and(
       a.ManufacturingOrderType     = 'Z111' //Production Order
    or a.ManufacturingOrderType     = 'Z112' // Packing Order
  )
group by
  a.ManufacturingOrder,
  a.CompanyCode,
  a.ProductionPlant,
  a.CreationDate,
  a.MfgOrderActualReleaseDate,
  a.ManufacturingOrderType,
  a.Product,
  prd.ProductName,
  a.BillOfMaterialCategory,
  a.BillOfMaterialInternalID,
  a.BillOfMaterialVariant,
  a.BusinessArea,
  a.ControllingArea,
  a.ProfitCenter,
  a.CostingSheet,
  a.ProductionUnit,
  a.MfgOrderPlannedTotalQty,
  a.MfgOrderConfirmedYieldQty,
  a.ActualDeliveredQuantity
