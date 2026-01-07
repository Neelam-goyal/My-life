@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Status Cube'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
@Metadata.allowExtensions: true
@ObjectModel.modelingPattern: #ANALYTICAL_CUBE
@ObjectModel.supportedCapabilities:  [ #ANALYTICAL_PROVIDER ,#CDS_MODELING_DATA_SOURCE]
@Aggregation.allowPrecisionLoss:true

define view entity ZCUBE_SalesOrderStatus
  with parameters
    p_date_from : datum,
    p_date_to   : datum,
    pSalesOrg   : vkorg
  //    P_ExchangeRateType : kurst,
  //    P_DisplayCurrency  : vdm_v_display_currency
  as select from ZR_SalesDocumentItemFulfillmnt as status
  association [1..1] to I_SalesDocument               as _SalesDocument                 on  $projection.SalesDocument = _SalesDocument.SalesDocument
  association [0..1] to I_Product                     as _Product                       on  $projection.Product = _Product.Product
  association [0..1] to I_SalesOrganization           as _SalesOrganization             on  $projection.SalesOrganization = _SalesOrganization.SalesOrganization
  association [0..1] to I_DistributionChannel         as _DistributionChannel           on  $projection.DistributionChannel = _DistributionChannel.DistributionChannel
  association [0..1] to I_Customer                    as _SoldToParty                   on $projection.SoldToParty = _SoldToParty.Customer
  association [0..1] to I_ProductGroup_2              as _ProductGroup                  on  $projection.ProductGroup = _ProductGroup.ProductGroup
  association [0..1] to I_OverallDelivConfStatus      as _OverallDelivConfStatus        on  $projection.OverallDelivConfStatus = _OverallDelivConfStatus.OverallDelivConfStatus
  association [0..1] to I_OverallTotalDeliveryStatus  as _OverallTotalDeliveryStatus    on  $projection.OverallTotalDeliveryStatus = _OverallTotalDeliveryStatus.OverallTotalDeliveryStatus
  association [0..1] to I_OverallDeliveryStatus       as _OverallDeliveryStatus         on  $projection.OverallDeliveryStatus = _OverallDeliveryStatus.OverallDeliveryStatus
  association [0..1] to I_SDDocumentRejectionStatus   as _SDDocumentRejectionStatus     on  $projection.SDDocumentRejectionStatus = _SDDocumentRejectionStatus.SDDocumentRejectionStatus
  association [0..1] to I_OverallSDDocumentRjcnStatus as _OverallSDDocumentRejectionSts on  $projection.OverallSDDocumentRejectionSts = _OverallSDDocumentRejectionSts.OverallSDDocumentRejectionSts

{
      //Key
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesDocumentStdVH', element: 'SalesDocument' }}]
      @ObjectModel.foreignKey.association: '_SalesDocument'
  key status.SalesDocument,
      @UI.hidden: true
  key cast(status.SalesDocumentItem as posnr     preserving type) as SalesDocumentItem,
      SalesDocumentDate,
      @ObjectModel.foreignKey.association: '_SalesOrganization'
      SalesOrganization,
      _SalesOrganization,

      @ObjectModel.foreignKey.association: '_DistributionChannel'
      DistributionChannel,
      _DistributionChannel,

      @ObjectModel.foreignKey.association: '_SoldToParty'
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      SoldToParty,
      _SoldToParty,
      
      @EndUserText.label: 'SoldToPartyMstDistChannel'
      SoldToPartyMstDistChannel,
      
      @EndUserText.label: 'SoldToPartyMstCity'
      SoldToPartyMstCity,
      
      @EndUserText.label: 'SoldToPartyMstState'
      SoldToPartyMstState,
      
      @EndUserText.label: 'SoldToPartyMstDivision'
      SoldToPartyMstDivision,
      
      //Product
      @ObjectModel.foreignKey.association: '_Product'
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_ProductStdVH', element: 'Product' } } ]
      status.Product,

      @ObjectModel.foreignKey.association: '_ProductGroup'
      ProductGroup,
      _ProductGroup,

      //Sales
      @EndUserText.label: 'Item'
      status.SalesDocumentItemText                                as MaterialText,

      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      @DefaultAggregation: #SUM
      @EndUserText.label: 'Order Quantity'
      status.OrderQuantity,

      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      @DefaultAggregation: #SUM
      @EndUserText.label: 'Shipped Quantity'
      status.ShippedQuantityInOrderQtyUnit,

      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      @DefaultAggregation: #SUM
      @EndUserText.label: 'Invoiced Quantity'
      status.InvoicedQuantityInOrderQtyUnit,

      @ObjectModel.foreignKey.association: '_OrderQuantityUnit'
      @UI.hidden: true
      status.OrderQuantityUnit,

      @EndUserText.label: 'Order Amount'
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      status.IncomingSalesOrdersNetAmount,

      @EndUserText.label: 'Invoice Amount'
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      status.InvoicedNetAmountInTranCurr,
      status.TransactionCurrency,

      //      @Semantics.currencyCode: true
      //      cast($parameters.P_DisplayCurrency as vdm_v_display_currency) as DisplayCurrency,
      //
      //      @EndUserText.label: 'OrderAmountINR'
      //      @DefaultAggregation: #SUM
      //      @Semantics.amount.currencyCode: 'DisplayCurrency'
      //      cast (currency_conversion(
      //        amount => IncomingSalesOrdersNetAmount,
      //        source_currency => TransactionCurrency,
      //        target_currency => $parameters.P_DisplayCurrency,
      //        exchange_rate_date => SalesDocumentDate,
      //        exchange_rate_type => $parameters.P_ExchangeRateType,
      //        error_handling => 'FAIL_ON_ERROR',
      //        round => 'true',
      //        decimal_shift => 'true',
      //        decimal_shift_back => 'true'
      //      ) as abap.curr(19,2))                                         as OrderAmountINR,
      //
      //      @EndUserText.label: 'InvoiceAmountINR'
      //      @DefaultAggregation: #SUM
      //      @Semantics.amount.currencyCode: 'DisplayCurrency'
      //      cast (currency_conversion(
      //        amount => InvoicedNetAmountInTranCurr,
      //        source_currency => TransactionCurrency,
      //        target_currency => $parameters.P_DisplayCurrency,
      //        exchange_rate_date => SalesDocumentDate,
      //        exchange_rate_type => $parameters.P_ExchangeRateType,
      //        error_handling => 'FAIL_ON_ERROR',
      //        round => 'true',
      //        decimal_shift => 'true',
      //        decimal_shift_back => 'true'
      //      ) as abap.curr(19,2))                                         as InvoiceAmountINR,

      //  Shipping status
      @EndUserText.label: 'Item Shipping status'
      case
          cast (case
            when status.ShippingStatus = '0'
              then ' '
            when status.ShippingStatus = 'A' and (status.DeliveryStatus = 'B' or status.DeliveryStatus = 'C')
               then 'A'
            when status.ShippingStatus = 'A' and status.DeliveryStatus = 'A'
              then '0'
            else status.ShippingStatus
          end as abap.char(1))
      when 'A' then 'Not Shipped'
      when 'B' then 'Partially Shipped'
      when 'C' then 'Completly Shipped'
      when '0' then 'Delivery not started'
      else 'Not Relevant for Delivery'
      end                                                         as ShippingStatus,

      //  Invoicing status
      @EndUserText.label: 'Item Invoicing status'
      case
          (cast (case
            when status.InvoicingStatus = '0'
              then ' '
            else status.InvoicingStatus
          end as abap.char(1)))
      when 'A' then 'Not Invoiced'
      when 'B' then 'Partially Invoiced'
      when 'C' then 'Completely Invoiced'
      else 'Not Relevant for Invoicing'
      end                                                         as InvoicingStatus,


      @ObjectModel.foreignKey.association: '_OverallDelivConfStatus'
      OverallDelivConfStatus,
      _OverallDelivConfStatus,
      @ObjectModel.foreignKey.association: '_OverallTotalDeliveryStatus'
      OverallTotalDeliveryStatus,
      _OverallTotalDeliveryStatus,
      @ObjectModel.foreignKey.association: '_OverallDeliveryStatus'
      OverallDeliveryStatus,
      _OverallDeliveryStatus,
      @ObjectModel.foreignKey.association: '_OverallSDDocumentRejectionSts'
      OverallSDDocumentRejectionSts,
      _OverallSDDocumentRejectionSts,
      @ObjectModel.foreignKey.association: '_SDDocumentRejectionStatus'
      SDDocumentRejectionStatus,
      _SDDocumentRejectionStatus,

      @Consumption.filter.hidden: true
      status._OrderQuantityUnit,
      _SalesDocument,
      _Product

}
where
      SalesDocumentDate between $parameters.p_date_from and $parameters.p_date_to
  and SalesOrganization = $parameters.pSalesOrg
