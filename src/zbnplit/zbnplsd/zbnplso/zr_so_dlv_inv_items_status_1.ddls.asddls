@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shipping Status and Invoicing Staus'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SO_DLV_INV_ITEMS_STATUS_1
  as select from ZR_SO_DLV_INV_ITEMS
{
      //Key
  key SalesDocument,
  key SalesDocumentItem,

      //Category
      SalesDocumentType,

      //Organization
      SalesOrganization,
      DistributionChannel,
      OrganizationDivision,

      //Product
      Material,
      Product,

      //Sales
      SalesDocumentItemText,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OrderQuantity,

      OrderQuantityUnit,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'TargetQuantityUnit'
      TargetQuantity,

      TargetQuantityUnit,

      //Shipping
      RequestedDeliveryDate, -- required for Project Based Service scenario process flow
      UnderdelivTolrtdLmtRatioInPct,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      ShippedQuantityInOrderQtyUnit,

      //Invoicing
      BillingDocumentDate, -- required for Project Based Service scenario process flow
      ItemIsBillingRelevant,
      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      InvoicedQuantityInOrderQtyUnit,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      IncomingSalesOrdersNetAmount,
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      InvoicedNetAmountInTranCurr,
      TransactionCurrency,

      //Status
      SDDocumentRejectionStatus,
      DeliveryStatus,

      SDProcessStatus, --- useful information for
      OverallSDProcessStatus, --- status determination in
      OverallSDDocumentRejectionSts, --- sales order process flow

      //Shipping status
      case when
         OrderQuantity = 0       -- Shipping Status set to 'Not shipping relevant' when order quantity eq zero
        or
         DeliveryStatus = ''        -- Shipping Status set to 'Not shipping relevant' when item is not delivery relevant
        or  (
           (
                  SDDocumentRejectionStatus = 'B'
              or  SDDocumentRejectionStatus = 'C'   -- Shipping Status set to 'Not shipping relevant'
             )                                        -- when item is rejected before
             and ShippedQuantityInOrderQtyUnit = 0       -- anything has been shipped
            )
      then
        '0'
      else
          case when
                SDDocumentRejectionStatus != 'B'                  -- Shipping Status set to 'Partially Shipped'
            and SDDocumentRejectionStatus != 'C'                   -- when item has not been rejected, and
            and ShippedQuantityInOrderQtyUnit > 0                   -- a quantity > 0 has been shipped, and
            and UnderdeliveryInPct < MinimumDeliveryFulfillmntInPct  -- a quantity is oustanding for shipment to comply
          then                                                        -- with Underdelivery Tolerance Limit
            'B'
          else
            case when
              (
                ( SDDocumentRejectionStatus = 'B'   -- Shipping Status set to 'Completely Shipped'
               or SDDocumentRejectionStatus = 'C'  -- when item is rejected after a quantity > 0 has already been shipped
                )
                and ShippedQuantityInOrderQtyUnit > 0
              )                                      --
              or UnderdeliveryInPct >=  MinimumDeliveryFulfillmntInPct   -- Shipping Status set to 'Completely Shipped'
            then                                                          -- when there is no quantity outstanding for shipment to comply
              'C'                                                          -- with Underdelivery Tolerance Limit
            else
              'A'                -- else, Shipping Status set to 'Not Shipped'
            end
          end
      end as ShippingStatus,

      // Invoicing status
      case when
          OrderRelatedBillingStatus != ''  --- for sales document items with order related invoicing
       then
           OrderRelatedBillingStatus       --- Invoicing Status to be copied 1:1 from OrderRelatedBillingStatus

      else
       case when
           OrderQuantity = 0           -- Invoicing Status set to 'Not invoicing relevant' when order quantity eq zero

        or                             -- Invoicing Status also set to 'Not invoicing relevant', when
           ItemIsBillingRelevant = ''  --- item is not relevant for billing

        or (                           -- Invoicing Status also set to 'Not invoicing relevant', when
            (
              SDDocumentRejectionStatus = 'B'
            or SDDocumentRejectionStatus = 'C'    -- item is rejected, with a reason that takes back billing relevance
            )
          and OrderRelatedBillingStatus != 'A'     --- i.e. Order Related Billing Status is neither 'Not Processed'
            and OrderRelatedBillingStatus != 'B'      --- nor 'Partially Processed'

            and ShippedQuantityInOrderQtyUnit = 0       -- before anything has been shipped
            and InvoicedQuantityInOrderQtyUnit = 0       -- and before anything has been invoiced
           )
       then
        '0'                                       -- 0 = 'Not Relevant for Invoicing'

       else
          case when
           (                                         --- Invoicing Status set to 'Partially Invoiced', when
            (
               ( SDDocumentRejectionStatus != 'B'     --- item has not been rejected,
              and SDDocumentRejectionStatus != 'C' )

              or
               (                                     -- or,
                (
                 SDDocumentRejectionStatus = 'B'
               or SDDocumentRejectionStatus = 'C'    --  item is rejected, however,
                )
      --  with a reason that keeps billing relevance!
                and OrderRelatedBillingStatus >= ''         --- i.e. Order Related Billing Status is neither 'Not Relevant'
                and OrderRelatedBillingStatus >= 'C'         --- nor 'Completely Processed'

           )
             )                                    -- and
             and InvoicedQuantityInOrderQtyUnit > 0              -- a quantity > 0 has been invoiced, and
             and InvoicedQuantityInOrderQtyUnit < OrderQuantity   -- a quantity is oustanding for invoicing
           )

           or
           (                                         --- Invoicing Status also set to 'Partially Invoiced'
            ( SDDocumentRejectionStatus = 'B'
            or SDDocumentRejectionStatus = 'C'        --- when item is rejected, however,
            )
             and InvoicedQuantityInOrderQtyUnit > 0                              -- after a quantity > 0 has already been invoiced, and
             and InvoicedQuantityInOrderQtyUnit < ShippedQuantityInOrderQtyUnit  -- a quantity that has been shipped is still outstanding for invoicing
           )
         then
           'B'                                       -- B = 'Partially Invoiced'

        else
           case when
            (                                       -- Invoicing Status set to 'Completely Invoiced'
             ( SDDocumentRejectionStatus = 'B'
             or SDDocumentRejectionStatus = 'C'      -- when item is rejected, however,
             )
             and InvoicedQuantityInOrderQtyUnit > 0                               -- after a quantity > 0 has already been invoiced, and
             and InvoicedQuantityInOrderQtyUnit >= ShippedQuantityInOrderQtyUnit  -- everything that has been shipped has also been invoiced already
            )

            or                                               -- Invoicing Status also set to 'Completely Invoiced'
              InvoicedQuantityInOrderQtyUnit >= OrderQuantity -- when entire order quantity has been invoiced
           then
             'C'                                       -- C = 'Completely Invoiced'

           else
             'A'                  -- else, Invoicing Status set to  A = 'Not Invoiced'

           end
          end
         end
      end as InvoicingStatus,

      //Associations
      _OrderQuantityUnit, -- provides an association to OrderQuantityUnit and its attributes
      _TargetQuantityUnit,
      _SalesDocumentType
}
