@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Status Item Level Fulfillment'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SalesDocumentItemFulfillmnt
  as select from    ZR_SO_DLV_INV_ITEMS_STATUS as status
    inner join      I_SalesDocument            as _SalesDocument on status.SalesDocument = _SalesDocument.SalesDocument
    inner join      ZDIM_Product               as prd            on status.Product = prd.Product
    left outer join ZDIM_CustomerWithSalesArea as _CustWithSalesArea   on  _SalesDocument.SoldToParty = _CustWithSalesArea.Customer
                                                                 and status.SalesOrganization   = _CustWithSalesArea.SalesOrg


{
      //Key
  key status.SalesDocument,
  key status.SalesDocumentItem,
      _SalesDocument.SalesDocumentDate,
      //Category
      status.SalesDocumentType,

      //Organization
      status.SalesOrganization,
      status.DistributionChannel,
      status.OrganizationDivision,

      //SoldtoParty
      _SalesDocument.SoldToParty,
      
      @EndUserText.label: 'SoldToPartyMstDistChannel'
      _CustWithSalesArea._DistributionChannel.DistributionChannelName as SoldToPartyMstDistChannel,

      @EndUserText.label: 'SoldToPartyMstCity'
      _CustWithSalesArea.City                                         as SoldToPartyMstCity,

      @EndUserText.label: 'SoldToPartyMstState'
      _CustWithSalesArea.State                                        as SoldToPartyMstState,

      @EndUserText.label: 'SoldToPartyMstDivision'
      _CustWithSalesArea.Division                                     as SoldToPartyMstDivision,

      //Product
      status.Material,
      status.Product,
      prd.ProductGroup,
      //Sales
      status.SalesDocumentItemText,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      status.OrderQuantity,

      status.OrderQuantityUnit,
      //
      //      @DefaultAggregation: #SUM
      //      @Semantics.quantity.unitOfMeasure: 'TargetQuantityUnit'
      //      TargetQuantity,
      //
      //      TargetQuantityUnit,

      //Shipping
      status.RequestedDeliveryDate, -- required for Project Based Service scenario process flow

      @DefaultAggregation: #MIN
      cast (status.NextPlannedProdAvailDate as abap.dats)       as NextPlannedProdAvailDate,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      status.ShippedQuantityInOrderQtyUnit,

      //Invoicing
      status.BillingDocumentDate, -- required for Project Based Service scenario process flow
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      status.InvoicedQuantityInOrderQtyUnit,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      status.IncomingSalesOrdersNetAmount,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      status.InvoicedNetAmountInTranCurr,
      status.TransactionCurrency,

      //Status
      status.SDDocumentRejectionStatus,
      status.SDProcessStatus, --- useful information for
      status.OverallSDProcessStatus, --- status determination in
      status.OverallSDDocumentRejectionSts, --- sales order process flow
      status.DeliveryStatus,
      _SalesDocument.OverallOrdReltdBillgStatus,
      _SalesDocument.HeaderBillgIncompletionStatus,

      _SalesDocument.OverallDelivConfStatus,
      _SalesDocument.OverallTotalDeliveryStatus,
      _SalesDocument.OverallDeliveryStatus,

      //Shipping status
      status.ShippingStatus,

      //Invoicing status
      status.InvoicingStatus,

      //Associations
      status._OrderQuantityUnit,

      status._SalesDocumentType
}
