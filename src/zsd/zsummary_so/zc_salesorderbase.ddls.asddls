@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales data definition'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_SalesOrderBase as
  select from I_SalesDocumentItem as item
    left outer join I_SalesDocument             as head     on item.SalesDocument = head.SalesDocument
    left outer join I_Customer                  as cust     on item.BillToParty = cust.Customer
    left outer join I_RegionText                as region   on cust.Region = region.Region and region.Country = cust.Country  and region.Language = 'E'
    left outer join I_ProductText               as prod_txt on item.Material = prod_txt.Product and prod_txt.Language = 'E'
    left outer join I_CreditBlockedSalesDocument as credit  on item.SalesDocument = credit.SalesDocument

{
    item.SalesDocument,
    item.SalesDocumentItem,
    item.Material,
    item.Plant,
    head.DistributionChannel,
    head.CreationDate,
    head.CreationTime,
    item.BillToParty,
    cust.CustomerName,
    region.RegionName,
    prod_txt.ProductName,
    head.PurchaseOrderByCustomer,
     @Semantics.quantity.unitOfMeasure: 'unit'
    item.OrderQuantity,
     item.OrderQuantityUnit as unit,
     @Semantics.amount.currencyCode: 'curr'
    item.NetAmount,
    item.TransactionCurrency as curr,
    case when credit.SalesDocument is null then 'YES' else 'NO' end as FinancialStatus
}
