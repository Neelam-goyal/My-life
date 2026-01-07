@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order cds'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZI_PurchaseOrderData as select distinct from I_PurchaseOrderAPI01 as PO
    left outer join I_PurchaseOrderItemAPI01 as POItem on POItem.PurchaseOrder = PO.PurchaseOrder
    left outer join I_ProductPlantBasic as ProductPlant on ProductPlant.Product = POItem.Material 
                                                  and ProductPlant.Plant = POItem.Plant {
    key PO.PurchaseOrder as DocumentNo,
    key POItem.PurchaseOrderItem as DocumentItemNo,
    PO.PurchaseOrderDate as PODate,
    PO.PurchaseOrderType as POType,
    PO.CompanyCode as CompanyCode,
    PO.PurchasingGroup as PurchasingGroup,
    PO.PurchasingOrganization as PurchasingOrganization,
    @Semantics.quantity.unitOfMeasure: 'POUOM'
    POItem.OrderQuantity as OrderQuantity,
    @UI.hidden: true
    POItem.BaseUnit as POUOM,
    POItem.Plant as Plant,
    POItem.Material as Material,
    POItem.ProfitCenter as ProfitCenter,
    POItem.TaxCode as TaxCode,
    @Semantics.amount.currencyCode: 'curr'
    POItem.NetPriceAmount as PORate,
    @UI.hidden: true
    POItem.DocumentCurrency as curr,
    ProductPlant.ConsumptionTaxCtrlCode as HSNCode
};
