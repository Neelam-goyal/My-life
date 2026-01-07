@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order with Delivery Doc and Invoiced Item Quantity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SO_DLV_INV_ITEMS
  as

  select from               ZR_SalesOrderAndDelvryDocItem  as SalesDocItem

    left outer to many join ZR_SalesOrderAndInvoiceDocItem as SalesDocItemInvoicing on  SalesDocItem.SalesDocument     = SalesDocItemInvoicing.SalesDocument
                                                                                    and SalesDocItem.SalesDocumentItem = SalesDocItemInvoicing.SalesDocumentItem
{
      //Key
  key SalesDocItem.SalesDocument,
  key SalesDocItem.SalesDocumentItem,

      //Category
      SalesDocItem.SalesDocumentType,

      //Organization
      SalesDocItem.SalesOrganization,
      SalesDocItem.DistributionChannel,
      SalesDocItem.OrganizationDivision,

      //Product
      SalesDocItem.Material,
      SalesDocItem.Product,


      //Sales
      SalesDocItem.SalesDocumentItemText,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SalesDocItem.OrderQuantity,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SalesDocItemInvoicing.IncomingSalesOrdersNetAmount,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SalesDocItemInvoicing.InvoicedNetAmountInTranCurr,
      SalesDocItemInvoicing.TransactionCurrency,
      
      SalesDocItem.OrderQuantityUnit,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'TargetQuantityUnit'
      SalesDocItem.TargetQuantity,

      SalesDocItem.TargetQuantityUnit,

      //Shipping
      SalesDocItem.RequestedDeliveryDate, -- required for Project Based Service scenario process flow
      SalesDocItem.UnderdelivTolrtdLmtRatioInPct,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      cast ( cast( SalesDocItem.ShippedQuantityInOrderQtyUnit as abap.quan( 13, 3 ) ) as abap.quan( 13, 3) )        as ShippedQuantityInOrderQtyUnit,

      100 - SalesDocItem.UnderdelivTolrtdLmtRatioInPct                                                              as MinimumDeliveryFulfillmntInPct, -- calculation result assigned to identifier as intermediate step

      case when SalesDocItem.OrderQuantity = 0
        then 0
        else
      division( 100 * cast( SalesDocItem.ShippedQuantityInOrderQtyUnit as abap.dec( 13, 3 )) ,
                      cast( SalesDocItem.OrderQuantity as abap.dec(13,3)), 3 )
       end                                                                                                          as UnderdeliveryInPct, -- calculation result assigned to identifier as intermediate step

      //Invoicing
      SalesDocItem.BillingDocumentDate, -- required for Project Based Service scenario process flow
      //SalesDocItemInvoicing.ItemIsBillingRelevant,
      SalesDocItem.ItemIsBillingRelevant,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      cast ( cast( SalesDocItemInvoicing.InvoicedQuantityInOrderQtyUnit as abap.quan(13,3) ) as abap.quan( 13, 3) ) as InvoicedQuantityInOrderQtyUnit,

      //Status
      SalesDocItem.SDDocumentRejectionStatus,
      SalesDocItem.DeliveryStatus,

      SalesDocItem.SDProcessStatus, --- useful information for
      SalesDocItem.OverallSDProcessStatus, --- status determination in
      SalesDocItem.OverallSDDocumentRejectionSts, --- sales order process flow

      SalesDocItem.OrderRelatedBillingStatus, -- FKSAA from VBAP, required to handle rejected items with rejection reasons that keep invoice relevance

      //Associations
      SalesDocItem._OrderQuantityUnit, -- provides an association to OrderQuantityUnit and its attributes
      SalesDocItem._TargetQuantityUnit,
      SalesDocItem._SalesDocumentType
}
