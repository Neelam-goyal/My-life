@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order with Delivery Doc Item Quantity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SalesOrderAndDelvryDocItem
  as select from            I_SalesDocumentItem    as SalesDocItem

    left outer to many join I_DeliveryDocumentItem as DeliveryDocItem on  SalesDocItem.SalesDocument         = DeliveryDocItem.ReferenceSDDocument
                                                                      and SalesDocItem.SalesDocumentItem     = DeliveryDocItem.ReferenceSDDocumentItem
                                                                      and (
                                                                         DeliveryDocItem.GoodsMovementStatus = 'C'
                                                                       ) --> only when Goods Issue posted

{
      //Key
  key SalesDocItem.SalesDocument,
  key SalesDocItem.SalesDocumentItem,

      //Category
      SalesDocItem._SalesDocument.SalesDocumentType, -- AUART from VBAK

      //Organization
      SalesDocItem._SalesDocument.SalesOrganization,
      SalesDocItem._SalesDocument.DistributionChannel,
      SalesDocItem._SalesDocument.OrganizationDivision,

      //Product
      SalesDocItem.Material,
      SalesDocItem.Product,

      //Sales
      SalesDocItem.SalesDocumentItemText,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      SalesDocItem.OrderQuantity,
      
      SalesDocItem.OrderQuantityUnit,

      SalesDocItem.OrderToBaseQuantityDnmntr,
      SalesDocItem.OrderToBaseQuantityNmrtr,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'TargetQuantityUnit'
      SalesDocItem.TargetQuantity,
      
      SalesDocItem.TargetQuantityUnit,

      //Shipping
      SalesDocItem._SalesDocument.RequestedDeliveryDate, -- required for Project Based Service scenario process flow
      SalesDocItem.UnderdelivTolrtdLmtRatioInPct,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sum (case when DeliveryDocItem.ActualDeliveredQtyInBaseUnit is null then
        0
      else
        division (cast(DeliveryDocItem.ActualDeliveredQtyInBaseUnit as abap.dec( 13, 3 ))
                    * SalesDocItem.OrderToBaseQuantityDnmntr,
                    SalesDocItem.OrderToBaseQuantityNmrtr, 3)
      end ) as ShippedQuantityInOrderQtyUnit,

      // Invoicing
      SalesDocItem._SalesDocument.BillingDocumentDate, -- required for Project Based Service scenario process flow
      SalesDocItem.ItemIsBillingRelevant, -- FKREL from VBAP

      //Status
      SalesDocItem.SDDocumentRejectionStatus,
      SalesDocItem.DeliveryStatus,

      SalesDocItem.SDProcessStatus, --- useful information for
      SalesDocItem._SalesDocument.OverallSDProcessStatus, --- status determination in
      SalesDocItem._SalesDocument.OverallSDDocumentRejectionSts, --- sales order process flow

      SalesDocItem.OrderRelatedBillingStatus, -- FKSAA from VBAP, required to handle rejected items with rejection reasons that keep invoice relevance

      //Associations
      SalesDocItem._OrderQuantityUnit, -- provides an association to OrderQuantityUnit and its attributes
      SalesDocItem._TargetQuantityUnit,
      SalesDocItem._SalesDocument._SalesDocumentType
}

where
  (
    (
      SalesDocItem.DeliveryStatus                    != ' '
    ) --> set at least to 'A' by status logic when item is delivery relevant
    or(
      SalesDocItem.ItemIsBillingRelevant             != ' '
    ) -- invoicing relevant order items to be included
    -- to avoid the need for full join when later
    -- joining with sales order item invoice fulfillment

    or(
      SalesDocItem._SalesDocument.SDDocumentCategory =  'C'
    ) -- 'bypass' required for Project Based Service scenario process flow
  )

group by
  SalesDocItem.SalesDocument,
  SalesDocItem.SalesDocumentItem,
  SalesDocItem._SalesDocument.SalesDocumentType,
  SalesDocItem._SalesDocument.SalesOrganization,
  SalesDocItem._SalesDocument.DistributionChannel,
  SalesDocItem._SalesDocument.OrganizationDivision,
  SalesDocItem.Material,
  SalesDocItem.Product,
  SalesDocItem.SalesDocumentItemText,
  SalesDocItem.OrderQuantity,
  SalesDocItem.OrderQuantityUnit,
  SalesDocItem.OrderToBaseQuantityDnmntr,
  SalesDocItem.OrderToBaseQuantityNmrtr,
  SalesDocItem.UnderdelivTolrtdLmtRatioInPct,
  SalesDocItem.SDDocumentRejectionStatus,
  SalesDocItem.DeliveryStatus,
  SalesDocItem.SDProcessStatus,
  SalesDocItem._SalesDocument.OverallSDProcessStatus,
  SalesDocItem._SalesDocument.OverallSDDocumentRejectionSts,
  SalesDocItem.OrderRelatedBillingStatus,
  SalesDocItem._SalesDocument.RequestedDeliveryDate,
  SalesDocItem._SalesDocument.BillingDocumentDate,
  SalesDocItem.ItemIsBillingRelevant,
  SalesDocItem.TargetQuantity,
  SalesDocItem.TargetQuantityUnit
