@EndUserText.label: 'HSN B2B'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_HSNB2B'
@Metadata.allowExtensions: false
@UI.headerInfo: {typeName: 'HSN B2B' , typeNamePlural : 'HSN B2B' }
define custom entity ZCE_HSN_B2B
{
      @UI.facet           : [ {
             id           : 'idHSN',
             purpose      : #STANDARD,
             type         : #IDENTIFICATION_REFERENCE,
             label        : 'HSN B2B',
             position     : 10
           } ]


      @UI.identification  : [{ position: 5, label: 'Company Code' }]
      @UI.lineItem        : [{ position: 5 }]
      @UI.selectionField  : [{ position: 5 }]
      @EndUserText.label  : 'Company Code'
      @Consumption.valueHelpDefinition : [{ entity : { name : 'I_CompanyCodeStdVH' , element : 'CompanyCode' } }]
      @Consumption.filter : { mandatory: false }
  key COMPANYCODE         : abap.char(4);

      @UI.identification  : [{ position: 12 , label: 'HSN Code'  }]
      @UI.lineItem        : [{ position: 12 }]
      @UI.selectionField  : [{ position: 12 }]
      @EndUserText.label  : 'HSN Code'
      //      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_H', element: 'Consumptiontaxctrlcode' } }]
      @Consumption.filter : { mandatory: false}
  key HSN                 : abap.char( 8 );



      @UI.identification  : [{ position: 7, label: 'Plant Code' }]
      @UI.lineItem        : [{ position: 7 }]
      @UI.selectionField  : [{ position: 7 }]
      @EndUserText.label  : 'Plant Code'
      @Consumption.valueHelpDefinition : [{ entity : { name : 'ZPlantValueHelp' , element : 'plant_code' } }]
      @Consumption.filter : { mandatory: false }
  key PLANTCODE           : abap.char(4);

      @UI.identification  : [{ position: 112 , label: 'B2B/B2C' }]
      @UI.lineItem        : [{ position: 112}]
      @UI.selectionField  : [{ position: 112 }]
      @EndUserText.label  : 'B2B/B2C'
      @Consumption.filter : { mandatory: false }
  key B2B_B2C             : abap.char(16);

      @UI.identification  : [{ position: 20 , label: 'UOM' }]
      @UI.lineItem        : [{ position: 30 }]
//      @Consumption.filter.hidden: true
      @EndUserText.label  : 'UOM'
      //      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbillinglines', element: 'uom' } }]
    @Consumption.filter : { mandatory: false }
  key UQM                 : abap.unit( 3 );


      @UI.identification  : [{ position: 60 , label: ' GST Rate' }]
      @UI.lineItem        : [{ position: 60 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'GST Rate'
  key GstRate             : abap.dec( 13,2 );

           @UI.identification: [{ position: 131, label: 'Bill Date' }]
      @UI.selectionField  : [{ position: 131 }]
        @UI.lineItem:       [{ position: 131, hidden  : true}]
      @EndUserText.label  : 'Bill Date'
           
      bill_Date           : abap.dats;


      @UI.identification  : [{ position: 40 , label: 'Description' }]
      @UI.lineItem        : [{ position: 20 }]
      @Consumption.filter.hidden: true
      Description         : abap.char( 60 );

      @UI.identification  : [{ position: 30 , label: 'Total Quantity' }]
      @UI.lineItem        : [{ position: 40 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'Total Quantity'
      TotalQuantity       : abap.dec( 13,3 );


      @UI.identification  : [{ position: 50 , label: 'Total Value' }]
      @UI.lineItem        : [{ position: 50 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'Total Value'
      TotalValue          : abap.dec( 13,2 );


      @UI.identification  : [{ position: 70 , label: 'Taxable Value' }]
      @UI.lineItem        : [{ position: 70 }]

      @Consumption.filter.hidden: true
      @EndUserText.label  : 'Taxable Value'
      TaxableValue        : abap.dec( 13,2 );

      @UI.identification  : [{ position: 80 , label: 'Integrated Tax Amount' }]
      @UI.lineItem        : [{ position: 80 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'IGST Amount'
      IntegratedTaxAmount : abap.dec( 13,2 );

      @UI.identification  : [{ position: 90 , label: 'Central Tax Amount' }]
      @UI.lineItem        : [{ position: 90 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'CGST Amount'
      CentralTaxAmount    : abap.dec( 13,2 );

      @UI.identification  : [{ position: 92 , label: 'State Tax Amount' }]
      @UI.lineItem        : [{ position: 92 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'SGST Amount'
      StateTaxAmount      : abap.dec( 13,2 );


      @UI.identification  : [{ position: 100 , label: 'UTGST Amount' }]
      @UI.lineItem        : [{ position: 100 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'UTGST Amount'
      StateUTTaxAmount    : abap.dec( 13,2 );

      @UI.identification  : [{ position: 110 , label: 'Cess Amount' }]
      @UI.lineItem        : [{ position: 110 }]
      @Consumption.filter.hidden: true
      @EndUserText.label  : 'Cess Amount'
      CessAmmount         : abap.dec( 13,2 );


      @UI.identification  : [{ position: 9 , label: 'GSTIN' }]
      @UI.lineItem        : [{ position: 9 }]
      @UI.selectionField  : [{ position: 9 }]
      GSTIN               : abap.char(16);



}
