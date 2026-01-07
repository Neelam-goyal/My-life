@EndUserText.label: 'CDS VIEW FOR SHORTAGE CALCULATION'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SHORTAGE_CALC'
@UI.headerInfo: {
typeName: 'Lines',
typeNamePlural: 'Lines'
}
define custom entity ZCDS_SHORTAGE_CALC
{

      @UI.lineItem         : [{ position: 50, label:'Component Number' }]
      @EndUserText.label   : 'Component Number'
  key MATERIAL             : abap.char(40);

      @UI.lineItem         : [{ position: 70, label:'BOM Location' }]
      @EndUserText.label   : 'BOM Location'
  key BOMLocation          : abap.char(4);

      @UI.selectionField   : [{ position: 30 }]
      @EndUserText.label   : 'Production Order'
      @Consumption.filter  : { mandatory: true }
        
      productionorder      : abap.char(12);

      @EndUserText.label   : 'Company Code'
      @UI.selectionField   : [{ position: 10 }]
      @Consumption.filter  : { mandatory: true  }
      @Consumption.valueHelpDefinition: [{ entity: {
          name             : 'I_CompanyCodeStdVH',
          element          : 'CompanyCode'
      } }]
      bukrs                : abap.char(4);

      @EndUserText.label   : 'Plant'
      @UI.selectionField   : [{ position: 20 }]
      @Consumption.filter  : { mandatory: true  }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'zbukrs_werks_vh', element: 'plant' },
        additionalBinding  : [{ localElement: 'bukrs', element: 'bukrs',  usage:#FILTER  }]
        }]
      plant                : abap.char(4);

      @UI.lineItem         : [{ position: 60, label:'Component Description' }]
      @EndUserText.label   : 'Component Description'
      maktx : abap.char(50);

      @UI.lineItem         : [{ position: 75, label:'Quantity at BOM Location' }]
      @Consumption.filter.hidden: true
      @EndUserText.label   : 'Quantity at BOM Location'
      stock                : abap.dec(20,3);

      @UI.lineItem         : [{ position: 80, label:'Plant Stock' }]
      @Consumption.filter.hidden: true
      @EndUserText.label   : 'Plant Stock'
      plantstock           : abap.dec(20,3);

      @UI.lineItem         : [{ position: 90, label:'Required Quantity' }]
      @Consumption.filter.hidden: true
      @EndUserText.label   : 'Required Quantity'
      requiredquantity     : abap.dec(16,3);

      @UI.lineItem         : [{ position: 110, label:'Short/Excess Quantity' }]
      @Consumption.filter.hidden: true
      @EndUserText.label   : 'Short/Excess Quantity'
      short_excess_qty     : abap.dec(20,3);

      //      @UI.selectionField    : [{ position: 1 }]
      //      //            @Consumption.filter   : { defaultValue: '20250521' }
      //      fromdate              : datn;
      //      @UI.selectionField    : [{ position: 2 }]
      //      @Consumption.filter   : { defaultValue: '20250521' }
      //      todate                : datn;

}
