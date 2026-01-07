@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GOODS RECIEPT ENTRIES'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WE_GOODSRECIEPT
  as select from ZR_MaterialDocument_2
{
  key MaterialDocumentYear,
  key MaterialDocument,
  key MaterialDocumentItem,
      DocumentDate,
      PostingDate,
      AccountingDocumentType,
      InventoryTransactionType,
      CreatedByUser,
      CreationDate,
      CreationTime,
      MaterialDocumentHeaderText,
      DeliveryDocument,
      ReferenceDocument,
      BillOfLading,
      Plant,
      StorageLocation,
      IssuingOrReceivingPlant,
      IssuingOrReceivingStorageLoc,
      Material,
      Supplier,
      Customer,
      InventoryStockType,
      GoodsMovementType,
      DebitCreditCode,
      InventoryUsabilityCode,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      QuantityInBaseUnit,
      MaterialBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      QuantityInEntryUnit,
      EntryUnit,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalGoodsMvtAmtInCCCrcy,
      CompanyCodeCurrency,
      ReservationIsFinallyIssued,
      PurchaseOrder,
      PurchaseOrderItem,
      ReversedMaterialDocumentYear,
      ReversedMaterialDocument,
      ReversedMaterialDocumentItem,
      RvslOfGoodsReceiptIsAllowed,
      GoodsRecipientName,
      GoodsMovementReasonCode,
      UnloadingPointName,
      CostCenter,
      GLAccount,
      AccountAssignmentCategory,
      ServicesRenderedDate,
      CompanyCode,
      BusinessArea,
      ControllingArea,
      FiscalYearPeriod,
      FiscalYearVariant,
      GoodsMovementRefDocType,
      IsCompletelyDelivered,
      MaterialDocumentItemText,

      ConsumptionPosting,
      MultiAcctAssgmtOriglMatlDocItm,
      MultipleAccountAssignmentCode,
      GoodsMovementIsCancelled,
      MaterialDocumentLine,
      MaterialDocumentParentLine,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      QtyInPurchaseOrderPriceUnit,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      PurchaseOrderItemNetPrice,
      OrderPriceUnit,
      DocumentCurrency,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      QuantityInDeliveryQtyUnit,
      DeliveryQuantityUnit,
      ProfitCenter,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      GdsMvtExtAmtInCoCodeCrcy,
      ReferenceDocumentFiscalYear,
      InvtryMgmtReferenceDocument,
      InvtryMgmtRefDocumentItem,
      MaterialDocumentPostingType,
      OriginalMaterialDocumentItem
}
where
      AccountingDocumentType =  'WE'
  and Supplier               <> ''
