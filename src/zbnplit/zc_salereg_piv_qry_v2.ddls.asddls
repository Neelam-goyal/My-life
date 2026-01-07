@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Pivot Sales Report'

@UI.headerInfo: {
  typeNamePlural: 'Sales Report V2'

}

define transient view entity ZC_SALEREG_PIV_Qry_V2
  provider contract analytical_query
  with parameters

    @AnalyticsDetails.query.variableSequence: 1
    @EndUserText.label: 'From Date'
    @Consumption.derivation: { lookupEntity: 'I_CalendarDate',
    resultElement: 'FirstDayofMonthDate',
    binding: [
    { targetElement : 'CalendarDate' , type : #PARAMETER, value : 'p_date_to' } ]
    }
    p_date_from  : datum,

    @AnalyticsDetails.query.variableSequence: 2
    @EndUserText.label: 'To Date'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
    resultElement: 'UserLocalDate', binding: [
    { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
    }
    p_date_to    : datum,

    @AnalyticsDetails.query.variableSequence: 3
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs
  as projection on ZCUBE_BillingDocumentItem(P_DisplayCurrency : 'INR', P_ExchangeRateType : 'M') as item
{


  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  BillingYear,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  BillingQuarter,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  BillingYearMonth,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  CompanyCode,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_ONLY
  DistributionChannel,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  BillToPartyMstDistChannel,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  BillToPartyMstState,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_ONLY
  Division,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  SDDocumentCategory,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  BillingDocumentType,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  SoldToPartyGSTIN,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  City,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  SalesDistrict,
  
  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #HIDE
  }
  @UI.textArrangement: #TEXT_FIRST
  SalesDocument,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  Country,

  @AnalyticsDetails.query: {
   axis: #FREE,
   totals: #SHOW
   }
  @UI.textArrangement: #TEXT_FIRST
  RegionName,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_ONLY
  Plant,

  @AnalyticsDetails.query: {
    axis: #FREE,
    totals: #SHOW
    }
  BillingDocument,

  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW
    }
  DocumentReferenceID,

  @AnalyticsDetails.query: {
    axis: #ROWS,
    totals: #SHOW
    }
  BillingDocumentDate,

  @AnalyticsDetails.query: {
  axis: #ROWS,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  SoldToParty,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  BillToParty,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  ShipToParty,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_FIRST
  Product,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_ONLY
  ProductType,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  ProductGroupName,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  ProductSubGroupName,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_ONLY
  ProductCategory,

  @AnalyticsDetails.query: {
  axis: #FREE,
  totals: #SHOW
  }
  @UI.textArrangement: #TEXT_ONLY
  Brand,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:2,
  totals: #SHOW
  }
  BillingQuantity,

  @EndUserText.label: 'Sale Rate Per Unit'
  @Semantics.amount.currencyCode: 'Currency'
  @Aggregation.default: #FORMULA
  abs((curr_to_decfloat_amount( NetAmountInINR ) - curr_to_decfloat_amount( FreightAmountInINR ) ) / abs(cast( BillingQuantity as abap.dec(13,3)))) as SaleRatePerUnit,

  @EndUserText.label: 'Sale Amount'
  @Semantics.amount.currencyCode: 'Currency'
  @Aggregation.default: #FORMULA
  NetAmountInINR - FreightAmountInINR                                                                                                               as SaleAmount,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:3,
  totals: #SHOW
  }
  ItemGrossWeight,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:3,
  totals: #SHOW
  }
  ItemNetWeight,

  @EndUserText.label: 'Freight Amount'
  @AnalyticsDetails.query: {
  axis: #FREE,
  decimals:2,
  totals: #SHOW
  }
  FreightAmountInINR,


  @EndUserText.label: 'Txbl Rate Per Kg'
  @Semantics.amount.currencyCode: 'Currency'
  @Aggregation.default: #FORMULA
  abs(curr_to_decfloat_amount( NetAmountInINR ) / cast( ItemNetWeight as abap.dec(13,3)))                                                           as TxblRatePerKg,


  @EndUserText.label: 'Taxable Amount'
  @AnalyticsDetails.query: {
   axis: #FREE,
   decimals:2,
   totals: #SHOW
   }
  NetAmountInINR                                                                                                                                    as TxblAmountInInr,

  @EndUserText.label: 'Tax Amount'
  @AnalyticsDetails.query: {
  axis: #FREE,
  decimals:2,
  totals: #SHOW
  }
  TaxAmountInINR,


  @EndUserText.label: 'Net Rate Per Unit'
  @Semantics.amount.currencyCode: 'Currency'
  @Aggregation.default: #FORMULA
  abs((curr_to_decfloat_amount( NetAmountInINR ) + curr_to_decfloat_amount( TaxAmountInINR ) ) / abs(cast( BillingQuantity as abap.dec(13,3))))     as NetRatePerUnit,

  @EndUserText.label: 'Net Rate Per Kg'
  @Semantics.amount.currencyCode: 'Currency'
  @Aggregation.default: #FORMULA
  abs((curr_to_decfloat_amount( NetAmountInINR ) + curr_to_decfloat_amount( TaxAmountInINR ) ) / cast( ItemNetWeight as abap.dec(13,3)))            as NetRatePerKg,

  @EndUserText.label: 'Net Amount'
  @Semantics.amount.currencyCode: 'Currency'
  @Aggregation.default: #FORMULA
  NetAmountInINR + TaxAmountInINR                                                                                                                   as InvAmount,

  @UI.hidden: true
  @EndUserText.label: '_Currency'
  Currency,

  @UI.hidden: true
  @EndUserText.label: '_Sales Unit'
  BillingQuantityUnit,

  @UI.hidden: true
  @EndUserText.label: '_Weight Unit'
  ItemWeightUnit

}
where
      BillingDocumentDate between $parameters.p_date_from and $parameters.p_date_to
  and CompanyCode         = $parameters.pCompanyCode
