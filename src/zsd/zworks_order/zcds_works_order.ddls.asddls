@EndUserText.label: 'I_SALESDOCUMENT CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCLASS_WO_SCREEN'
@UI.headerInfo: {typeName: 'Sales Order Print'}
define view entity zcds_works_order
  as select from I_SalesDocument
{
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'sales document' }]
  key SalesDocument,


      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'sales order type' }]
      SDDocumentCategory,
      
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'sales order creation date' }]
      @Consumption.filter:{ mandatory: true }
      CreationDate

}
