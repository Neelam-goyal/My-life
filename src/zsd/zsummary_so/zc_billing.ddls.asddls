@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'billing data definition'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_Billing
  as select from I_BillingDocumentItem as bill_item
    left outer join I_BillingDocument as bdoc on bill_item.BillingDocument = bdoc.BillingDocument
{
    bill_item.SalesDocument,
    bill_item.SalesDocumentItem,
    bill_item.Material,
    @Semantics.quantity.unitOfMeasure: 'bill_unit'
    sum( case 
            when bdoc.BillingDocumentIsCancelled = 'X' 
              or bdoc.BillingDocumentType = 'S1'
              or bdoc.BillingDocumentType = 'F8'
            then 0
            else cast ( bill_item.BillingQuantityInBaseUnit as abap.dec(13,3) )
         end ) as BillingQty,
         

    bill_item.BillingQuantityUnit as bill_unit,

    @Semantics.amount.currencyCode: 'curr1' 
    sum( case 
            when bdoc.BillingDocumentIsCancelled = 'X' 
              or bdoc.BillingDocumentType = 'S1'
              or bdoc.BillingDocumentType = 'F8'
            then 0
             else cast( bill_item.NetAmount as abap.dec(15,2) )
         end ) as BillingVal,

    bill_item.TransactionCurrency as curr1
}
group by
    bill_item.SalesDocument,
    bill_item.SalesDocumentItem,
    bill_item.Material,
    bill_item.TransactionCurrency,
    bill_item.BillingQuantityUnit

//  as select from I_BillingDocumentItem as bill_item
//    left outer join I_BillingDocument as bdoc on bill_item.BillingDocument = bdoc.BillingDocument
//   
//{
//    bill_item.SalesDocument,
//    bill_item.SalesDocumentItem,
//    bill_item.Material,
//    @Semantics.quantity.unitOfMeasure: 'bill_unit'
//    sum( bill_item.BillingQuantityInBaseUnit ) as BillingQty,
//       bill_item.BillingQuantityUnit as bill_unit,
//      @Semantics.amount.currencyCode: 'curr1' 
//    sum( bill_item.NetAmount )                 as BillingVal,
//     bill_item.TransactionCurrency as curr1
//     
//}
//where
//    bdoc.BillingDocumentIsCancelled <> 'X' and
//    ( bdoc.BillingDocumentType <> 'S1' or bdoc.BillingDocumentType <> 'F8' )
//group by
//    bill_item.SalesDocument,
//    bill_item.SalesDocumentItem,
//    bill_item.Material,
//    bill_item.TransactionCurrency,
//    bill_item.BillingQuantityUnit
////    del.OverallGoodsMovementStatus
