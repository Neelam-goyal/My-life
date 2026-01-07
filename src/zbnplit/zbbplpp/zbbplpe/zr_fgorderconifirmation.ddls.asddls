@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FG Order Confirmation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_FGOrderConifirmation
  as select from I_MfgOrderConfirmation as conf
    inner join   I_ManufacturingOrder   as head on conf.ManufacturingOrder = head.ManufacturingOrder
{
  key conf.MfgOrderConfirmationGroup,
  key conf.MfgOrderConfirmation,
      conf.ManufacturingOrder,
      head.Product,
      head._Product.WeightUnit,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      head._Product.GrossWeight,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      head._Product.NetWeight,
      head.BillOfMaterial,
      head.BillOfMaterialInternalID,
      head.BillOfMaterialVariant,
      head.BillOfMaterialVariantUsage,
      head.BillOfMaterialVersion,

      head.BillOfOperations,
      head.BillOfOperationsVariant,
      head.BillOfOperationsType,
      head.BillOfOperationsMaterial,

      conf.ManufacturingOrderCategory,
      conf.ManufacturingOrderType,
      conf.OrderInternalID,
      conf.OrderOperationInternalID,
      conf.ConfirmationText,
      conf.MfgOrderConfirmationEntryDate,
      conf.MfgOrderConfirmationEntryTime,

      conf.IsReversed,
      conf.IsReversal,
      conf.OrderConfirmationType,
      conf.OrderConfirmationRecordType,
      conf.Plant,
      conf.WorkCenterTypeCode,
      conf.WorkCenterInternalID,
      conf.ShiftDefinition,
      conf.MaterialDocument,
      conf.MaterialDocumentYear,
      conf.PlantDataCollectionID,
      conf.CompanyCode,
      conf.ControllingArea,
      conf.ProfitCenter,
      conf.PostingDate,
      conf.PostingDateYear,
      conf.ConfirmationUnit,
      conf.VarianceReasonCode,
      conf.ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      conf.ConfYieldQtyInProductionUnit,
      conf.OperationUnit,
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      conf.OpPlannedTotalQuantity,
      conf.OpWorkQuantityUnit1,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit1'
      conf.OpConfirmedWorkQuantity1,
      conf.NoFurtherOpWorkQuantity1IsExpd,
      conf.OpWorkQuantityUnit2,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit2'
      conf.OpConfirmedWorkQuantity2,
      conf.NoFurtherOpWorkQuantity2IsExpd,
      conf.OpWorkQuantityUnit3,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit3'
      conf.OpConfirmedWorkQuantity3,
      conf.NoFurtherOpWorkQuantity3IsExpd,
      conf.OpWorkQuantityUnit4,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit4'
      conf.OpConfirmedWorkQuantity4,
      conf.NoFurtherOpWorkQuantity4IsExpd,
      conf.OpWorkQuantityUnit5,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit5'
      conf.OpConfirmedWorkQuantity5,
      conf.NoFurtherOpWorkQuantity5IsExpd,
      conf.OpWorkQuantityUnit6,
      @Semantics.quantity.unitOfMeasure: 'OpWorkQuantityUnit6'
      conf.OpConfirmedWorkQuantity6
}
where
      conf.Plant                  =  'BB03'
  and conf.PostingDate            >= '20260101'
  and conf.ManufacturingOrderType =  'Z112'
