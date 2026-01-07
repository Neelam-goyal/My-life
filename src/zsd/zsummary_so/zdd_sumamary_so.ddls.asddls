@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Summary Sales Order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_sumamary_so
  as select distinct from ZC_SalesOrderBase as so
    left outer join ZC_Billing as bs
      on so.SalesDocument = bs.SalesDocument
     and so.SalesDocumentItem = bs.SalesDocumentItem
     and so.Material = bs.Material
//     left outer join I_DeliveryDocumentItem as del_item on del_item.ReferenceSDDocument = so.SalesDocument and del_item.ReferenceSDDocumentItem = so.SalesDocumentItem
//     left outer join I_DeliveryDocument as del on del_item.DeliveryDocument = del.DeliveryDocument 
{
    key so.SalesDocument,
    key  so.SalesDocumentItem,
    so.Material,
    so.Plant,
    so.DistributionChannel,
    so.CreationDate,
    so.CreationTime,
    so.BillToParty,
    so.CustomerName,
    so.RegionName,
    so.ProductName,
    so.PurchaseOrderByCustomer,
     @Semantics.quantity.unitOfMeasure: 'unit1'
    so.OrderQuantity,
    so.unit as unit1,
    @Semantics.amount.currencyCode: 'curr1'
    so.NetAmount,
    so.curr as curr1,
    @Semantics.quantity.unitOfMeasure: 'bill_unit1'
    bs.BillingQty,
    bs.bill_unit as bill_unit1,
    @Semantics.amount.currencyCode: 'currency' 
    bs.BillingVal,
    bs.curr1 as currency,
    
    @Semantics.quantity.unitOfMeasure: 'bill_unit2'
    cast( so.OrderQuantity - coalesce(bs.BillingQty,cast(0 as abap.quan(13,3))) as abap.dec(13,3) ) as QuantityDiff,
    bs.bill_unit as bill_unit2,
    @Semantics.amount.currencyCode: 'bill_curr' 
    cast(
        cast( so.NetAmount as abap.dec(15,2) ) - coalesce(
            cast( bs.BillingVal as abap.dec(15,2) ), 
            cast( 0 as abap.dec(15,2) )
        )
        as abap.dec(15,2)
    ) as ValueDiff,
    bs.curr1 as bill_curr,

    
//       case when del.OverallGoodsMovementStatus = 'C' then 'YES'
//         else 'NO'
//         end as pgi_stat,
//         
//         case when bs.SalesDocument is null then 'NO'
//         else 'YES'
//         end as inv_stat,
//         
//         case when del_item.ReferenceSDDocument is null then 'NO'
//         else 'YES'
//         end as del_stat,

    case
      when coalesce(bs.BillingQty, 0) = 0 then 'Open Order'
      when coalesce(bs.BillingQty, 0) != 0 and
           cast( so.OrderQuantity - coalesce(bs.BillingQty, cast(0 as abap.quan(13,3))) as abap.dec(13,3) ) = 0
        then 'Fully Delivered'
      else 'Short Supply'
    end as Delivery_status,

    so.FinancialStatus
}
