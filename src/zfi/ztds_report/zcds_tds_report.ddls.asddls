@EndUserText.label: 'CDS for TDS Report'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TDS_REPORT'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI.headerInfo: {
  typeName: 'COUNT',
  typeNamePlural : 'COUNT'
}
define custom entity zcds_tds_report
  with parameters

    @EndUserText.label: 'Voucher Date From'
    p_fromdate : vdm_v_start_date,
    @EndUserText.label: 'Voucher Date To'
    p_todate   : vdm_v_end_date

{
      @UI.lineItem           : [{ position: 10 }]
      @UI.selectionField     : [{ position: 10 }]
      @EndUserText.label     : 'Voucher Date '
      @Consumption.filter    : { hidden: true }
  key Voucher_date           : abap.dats;

      @UI.lineItem           : [{ position: 20 }]
      @UI.selectionField     : [{ position: 20 }]
      @EndUserText.label     : 'Voucher Number'
      @Consumption.valueHelpDefinition: [{
        entity               : {
          name               : 'ZCDSVouchernoVH',
          element            : 'AccountingDocument'
        }
      }]
  key VOUCHER_NO             : abap.char(18);


      @UI.lineItem           : [{ position: 21 }]
      @UI.selectionField     : [{ position: 30 }]
      @EndUserText.label     : 'Company Code'
      @Consumption.valueHelpDefinition: [{
        entity               : {
          name               : 'ZCDSCOMPANYCODEVH',
          element            : 'CompanyCode'
        }
      }]
  key Company_code           : abap.char(5);


      @UI.lineItem           : [{ position: 40 }]
//      @UI.selectionField     : [{ position: 40 }]
      @EndUserText.label     : 'Account Code'
      @Consumption.valueHelpDefinition: [{
         entity              : {
           name              : 'ZCDSAccountCodeVH',
           element           : 'CustomerSupplierAccount'
         }
       }]
  key ACCOUNT_CODE           : abap.char(18);


      @UI.lineItem           : [{ position: 70 }]
      @EndUserText.label     : 'TDS Code'
      @UI.selectionField     : [{ position: 70 }]
      @Consumption.valueHelpDefinition: [{
      entity                 : {
       name                  : 'ZCDSTDSCodeVH',
       element               : 'officialwhldgtaxcode'
      }
      }]
  key TDS_Code               : abap.char(18);

      @UI.lineItem           : [{ position: 100 }]
      @EndUserText.label     : 'TDS Amount'
      @Consumption.filter    : { hidden: true }
  key TDS_Amount             : abap.dec(23,2);

      @UI.lineItem           : [{ position: 30 }]
      @UI.selectionField     : [{ position: 30 }]
      @EndUserText.label     : 'Plant Code'
      @Consumption.valueHelpDefinition: [{
      entity                 : {
        name                 : 'ZCDSPLANTVH',
        element              : 'PlantCode'
      }
    }]
  key plantcode              : abap.char(18);

      @UI.lineItem           : [{ position: 31 }]
      @EndUserText.label     : 'Location'
      @Consumption.filter    : { hidden: true }
  key location               : abap.char(18);

      @UI.lineItem           : [{ position: 80 }]
      @EndUserText.label     : 'TDS Deduction Rate'
      @Consumption.filter    : { hidden: true }
  key TDS_Deduction_Rate     : abap.dec(7,4);

      @UI.lineItem           : [{ position: 50 }]
      @EndUserText.label     : 'Supplier Account Name'
      @Consumption.filter    : { hidden: true }
      Supplier_Account_Name  : abap.char(80);

      @UI.lineItem           : [{ position: 60 }]
      @EndUserText.label     : 'PAN Number'
      @Consumption.filter    : { hidden: true }
      Pan_No                 : abap.char(18);


      @UI.lineItem           : [{ position: 90 }]
      @EndUserText.label     : 'TDS Base Amount'
      @Consumption.filter    : { hidden: true }
      TDS_Base_Amount        : abap.dec(23,2);

      @UI.lineItem           : [{ position: 110 }]
      @EndUserText.label     : 'Lower Deduction Number'
      @Consumption.filter    : { hidden: true }
      Lower_Deduction_No     : abap.char(18);

      @UI.hidden
      @Consumption.filter    : { hidden: true }
      Accountingdocumenttype : abap.char(2);
      @UI.hidden
      @Consumption.filter    : { hidden: true }
      DebitCreditCode        : abap.char(1);

}
