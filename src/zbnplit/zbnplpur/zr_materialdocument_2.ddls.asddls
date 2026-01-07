@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MaterialDocument_2
  as select from I_MaterialDocumentHeader_2 as _header
    inner join   I_MaterialDocumentItem_2   as _item      on  _header.MaterialDocumentYear = _item.MaterialDocumentYear
                                                          and _header.MaterialDocument     = _item.MaterialDocument
    inner join   I_PurchaseOrderItemAPI01   as _OrderItem on  _item.PurchaseOrder     = _OrderItem.PurchaseOrder
                                                          and _item.PurchaseOrderItem = _OrderItem.PurchaseOrderItem
{
  key _item.MaterialDocumentYear,
  key _item.MaterialDocument,
  key _item.MaterialDocumentItem,
      _header.DocumentDate,
      _header.PostingDate,
      _header.AccountingDocumentType,
      _header.InventoryTransactionType,
      _header.CreatedByUser,
      _header.CreationDate,
      _header.CreationTime,
      _header.MaterialDocumentHeaderText,
      _header.DeliveryDocument,
      _header.ReferenceDocument,
      _header.BillOfLading,
      _header.VersionForPrintingSlip,
      _header.ManualPrintIsTriggered,
      _header.CtrlPostgForExtWhseMgmtSyst,
      _header.Plant,
      _header.StorageLocation,
      _header.IssuingOrReceivingPlant,
      _header.IssuingOrReceivingStorageLoc,
      _item.Material,


      _item.StorageType,
      _item.StorageBin,
      _item.Batch,
      _item.ShelfLifeExpirationDate,
      _item.ManufactureDate,
      _item.Supplier,
      _item.SalesOrder,
      _item.SalesOrderItem,
      _item.SalesOrderScheduleLine,
      _item.WBSElementInternalID,
      _item.Customer,
      _item.InventorySpecialStockType,
      _item.InventoryStockType,
      _item.StockOwner,
      _item.GoodsMovementType,
      _item.DebitCreditCode,
      _item.InventoryUsabilityCode,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      _item.QuantityInBaseUnit,
      _item.MaterialBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      _item.QuantityInEntryUnit,
      _item.EntryUnit,

      _item.ReservationItemRecordType,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _item.TotalGoodsMvtAmtInCCCrcy,
      _item.CompanyCodeCurrency,
      _item.InventoryValuationType,
      _item.ReservationIsFinallyIssued,
      _item.PurchaseOrder,
      _item.PurchaseOrderItem,
      _OrderItem.DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      _OrderItem.NetPriceAmount as PurchaseOrderItemNetPrice,
      _item.ProjectNetwork,
      _item.OrderID,
      _item.OrderItem,
      _item.MaintOrderRoutingNumber,
      _item.MaintOrderOperationCounter,
      _item.Reservation,
      _item.ReservationItem,

      _item.DeliveryDocumentItem,
      _item.ReversedMaterialDocumentYear,
      _item.ReversedMaterialDocument,
      _item.ReversedMaterialDocumentItem,
      _item.RvslOfGoodsReceiptIsAllowed,
      _item.GoodsRecipientName,
      _item.GoodsMovementReasonCode,
      _item.UnloadingPointName,
      _item.CostCenter,
      _item.GLAccount,
      _item.ServicePerformer,
      _item.PersonWorkAgreement,
      _item.AccountAssignmentCategory,
      _item.WorkItem,
      _item.ServicesRenderedDate,
      _item.IssgOrRcvgMaterial,


      _item.IssgOrRcvgBatch,
      _item.IssgOrRcvgSpclStockInd,
      _item.IssuingOrReceivingValType,
      _item.CompanyCode,
      _item.BusinessArea,
      _item.ControllingArea,
      _item.FiscalYearPeriod,
      _item.FiscalYearVariant,
      _item.GoodsMovementRefDocType,
      _item.IsCompletelyDelivered,
      _item.MaterialDocumentItemText,
      _item.IsAutomaticallyCreated,
      _item.SerialNumbersAreCreatedAutomly,
      _item.GoodsReceiptType,
      _item.ConsumptionPosting,
      _item.MultiAcctAssgmtOriglMatlDocItm,
      _item.MultipleAccountAssignmentCode,
      _item.GoodsMovementIsCancelled,
      _item.IssuingOrReceivingStockType,
      _item.ManufacturingOrder,
      _item.ManufacturingOrderItem,
      _item.MaterialDocumentLine,
      _item.MaterialDocumentParentLine,
      _item.SpecialStockIdfgSalesOrder,
      _item.SpecialStockIdfgSalesOrderItem,
      _item.SpecialStockIdfgWBSElement,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      _item.QtyInPurchaseOrderPriceUnit,
      _item.OrderPriceUnit,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      _item.QuantityInDeliveryQtyUnit,
      _item.DeliveryQuantityUnit,
      _item.ProfitCenter,
      _item.ProductStandardID,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      _item.GdsMvtExtAmtInCoCodeCrcy,
      _item.ReferenceDocumentFiscalYear,
      _item.InvtryMgmtReferenceDocument,
      _item.InvtryMgmtRefDocumentItem,
      _item.EWMWarehouse,
      _item.EWMStorageBin,
      _item.MaterialDocumentPostingType,
      _item.OriginalMaterialDocumentItem

}
