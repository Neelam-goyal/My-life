@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Grouped Summary Data by Sales Doc & Material'
define view entity zdd_summary_grouped as
  select from zdd_sumamary_so as a
{
  key a.SalesDocument,
//   a.Material,
//   a.ProductName,
   @Semantics.quantity.unitOfMeasure: 'unit1'
  sum(a.OrderQuantity)       as OrderQuantity,
  a.unit1,
   @Semantics.amount.currencyCode: 'curr1'
  sum(a.NetAmount)           as NetAmount,
  a.curr1,
  @Semantics.quantity.unitOfMeasure: 'bill_unit'
  sum(a.BillingQty)          as BillingQty,
   a.unit1 as bill_unit,
   @Semantics.amount.currencyCode: 'bill_curr'
  sum(a.BillingVal)          as BillingVal,
  a.curr1 as bill_curr,
  @Semantics.quantity.unitOfMeasure: 'diff_unit'
  sum(a.QuantityDiff)        as QuantityDiff,
  a.unit1 as diff_unit,
     @Semantics.amount.currencyCode: 'diff_curr'
  sum(a.ValueDiff)           as ValueDiff,
 a.curr1 as diff_curr,
  min(a.Plant)               as Plant, 
  min(a.DistributionChannel) as DistributionChannel,
  min(a.CreationDate)        as CreationDate,
  min(a.CreationTime)        as CreationTime,
  min(a.BillToParty)         as BillToParty,
  min(a.CustomerName)        as CustomerName,
  min(a.RegionName)          as RegionName,
  min(a.PurchaseOrderByCustomer) as PurchaseOrderByCustomer,
  min(a.FinancialStatus) as FinancialStatus
} 
group by
  a.SalesDocument,
//  a.Material,
//  a.ProductName,
  a.unit1,
  a.curr1
