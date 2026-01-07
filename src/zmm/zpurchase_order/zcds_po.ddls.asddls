@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'i_purchaseorderitemapi01 CDS'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {typeName: 'PO INVOICE PRINT'}
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zcds_po
  as select from I_PurchaseOrderItemAPI01 as a
{

      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 1 }]
      @UI.lineItem: [{ position: 1 , label:'Purchase Order' }]
      @EndUserText.label: 'Purchase Order'
  key a.PurchaseOrder,


      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 2 }]
      @UI.lineItem: [{ position: 2 , label:'Purchase Order Item' }]
      @EndUserText.label: 'Purchase Order Item'
  key a.PurchaseOrderItem,



      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 2 }]
      @UI.lineItem: [{ position: 2 , label:'Company Code'}]
      @EndUserText.label: 'Company Code'
      a.CompanyCode,


      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 3 }]
      @UI.lineItem: [{ position: 3 , label:'' }]
      a.Material





}
