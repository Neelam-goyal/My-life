@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Customized Purchase Data Query'
@ObjectModel.modelingPattern: #ANALYTICAL_QUERY
@ObjectModel.supportedCapabilities: [#ANALYTICAL_QUERY]
define transient view entity ZC_PurchaseData001_QRY
  provider contract analytical_query
  with parameters
    @EndUserText.label: 'Company'
    @Consumption.valueHelpDefinition: [{entity.name: 'I_CompanyCodeStdVH', entity.element: 'CompanyCode'  }]
    pCompanyCode : bukrs,

    @EndUserText.label: 'From (Posting Date)'
    @Consumption.defaultValue: '20250401'
    pFromDate    : budat,

    @EndUserText.label: 'To (Posting Date)'
    @Consumption.derivation: { lookupEntity: 'I_MySessionContext',
        resultElement: 'UserLocalDate', binding: [
        { targetElement : 'UserID' , type : #SYSTEM_FIELD, value : '#USER' } ]
       }
    pToDate      : budat
  as projection on ZC_PurchaseData001(
                   pCompany : $parameters.pCompanyCode,
                   pFromDate:$parameters.pFromDate,
                   pToDate:$parameters.pToDate
                   )

{
  FiscalYearVariant,
  FinYear,
  Quarter,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 1
  }
  YearMonth,
  @UI.hidden: true
  CompanyCode,
  PurchaseOrder,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 3
  }
  MIROEntryNo,
  MiroEntryFiscalYear,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 2
  }
  MIRODate,
  MIROJournalEntry,
  MIROJournalEntryType,
  MIROJournalEntryFiscalYear,

  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #SHOW,
      variableSequence: 4
        }
  @UI.textArrangement: #TEXT_FIRST
  Supplier,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 5
        }
  SupplierInvoiceDt,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 6
        }
  SupplierInvoiceNo,


  DocumentCurrency,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 7
        }
  InvoiceGrossAmount,
  BusinessPlace,
  MIROItemSrNo,
  Plant,

  ProductType,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 8
        }
  ProductGroupName,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 9
        }
  ProductSubGroupName,
    @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 10
        }
  Material,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 11
        }
  ProductName,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 13
        }
  @UI.textArrangement: #TEXT_FIRST      
  InventoryGLHead,

  PurchaseOrderQuantityUnit,
  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:3,
  totals: #SHOW,
      variableSequence: 1
  }
  QuantityInPurchaseOrderUnit,

  @EndUserText.label: 'Rate Per Unit'
  @Semantics.amount.currencyCode: 'DocumentCurrency'
  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:3,
  totals: #SHOW,
      variableSequence: 2
  }
  @Aggregation.default: #FORMULA
  abs((curr_to_decfloat_amount( SupplierInvoiceItemAmount ) ) / abs(cast( QuantityInPurchaseOrderUnit as abap.dec(13,3)))) as RatePerUnit,

  @AnalyticsDetails.query: {
  axis: #COLUMNS,
  decimals:2,
  totals: #SHOW,
      variableSequence: 3
  }
  SupplierInvoiceItemAmount,
  TaxCode,
  @AnalyticsDetails.query: {
      axis: #ROWS,
      totals: #HIDE,
      variableSequence: 14
        }
  TaxDesc,
  TaxRate,
  /* Associations */
  _CompanyCode,
  _GLAccount,
  _PurchaseOrder,
  _Supplier,
  _TimeDim
}
