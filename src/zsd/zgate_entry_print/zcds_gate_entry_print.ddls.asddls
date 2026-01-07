@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_CN_DN_SCREEN_CLASS'
@UI.headerInfo: {typeName: 'cn_dn PRINT'}


define root view entity   ZCDS_GATE_ENTRY_PRINT as select from zgatepassheader
{

 @Search.defaultSearchElement: true
    @UI.selectionField : [{ position:1 }]
    @UI.lineItem : [{ position:1, label:'Gate Pass' }]
    // @EndUserText.label: 'Accounting document'
   key gate_pass,
   
    @Search.defaultSearchElement: true
    @UI.selectionField : [{ position: 2}]
    @UI.lineItem : [{ position:10, label:'Entry Date' }]
    // @EndUserText.label: 'Accounting document'
    entry_date  
}
