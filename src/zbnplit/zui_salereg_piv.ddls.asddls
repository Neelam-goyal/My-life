@ClientHandling.algorithm: #SESSION_VARIABLE
@EndUserText.label: 'Pivot Report - Sales Register'
@VDM.viewType: #CONSUMPTION
@AccessControl.authorizationCheck: #PRIVILEGED_ONLY
@AbapCatalog: {
   sqlViewName: 'ZUISALEREG_PIV',
   compiler.compareFilter: true
}
@ObjectModel: {
   usageType: {
     dataClass: #MIXED,
     serviceQuality: #D,
     sizeCategory: #XL
   },
   supportedCapabilities: [ #ANALYTICAL_QUERY ],
   modelingPattern: #ANALYTICAL_QUERY
}

@Metadata.ignorePropagatedAnnotations: true
@Analytics:{query: true,
    settings:{
    //    columns.hierarchicalDisplay.active: true,
    //    rows.hierarchicalDisplay.active: true,
        rows.totalsLocation: #BOTTOM,
        columns.totalsLocation: #RIGHT
    }
 }
define view ZUI_SaleReg_PIV
  with parameters
    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'From Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_from : sydate,

    @AnalyticsDetails.query.variableSequence: 2
    @EndUserText.label: 'To Date'
    @Environment.systemField: #SYSTEM_DATE
    p_date_to   : sydate

  as select from ZC_SALEREG_PIV
{
  @AnalyticsDetails.query: {
    variableSequence: 3,
    axis: #ROWS,
    sortDirection: #ASC,
    totals: #SHOW,
    display: #KEY 
  }
  @Consumption: { filter: { selectionType: #SINGLE, multipleSelections: true, mandatory: true } }
  CompanyCode,
  
  @EndUserText.label: 'Sales Organization' 
  SalesOrganization,
  
  @EndUserText.label: 'Distribution Channel'
  DistributionChannel,
  
  @EndUserText.label:'Division'
  Division,  
    
  @AnalyticsDetails.query:{totals: #SHOW}
  InvoiceNo,

  @AnalyticsDetails.query:{totals: #SHOW}
  SalesQuotation,

  @AnalyticsDetails.query:{totals: #SHOW}
  CreationDate,

  @AnalyticsDetails.query:{totals: #SHOW}
  SalesPerson,

  @AnalyticsDetails.query:{totals: #SHOW}
  SaleOrderNumber,

  @AnalyticsDetails.query:{totals: #SHOW}
  SalesCreationDate,

  @AnalyticsDetails.query:{totals: #SHOW}
  BillingType,

  @AnalyticsDetails.query:
  { axis: #ROWS,
    sortDirection: #ASC,
    totals: #SHOW,
    display: #KEY_TEXT
   }
  BillingDocDesc,

  @AnalyticsDetails.query: {
      axis: #ROWS,
      sortDirection: #ASC,
      display: #KEY_TEXT,
      totals: #SHOW
  }
  DeliveryPlant,

  @AnalyticsDetails.query.hidden: true

  @AnalyticsDetails.query:{totals: #SHOW}
  CustomerPONumber,
  @AnalyticsDetails.query.hidden: true

  @AnalyticsDetails.query:{totals: #SHOW}
  SoldToPartyGSTIN,

  @AnalyticsDetails.query: {
        axis: #ROWS,
        variableSequence: 4,
        display: #KEY_TEXT,
        totals: #SHOW
    }
  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true, mandatory: false }
  SoldToPartyCode,

  @AnalyticsDetails.query: {
      axis: #ROWS,
      sortDirection: #ASC,
      totals: #SHOW,
      display: #KEY_TEXT
  }
  InvoiceDate,

  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true, mandatory: false }
  @AnalyticsDetails.query: {
      variableSequence: 5,
      axis: #ROWS,
      sortDirection: #ASC,
      totals: #SHOW,
      display: #KEY_TEXT
  }
  BillNo,

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      hidden: true,
      totals: #SHOW
  }
  ShipToPartyCode,

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      totals: #SHOW
  }
  ShipToPartyName,

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      totals: #SHOW
  }
  ShipToPartyGSTIN,

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      totals: #SHOW
  }
  SoldToRegionCode,

  VehicleNumber,
  TptVendorName,
  TptMode,

  Grno,

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      totals: #SHOW
  }
  BillingYear,

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      totals: #SHOW
  }
  BillingQuarter,

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      totals: #SHOW
  }
  BillingYearMonth,

  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true }
  @AnalyticsDetails.query: {
      axis: #ROWS,
      sortDirection: #ASC,
      display: #KEY_TEXT,
      totals: #SHOW
    }
  MaterialNo,

  @AnalyticsDetails.query.hidden: true

  @AnalyticsDetails.query: {
      display: #KEY_TEXT,
      totals: #SHOW
  }
  HSNCode,

  @AnalyticsDetails.query: {
      display: #KEY,
      hidden: true,
      totals: #SHOW
  }
  UOM,

  @AnalyticsDetails.query: {
      display: #KEY,
      hidden: true,
      totals: #SHOW
  }
  Currency,

  @AnalyticsDetails.query.hidden: true
  FreightChargeINR,

  @AnalyticsDetails.query.hidden: true
  InsuranceAmountINR,
  @DefaultAggregation: #NONE
  @AnalyticsDetails.query.hidden: true
  UGSTRate,

  @AnalyticsDetails.query.hidden: true
  @DefaultAggregation: #NONE
  IGSTRate,
  @AnalyticsDetails.query.hidden: true
  @DefaultAggregation: #NONE
  CGSTRate,
  @AnalyticsDetails.query.hidden: true
  @DefaultAggregation: #NONE
  SGSTRate,
  @AnalyticsDetails.query.hidden: true
  @DefaultAggregation: #NONE
  TCSRate,

  @AnalyticsDetails.query.hidden: true
  CancelledInvoice,

  SoldQty,
  GrossWeight,
  Netweight,
  
  @EndUserText.label: 'Item Rate'
  @DefaultAggregation: #FORMULA
  @AnalyticsDetails.query:{
    formula: 'NDIV0( $projection.TaxableValueBeforeDiscount / $projection.SoldQty )',
    decimals : 2
    }
  cast (1 as abap.dec(18,3)) as SKURate,

  TaxableValueBeforeDiscount,
  DiscountAmount,

  @EndUserText.label: 'Sale Rate'
  @DefaultAggregation: #FORMULA
  @AnalyticsDetails.query:{
    formula: 'NDIV0( $projection.TaxableValueAfterDiscount / $projection.SoldQty )',
    decimals : 2
    }
  cast (1 as abap.dec(18,3)) as SaleRate,

  TaxableValueAfterDiscount,
  IGSTAmt,
  SGSTAmt,
  CGSTAmt,
  @AnalyticsDetails.query.hidden: true
  UGSTAmt,
  TCSAmount,
  @AnalyticsDetails.query.hidden: true
  RoundOffAmt,

  @EndUserText.label: 'Invoice Rate'
  @DefaultAggregation: #FORMULA
  @AnalyticsDetails.query:{
    formula: 'NDIV0( $projection.InvoiceAmount / $projection.SoldQty )',
    decimals : 2
    }
  cast (1 as abap.dec(18,3)) as InvRate,

  InvoiceAmount

}
where
  InvoiceDate between :p_date_from and :p_date_to
