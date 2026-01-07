@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Confirmation Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MfgOrderConfirmationHeader
  as select from ZR_MfgOrderConfirmation
{
  key ManufacturingOrder,
  key MfgOrderConfirmationGroup,
  key MfgOrderConfirmation,
  key MaterialDocument,
  key MaterialDocumentYear,

      ManufacturingOrderCategory,
      ManufacturingOrderType,
      OrderInternalID,
      MfgOrderConfirmationEntryDate,
      MfgOrderConfirmationEntryTime,
      Plant,
      CompanyCode,
      ControllingArea,
      ProfitCenter,
      WorkCenterText,
      ShiftDefinition,
      OrderCreationDate,
      PostingDate,
      OrderActualReleaseDate,
      ConfirmationUnit,

      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      ConfirmationYieldQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      ConfirmationScrapQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      ConfirmationReworkQuantity,
      @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
      ConfirmationTotalQuantity,
      ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      ConfYieldQtyInProductionUnit,
      OperationUnit,
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      OpPlannedTotalQuantity
}
group by
  ManufacturingOrder,
  MfgOrderConfirmationGroup,
  MfgOrderConfirmation,
  MaterialDocument,
  MaterialDocumentYear,

  ManufacturingOrderCategory,
  ManufacturingOrderType,
  OrderInternalID,
  MfgOrderConfirmationEntryDate,
  MfgOrderConfirmationEntryTime,
  Plant,
  CompanyCode,
  ControllingArea,
  ProfitCenter,
  WorkCenterText,
  ShiftDefinition,
  OrderCreationDate,
  PostingDate,
  OrderActualReleaseDate,
  ConfirmationUnit,
  ConfirmationYieldQuantity,
  ConfirmationScrapQuantity,
  ConfirmationReworkQuantity,
  ConfirmationTotalQuantity,
  ProductionUnit,
  ConfYieldQtyInProductionUnit,
  OperationUnit,
  OpPlannedTotalQuantity
