@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Helper CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zpo_helper as select from ZI_PurchaseOrderData as PO {
    
    key PO.DocumentNo,
    key lpad(PO.DocumentItemNo, 6, '0') as DocumentItemNo, 

    PO.PODate,
    PO.POType,
    PO.CompanyCode,
    PO.PurchasingGroup,
    PO.PurchasingOrganization,
    
    @Semantics.quantity.unitOfMeasure: 'POUOM'
    PO.OrderQuantity,
    @UI.hidden: true
    PO.POUOM,
    
    PO.Plant,
    PO.Material,
    PO.ProfitCenter,
    PO.TaxCode,
    
    @Semantics.amount.currencyCode: 'curr'
    PO.PORate,
    @UI.hidden: true
    PO.curr,

    PO.HSNCode

}
