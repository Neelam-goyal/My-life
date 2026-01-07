@EndUserText.label: 'Control Sheet'
@Search.searchable: false
@UI.headerInfo: {typeName: 'PO BAS SCREEN'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_POSCREEN as select from I_PurchaseOrderAPI01
{
    @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'PurchaseOrder' }]
    key PurchaseOrder as PurchaseOrder,
    @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'PurchaseOrderDate' }]
    PurchaseOrderDate as PurchaseOrderDate,
    @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'PurchaseOrderType' }]
    PurchaseOrderType as PurchaseOrderType,
    @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:4 }]
      @UI.lineItem   : [{ position:4, label:'CompanyCode' }]
    CompanyCode as CompanyCode,
    @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:5 }]
      @UI.lineItem   : [{ position:5, label:'SupplyingPlant' }]
    SupplyingPlant as SupplyingPlant,
    @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:6 }]
      @UI.lineItem   : [{ position:6, label:'Supplier' }]
    Supplier as Supplier 
    
}
