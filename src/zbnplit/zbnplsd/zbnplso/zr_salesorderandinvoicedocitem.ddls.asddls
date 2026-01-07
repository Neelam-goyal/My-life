@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order with Invoiced Quantity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SalesOrderAndInvoiceDocItem
  as select from    I_SalesDocumentItem as SalesDocItem
    left outer join ZR_InvoicingDocItem as InvoicingDocItem on  SalesDocItem.SalesDocument     = InvoicingDocItem.SalesDocument
                                                            and SalesDocItem.SalesDocumentItem = InvoicingDocItem.SalesDocumentItem
{
      //Key
  key SalesDocItem.SalesDocument,
  key SalesDocItem.SalesDocumentItem,

      //Category
      SalesDocItem.SalesDocumentType, -- AUART from VBAK

      //Organization
      SalesDocItem.SalesOrganization,
      SalesDocItem.DistributionChannel,
      SalesDocItem.OrganizationDivision,

      //Product
      SalesDocItem.Material,

      //Sales
      SalesDocItem.SalesDocumentItemText,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SalesDocItem.OrderQuantity,

      SalesDocItem.OrderQuantityUnit,

      SalesDocItem.OrderToBaseQuantityDnmntr,
      SalesDocItem.OrderToBaseQuantityNmrtr,

      //Shipping
      SalesDocItem.UnderdelivTolrtdLmtRatioInPct,

      //Invoicing
      SalesDocItem.ItemIsBillingRelevant, -- FKREL from VBAP

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sum (case when InvoicingDocItem.BillingQuantityInBaseUnit is null then
       0
      else
        division (cast(InvoicingDocItem.BillingQuantityInBaseUnit
                        as abap.dec( 13, 3 ))
                      * SalesDocItem.OrderToBaseQuantityDnmntr,
                       SalesDocItem.OrderToBaseQuantityNmrtr, 3)
      end )                    as InvoicedQuantityInOrderQtyUnit,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast( case when SalesDocItem.IsReturnsItem = '' and ( SalesDocItem.ItemIsBillingRelevant != '' or SalesDocItem.TotalDeliveryStatus != '' )
           then
           case
              when
                ( SalesDocItem.SDDocumentCategory = 'C' or   -- Order
                  SalesDocItem.SDDocumentCategory = 'L' or   -- DMR
                  SalesDocItem.SDDocumentCategory = 'I' or   -- Order w/o Change
                  SalesDocItem.SDDocumentCategory = 'E' or   -- Scheduling Aggreement
                  SalesDocItem.SDDocumentCategory = 'F' )    -- Scheduling Aggreement w. ext. Service Agent
              then SalesDocItem.NetAmount
              when
                ( SalesDocItem.SDDocumentCategory = 'H' or   -- Returns
                  SalesDocItem.SDDocumentCategory = 'K' )    -- CMR
              then  -1 * SalesDocItem.NetAmount
           end
      end as abap.curr(19,2) ) as IncomingSalesOrdersNetAmount,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum (case when InvoicingDocItem.NetAmount is null then
       0
      else
        cast(InvoicingDocItem.NetAmount as abap.dec(19,2))
      end )                    as InvoicedNetAmountInTranCurr,

      SalesDocItem.TransactionCurrency,
      //Status
      SalesDocItem.SDDocumentRejectionStatus,

      //Associations
      SalesDocItem._OrderQuantityUnit -- provides an association to OrderQuantityUnit and its attributes
}
where
  (
    (
      SalesDocItem.ItemIsBillingRelevant != ' '
    ) -- invoicing relevant order items only
    or(
      SalesDocItem.TargetQuantity        >  0
    ) --- exception for Project Based Service Sales Orders
  )

group by
  SalesDocItem.SalesDocument,
  SalesDocItem.SalesDocumentItem,
  SalesDocItem.SalesDocumentType,
  SalesDocItem.SalesOrganization,
  SalesDocItem.DistributionChannel,
  SalesDocItem.OrganizationDivision,
  SalesDocItem.Material,
  SalesDocItem.SalesDocumentItemText,
  SalesDocItem.OrderQuantity,
  SalesDocItem.OrderQuantityUnit,
  SalesDocItem.OrderToBaseQuantityDnmntr,
  SalesDocItem.OrderToBaseQuantityNmrtr,
  SalesDocItem.ItemIsBillingRelevant,
  SalesDocItem.SDDocumentRejectionStatus,
  SalesDocItem.UnderdelivTolrtdLmtRatioInPct,
  SalesDocItem.SDDocumentCategory,
  SalesDocItem.IsReturnsItem,
  SalesDocItem.NetAmount,
  SalesDocItem.TransactionCurrency,
  SalesDocItem.TotalDeliveryStatus
