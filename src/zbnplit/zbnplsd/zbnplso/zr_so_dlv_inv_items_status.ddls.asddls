@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shipping Status and Invoicing Staus Final'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SO_DLV_INV_ITEMS_STATUS
  as select from            ZR_SO_DLV_INV_ITEMS_STATUS_1 as SalesDocItemFulfillmnt

    left outer to many join I_SalesDocumentScheduleLine  as ConfirmedSchedL

    on  SalesDocItemFulfillmnt.SalesDocument          = ConfirmedSchedL.SalesDocument
    and SalesDocItemFulfillmnt.SalesDocumentItem      = ConfirmedSchedL.SalesDocumentItem
    and ConfirmedSchedL.OpenConfdDelivQtyInOrdQtyUnit > 0

    left outer to many join I_SalesDocumentScheduleLine  as RequestedSchedL

    on  SalesDocItemFulfillmnt.SalesDocument         = RequestedSchedL.SalesDocument
    and SalesDocItemFulfillmnt.SalesDocumentItem     = RequestedSchedL.SalesDocumentItem
    and RequestedSchedL.OpenReqdDelivQtyInOrdQtyUnit > 0

{
      //Key
  key SalesDocItemFulfillmnt.SalesDocument,
  key SalesDocItemFulfillmnt.SalesDocumentItem,

      //Category
      SalesDocItemFulfillmnt.SalesDocumentType,

      //Organization
      SalesDocItemFulfillmnt.SalesOrganization,
      SalesDocItemFulfillmnt.DistributionChannel,
      SalesDocItemFulfillmnt.OrganizationDivision,

      //Product
      SalesDocItemFulfillmnt.Material,
      SalesDocItemFulfillmnt.Product,

      //Sales
      SalesDocItemFulfillmnt.SalesDocumentItemText,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SalesDocItemFulfillmnt.OrderQuantity,

      SalesDocItemFulfillmnt.OrderQuantityUnit,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'TargetQuantityUnit'
      SalesDocItemFulfillmnt.TargetQuantity,

      SalesDocItemFulfillmnt.TargetQuantityUnit,

      //Shipping
      SalesDocItemFulfillmnt.RequestedDeliveryDate, -- required for Project Based Service scenario process flow

      @DefaultAggregation: #MIN
      min
      (                -- ConfirmedSchedLine 'beats' RequestedSchedLine
      case when ConfirmedSchedL.DeliveryCreationDate > '00000000' and ConfirmedSchedL.IsConfirmedDelivSchedLine = 'X'
                 then ConfirmedSchedL.DeliveryCreationDate else
                  case when RequestedSchedL.DeliveryCreationDate > '00000000' and RequestedSchedL.IsRequestedDelivSchedLine = 'X'
                        then RequestedSchedL.DeliveryCreationDate
      -- else  -- else branch omitted to enforce a NULL-value, that is needed by ODATA
                  end
           end
         )                                                             as NextPlannedProdAvailDate,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SalesDocItemFulfillmnt.ShippedQuantityInOrderQtyUnit,

      //Invoicing
      SalesDocItemFulfillmnt.BillingDocumentDate, -- required for Project Based Service scenario process flow
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SalesDocItemFulfillmnt.InvoicedQuantityInOrderQtyUnit,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SalesDocItemFulfillmnt.IncomingSalesOrdersNetAmount,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SalesDocItemFulfillmnt.InvoicedNetAmountInTranCurr,
      SalesDocItemFulfillmnt.TransactionCurrency,

      //Status
      SalesDocItemFulfillmnt.SDDocumentRejectionStatus,
      SalesDocItemFulfillmnt.SDProcessStatus, --- useful information for
      SalesDocItemFulfillmnt.OverallSDProcessStatus, --- status determination in
      SalesDocItemFulfillmnt.OverallSDDocumentRejectionSts, --- sales order process flow
      SalesDocItemFulfillmnt.DeliveryStatus,

      //Shipping status
      cast ( SalesDocItemFulfillmnt.ShippingStatus as abap.char(1) )   as ShippingStatus,

      //Invoicing status
      cast ( SalesDocItemFulfillmnt.InvoicingStatus as abap.char(1)  ) as InvoicingStatus,

      //Associations
      SalesDocItemFulfillmnt._OrderQuantityUnit,
      SalesDocItemFulfillmnt._TargetQuantityUnit,
      SalesDocItemFulfillmnt._SalesDocumentType
}
group by
  SalesDocItemFulfillmnt.SalesDocument,
  SalesDocItemFulfillmnt.SalesDocumentItem,
  SalesDocItemFulfillmnt.SalesDocumentType,
  SalesDocItemFulfillmnt.SalesOrganization,
  SalesDocItemFulfillmnt.DistributionChannel,
  SalesDocItemFulfillmnt.OrganizationDivision,
  SalesDocItemFulfillmnt.Material,
  SalesDocItemFulfillmnt.Product,
  SalesDocItemFulfillmnt.SalesDocumentItemText,
  SalesDocItemFulfillmnt.OrderQuantity,
  SalesDocItemFulfillmnt.OrderQuantityUnit,
  SalesDocItemFulfillmnt.ShippedQuantityInOrderQtyUnit,
  SalesDocItemFulfillmnt.InvoicedQuantityInOrderQtyUnit,
  SalesDocItemFulfillmnt.ShippingStatus,
  SalesDocItemFulfillmnt.InvoicingStatus,
  SalesDocItemFulfillmnt.RequestedDeliveryDate,
  SalesDocItemFulfillmnt.BillingDocumentDate,
  SalesDocItemFulfillmnt.TargetQuantity,
  SalesDocItemFulfillmnt.TargetQuantityUnit,
  SalesDocItemFulfillmnt.SDDocumentRejectionStatus,
  SalesDocItemFulfillmnt.SDProcessStatus,
  SalesDocItemFulfillmnt.OverallSDProcessStatus,
  SalesDocItemFulfillmnt.OverallSDDocumentRejectionSts,
  SalesDocItemFulfillmnt.DeliveryStatus,
  SalesDocItemFulfillmnt.IncomingSalesOrdersNetAmount,
  SalesDocItemFulfillmnt.InvoicedNetAmountInTranCurr,
  SalesDocItemFulfillmnt.TransactionCurrency
