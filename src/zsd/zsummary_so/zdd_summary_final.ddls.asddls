@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Summary Final Data Definition'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_summary_final as select from zdd_summary_grouped as a
left outer join I_SalesDocumentItem as b on  a.SalesDocument = b.SalesDocument
left outer join I_ProductText as c on b.Material = c.Product
{
    key a.SalesDocument,
    key  b.Material,
    key  c.ProductName,
//    b.ProductName,
    a.Plant,
    a.DistributionChannel,
    a.CreationDate,
    a.CreationTime,
    a.BillToParty,
    a.CustomerName,
    a.RegionName,
    a.PurchaseOrderByCustomer,

    @Semantics.quantity.unitOfMeasure: 'unit1'
    a.OrderQuantity,
    a.unit1,

    @Semantics.amount.currencyCode: 'curr1'
    a.NetAmount,
    a.curr1,

    @Semantics.quantity.unitOfMeasure: 'bill_unit'
    a.BillingQty,
    a.bill_unit,

    @Semantics.amount.currencyCode: 'bill_curr'
    a.BillingVal,
    a.bill_curr,

    @Semantics.quantity.unitOfMeasure: 'diff_unit'
    a.QuantityDiff,
    a.diff_unit,

    @Semantics.amount.currencyCode: 'diff_curr'
    a.ValueDiff,
    a.diff_curr,

    case
        when coalesce(a.BillingQty, 0) = 0 then 'Open Order'
        when coalesce(a.BillingQty, 0) != 0 and
             cast(a.OrderQuantity - coalesce(a.BillingQty, cast(0 as abap.dec(13,3))) as abap.dec(13,3)) = 0
            then 'Fully Delivered'
        else 'Short Supply'
    end as Delivery_status,
    a.FinancialStatus
}
