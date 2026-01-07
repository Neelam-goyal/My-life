@EndUserText.label: 'Customer Trial Balance'
//@Search.searchable: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_GSTR1_B2B'
@UI.headerInfo: {typeName: 'GSTR1 B2B' , typeNamePlural: 'GSTR1'}
define custom entity zgstr1_ce
  // with parameters parameter_name : parameter_type
{
      //      @Search.defaultSearchElement:true
      @EndUserText.label  : 'Company Code'
      @UI.selectionField  : [{ position:10}]
      @UI.lineItem        : [{ position:10, label:'Company Code' }]
      @Consumption.valueHelpDefinition: [{ entity : { element: 'CompanyCode', name : 'I_CompanyCodeVH' } } ]
  key companycode         : abap.char(4);
      //      @Search.defaultSearchElement:true
      @EndUserText.label  : 'Billing Number'
      @UI.selectionField  : [{ position:20 }]
      @UI.lineItem        : [{ position:20, label:'Billing Document' }]
      //      @Consumption.valueHelpDefinition: [{ entity : { element: 'BillingDocument', name : 'I_BillingDocumentVH' } } ]
  key invoice             : abap.char(10);
      @UI.lineItem        : [{ position:25, label:'Billing Document Item' }]
  key invoicelitem        : abap.char(6);
      @EndUserText.label  : 'Fiscal Year'
      @UI.selectionField  : [{ position:40 }]
      @UI.lineItem        : [{ position:30, label:'Fiscal Year' }]
  key fiscalyearvalue     : abap.numc(4);
      //      creationdatetime           : abp_creation_tstmpl;
      //      salesquotation             : abap.char(10);
      @UI.lineItem        : [{ position:60, label:'Billing Date' }]
      billingdate         : abap.dats;
      @UI.lineItem        : [{ position:70, label:'Unit of Measure' }]
      uom                 : abap.unit(3);
      @UI.lineItem        : [{ position:80, label:'Billing Type' }]
      billingtype         : abap.char(4);
      @UI.lineItem        : [{ position:90, label:'Material Number' }]
      materialno          : abap.char(40);
      @UI.lineItem        : [{ position:100, label:'Material Description' }]
      materialdescription : abap.char(40);
      @UI.lineItem        : [{ position:110, label:'Customer Name' }]
      customername        : abap.char(40);
      @UI.lineItem        : [{ position:120, label:'Sold to Party' }]
      soldtopartynumber   : abap.char(10);
      @UI.lineItem        : [{ position:130, label:'Region' }]
      region              : abap.char(2);
      @UI.lineItem        : [{ position:140, label:'Sold to Party GSTIN' }]
      GSTIN_number        : abap.char(18);
      @UI.lineItem        : [{ position:150, label:'HSN Code' }]
      hsncode             : abap.char(16);
      @UI.lineItem        : [{ position:160, label:'Document Currency' }]
      Documentcurrency    : abap.char(3);
      @UI.lineItem        : [{ position:170, label:'Plant' }]
      deliveryplant       : abap.char(4);
      @UI.lineItem        : [{ position:180, label:'Invoice Quantity' }]
      billingqtyinsku     : abap.dec(13,2);
      //      salesperson                : abap.char(80);
      //      saleordernumber            : abap.char(10);
      //      salescreationdate          : abap.dats;
      //      customerponumber           : abap.char(35);
      //      soldtopartygstin           : abap.char(18);
      //      soldtopartyname            : abap.char(80);

      //      shiptopartynumber          : abap.char(10);
      //      shiptopartyname            : abap.char(80);
      //      shiptopartygstno           : abap.char(18);
      //      deliveryplacestatecode     : abap.char(2);
      //      soldtoregioncode           : abap.char(2);
      //      deliverynumber             : abap.char(10);
      //      deliverydate               : abap.dats;
      //      billingdocdesc             : abap.char(20);
      //      billno                     : abap.char(16);
      //      ewaybillnumber             : abap.char(15);
      //      ewaybilldatetime           : abap.dec(21,0);
      //      ewaydatetime               : abap.char(21);
      //      irnacknumber               : abap.char(15);
      //      vehiclenumber              : abap.char(20);
      //      tptvendorname              : abap.char(60);
      //      tptmode                    : abap.char(50);
      //      actualnetweight            : abap.dec(15,2);
      //      grossweight                : abap.dec(15,2);
      //      grno                       : abap.char(20);
      //      deliveryplant              : abap.char(4);
      //      invoicedate                : abap.dats;
      //      customeritemcode           : abap.char(35);
      //      hscode                     : abap.char(10);
      //      qty                        : abap.dec(13,3);
      //      netamount                  : abap.dec(13,2);
      //      taxamount                  : abap.dec(13,2);
      //      mrp                        : abap.dec(13,2);
      //      rate                       : abap.dec(13,2);
      //      documentcurrency           : abap.cuky;
      //      exchangerate               : abap.dec(9,2);
      //      rateininr                  : abap.dec(13,2);
      //      taxablevaluebeforediscount : abap.dec(13,2);
      //      igstamt                    : abap.dec(13,2);
      //      sgstamt                    : abap.dec(13,2);
      //      cgstamt                    : abap.dec(13,2);
      //      taxablevalueafterdiscount  : abap.dec(13,2);
      //      freightchargeinr           : abap.dec(13,2);
      //      insurancerateinr           : abap.dec(13,2);
      //      insuranceamountinr         : abap.dec(13,2);
      //      ugstrate                   : abap.dec(13,2);
      //      ugstamt                    : abap.dec(13,2);
      //      roundoffvalue              : abap.dec(13,2);
      //      manditax                   : abap.dec(13,2);
      //      mandicess                  : abap.dec(13,2);
      //      discountamount             : abap.dec(13,2);
      //      discountrate               : abap.dec(13,2);
      //      invoiceamount              : abap.dec(13,2);
      //      exempted                   : abap.char(3);
      //      igstrate                   : abap.dec(13,2);
      //      cgstrate                   : abap.dec(13,2);
      //      sgstrate                   : abap.dec(13,2);
      //      discountrate2              : abap.dec(13,2);
      //      billingqtyinsku            : abap.dec(13,2);
      //      tcsrate                    : abap.dec(13,2);
      //      tcsamount                  : abap.dec(13,2);
}
